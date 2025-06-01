export interface Fighter {
    name: string
    link: string
    result?: string //'win' | 'loss' | 'draw' | 'nc'
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
    titleFight: boolean
}

export interface PendingFight extends BaseFight {
    type: 'pending'
}

export interface DoneFight extends BaseFight {
    decision: string
    referee: string
    method: string
    time: number
    round: number
    type: 'done'
}

export type Fight = PendingFight | DoneFight
