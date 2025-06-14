export const Storage = {
    has(key: string): boolean {
        return localStorage.getItem(key) !== null
    },
    get(key: string): string|null {
        return localStorage.getItem(key)
    },
    set(key: string, value: string): void {
        localStorage.setItem(key, value)
    }
}
