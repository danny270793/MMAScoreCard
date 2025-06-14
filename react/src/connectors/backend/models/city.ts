import type { Country } from './country'

export interface City {
  id: number
  name: string
  countries: Country
}
