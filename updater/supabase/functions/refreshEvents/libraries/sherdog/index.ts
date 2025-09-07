import { parseHTML } from "npm:linkedom";
import { Cache } from "../cache/index.ts";
import { Logger } from "../logger.ts";
import { Event } from "./models/event.ts";
import { Utils } from "../utils.ts";
import { Fight, Fighter, NoEventFight } from "./models/fight.ts";
import { Stats } from "./models/stats.ts";

const logger: Logger = new Logger("./libraries/sherdog/index.ts");

export class Sherdog {
  baseUrl: string = "https://www.sherdog.com";
  cache?: Cache = undefined;

  setCache(cache?: Cache) {
    this.cache = cache;
  }

  async getHtml(url: string): Promise<string> {
    if (this.cache && this.cache.has(url)) {
      return this.cache.get(url);
    }
    logger.debug(`CACHE MISS ${url}`);

    const response: Response = await fetch(url);
    if (response.status >= 300) {
      throw new Error(
        `Failed to fetch ${url}: ${response.status} ${response.statusText}`
      );
    }
    const html: string = await response.text();
    if (this.cache) {
      this.cache.set(url, html);
    }
    return html;
  }

  async getEventsFromPage(page: number): Promise<Event[]> {
    const events: Event[] = [];

    const url: string = `${this.baseUrl}/organizations/Ultimate-Fighting-Championship-UFC-2/recent-events/${page}`;
    const html: string = await this.getHtml(url);

    const { document } = parseHTML(html);
    const tables: HTMLTableElement[] = Array.from(
      document.querySelectorAll("table")
    );
    let tableNumber = -1;

    for (const table of tables) {
      tableNumber += 1;

      // Skip first table if page > 1 (as per your original logic)
      if (page > 1 && tableNumber === 0) {
        continue;
      }

      if (table.getAttribute("class") !== "new_table event") {
        continue;
      }

      const rows = Array.from(table.querySelectorAll("tr")).slice(1); // Skip header row
      for (const row of rows) {
        const cells = Array.from(row.querySelectorAll("td"));

        if (cells.length < 3) continue;

        const one = cells[0].textContent?.trim()!;
        const two = cells[1].textContent?.trim()!;
        const three = cells[2].textContent?.trim()!;

        let name = "";
        let fight: string | undefined;

        if (two.includes("vs.")) {
          const [n, f] = two.split("-");
          name = n.trim();
          fight = f?.trim();
        } else {
          name = two;
        }

        const threeParts = three.split(",");
        const country = threeParts[threeParts.length - 1].trim();
        const cityNotTrimmed = threeParts[threeParts.length - 2];
        const city = cityNotTrimmed ? cityNotTrimmed.trim() : "";
        const location = threeParts.slice(0, -2).join(", ").trim();

        const linkAnchor = cells[1].querySelector("a");
        const href = linkAnchor?.getAttribute("href") || "";

        const event: Event = {
          name,
          fight,
          date: Utils.parseCompactDate(one)!,
          country,
          city,
          location,
          state: tableNumber === 0 ? "uppcoming" : "past",
          link: `${this.baseUrl}${href}`,
        };

        events.push(event);
      }
    }

    return events;
  }

  async getEvents(): Promise<Event[]> {
    let index: number = 1;
    let hasEvents: boolean = true;

    const events: Event[] = [];
    while (hasEvents) {
      const pageEvents: Event[] = await this.getEventsFromPage(index);
      if (pageEvents.length === 0) {
        hasEvents = false;
      } else {
        events.push(...pageEvents);
        index++;
      }
    }
    return events;
  }

