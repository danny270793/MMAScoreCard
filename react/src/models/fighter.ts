import { EmptyCity, type City } from './city'

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

export const EmptyFighter: Fighter = {
  id: 0,
  name: 'fighter name',
  nickname: undefined,
  city: EmptyCity,
  birthday: undefined,
  died: undefined,
  height: 0,
  weight: 0,
  link: '',
}
