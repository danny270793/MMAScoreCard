export interface Fight {
    id: number;
    position: number
    categoryId: number
    fighterOne: number
    fighterTwo: number
    referee: number
    mainEvent: number
    titleFight: number
    type: "pending"|'done'
    method?: string
    time?: string
    round?: number
    decision?: string
}
