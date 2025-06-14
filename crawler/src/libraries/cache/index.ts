export interface Cache {
    keysCount(): number
    has(key: string): boolean
    get(key: string): any
    set(key: string, value: any): void
}
