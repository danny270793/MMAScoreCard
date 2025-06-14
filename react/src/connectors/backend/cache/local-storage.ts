import type { Cache } from '.'

export class LocalStorageCache implements Cache {
  async has(key: string): Promise<boolean> {
    const hasItem: boolean = localStorage.getItem(key) !== null
    if (!hasItem) {
      console.warn(`Cache miss for key: ${key}`)
    }
    return hasItem
  }
  async get(key: string): Promise<string> {
    // await new Promise((resolve) => setTimeout(resolve, 2000))

    const item: string | null = localStorage.getItem(key)
    if (item === null) {
      throw new Error(`Cache miss for key: ${key}`)
    }
    return item
  }
  async set(key: string, value: unknown): Promise<void> {
    const stringified: string = JSON.stringify(value)
    localStorage.setItem(key, stringified)
  }
}
