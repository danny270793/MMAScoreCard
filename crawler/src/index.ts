import { Cache } from './libraries/cache'
import Path from 'node:path'
import Fs from 'node:fs'
import { FileCache } from './libraries/cache/file-cache'
import { Sherdog } from './libraries/sherdog'
import { Event } from './libraries/sherdog/models/event'
import { Database } from './libraries/database'
import { Fight, NoEventFight } from './libraries/sherdog/models/fight'
import { Stats } from './libraries/sherdog/models/stats'
import { ProgressBar } from './libraries/progressbar'
import { Logger } from './libraries/logger'
import { SQLite } from './libraries/database/sqlite'

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

async function dropAndCreateTables(database: Database): Promise<void> {
    await database.dropTable('fights')
    await database.dropTable('referees')
    await database.dropTable('categories')
    await database.dropTable('fighters')
    await database.dropTable('events')
    await database.dropTable('locations')
    await database.dropTable('cities')
    await database.dropTable('countries')

    await database.createTable(
        'countries',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            name: 'VARCHAR(255) NOT NULL UNIQUE',
        },
        [],
    )

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

    await database.createTable(
        'fighters',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            name: 'VARCHAR(255) NOT NULL',
            nickname: 'VARCHAR(255) NULL',
            cityId: 'INTEGER NOT NULL',
            birthday: 'DATE NULL',
            died: 'DATE NULL',
            height: 'FLOAT NOT NULL',
            weight: 'FLOAT NOT NULL',
            link: 'VARCHAR(255) NOT NULL',
            UNIQUE: '(name)',
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
        'categories',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            name: 'VARCHAR(255) NOT NULL',
            weight: 'int NOT NULL',
            UNIQUE: '(name, weight)',
        },
        [],
    )

    await database.createTable(
        'referees',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            name: 'VARCHAR(255) NOT NULL',
            UNIQUE: '(name)',
        },
        [],
    )

    await database.createTable(
        'fights',
        {
            id: 'INTEGER PRIMARY KEY AUTOINCREMENT',
            position: 'INTEGER NOT NULL',
            categoryId: 'INTEGER NULL',
            fighterOne: 'INTEGER NOT NULL',
            fighterTwo: 'INTEGER NOT NULL',
            refereeId: 'INTEGER NULL',
            mainEvent: 'INTEGER NOT NULL DEFAULT 0',
            titleFight: 'INTEGER NOT NULL DEFAULT 0',
            type: "VARCHAR(255) NOT NULL CHECK (type IN ('pending', 'done'))",
            method: 'VARCHAR(255) NULL',
            time: 'INTEGER NULL',
            round: 'INTEGER NULL',
            decision: 'VARCHAR(255) NULL',
            eventId: 'INTEGER NULL',
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
                column: 'refereeId',
                referencedTable: 'referees',
                referencedColumn: 'id',
            },
            {
                column: 'eventId',
                referencedTable: 'events',
                referencedColumn: 'id',
            },
        ],
    )
}

async function exportData(database: Database): Promise<void> {
    const tables: string[] = [
        'countries',
        'cities',
        'locations',
        'events',
        'fighters',
        'categories',
        'referees',
        'fights',
    ]
    const promises: Promise<void>[] = tables.map(async (table: string) => {
        const rows: any[] = await database.get(table, {})
        Fs.writeFileSync(
            Path.join(__dirname, '..', 'exports', `${table}.json`),
            JSON.stringify(rows, null, 2),
        )

        const fieldSeparator: string = ';'
        const fieldScaper: string = '"'
        const csv: string[] = [Object.keys(rows[0]).map((row: string) => `${fieldScaper}${row}${fieldScaper}`).join(fieldSeparator)]

        csv.push(...rows.map((row) => {
            const columns: string[] = Object.keys(row)
            return columns.map((column: string) => {
                if(row[column] === null) {
                    return ''
                }
                return `${fieldScaper}${row[column]}${fieldScaper}`
            }).join(fieldSeparator)
        }))
        Fs.writeFileSync(
            Path.join(__dirname, '..', 'exports', `${table}.csv`),
            csv.join('\n'),
        )
    })
    console.log('exporting to JSON files')
    await Promise.all(promises)
    console.log('exported to JSON files')
}

