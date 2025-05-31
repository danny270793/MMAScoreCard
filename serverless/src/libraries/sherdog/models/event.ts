export interface Event {
    name: string
    fight?: string
    date: Date
    country: string
    city: string
    location: string
    state: 'uppcoming' | 'past'
}
