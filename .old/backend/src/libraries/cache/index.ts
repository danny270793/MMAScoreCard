export interface Cache {
    has(key: string): Promise<boolean>
    get(key: string): Promise<string|null>
    set(key: string, value: string): Promise<void>
}