async function main(cache: Cache, database: Database): Promise<void> {
    await dropAndCreateTables(database)

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

    for (const event of events) {
        bar.increase('categories')
        const fights: Fight[] = await sherdog.getFightsFromEvent(event)

        for (const fight of fights) {
            if (!fight.category) {
                continue
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
            const existsOne: boolean = await database.exists('fighters', {
                name: fight.fighterOne.name,
            })
            if (!existsOne) {
                const stats: Stats = await sherdog.getStatsFighter(
                    fight.fighterOne,
                )

                const existsCountry: boolean = await database.exists(
                    'countries',
                    {
                        name: stats.country,
                    },
                )
                if (!existsCountry) {
                    await database.insert('countries', {
                        name: stats.country,
                    })
                }
                const country: any = await database.getFirst('countries', {
                    name: stats.country,
                })

                const existsCity: boolean = await database.exists('cities', {
                    name: stats.city,
                    countryId: country.id,
                })
                if (!existsCity) {
                    await database.insert('cities', {
                        name: stats.city,
                        countryId: country.id,
                    })
                }
                const city: any = await database.getFirst('cities', {
                    name: stats.city,
                    countryId: country.id,
                })

                await database.insert('fighters', {
                    name: fight.fighterOne.name,
                    link: fight.fighterOne.link,
                    nickname: stats.nickname,
                    cityId: city.id,
                    birthday: stats.birthday
                        ? stats.birthday.toISOString().split('T')[0]
                        : undefined,
                    died: stats.died
                        ? stats.died.toISOString().split('T')[0]
                        : null,
                    height: stats.height,
                    weight: stats.weight,
                })
            }

            const existsTwo: boolean = await database.exists('fighters', {
                name: fight.fighterTwo.name,
            })
            if (!existsTwo) {
                const stats: Stats = await sherdog.getStatsFighter(
                    fight.fighterTwo,
                )

                const existsCountry: boolean = await database.exists(
                    'countries',
                    {
                        name: stats.country,
                    },
                )
                if (!existsCountry) {
                    await database.insert('countries', {
                        name: stats.country,
                    })
                }
                const country: any = await database.getFirst('countries', {
                    name: stats.country,
                })

                const existsCity: boolean = await database.exists('cities', {
                    name: stats.city,
                    countryId: country.id,
                })
                if (!existsCity) {
                    await database.insert('cities', {
                        name: stats.city,
                        countryId: country.id,
                    })
                }
                const city: any = await database.getFirst('cities', {
                    name: stats.city,
                    countryId: country.id,
                })

                await database.insert('fighters', {
                    name: fight.fighterTwo.name,
                    link: fight.fighterTwo.link,
                    nickname: stats.nickname,
                    cityId: city.id,
                    birthday: stats.birthday
                        ? stats.birthday.toISOString().split('T')[0]
                        : undefined,
                    died: stats.died
                        ? stats.died.toISOString().split('T')[0]
                        : null,
                    height: stats.height,
                    weight: stats.weight,
                })
            }
        }
    }
    bar.reset()

    for (const event of events) {
        bar.increase('fights')
        const fights: Fight[] = await sherdog.getFightsFromEvent(event)

        for (const fight of fights) {
            const one: any = await database.getFirst('fighters', {
                name: fight.fighterOne.name,
            })
            const two: any = await database.getFirst('fighters', {
                name: fight.fighterTwo.name,
            })

            let category: any | undefined = undefined
            if (fight.category) {
                const weight: number =
                    fight.category.weight || weights[fight.category.name]
                category = await database.getFirst('categories', {
                    name: fight.category.name,
                    weight,
                })
            }

            const savedEvent: any = await database.getFirst('events', {
                name: event.name,
            })

            if (fight.type === 'done') {
                const referee: any = await database.getFirst('referees', {
                    name: fight.referee,
                })

                await database.insert('fights', {
                    categoryId: category ? category.id : null,
                    position: fight.position,
                    fighterOne: one.id,
                    fighterTwo: two.id,
                    refereeId: referee.id,
                    mainEvent: fight.mainEvent ? 1 : 0,
                    titleFight: fight.titleFight ? 1 : 0,
                    type: fight.type,
                    method: fight.method,
                    time: fight.time,
                    round: fight.round,
                    decision: fight.decision,
                    eventId: savedEvent.id,
                })
            } else {
                await database.insert('fights', {
                    categoryId: category ? category.id : null,
                    position: fight.position,
                    fighterOne: one.id,
                    fighterTwo: two.id,
                    mainEvent: fight.mainEvent ? 1 : 0,
                    titleFight: fight.titleFight ? 1 : 0,
                    type: fight.type,
                    eventId: savedEvent.id,
                })
            }
        }
    }
    bar.reset()

    const fighters: any[] = await database.get('fighters', {})
    const bar2: ProgressBar = new ProgressBar(fighters.length)
    for (const fighter of fighters) {
        bar2.increase('no event fights')
        const fights: NoEventFight[] =
            await sherdog.getFightsFromFighter(fighter)
        for (const fight of fights) {
            // const exists: boolean = await database.exists('fights', {
            //     fighterOne: fighter.id,
            //     fighterTwo: fight.fighter.name,
            //     type: 'done',
            // })
            // if (!exists) {
            //     const opponent: any = await database.getFirst('fighters', {
            //         name: fight.fighter.name,
            //     })
            //     await database.insert('fights', {
            //         fighterOne: fighter.id,
            //         fighterTwo: opponent.id,
            //         refereeId: null,
            //         mainEvent: 0,
            //         titleFight: 0,
            //         type: 'done',
            //         decision: fight.decision,
            //         method: fight.method,
            //         time: fight.time,
            //         round: fight.round,
            //     })
            // }
        }
    }
    bar2.reset()

    console.log('Done')
}

const cachePath: string = Path.join(__dirname, '..', '.cache.json')
const cache: Cache = new FileCache(cachePath)
console.log(`${cache.keysCount()} keys in cache`)

const databasePath: string = Path.join(__dirname, '..', 'database.sqlite')
const database: Database = new SQLite(databasePath)

// exportData(database).catch(console.error)

main(cache, database)
    .then(() => exportData(database))
    .catch(console.error)
