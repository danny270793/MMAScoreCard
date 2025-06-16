import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "jsr:@supabase/supabase-js@2";
import { Logger } from "./libraries/logger.ts";
import { Sherdog } from "./libraries/sherdog/index.ts";
import { Event } from "./libraries/sherdog/models/event.ts";
import { DoneFight, Fight } from "./libraries/sherdog/models/fight.ts";
import { MemoryCache } from "./libraries/cache/memory-cache.ts";
import { Cache } from "./libraries/cache/index.ts";
import { Stats } from "./libraries/sherdog/models/stats.ts";

const logger: Logger = new Logger("/index.ts");

const weights: Record<string, number> = {
  Strawweight: 115,
  Flyweight: 125,
  Bantamweight: 135,
  Featherweight: 145,
  Lightweight: 155,
  Welterweight: 170,
  Middleweight: 185,
  "Light Heavyweight": 205,
  Heavyweight: 225,
};

function sendResponse(data: any, status: number = 200) {
  return new Response(
    JSON.stringify(
      status !== 200
        ? {
            message: data?.message ?? data,
            stack: data?.stack,
          }
        : {
            ...data,
          }
    ),
    {
      headers: {
        "Content-Type": "application/json",
      },
      status: status,
    }
  );
}

async function getTable(supabase, table: string) {
  const { data, error } = await supabase.from(table).select("*");
  if (error) {
    throw error;
  }
  return data;
}

async function insertInTable(supabase, table: string, rows: unknown[]) {
  console.log(`into table "${table}" insert ${JSON.stringify(rows, null, 0)}`);
  const { error } = await supabase.from(table).insert(rows);

  if (error) {
    console.error(error);
    throw error;
  }

  return await getTable(supabase, table);
}

