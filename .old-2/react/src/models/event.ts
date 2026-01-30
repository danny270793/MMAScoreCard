import { EmptyLocation, type Location } from './location'

export interface Event {
  id: number
  name: string
  fight?: string
  date: Date
  link: string
  location: Location
  status: string
}

export const EmptyEvent: Event = {
  date: new Date(),
  id: 1,
  link: '',
  name: 'event name',
  status: 'uppcomming',
  fight: 'fighter one vs. fighter two',
  location: EmptyLocation,
}
