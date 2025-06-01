import * as cheerio from 'cheerio'
import { Cache } from '../cache'
import { Logger } from '../logger'
import { Event } from './models/event'
import { Utils } from '../utils'
import {
    DoneFight,
    Fight,
    Fighter,
    NoEventFight,
    PendingFight,
} from './models/fight'
import { Stats } from './models/stats'

const logger: Logger = new Logger('./libraries/sherdog/index.ts')

export class Sherdog {
    baseUrl: string = 'https://www.sherdog.com'
    cache?: Cache = undefined

    setCache(cache?: Cache) {
        this.cache = cache
    }

    async getHtml(url: string): Promise<string> {
        if (this.cache && this.cache.has(url)) {
            return this.cache.get(url)
        }
        logger.debug(`CACHE MISS ${url}`)
        const response: Response = await fetch(url)
        if (response.status >= 300) {
            throw new Error(
                `Failed to fetch ${url}: ${response.status} ${response.statusText}`,
            )
        }
        const html: string = await response.text()
        if (this.cache) {
            this.cache.set(url, html)
        }
        return html
    }

    async getEventsFromPage(page: number): Promise<Event[]> {
        const events: Event[] = []

        const url: string = `${this.baseUrl}/organizations/Ultimate-Fighting-Championship-UFC-2/recent-events/${page}`
        const html: string = await this.getHtml(url)
        const $: cheerio.Root = cheerio.load(html)
        const tables: Element[] = $('table').get()
        let tablerNumber: number = -1
        for (const eachTable of tables) {
            tablerNumber += 1

            if (page > 1 && tablerNumber === 0) {
                continue
            }

            const table: cheerio.Cheerio = $(eachTable)
            if (table.attr('class') !== 'new_table event') {
                continue
            }

            const rows: Element[] = table.find('tr').get()
            for (const row of rows.slice(1)) {
                const cells: Element[] = $(row).find('td').get()
                const cellOne: cheerio.Cheerio = $(cells[0])
                const cellTwo: cheerio.Cheerio = $(cells[1])

                const one: string = cellOne.text().trim()
                const two: string = cellTwo.text().trim()
                const three: string = $(cells[2]).text().trim()

                let name: string = ''
                let fight: string | undefined
                if (two.includes('vs.')) {
                    const twoParts: string[] = two.split('-')
                    name = twoParts[0].trim()
                    fight = twoParts[1].trim()
                } else {
                    name = two
                }

                const threeParts: string[] = three.split(',')
                const country: string = threeParts[threeParts.length - 1].trim()
                const city: string = threeParts[threeParts.length - 2].trim()
                const location: string = threeParts.slice(0, -2).join(', ')
                const event: Event = {
                    name,
                    fight,
                    date: Utils.parseCompactDate(one)!,
                    country,
                    city,
                    location,
                    state: tablerNumber === 0 ? 'uppcoming' : 'past',
                    link: `${this.baseUrl}${cellTwo.find('a').attr('href')}`,
                }
                events.push(event)
            }
        }

        return events
    }

    async getEvents(): Promise<Event[]> {
        let index: number = 1
        let hasEvents: boolean = true

        const events: Event[] = []
        while (hasEvents) {
            const pageEvents: Event[] = await this.getEventsFromPage(index)
            if (pageEvents.length === 0) {
                hasEvents = false
            } else {
                events.push(...pageEvents)
                index++
            }
        }
        return events
    }

