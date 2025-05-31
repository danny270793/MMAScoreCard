export interface Fighter {
    name: string
    link: string
}

export interface Category {
    name: string
    weight?: number
}

export interface PendingFight {
    position: number
    fighterOne: Fighter
    category: Category
    fighterTwo: Fighter
    mainEvent: boolean

    type: 'pending'
}

export interface DoneFight {
    position: number
    fighterOne: Fighter
    category: Category
    fighterTwo: Fighter
    mainEvent: boolean

    result: string
    method: string
    time: string
    round: number
    type: 'done'
}

export type Fight = PendingFight | DoneFight