  async getFightsFromEvent(event: Event): Promise<Fight[]> {
    const html: string = await this.getHtml(event.link);
    const { document } = parseHTML(html);
    const fights: Fight[] = [];

    const tables = [
      ...document.querySelectorAll("table.new_table.upcoming"),
      ...document.querySelectorAll("table.new_table.result"),
    ];

    for (const table of tables) {
      const rows = Array.from(table.querySelectorAll("tr")).slice(1);
      for (const row of rows) {
        const cells = (row as HTMLTableRowElement).querySelectorAll("td");

        const position = parseInt(cells[0].textContent!.trim());

        cells[1].querySelectorAll("br").forEach((br) => {
          br.replaceWith(document.createTextNode("\n"));
        });

        const nameOneParts = cells[1].textContent!.trim().split("\n");
        const fighterOne = cells[1]
          .textContent!.trim()
          .replace(nameOneParts[nameOneParts.length - 1], "")
          .replace("\n", " ")
          .trim();
        const fighterOneLink =
          cells[1].querySelector("a")?.getAttribute("href") || "";

        let category = cells[2].textContent!.trim();
        const titleFight = category.includes("TITLE FIGHT");
        category = category.replace("TITLE FIGHT", "").trim();
        const categoryParts = category.split("lb");

        cells[3].querySelectorAll("br").forEach((br) => {
          br.replaceWith(document.createTextNode("\n"));
        });

        const nameTwoParts = cells[3].textContent!.trim().split("\n");
        const fighterTwo = cells[3]
          .textContent!.trim()
          .replace(nameTwoParts[nameTwoParts.length - 1], "")
          .replace("\n", " ")
          .trim();
        const fighterTwoLink =
          cells[3].querySelector("a")?.getAttribute("href") || "";

        if (cells.length === 5) {
          fights.push({
            position,
            fighterOne: {
              name: fighterOne,
              link: `${this.baseUrl}${fighterOneLink}`,
            },
            category:
              category === ""
                ? undefined
                : categoryParts.length > 1
                ? {
                    name: categoryParts[1].trim(),
                    weight: parseInt(categoryParts[0].trim()),
                  }
                : {
                    name: categoryParts[0].trim(),
                  },
            fighterTwo: {
              name: fighterTwo,
              link: `${this.baseUrl}${fighterTwoLink}`,
            },
            mainEvent: false,
            titleFight,
            type: "pending",
          });
        } else if (cells.length === 7) {
          const [decision, rawMethod] = cells[4].textContent!.trim().split("(");
          const referee = cells[4].textContent!.split("\n")[1]?.trim();
          const round = parseInt(cells[5].textContent!.trim());
          const time = Utils.timeToSeconds(cells[6].textContent!.trim());

          const method = rawMethod ? rawMethod.split(")")[0].trim() : "";
          const resultOne = nameOneParts[nameOneParts.length - 1].trim();
          const resultTwo = nameTwoParts[nameTwoParts.length - 1].trim();

          fights.push({
            position,
            fighterOne: {
              name: fighterOne,
              link: `${this.baseUrl}${fighterOneLink}`,
              result: resultOne,
            },
            category:
              category === ""
                ? undefined
                : categoryParts.length > 1
                ? {
                    name: categoryParts[1].trim(),
                    weight: parseInt(categoryParts[0].trim()),
                  }
                : {
                    name: categoryParts[0].trim(),
                  },
            fighterTwo: {
              name: fighterTwo,
              link: `${this.baseUrl}${fighterTwoLink}`,
              result: resultTwo,
            },
            mainEvent: false,
            titleFight,
            type: "done",
            method,
            decision: decision.trim(),
            time,
            round,
            referee,
          });
        } else {
          throw new Error("Unexpected number of cells in row");
        }
      }
    }

    // Main event parsing
    const resumes = Array.from(document.querySelectorAll("div.fight_card"));
    for (const resume of resumes) {
      const leftSide = (resume as HTMLTableRowElement).querySelector(
        "div.fighter.left_side"
      )!;
      const fighterOne = leftSide.textContent!.trim().split("\n")[0].trim();
      const fighterOneLink =
        leftSide.querySelector("a")?.getAttribute("href") || "";

      const rightSide = (resume as HTMLTableRowElement).querySelector(
        "div.fighter.right_side"
      )!;
      const fighterTwo = rightSide.textContent!.trim().split("\n")[0].trim();
      const fighterTwoLink =
        rightSide.querySelector("a")?.getAttribute("href") || "";

      const titleFight = !!(resume as HTMLTableRowElement).querySelector(
        "span.title_fight"
      );

      const span = (resume as HTMLTableRowElement).querySelector(
        "span.weight_class"
      );
      const categoryRaw = span?.textContent?.trim() || "";
      const categoryParts = categoryRaw.split(" ");

      const table = document.querySelector("table.fight_card_resume");
      if (!table) {
        fights.push({
          position: fights.length + 1,
          fighterOne: {
            name: fighterOne,
            link: `${this.baseUrl}${fighterOneLink}`,
          },
          category:
            categoryParts.length > 1
              ? {
                  name: categoryParts[1].trim(),
                  weight: parseInt(categoryParts[0].replace("lb", "").trim()),
                }
              : {
                  name: categoryParts[0].trim(),
                },
          fighterTwo: {
            name: fighterTwo,
            link: `${this.baseUrl}${fighterTwoLink}`,
          },
          titleFight,
          mainEvent: true,
          type: "pending",
        });
      } else {
        const resultOne =
          leftSide.querySelector("span.final_result")?.textContent?.trim() ||
          "";
        console.log(`resultOne=${resultOne}`);
        const resultTwo =
          rightSide.querySelector("span.final_result")?.textContent?.trim() ||
          "";
        console.log(`resultTwo=${resultTwo}`);

        for (const row of table.querySelectorAll("tr")) {
          const cells = row.querySelectorAll("td");
          const [decisionRaw, methodRaw] = cells[1].textContent!.split("(");
          const referee = cells[2].textContent!.replace("Referee ", "").trim();
          const round = parseInt(
            cells[3].textContent!.replace("Round ", "").trim()
          );
          const time = Utils.timeToSeconds(
            cells[4].textContent!.replace("Time ", "").trim()
          );

          fights.push({
            position: fights.length + 1,
            fighterOne: {
              name: fighterOne,
              link: `${this.baseUrl}${fighterOneLink}`,
              result: resultOne,
            },
            category:
              categoryParts.length > 1
                ? {
                    name: categoryParts[1].trim(),
                    weight: parseInt(categoryParts[0].replace("lb", "").trim()),
                  }
                : {
                    name: categoryParts[0].trim(),
                  },
            fighterTwo: {
              name: fighterTwo,
              link: `${this.baseUrl}${fighterTwoLink}`,
              result: resultTwo,
            },
            mainEvent: true,
            titleFight,
            type: "done",
            method: methodRaw?.replace(")", "").trim(),
            decision: decisionRaw.replace("Method ", "").trim(),
            round,
            time,
            referee,
          });
        }
      }
    }

    return fights;
  }

