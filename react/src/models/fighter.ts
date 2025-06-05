import type { City } from './city'

export interface Fighter {
  id: number
  name: string
  nickname?: string
  city: City
  birthday?: Date
  died?: Date
  height: number
  weight: number
  link: string
}
