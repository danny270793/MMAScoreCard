import { Cache } from './libraries/cache'
import Path from 'node:path'
import { FileCache } from './libraries/cache/file-cache'
import { Sherdog } from './libraries/sherdog'
import { Event } from './libraries/sherdog/models/event'
import { Fight, NoEventFight } from './libraries/sherdog/models/fight'
import { error } from 'node:console'
import { Database } from './libraries/database'

interface Entity {
    id: number
}
interface Country extends Entity {
    name: string
}

async function main(): Promise<void> {
    const cachePath: string = Path.join(__dirname, '..', '.cache.json')
    const cache: Cache = new FileCache(cachePath)

    const databasePath: string = Path.join(__dirname, '..', '.database.sqlite')
    const database: Database = new Database(databasePath)

    await database.dropTable('events')
    await database.dropTable('locations')
    await database.dropTable('cities')
    await database.dropTable('countries')

    await database.createTable('countries', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL UNIQUE',
    })

    await database.createTable('cities', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL',
        countryId: 'INTEGER NOT NULL',
        FOREIGN: 'KEY (countryId) REFERENCES countries(id)',
        UNIQUE: '(name, countryId)',
    })

    await database.createTable('locations', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL',
        cityId: 'INTEGER NOT NULL',
        FOREIGN: 'KEY (cityId) REFERENCES cities(id)',
        UNIQUE: '(name, cityId)',
    })

    await database.createTable('events', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL',
        fight: 'VARCHAR(255) NULL',
        date: 'DATE NOT NULL',
        link: 'VARCHAR(255) NOT NULL',
        status: "VARCHAR(255) NOT NULL CHECK (status IN ('uppcoming', 'past'))",
        locationId: 'INTEGER NOT NULL',
        FOREIGN: 'KEY (locationId) REFERENCES locations(id)',
        UNIQUE: '(name)',
    })

    const sherdog = new Sherdog()
    sherdog.setCache(cache)

    const events: Event[] = await sherdog.getEvents()
    for (const event of events) {
        const exists: boolean = await database.exists('countries', {
            name: event.country,
        })
        if (!exists) {
            await database.insert('countries', { name: event.country })
        }
    }

    for (const event of events) {
        const country: any = await database.getFirst('countries', {
            name: event.country,
        })
        const exists: boolean = await database.exists('cities', {
            name: event.city,
            countryId: country.id,
        })
        if (!exists) {
            await database.insert('cities', {
                name: event.city,
                countryId: country.id,
            })
        }
    }

    for (const event of events) {
        const country: any = await database.getFirst('countries', {
            name: event.country,
        })
        const city: any = await database.getFirst('cities', {
            name: event.city,
            countryId: country.id,
        })
        const exists: boolean = await database.exists('locations', {
            name: event.location,
            cityId: city.id,
        })
        if (!exists) {
            await database.insert('locations', {
                name: event.location,
                cityId: city.id,
            })
        }
    }

    for (const event of events) {
        const country: any = await database.getFirst('countries', {
            name: event.country,
        })
        const city: any = await database.getFirst('cities', {
            name: event.city,
            countryId: country.id,
        })
        const location: any = await database.getFirst('locations', {
            name: event.location,
            cityId: city.id,
        })
        const exists: boolean = await database.exists('events', {
            name: event.name,
        })
        if (!exists) {
            await database.insert('events', {
                name: event.name,
                fight: event.fight,
                date: event.date.toISOString().split('T')[0],
                link: event.link,
                status: event.state,
                locationId: location.id,
            })
        }
    }
}

main().catch(console.error)
