import { EmptyCountry, type Country } from './country'

export interface City {
  id: number
  name: string
  country: Country
}

export const EmptyCity: City = {
  id: 0,
  name: 'city',
  country: EmptyCountry,
}
