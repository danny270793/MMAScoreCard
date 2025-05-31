import { Cache } from './libraries/cache'
import Path from 'node:path'
import { FileCache } from './libraries/cache/file-cache'
import { Sherdog } from './libraries/sherdog'
import { Event } from './libraries/sherdog/models/event'

async function main(): Promise<void> {
    const cachePath: string = Path.join(__dirname, '..', '.cache.json')
    const cache: Cache = new FileCache(cachePath)

    const sherdog = new Sherdog()
    sherdog.setCache(cache)

    const events: Event[] = await sherdog.getEvents()
    for (const event of events) {
        console.log(event)
    }
    console.log(`${events.length} events`)
}

main().catch(console.error)
