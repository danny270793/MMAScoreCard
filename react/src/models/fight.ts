import { EmptyCategory, type Category } from './category'
import { EmptyEvent, type Event } from './event'
import { EmptyFighter, type Fighter } from './fighter'
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

export const EmptyFight: Fight = {
  id: 0,
  position: 1,
  category: EmptyCategory,
  fighterOne: EmptyFighter,
  fighterTwo: EmptyFighter,
  referee: undefined,
  mainEvent: false,
  titleFight: true,
  type: 'done',
  method: 'method',
  time: 120,
  round: 4,
  decision: 'decision',
  event: EmptyEvent,
}
