export interface Fighter {
    name: string
    link: string
}

export interface Category {
    name: string
    weight?: number
}

export interface BaseFight {
    position: number
    fighterOne: Fighter
    category: Category
    fighterTwo: Fighter
    mainEvent: boolean
}

export interface PendingFight extends BaseFight {
    type: 'pending'
}

export interface DoneFight extends BaseFight {
    decision: string
    referee: string
    method: string
    time: string
    round: number
    type: 'done'
}

export type Fight = PendingFight | DoneFight