async function main(supabase) {
  logger.debug("getting sherdog events");
  const cache: Cache = new MemoryCache();
  const sherdog: Sherdog = new Sherdog();
  sherdog.setCache(cache);
  const sherdogEvents: Event[] = await sherdog.getEventsFromPage(1);

  logger.debug("deleting not completed events");
  const { error } = await supabase
    .from("events")
    .delete()
    .eq("status", "uppcoming");
  if (error) {
    throw error;
  }

  logger.debug("add new countries");
  const supabaseCountries: any[] = await getTable(supabase, "countries");
  const countriesToAdd: unknown[] = [];
  for (const sherdogEvent of sherdogEvents) {
    const countryExists: boolean =
      supabaseCountries.filter(
        (country) => sherdogEvent.country === country.name
      ).length > 0;
    const countryAlreadyAdded: boolean =
      countriesToAdd.filter(
        (country: any) => sherdogEvent.country === country.name
      ).length > 0;
    if (!countryExists && !countryAlreadyAdded) {
      countriesToAdd.push({ name: sherdogEvent.country });
    }
  }
  if (countriesToAdd.length > 0) {
    logger.debug(`${countriesToAdd.length} countries added`);
    supabaseCountries.length = 0;
    supabaseCountries.push(
      ...(await insertInTable(supabase, "countries", countriesToAdd))
    );
  }

  logger.debug("add new cities");
  const supabaseCities: any[] = await getTable(supabase, "cities");
  const citiesToAdd: unknown[] = [];
  for (const sherdogEvent of sherdogEvents) {
    const country: any = supabaseCountries.filter(
      (country) => sherdogEvent.country === country.name
    )[0];
    const cityExists: boolean =
      supabaseCities.filter((city) => sherdogEvent.city === city.name).length >
      0;
    const cityAlreadyAdded: boolean =
      citiesToAdd.filter((city: any) => sherdogEvent.city === city.name)
        .length > 0;
    if (!cityExists && !cityAlreadyAdded) {
      citiesToAdd.push({ name: sherdogEvent.city, countryId: country.id });
    }
  }
  if (citiesToAdd.length > 0) {
    logger.debug(`${citiesToAdd.length} cities added`);
    supabaseCities.length = 0;
    supabaseCities.push(
      ...(await insertInTable(supabase, "cities", citiesToAdd))
    );
  }

  logger.debug("add new locations");
  const supabaseLocations: any[] = await getTable(supabase, "locations");
  const locationsToAdd: any[] = [];
  for (const sherdogEvent of sherdogEvents) {
    const city: any = supabaseCities.filter(
      (city) => sherdogEvent.city === city.name
    )[0];
    const locationExists: boolean =
      supabaseLocations.filter(
        (location) => sherdogEvent.location === location.name
      ).length > 0;
    const locationAlreadyAdded: boolean =
      locationsToAdd.filter(
        (location) => sherdogEvent.location === location.name
      ).length > 0;
    if (!locationExists && !locationAlreadyAdded) {
      locationsToAdd.push({ name: sherdogEvent.location, cityId: city.id });
    }
  }
  if (locationsToAdd.length > 0) {
    logger.debug(`${locationsToAdd.length} locations added`);
    supabaseLocations.length = 0;
    supabaseLocations.push(
      ...(await insertInTable(supabase, "locations", locationsToAdd))
    );
  }

  logger.debug("add new events");
  const supabaseEvents: any[] = await getTable(supabase, "events");
  const eventsToAdd: unknown[] = [];
  for (const sherdogEvent of sherdogEvents) {
    const location: any = supabaseLocations.filter(
      (location) => sherdogEvent.location === location.name
    )[0];
    const eventExists: boolean =
      supabaseEvents.filter((event) => sherdogEvent.name === event.name)
        .length > 0;
    const eventAlreadyAdded: boolean =
      eventsToAdd.filter((event: any) => sherdogEvent.name === event.name)
        .length > 0;
    if (!eventExists && !eventAlreadyAdded) {
      eventsToAdd.push({
        name: sherdogEvent.name,
        fight: sherdogEvent.fight,
        date: sherdogEvent.date,
        link: sherdogEvent.link,
        status: sherdogEvent.state,
        locationId: location.id,
      });
    }
  }
  if (eventsToAdd.length > 0) {
    logger.debug(`${eventsToAdd.length} events added`);
    supabaseEvents.length = 0;
    supabaseEvents.push(
      ...(await insertInTable(supabase, "events", eventsToAdd))
    );
  }

  const addedEvents = supabaseEvents.filter(
    (supabaseEvent) =>
      eventsToAdd.filter(
        (eventToAdd: any) => eventToAdd.name === supabaseEvent.name
      ).length > 0
  );
  logger.debug(`addedEvents.length=${addedEvents.length}`);

  logger.debug("preload all data");
  const fightPromises: Promise<Fight[]>[] = [];
  for (const sherdogEvent of addedEvents) {
    fightPromises.push(sherdog.getFightsFromEvent(sherdogEvent));
  }
  logger.debug(`preloading ${fightPromises.length} requests`);
  await Promise.all(fightPromises);

  logger.debug("add new categories");
  const supabaseCategories: any[] = await getTable(supabase, "categories");
  const categoriesToAdd: unknown[] = [];
  for (const sherdogEvent of addedEvents) {
    const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent);

    for (const fight of fights) {
      if (!fight.category) {
        continue;
      }

      const categoryExists: boolean =
        supabaseCategories.filter(
          (category) =>
            fight.category!.name === category.name &&
            weights[fight.category!.name] === category.weight
        ).length > 0;
      const categoryAlreadyAdded: boolean =
        categoriesToAdd.filter(
          (category: any) =>
            fight.category!.name === category.name &&
            weights[fight.category!.name] === category.weight
        ).length > 0;
      if (!categoryExists && !categoryAlreadyAdded) {
        categoriesToAdd.push({
          name: fight.category.name,
          weight: weights[fight.category.name],
        });
      }
    }
  }
  if (categoriesToAdd.length > 0) {
    logger.debug(`${categoriesToAdd.length} categories added`);
    supabaseCategories.length = 0;
    supabaseCategories.push(
      ...(await insertInTable(supabase, "categories", categoriesToAdd))
    );
  }

  logger.debug("add new referees");
  const supabaseReferees: any[] = await getTable(supabase, "referees");
  const refereesToAdd: unknown[] = [];
  for (const sherdogEvent of addedEvents) {
    const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent);

    for (const fight of fights) {
      if (fight.type === "pending") {
        continue;
      }

      const refereeExists: boolean =
        supabaseReferees.filter((referee) => fight.referee === referee.name)
          .length > 0;
      const refereeAlreadyAdded: boolean =
        refereesToAdd.filter((referee: any) => fight.referee === referee.name)
          .length > 0;
      if (!refereeExists && !refereeAlreadyAdded) {
        refereesToAdd.push({ name: fight.referee });
      }
    }
  }
  if (refereesToAdd.length > 0) {
    logger.debug(`${refereesToAdd.length} referees added`);
    supabaseReferees.length = 0;
    supabaseReferees.push(
      ...(await insertInTable(supabase, "referees", refereesToAdd))
    );
  }

  const supabaseFighters: any[] = await getTable(supabase, "fighters");

  logger.debug("preload all fighters data");
  const fighterOneStatPromises: Promise<Stats>[] = [];
  for (const sherdogEvent of addedEvents) {
    const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent);
    for (const fight of fights) {
      if (
        supabaseFighters.filter(
          (fighter) => fighter.name === fight.fighterOne.name
        ).length === 0
      ) {
        fighterOneStatPromises.push(sherdog.getStatsFighter(fight.fighterOne));
      }
    }
  }
  logger.debug(
    `preloading ${fighterOneStatPromises.length} fighter one requests`
  );
  await Promise.all(fighterOneStatPromises);

  const fighterTwoStatPromises: Promise<Stats>[] = [];
  for (const sherdogEvent of addedEvents) {
    const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent);
    for (const fight of fights) {
      if (
        supabaseFighters.filter(
          (fighter) => fighter.name === fight.fighterTwo.name
        ).length === 0
      ) {
        fighterTwoStatPromises.push(sherdog.getStatsFighter(fight.fighterTwo));
      }
    }
  }
  logger.debug(
    `preloading ${fighterTwoStatPromises.length} fighter two requests`
  );
  await Promise.all(fighterTwoStatPromises);

  logger.debug("add new fighters");
  const fightersToAdd: unknown[] = [];
  for (const sherdogEvent of addedEvents) {
    const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent);

    for (const fight of fights) {
      if (fight.type !== "done") {
        continue;
      }

      //fighter one
      const fighterOneStats: Stats = await sherdog.getStatsFighter(
        fight.fighterOne
      );
      if (
        supabaseCountries.filter(
          (country) => country.name === fighterOneStats.country
        ).length === 0
      ) {
        supabaseCountries.length = 0;
        supabaseCountries.push(
          ...(await insertInTable(supabase, "countries", [
            { name: fighterOneStats.country },
          ]))
        );
      }

      if (
        supabaseCities.filter((city) => city.name === fighterOneStats.city)
          .length === 0
      ) {
        const country = supabaseCountries.filter(
          (country) => country.name === fighterOneStats.country
        )[0];
        supabaseCities.length = 0;
        supabaseCities.push(
          ...(await insertInTable(supabase, "cities", [
            { name: fighterOneStats.city, countryId: country.id },
          ]))
        );
      }

      const fighterOneCity = supabaseCities.filter(
        (city) => city.name === fighterOneStats.city
      )[0];

      const fighterOneExists: boolean =
        supabaseFighters.filter(
          (fighter) => fighter.name === fight.fighterOne.name
        ).length > 0;
      const fighterOneAlreadyAdded: boolean =
        fightersToAdd.filter(
          (fighter: any) => fighter.name === fight.fighterOne.name
        ).length > 0;
      if (!fighterOneExists && !fighterOneAlreadyAdded) {
        fightersToAdd.push({
          name: fight.fighterOne.name,
          link: fight.fighterOne.link,
          nickname: fighterOneStats.nickname,
          cityId: fighterOneCity.id,
          birthday: fighterOneStats.birthday
            ? fighterOneStats.birthday.toISOString().split("T")[0]
            : undefined,
          died: fighterOneStats.died
            ? fighterOneStats.died.toISOString().split("T")[0]
            : null,
          height: fighterOneStats.height,
          weight: fighterOneStats.weight,
        });
      }

      //fighter two
      const fighterTwoStats: Stats = await sherdog.getStatsFighter(
        fight.fighterTwo
      );
      if (
        supabaseCountries.filter(
          (country) => country.name === fighterTwoStats.country
        ).length === 0
      ) {
        supabaseCountries.length = 0;
        supabaseCountries.push(
          ...(await insertInTable(supabase, "countries", [
            { name: fighterTwoStats.country },
          ]))
        );
      }

      if (
        supabaseCities.filter((city) => city.name === fighterTwoStats.city)
          .length === 0
      ) {
        const country = supabaseCountries.filter(
          (country) => country.name === fighterTwoStats.country
        )[0];
        supabaseCities.length = 0;
        supabaseCities.push(
          ...(await insertInTable(supabase, "cities", [
            { name: fighterTwoStats.city, countryId: country.id },
          ]))
        );
      }

      const fighterTwoCity = supabaseCities.filter(
        (city) => city.name === fighterTwoStats.city
      )[0];

      const fighterTwoExists: boolean =
        supabaseFighters.filter(
          (fighter) => fighter.name === fight.fighterTwo.name
        ).length > 0;
      const fighterTwoAlreadyAdded: boolean =
        fightersToAdd.filter(
          (fighter: any) => fighter.name === fight.fighterTwo.name
        ).length > 0;
      if (!fighterTwoExists && !fighterTwoAlreadyAdded) {
        fightersToAdd.push({
          name: fight.fighterTwo.name,
          link: fight.fighterTwo.link,
          nickname: fighterTwoStats.nickname,
          cityId: fighterTwoCity.id,
          birthday: fighterTwoStats.birthday
            ? fighterTwoStats.birthday.toISOString().split("T")[0]
            : undefined,
          died: fighterTwoStats.died
            ? fighterTwoStats.died.toISOString().split("T")[0]
            : null,
          height: fighterTwoStats.height,
          weight: fighterTwoStats.weight,
        });
      }
    }
  }
  if (fightersToAdd.length > 0) {
    logger.debug(`${fightersToAdd.length} fighters added`);
    supabaseFighters.length = 0;
    supabaseFighters.push(
      ...(await insertInTable(supabase, "fighters", fightersToAdd))
    );
  }

  logger.debug("add new fights");
  const supabaseFights: any[] = await getTable(supabase, "fights");
  const fightsToAdd: unknown[] = [];
  for (const sherdogEvent of addedEvents) {
    const fights: Fight[] = await sherdog.getFightsFromEvent(sherdogEvent);
    for (const fight of fights) {
      const event = supabaseEvents.filter(
        (event) => event.name === sherdogEvent.name
      )[0];
      const one = supabaseFighters.filter(
        (fighter) => fighter.name === fight.fighterOne.name
      )[0];
      const two = supabaseFighters.filter(
        (fighter) => fighter.name === fight.fighterTwo.name
      )[0];
      const category = supabaseCategories.filter(
        (category) =>
          category.name === fight.category?.name &&
          category.weight === fight.category?.weight
      )[0];
      if (fight.type === "done") {
        const referee = supabaseReferees.filter(
          (referee) => referee.name === fight.referee
        )[0];
        fightsToAdd.push({
          categoryId: category ? category.id : null,
          position: fight.position,
          fighterOne: one.id,
          fighterTwo: two.id,
          refereeId: referee.id,
          mainEvent: fight.mainEvent ? 1 : 0,
          titleFight: fight.titleFight ? 1 : 0,
          type: fight.type,
          method: fight.method,
          time: fight.time,
          round: fight.round,
          decision: fight.decision,
          winner:
            fight.fighterOne.result === "win"
              ? 1
              : fight.fighterTwo.result === "win"
              ? 2
              : null,
          eventId: event.id,
        });
      } else {
        fightsToAdd.push({
          categoryId: category ? category.id : null,
          position: fight.position,
          fighterOne: one.id,
          fighterTwo: two.id,
          mainEvent: fight.mainEvent ? 1 : 0,
          titleFight: fight.titleFight ? 1 : 0,
          type: fight.type,
          eventId: event.id,
        });
      }
    }
  }
  if (fightsToAdd.length > 0) {
    logger.debug(`${fightsToAdd.length} fights added`);
    supabaseFights.length = 0;
    supabaseFights.push(
      ...(await insertInTable(supabase, "fights", fightsToAdd))
    );
  }

  return supabaseEvents;
}

async function main2(supabase) {
  logger.debug("setting up sherdog");
  const sherdog: Sherdog = new Sherdog();
  logger.debug("setting up cache");
  const cache: Cache = new MemoryCache();
  sherdog.setCache(cache);

  logger.debug("getting events");
  const sherdogEvents: Event[] = await sherdog.getEventsFromPage(1);

  const fights = sherdog.getFightsFromEvent(sherdogEvents[4]);

  return fights;
}

Deno.serve(async (req) => {
  try {
    logger.debug("login to supabase");
    const url: string = Deno.env.get("SUPABASE_URL") ?? "";
    const key: string = Deno.env.get("SUPABASE_ANON_KEY") ?? "";
    const supabase = createClient(url, key, {
      global: {
        headers: {
          Authorization: req.headers.get("Authorization"),
        },
      },
    });

    const response = await main(supabase);

    return sendResponse(response);
  } catch (err) {
    logger.error("error", err);
    return sendResponse(err, 500);
  }
});
