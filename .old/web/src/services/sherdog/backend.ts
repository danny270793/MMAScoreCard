import { Sherdog } from "."

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
    position: string
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

export const backend: Sherdog = {
    async getEvents(): Promise<Event[]> {
        return (await (await fetch('http://localhost:8000/events')).json()).map((event: any) => ({
            ...event,
            date: new Date(event.date),
            url: new URL(event.url)
        }))
    },
    async getEvent(name: string): Promise<Event> {
        return (await (await fetch('http://localhost:8000/events')).json()).map((event: any) => ({
            ...event,
            date: new Date(event.date),
            url: new URL(event.url)
        })).filter((event: Event) => event.name === name)[0]
    },
    async getFights(event: Event): Promise<Fight[]> {
        return (await (await fetch(`http://localhost:8000/events/${event.name}`)).json()).map((fight: any) => ({
            ...fight,
        }))
    }
}
