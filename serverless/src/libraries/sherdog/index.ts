import * as cheerio from 'cheerio'
import { Cache } from '../cache'
import { Logger } from '../logger'
import { Event } from './models/event'
import { Utils } from '../utils'

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
                const one: string = $(cells[0]).text().trim()
                const two: string = $(cells[1]).text().trim()
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
            const events: Event[] = await this.getEventsFromPage(index)
            if (events.length === 0) {
                hasEvents = false
            } else {
                index++
            }
        }
        return events
    }
}
