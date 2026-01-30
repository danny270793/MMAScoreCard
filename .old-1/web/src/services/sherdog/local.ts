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

export const local: Sherdog = {
    async getEvents(): Promise<Event[]> {
        return []
    },
    async getEvent(name: string): Promise<Event> {
        console.log(name)
        return {
            date: new Date(),
            figth: null,
            location: '',
            name: '',
            url: new URL('http://localhost:8000')
        }
    },
    async getFights(event: Event): Promise<Fight[]> {
        console.log(event)
        return []
    }
}
