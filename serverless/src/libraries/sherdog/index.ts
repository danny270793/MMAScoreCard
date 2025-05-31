import { Cache } from '../cache'
import { Logger } from '../logger'

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

    async getEventsFromPage(page: number): Promise<string> {
        const url: string = `${this.baseUrl}/organizations/Ultimate-Fighting-Championship-UFC-2/recent-events/${page}`
        const html: string = await this.getHtml(url)
        return html
    }
}