  async getStatsFighter(fighter: Fighter): Promise<Stats> {
    const html: string = await this.getHtml(fighter.link);
    const { document } = parseHTML(html);

    const nicknameEl = document.querySelector("span.nickname");
    const nickname =
      nicknameEl?.textContent?.trim().replace(/"/g, "") || undefined;

    const nationalityEl = document.querySelector("span.item.birthplace");
    const country = nationalityEl?.textContent?.split("\n")[0].trim() || "";

    const localityEl = document.querySelector("span.locality");
    const city = localityEl?.textContent?.trim() || "";

    const bioHolder = document.querySelector("div.bio-holder");
    const table = bioHolder?.querySelector("table");
    const rows = table ? Array.from(table.querySelectorAll("tr")) : [];

    let birthday: Date | null = null;
    let deadAt: Date | null = null;
    let height: string | null = null;
    let weight: string | null = null;

    for (let index = 0; index < rows.length; index++) {
      const cells = (rows[index] as HTMLTableRowElement).querySelectorAll("td");
      const cellText = cells[1]?.textContent?.trim() ?? "";

      if (index === 0) {
        if (cellText.includes("N/A")) {
          const [, date] = cellText.split("/");
          birthday = Utils.parseDate(date.trim());
        }
      } else if (index === 1) {
        if (rows.length === 3) {
          height = cellText.split("/")[1]?.replace("cm", "").trim() ?? null;
        } else {
          deadAt = Utils.parseDate(cellText);
        }
      } else if (index === 2) {
        if (rows.length === 3) {
          weight = cellText.split("/")[1]?.replace("kg", "").trim() ?? null;
        } else {
          height = cellText.split("/")[1]?.replace("cm", "").trim() ?? null;
        }
      } else if (index === 3) {
        weight = cellText.split("/")[1]?.replace("kg", "").trim() ?? null;
      } else {
        throw new Error(`Unexpected index in bio table: ${index}`);
      }
    }

    return {
      nickname,
      country: country.trim() === "" ? null : city,
      city: city.trim() === "" ? null : city,
      died: deadAt ?? undefined,
      birthday: birthday ?? undefined,
      height: parseFloat(height!),
      weight: parseFloat(weight!),
    };
  }

  async getFightsFromFighter(fighter: Fighter): Promise<NoEventFight[]> {
    const fights: NoEventFight[] = [];

    const html: string = await this.getHtml(fighter.link);
    const { document } = parseHTML(html);

    const tables = Array.from(
      document.querySelectorAll("table.new_table.fighter")
    );

    for (let tableCounter = 0; tableCounter < tables.length; tableCounter++) {
      const table = tables[tableCounter];
      const rows = Array.from(
        (table as HTMLTableRowElement).querySelectorAll("tr")
      ).slice(1);

      for (const row of rows) {
        const cells = (row as HTMLTableRowElement).querySelectorAll("td");

        const resultTwo = cells[0]?.textContent?.trim() ?? "";
        const fighterTwo = cells[1]?.textContent?.trim() ?? "";
        const fighterTwoLink =
          cells[1]?.querySelector("a")?.getAttribute("href") ?? "";

        const decisionMethodRefereeNode = cells[3];
        decisionMethodRefereeNode
          ?.querySelectorAll("br")
          .forEach((br) => br.replaceWith("\n"));
        const decisionMethodReferee =
          decisionMethodRefereeNode?.textContent?.trim() ?? "";

        let decision: string | undefined = undefined;
        let method: string | undefined = undefined;
        let referee: string | undefined = undefined;

        if (decisionMethodReferee) {
          if (decisionMethodReferee.includes("(")) {
            const [decisionPart, rest] = decisionMethodReferee.split("(");
            decision = decisionPart.trim();
            const [methodPart, refereePart] = rest.trim().split(")");
            method = methodPart.trim();
            if (refereePart) {
              referee = refereePart.trim().split("\n")[0].trim();
            }
          } else if (decisionMethodReferee.includes("\n")) {
            const [dec, ref] = decisionMethodReferee.split("\n");
            decision = dec.trim();
            referee = ref.trim();
          } else {
            decision = decisionMethodReferee.trim();
          }
        }

        const round = parseInt(cells[4]?.textContent?.trim() ?? "0");
        const time = Utils.timeToSeconds(
          cells[5]?.textContent?.trim() ?? "0:00"
        );

        const fight: NoEventFight = {
          fighter: {
            name: fighterTwo,
            link: `${this.baseUrl}${fighterTwoLink}`,
            result: resultTwo,
          },
          method,
          decision,
          time,
          round,
          referee,
          proFight: tableCounter === 0,
        };

        fights.push(fight);
      }
    }

    return fights;
  }
}
