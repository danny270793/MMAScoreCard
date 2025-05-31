import { Cache } from './libraries/cache'
import Path from 'node:path'
import { FileCache } from './libraries/cache/file-cache'
import { Sherdog } from './libraries/sherdog'
import { Event } from './libraries/sherdog/models/event'
import { Fight } from './libraries/sherdog/models/fight'

async function main(): Promise<void> {
    const cachePath: string = Path.join(__dirname, '..', '.cache.json')
    const cache: Cache = new FileCache(cachePath)

    const sherdog = new Sherdog()
    sherdog.setCache(cache)

    const events: Event[] = await sherdog.getEvents()
    const fights: Fight[] = await sherdog.getFightsFromEvent(events[0])
    for (const fight of fights) {
        console.log(fight)
    }
    console.log(`${fights.length} fights`)
}

main().catch(console.error)
