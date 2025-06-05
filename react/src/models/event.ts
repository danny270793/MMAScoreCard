import type { Location } from './location'

export interface Event {
  id: number
  name: string
  fight?: string
  date: Date
  link: string
  location: Location
  status: string
}
