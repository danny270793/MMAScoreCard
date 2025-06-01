import { Cache } from './libraries/cache'
import Path from 'node:path'
import { FileCache } from './libraries/cache/file-cache'
import { Sherdog } from './libraries/sherdog'
import { Event } from './libraries/sherdog/models/event'
import { Database } from './libraries/database'
import { Fight } from './libraries/sherdog/models/fight'
import { Stats } from './libraries/sherdog/models/stats'
import { ProgressBar } from './libraries/progressbar'
import { Logger } from './libraries/logger'

Logger.enabled = false

const weights: Record<string, number> = {
    Strawweight: 115,
    Flyweight: 125,
    Bantamweight: 135,
    Featherweight: 145,
    Lightweight: 155,
    Welterweight: 170,
    Middleweight: 185,
    'Light Heavyweight': 205,
    Heavyweight: 225,
}

async function main(): Promise<void> {
    const cachePath: string = Path.join(__dirname, '..', '.cache.json')
    const cache: Cache = new FileCache(cachePath)

    const databasePath: string = Path.join(__dirname, '..', '.database.sqlite')
    const database: Database = new Database(databasePath)

    await database.dropTable('fights')
    await database.dropTable('referees')
    await database.dropTable('categories')
    await database.dropTable('fighters')
    await database.dropTable('events')
    await database.dropTable('locations')
    await database.dropTable('cities')
    await database.dropTable('countries')

    await database.createTable('countries', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL UNIQUE',
    })

    await database.createTable(
        'cities',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            name: 'VARCHAR(255) NOT NULL',
            countryId: 'INTEGER NOT NULL',
            UNIQUE: '(name, countryId)',
        },
        [
            {
                column: 'countryId',
                referencedTable: 'countries',
                referencedColumn: 'id',
            },
        ],
    )

    await database.createTable(
        'locations',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            name: 'VARCHAR(255) NOT NULL',
            cityId: 'INTEGER NOT NULL',
            UNIQUE: '(name, cityId)',
        },
        [
            {
                column: 'cityId',
                referencedTable: 'cities',
                referencedColumn: 'id',
            },
        ],
    )

    await database.createTable(
        'events',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            name: 'VARCHAR(255) NOT NULL',
            fight: 'VARCHAR(255) NULL',
            date: 'DATE NOT NULL',
            link: 'VARCHAR(255) NOT NULL',
            status: "VARCHAR(255) NOT NULL CHECK (status IN ('uppcoming', 'past'))",
            locationId: 'INTEGER NOT NULL',
            UNIQUE: '(name)',
        },
        [
            {
                column: 'locationId',
                referencedTable: 'locations',
                referencedColumn: 'id',
            },
        ],
    )

    await database.createTable('fighters', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL',
        link: 'VARCHAR(255) NOT NULL',
        UNIQUE: '(name)',
    })

    await database.createTable('categories', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL',
        weight: 'int NOT NULL',
        UNIQUE: '(name, weight)',
    })

    await database.createTable('referees', {
        id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
        name: 'VARCHAR(255) NOT NULL',
        UNIQUE: '(name)',
    })

    await database.createTable(
        'fights',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            position: 'INTEGER NOT NULL',
            categoryId: 'INTEGER NULL',
            fighterOne: 'INTEGER NOT NULL',
            fighterTwo: 'INTEGER NOT NULL',
            referee: 'INTEGER NULL',
            mainEvent: 'INTEGER NOT NULL DEFAULT 0',
            titleFight: 'INTEGER NOT NULL DEFAULT 0',
            type: "VARCHAR(255) NOT NULL CHECK (type IN ('pending', 'done'))",
            method: 'VARCHAR(255) NULL',
            time: 'INTEGER NULL',
            round: 'INTEGER NULL',
            decision: 'VARCHAR(255) NULL',
        },
        [
            {
                column: 'categoryId',
                referencedTable: 'categories',
                referencedColumn: 'id',
            },
            {
                column: 'fighterOne',
                referencedTable: 'fighters',
                referencedColumn: 'id',
            },
            {
                column: 'fighterTwo',
                referencedTable: 'fighters',
                referencedColumn: 'id',
            },
            {
                column: 'referee',
                referencedTable: 'referees',
                referencedColumn: 'id',
            },
        ],
    )

    const sherdog = new Sherdog()
    sherdog.setCache(cache)

    const events: Event[] = await sherdog.getEvents()

    const bar: ProgressBar = new ProgressBar(events.length)

    for (const event of events) {
        bar.increase('countries')
        const exists: boolean = await database.exists('countries', {
            name: event.country,
        })
        if (!exists) {
            await database.insert('countries', { name: event.country })
        }
    }
    bar.reset()

    for (const event of events) {
        bar.increase('cities')
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
    bar.reset()

    for (const event of events) {
        bar.increase('locations')
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
    bar.reset()

    for (const event of events) {
        bar.increase('events')
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
    bar.reset()

    // // const fights: Fight[] = await sherdog.getFightsFromEvent(events[0])
    // // const stats: Stats = await sherdog.getStatsFighter(fights[0].fighterOne)
    // // console.log(stats)

    for (const event of events) {
        bar.increase('categories')
        const fights: Fight[] = await sherdog.getFightsFromEvent(event)

        for (const fight of fights) {
            if (!fight.category) {
                return
            }

            const weight: number =
                fight.category.weight || weights[fight.category.name]
            const exists: boolean = await database.exists('categories', {
                name: fight.category.name,
                weight,
            })
            if (!exists) {
                await database.insert('categories', {
                    name: fight.category.name,
                    weight,
                })
            }
        }
    }
    bar.reset()

    for (const event of events) {
        bar.increase('referees')
        const fights: Fight[] = await sherdog.getFightsFromEvent(event)
        for (const fight of fights) {
            if (fight.type === 'done') {
                const exists: boolean = await database.exists('referees', {
                    name: fight.referee,
                })
                if (!exists) {
                    await database.insert('referees', {
                        name: fight.referee,
                    })
                }
            }
        }
    }
    bar.reset()

    for (const event of events) {
        bar.increase('fighters')
        const fights: Fight[] = await sherdog.getFightsFromEvent(event)

        for (const fight of fights) {
            console.log(fight)

            const existsOne: boolean = await database.exists('fighters', {
                name: fight.fighterOne.name,
            })
            if (!existsOne) {
                await database.insert('fighters', {
                    name: fight.fighterOne.name,
                    link: fight.fighterOne.link,
                })
            }

            const existsTwo: boolean = await database.exists('fighters', {
                name: fight.fighterTwo.name,
            })
            if (!existsTwo) {
                await database.insert('fighters', {
                    name: fight.fighterTwo.name,
                    link: fight.fighterTwo.link,
                })
            }
        }
    }
    bar.reset()

    // for (const fight of fights) {
    //     const one: any = await database.getFirst('fighters', {
    //         name: fight.fighterOne.name,
    //     })
    //     const two: any = await database.getFirst('fighters', {
    //         name: fight.fighterOne.name,
    //     })
    //     const weight: number =
    //         fight.category.weight || weights[fight.category.name]
    //     const category: any = await database.getFirst('categories', {
    //         name: fight.category.name,
    //         weight,
    //     })
    //     if (fight.type === 'done') {
    //         const referee: any = await database.getFirst('referees', {
    //             name: fight.referee,
    //         })

    //         await database.insert('fights', {
    //             categoryId: category.id,
    //             position: fight.position,
    //             fighterOne: one.id,
    //             fighterTwo: two.id,
    //             referee: referee.id,
    //             mainEvent: fight.mainEvent ? 1 : 0,
    //             titleFight: fight.titleFight ? 1 : 0,
    //             type: fight.type,
    //             method: fight.method,
    //             time: fight.time,
    //             round: fight.round,
    //             decision: fight.decision,
    //         })
    //     } else {
    //         await database.insert('fights', {
    //             categoryId: category.id,
    //             position: fight.position,
    //             fighterOne: one.id,
    //             fighterTwo: two.id,
    //             mainEvent: fight.mainEvent ? 1 : 0,
    //             titleFight: fight.titleFight ? 1 : 0,
    //             type: fight.type,
    //         })
    //     }
    // }

    console.log('Done')
}

main().catch(console.error)
