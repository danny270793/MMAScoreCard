import { backend } from "./backend"
import { local } from "./local"

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

export interface Sherdog {
    getEvents(): Promise<Event[]>
    getEvent(name: string): Promise<Event>
    getFights(event: Event): Promise<Fight[]> 
}

export const sherdog: Sherdog = window.cordova ? local : backend
