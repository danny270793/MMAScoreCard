import type { Category } from './category'
import type { Event } from './event'
import type { Fighter } from './fighter'
import type { Referee } from './referee'

export interface Fight {
  id: number
  position: number
  categories: Category
  fighterOne: Fighter
  fighterTwo: Fighter
  referees?: Referee
  mainEvent: boolean
  titleFight: boolean
  type: 'pending' | 'done'
  method?: string
  time?: number
  round?: number
  decision?: string
  events: Event
  winner?: number
}
