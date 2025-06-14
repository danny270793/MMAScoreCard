import type { Cache } from '.'
import { Logger } from '../../../utils/logger'

const logger: Logger = new Logger(
  '/src/connectors/backend/cache/local-storage.ts',
)

export class LocalStorageCache implements Cache {
  async has(key: string): Promise<boolean> {
    const hasItem: boolean = localStorage.getItem(key) !== null
    if (!hasItem) {
      logger.debug(`Cache miss key=${key}`)
    } else {
      logger.debug(`Cache hit key=${key}`)
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
