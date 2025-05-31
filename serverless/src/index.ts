import { Cache } from './libraries/cache'
import Path from 'node:path'
import { FileCache } from './libraries/cache/file-cache'
import { Sherdog } from './libraries/sherdog'

async function main(): Promise<void> {
    const cachePath: string = Path.join(__dirname, '..', 'assets', 'cache.json')
    const cache: Cache = new FileCache(cachePath)

    const sherdog = new Sherdog()
    sherdog.setCache(cache)

    const events = await sherdog.getEventsFromPage(1)
    console.log('events')
}

main().catch(console.error)
