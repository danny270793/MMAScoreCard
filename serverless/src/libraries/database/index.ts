import sqlite3 from 'sqlite3'
import { Logger } from '../logger'

const logger = new Logger('/src/libraries/database/index.ts')

export class Database {
    private path: string
    private database: sqlite3.Database
    constructor(path: string) {
        this.path = path
        this.database = new sqlite3.Database(this.path)
    }
    dropTable(name: string): Promise<void> {
        return new Promise((resolve, reject) => {
            const sql: string = `DROP TABLE IF EXISTS ${name}`
            logger.debug(sql)
            this.database.run(sql, (error) => {
                if (error) {
                    reject(error)
                } else {
                    resolve()
                }
            })
        })
    }
    async createTable(
        name: string,
        columns: Record<string, string>,
    ): Promise<void> {
        const columnsDefinition = Object.entries(columns)
            .map(([column, type]) => `${column} ${type}`)
            .join(', ')

        return new Promise((resolve, reject) => {
            const sql: string = `CREATE TABLE IF NOT EXISTS ${name} (${columnsDefinition})`
            logger.debug(sql)
            this.database.run(sql, (error) => {
                if (error) {
                    reject(error)
                } else {
                    resolve()
                }
            })
        })
    }
    exists(
        table: string,
        conditions: Record<string, string>,
    ): Promise<boolean> {
        const whereClause = Object.entries(conditions)
            .map(([column, value]) => `${column} = ?`)
            .join(' AND ')
        const values = Object.values(conditions)
        return new Promise((resolve, reject) => {
            const sql: string = `SELECT COUNT(*) as count FROM ${table} WHERE ${whereClause}`
            logger.debug(sql)
            this.database.get(sql, values, (error: Error, row: any) => {
                if (error) {
                    reject(error)
                } else {
                    resolve(row.count > 0)
                }
            })
        })
    }
    get<T>(table: string, conditions: Record<string, string>): Promise<T[]> {
        const whereClause = Object.entries(conditions)
            .map(([column, value]) => `${column} = ?`)
            .join(' AND ')
        const values = Object.values(conditions)
        return new Promise((resolve, reject) => {
            const sql: string = `SELECT * FROM ${table} WHERE ${whereClause}`
            logger.debug(sql)
            this.database.all(sql, values, (error: Error, rows: T[]) => {
                if (error) {
                    reject(error)
                } else {
                    resolve(rows)
                }
            })
        })
    }
    async getFirst<T>(
        table: string,
        conditions: Record<string, string>,
    ): Promise<T> {
        const rows: T[] = await this.get<T>(table, conditions)
        return rows[0]
    }
    insert(table: string, data: Record<string, any>): Promise<void> {
        const columns = Object.keys(data).join(', ')
        const placeholders = Object.keys(data)
            .map(() => '?')
            .join(', ')
        const values = Object.values(data)

        return new Promise((resolve, reject) => {
            const sql: string = `INSERT INTO ${table} (${columns}) VALUES (${placeholders})`
            logger.debug(sql)
            this.database.run(sql, values, (error) => {
                if (error) {
                    reject(error)
                } else {
                    resolve()
                }
            })
        })
    }
}