    async getFightsFromEvent(event: Event): Promise<Fight[]> {
        const html: string = await this.getHtml(event.link)
        const $: cheerio.Root = cheerio.load(html)

        const fights: Fight[] = []

        const tables: Element[] = [
            ...$('table.new_table.upcoming').get(),
            ...$('table.new_table.result').get(),
        ]
        for (const eachTable of tables) {
            const table: cheerio.Cheerio = $(eachTable)
            const rows: Element[] = table.find('tr').get()
            for (const row of rows.slice(1)) {
                const cells: Element[] = $(row).find('td').get()

                const position: number = parseInt($(cells[0]).text().trim())
                $(cells[1]).find('br').replaceWith(' ')
                const fighterOne: string = $(cells[1])
                    .text()
                    .trim()
                    .split('\n')[0]
                    .trim()

                const nameOneParts: string[] = $(cells[1])
                    .text()
                    .trim()
                    .split('\n')
                let category: string = $(cells[2]).text().trim()
                const titleFight: boolean = category.includes('TITLE FIGHT')
                category = category.replace('TITLE FIGHT', '').trim()
                const categoryParts: string[] = category.split('lb')

                $(cells[3]).find('br').replaceWith(' ')
                const fighterTwo: string = $(cells[3])
                    .text()
                    .trim()
                    .split('\n')[0]
                    .trim()
                const nameTwoParts: string[] = $(cells[3])
                    .text()
                    .trim()
                    .split('\n')
                const fighterOneLink: string =
                    $(cells[1]).find('a').attr('href') || ''

                const fighterTwoLink: string =
                    $(cells[3]).find('a').attr('href') || ''
                if (cells.length === 5) {
                    const fight: PendingFight = {
                        position,
                        fighterOne: {
                            name: fighterOne,
                            link: `${this.baseUrl}${fighterOneLink}`,
                        },
                        category:
                            category === ''
                                ? undefined
                                : categoryParts.length > 1
                                  ? {
                                        name: categoryParts[1].trim(),
                                        weight: parseInt(
                                            categoryParts[0].trim(),
                                        ),
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
                        type: 'pending',
                    }
                    fights.push(fight)
                } else if (cells.length === 7) {
                    const refereeAndMethod: string = $(cells[4]).text().trim()
                    const refereeAndMethodParts: string[] =
                        refereeAndMethod.split('\n')
                    const decisionAndMethod: string =
                        refereeAndMethodParts[0].trim()

                    let method: string | undefined
                    let decision: string | undefined
                    let referee: string

                    if (decisionAndMethod === 'No Contest') {
                        method = undefined
                        decision = undefined
                        referee = refereeAndMethodParts[1].trim()
                    } else {
                        const decisionAndMethodParts: string[] =
                            decisionAndMethod.split('(')
                        decision = decisionAndMethodParts[0].trim()
                        method = decisionAndMethodParts[1].trim().slice(0, -1)
                        referee = refereeAndMethodParts[1].trim()
                    }
                    const round: number = parseInt($(cells[5]).text().trim())
                    const time: number = Utils.timeToSeconds(
                        $(cells[6]).text().trim(),
                    )

                    const resultOne: string =
                        nameOneParts[nameOneParts.length - 1].trim()

                    const resultTwo: string =
                        nameTwoParts[nameTwoParts.length - 1].trim()

                    const fight: DoneFight = {
                        position,
                        fighterOne: {
                            name: fighterOne,
                            link: `${this.baseUrl}${fighterOneLink}`,
                            result: resultOne,
                        },
                        category:
                            category === ''
                                ? undefined
                                : categoryParts.length > 1
                                  ? {
                                        name: categoryParts[1].trim(),
                                        weight: parseInt(
                                            categoryParts[0].trim(),
                                        ),
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
                        type: 'done',
                        method,
                        decision,
                        time,
                        round,
                        referee,
                    }
                    fights.push(fight)
                } else {
                    throw new Error('Unexpected number of cells in row')
                }
            }
        }

        // get main event
        const resumes: Element[] = $('div.fight_card').get()
        for (const eachResume of resumes) {
            const resume: cheerio.Cheerio = $(eachResume)

            const leftSide: Element[] = resume
                .find('div.fighter.left_side')
                .get()
            const fighterOne: string = $(leftSide)
                .text()
                .trim()
                .split('\n')[0]
                .trim()
            const fighterOneLink: string =
                $(leftSide).find('a').attr('href') || ''

            const rightSide: Element[] = resume
                .find('div.fighter.right_side')
                .get()
            const fighterTwo: string = $(rightSide)
                .text()
                .trim()
                .split('\n')[0]
                .trim()
            const fighterTwoLink: string =
                $(rightSide).find('a').attr('href') || ''

            const isTitle: Element[] = resume.find('span.title_fight').get()
            const titleFight: boolean = isTitle.length > 0

            const spans: Element[] = resume.find('span.weight_class').get()
            $(spans[0]).find('br').replaceWith(' ')
            const category: string = $(spans[0]).text().trim()
            const categoryParts: string[] = category.split(' ')

            const tables: Element[] = $('table.fight_card_resume').get()
            if (tables.length === 0) {
                const fight: PendingFight = {
                    position: fights.length + 1,
                    fighterOne: {
                        name: fighterOne,
                        link: `${this.baseUrl}${fighterOneLink}`,
                    },
                    category:
                        categoryParts.length > 1
                            ? {
                                  name: categoryParts[1].trim(),
                                  weight: parseInt(
                                      categoryParts[0].trim().replace('lb', ''),
                                  ),
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
                    type: 'pending',
                }
                fights.push(fight)
            } else {
                const nameOneParts: string[] = $(leftSide)
                    .text()
                    .trim()
                    .split('\n')
                const resultOne: string =
                    nameOneParts[nameOneParts.length - 1].trim()

                const nameTwoParts: string[] = $(rightSide)
                    .text()
                    .trim()
                    .split('\n')
                const resultTwo: string =
                    nameTwoParts[nameTwoParts.length - 1].trim()

                for (const eachTable of tables) {
                    const table: cheerio.Cheerio = $(eachTable)
                    const rows: Element[] = table.find('tr').get()
                    for (const row of rows) {
                        const cells: Element[] = $(row).find('td').get()

                        const decisionAndMethod: string = $(cells[1])
                            .text()
                            .trim()
                        const decisionAndMethodParts: string[] =
                            decisionAndMethod.split('(')
                        const decision: string = decisionAndMethodParts[0]
                            .trim()
                            .replace('Method ', '')
                        const method: string = decisionAndMethodParts[1]
                            .trim()
                            .slice(0, -1)
                        const referee: string = $(cells[2])
                            .text()
                            .trim()
                            .replace('Referee ', '')
                        const round: number = parseInt(
                            $(cells[3]).text().trim().replace('Round ', ''),
                        )
                        const time: number = Utils.timeToSeconds(
                            $(cells[4]).text().trim().replace('Time ', ''),
                        )

                        const fight: DoneFight = {
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
                                          weight: parseInt(
                                              categoryParts[0]
                                                  .trim()
                                                  .replace('lb', ''),
                                          ),
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
                            type: 'done',
                            method,
                            decision,
                            time,
                            round,
                            referee,
                        }
                        fights.push(fight)
                    }
                }
            }
        }

        return fights
    }

    async getStatsFighter(fighter: Fighter): Promise<Stats> {
        const html: string = await this.getHtml(fighter.link)
        const $: cheerio.Root = cheerio.load(html)

        const nicknames: string[] = $('span.nickname').get()
        const nickname: string = $(nicknames[0]).text().trim()

        const nationalities: string[] = $('span.item.birthplace').get()
        const country: string = $(nationalities[0])
            .text()
            .trim()
            .split('\n')[0]
            .trim()

        const locality: string[] = $('span.locality').get()
        const city: string = $(locality[0]).text().trim()

        const bio: Element[] = $('div.bio-holder').get()
        const tables: Element[] = $(bio[0]).find('table').get()
        const rows: Element[] = $(tables[0]).find('tr').get()

        let birthday: Date | null = null
        let height: string | null = null
        let weight: string | null = null

        let index: number = -1
        for (const row of rows) {
            index += 1

            const cells: Element[] = $(row).find('td').get()
            if (index === 0) {
                const text: string = $(cells[1]).text().trim()

                birthday = Utils.parseDate(text.split('/')[1].trim())
            } else if (index === 1) {
                const text: string = $(cells[1]).text().trim()

                height = text.split('/')[1].trim().replace('cm', '').trim()
            } else if (index === 2) {
                const text: string = $(cells[1]).text().trim()

                weight = text.split('/')[1].trim().replace('kg', '').trim()
            }
        }

        return {
            nickname,
            country,
            city,
            birthday: birthday!,
            height: parseFloat(height!),
            weight: parseFloat(weight!),
        }
    }

    async getFightsFromFighter(fighter: Fighter): Promise<NoEventFight[]> {
        const fights: NoEventFight[] = []

        const html: string = await this.getHtml(fighter.link)
        const $: cheerio.Root = cheerio.load(html)

        const tables: Element[] = $('table.new_table.fighter').get()
        for (const eachTable of tables) {
            const table: cheerio.Cheerio = $(eachTable)
            const rows: Element[] = table.find('tr').get()
            for (const row of rows.slice(1)) {
                const cells: Element[] = $(row).find('td').get()

                const resultTwo: string = $(cells[0]).text().trim()
                const fighterTwo: string = $(cells[1]).text().trim()
                const fighterTwoLink: string =
                    $(cells[1]).find('a').attr('href') || ''

                $(cells[2]).find('br').replaceWith('\n')

                // const eventDate: string = $(cells[2]).text().trim()
                // const event: string = eventDateParts[0].trim()
                // const eventDateParts: string[] = eventDate.split('\n')
                // const date: string = eventDateParts[1].trim()

                // const dateClean: string = date.replace(/\s*\/\s*/g, '/')

                const decisionMethodReferee: string = $(cells[3]).text().trim()
                const decisionMethodRefereeParts: string[] =
                    decisionMethodReferee.split('(')
                const decision: string = decisionMethodRefereeParts[0].trim()
                const methodReferee: string[] = decisionMethodRefereeParts[1]
                    .trim()
                    .split(')')
                const method: string = methodReferee[0].trim()
                const referee: string = methodReferee[1]
                    .trim()
                    .split('\n')[0]
                    .trim()
                const round: number = parseInt($(cells[4]).text().trim())
                const time: number = Utils.timeToSeconds(
                    $(cells[5]).text().trim(),
                )

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
                }

                fights.push(fight)
            }
        }

        return fights
    }
}
