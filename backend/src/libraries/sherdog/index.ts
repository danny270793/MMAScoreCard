import { Cache } from "../cache"
import * as Cheerio from 'cheerio'
import type { Element } from 'domhandler'

export interface Event {
    name: string
    figth: string|null
    location: string
    date: Date
    url: URL
}

export interface Fighter {
    name: string
    image: URL
    url: URL
}

export interface Fight {
    position: number
    fighter1: Fighter
    fighter1Status: 'win'|'loss'|'pending'
    fighter2: Fighter
    fighter2Status: 'win'|'loss'|'pending'
    division: string
    method: string
    referee: string
    round: string
    time: string
    status: 'done'|'pending'
}

export class Sherdog {
    private baseUrl: string = 'https://www.sherdog.com'
    private cache: Cache|undefined = undefined
    setCache(cache: Cache): void {
        this.cache = cache
    }
    async downloadHtml(url: string): Promise<string> {
        const response: Response = await fetch(url)
        return await response.text()
    }
    async fetchAndSave(url: string): Promise<string> {
        if(this.cache === undefined) {
            return this.downloadHtml(url)
        }

        const hasAlreadyDownloaded = await this.cache.has(url)
        if(hasAlreadyDownloaded) {
            const data: string|null = await this.cache.get(url)
            return data!
        }
        const html: string = await this.downloadHtml(url)
        await this.cache.set(url, html)
        return html
    }
    async getFights(event: Event): Promise<Fight[]> {
        const htmlText: string = await this.fetchAndSave(event.url.toString())
        
        const fights: Fight[] = []
        
        const html: Cheerio.CheerioAPI = Cheerio.load(htmlText);
        const tables: Cheerio.Cheerio<Element> = html('table.new_table')
        tables.each((_: number, element: Element) => {
            const rows: Cheerio.Cheerio<Element> = html(element).find('tr')
            rows.each((rowNumber: number, rowElement: Element) => {
                if(rowNumber === 0) {
                    return
                }
    
                let position: number|null = null
                let fighter1Name: string|null = null
                let fighter1Image: URL|null = null
                let fighter1Url: URL|null = null
                let fighter1Status: 'win'|'loss'|'pending' = 'pending'
                let fighter2Name: string|null = null
                let fighter2Image: URL|null = null
                let fighter2Url: URL|null = null
                let fighter2Status: 'win'|'loss'|'pending' = 'pending'
                let division: string|null = null
                let method: string|null = null
                let referee: string|null = null
                let round: string|null = null
                let time: string|null = null
                let status: 'done'|'pending' = 'pending'
    
                const columns: Cheerio.Cheerio<Element> = html(rowElement).find('td')
                columns.each((columnNumber: number, columnElement: Element) => {
                    const tempHtml: string = html(columnElement).html()?.replace(/<br\s*\/?>/g, '\n') || ''
                    const content: string = Cheerio.load(tempHtml).text().trim();
                    if(columns.length === 7) {
                        status = 'done'
                        switch(columnNumber) {
                            case 0:
                                position = parseInt(content)
                                break
                            case 1:
                                content.endsWith('win') ? fighter1Status = 'win' : content.endsWith('loss') ? fighter1Status = 'loss' : fighter1Status = 'pending'
                                fighter1Name = content.split(' ').slice(0, -1).join(' ').trim()
                                html(columnElement).find('img').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.src) {
                                            fighter1Image = new URL(`${this.baseUrl}${element.attribs.src}`)
                                        }
                                    }
                                })
                                html(columnElement).find('a').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.href) {
                                            fighter1Url = new URL(`${this.baseUrl}${element.attribs.href}`)
                                        }
                                    }
                                })
                                break
                            case 2:
                                division = content
                                break
                            case 3:
                                content.endsWith('win') ? fighter2Status = 'win' : content.endsWith('loss') ? fighter2Status = 'loss' : fighter2Status = 'pending'
                                fighter2Name = content.split(' ').slice(0, -1).join(' ').trim()
                                html(columnElement).find('img').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.src) {
                                            fighter2Image = new URL(`${this.baseUrl}${element.attribs.src}`)
                                        }
                                    }
                                })
                                html(columnElement).find('a').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.href) {
                                            fighter2Url = new URL(`${this.baseUrl}${element.attribs.href}`)
                                        }
                                    }
                                })
                                break
                            case 4:
                                const parts: string[] = content.split(')')
                                method = `${parts[0].trim()})`
                                referee = parts[1].trim()
                                break
                            case 5:
                                round = content
                                break
                            case 6:
                                time = content
                                break
                        }
                    } else {
                        status = 'pending'
                        round = ''
                        time = ''
                        referee = ''
                        method = ''
                        switch(columnNumber) {
                            case 0:
                                position = parseInt(content)
                                break
                            case 1:
                                fighter1Name = content.split(' ').slice(0, -1).join(' ').trim()
                                html(columnElement).find('img').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.src) {
                                            fighter1Image = new URL(`${this.baseUrl}${element.attribs.src}`)
                                        }
                                    }
                                })
                                html(columnElement).find('a').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.href) {
                                            fighter1Url = new URL(`${this.baseUrl}${element.attribs.href}`)
                                        }
                                    }
                                })
                                break
                            case 2:
                                division = content
                                break
                            case 3:
                                fighter2Name = content.split(' ').slice(0, -1).join(' ').trim()
                                html(columnElement).find('img').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.src) {
                                            fighter2Image = new URL(`${this.baseUrl}${element.attribs.src}`)
                                        }
                                    }
                                })
                                html(columnElement).find('a').each((index: number, element: Element) => {
                                    if(element.attribs) {
                                        if(element.attribs.href) {
                                            fighter2Url = new URL(`${this.baseUrl}${element.attribs.href}`)
                                        }
                                    }
                                })
                                break
                        }
                    }
                })
    
                if(fighter1Name == null || fighter1Image == null || fighter1Url == null || fighter2Name == null || fighter2Image == null || fighter2Url == null || position == null || division == null || method == null || referee == null || referee == null || round == null || time == null) {
                    throw new Error(`required fields are null ${JSON.stringify({ rowNumber, fighter1Name, fighter1Image, fighter1Url, fighter2Name, fighter2Image, fighter2Url, position, division, method, referee, round, time, status })}`)
                }
    
                const fight: Fight = {
                    fighter1: {
                        name: fighter1Name,
                        image: new URL(fighter1Image),
                        url: new URL(fighter1Url)
                    },
                    fighter1Status,
                    fighter2: {
                        name: fighter2Name,
                        image: new URL(fighter2Image),
                        url: new URL(fighter2Url)
                    },
                    fighter2Status,
                    position,
                    division,
                    method,
                    referee,
                    round,
                    time,
                    status
                }
                fights.push(fight)
            })
        })
        fights.sort((a: Fight, b: Fight) => b.position - a.position)
        return fights
    }
    async getEvents(): Promise<Event[]> {
        const eventsUrl: string = `${this.baseUrl}/organizations/Ultimate-Fighting-Championship-UFC-2`
        const htmlText: string = await this.fetchAndSave(eventsUrl)
    
        const events: Event[] = []
    
        const html: Cheerio.CheerioAPI = Cheerio.load(htmlText);
        const tables: Cheerio.Cheerio<Element> = html('table.new_table')
        tables.each((index: number, element: Element) => {
            const rows: Cheerio.Cheerio<Element> = html(element).find('tr')
            rows.each((rowNumber: number, rowElement: Element) => {
                if(rowNumber === 0) {
                    return
                }
    
                let name: string|null = null
                let figth: string|null = null
                let location: string|null = null
                let url: URL|null = null
                let date: Date|null = null
    
                if(rowElement.attribs) {
                    const onClick: string|null = rowElement.attribs.onclick
                    if(onClick) {
                        const endpoint: string = onClick.split('=')[1].slice(1, -2)
                        url = new URL(`${this.baseUrl}${endpoint}`)
                    }
                }
    
                const columns: Cheerio.Cheerio<Element> = html(rowElement).find('td')
                columns.each((columnNumber: number, columnElement: Element) => {
                    const content: string|null = html(columnElement).text().trim()
                    switch(columnNumber) {
                        case 0:
                            const monthString: string = content.slice(0, 3)
                            const dayString: string = content.slice(3, 5)
                            const yearString: string = content.slice(5)
    
                            const formattedDateString: string = `${monthString} ${dayString}, ${yearString}`
    
                            date = new Date(formattedDateString)
                            break
                        case 1:
                            if(content.includes('vs')) {
                                const parts: string[] = content.split('-')
                                name = parts[0].trim()
                                figth = parts[1].trim()
                            } else {
                                name = content
                            }
                            
                            break
                        case 2:
                            location = content
                            break
                    }
                })
    
                if(name == null || location == null || url == null || date == null) {
                    throw new Error(`required fields are null ${JSON.stringify({ rowNumber, name, location, url, date })}`)
                }
    
                const event: Event = {
                    name,
                    figth,
                    location,
                    url,
                    date
                }
                events.push(event)
            })
        })
        events.sort((a: Event, b: Event) => b.date.getTime() - a.date.getTime())
        return events
    }
}
