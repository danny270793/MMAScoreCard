import type { City } from './city'

export interface Location {
  id: number
  name: string
  cities: City
}
