import type { Category } from './category'
import type { Fighter } from './fighter'
import type { Referee } from './referee'

export interface Fight {
  id: number
  position: number
  category: Category
  fighterOne: Fighter
  fighterTwo: Fighter
  referee: Referee
  mainEvent: boolean
  titleFight: boolean
  type: 'pending' | 'done'
  method?: string
  time?: string
  round?: number
  decision?: string
}
