import type { Location } from './location'

export interface Event {
  id: number
  name: string
  fight?: string
  date: string
  link: string
  locations: Location
  status: string
}
