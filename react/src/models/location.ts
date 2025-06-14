import { EmptyCity, type City } from './city'

export interface Location {
  id: number
  name: string
  city: City
}

export const EmptyLocation: Location = {
  id: 0,
  name: 'location',
  city: EmptyCity,
}
