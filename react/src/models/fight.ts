import type { Category } from './category'
import type { Event } from './event'
import type { Fighter } from './fighter'
import type { Referee } from './referee'

export interface Fight {
  id: number
  position: number
  category: Category
  fighterOne: Fighter
  fighterTwo: Fighter
  referee: Referee | undefined
  mainEvent: boolean
  titleFight: boolean
  type: 'pending' | 'done'
  method?: string
  time?: number
  round?: number
  decision?: string
  event: Event
}
