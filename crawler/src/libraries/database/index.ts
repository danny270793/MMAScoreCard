interface Relationship {
    column: string
    referencedTable: string
    referencedColumn: string
}

export interface Database {
    dropTable(name: string): Promise<void>
    createTable(
        name: string,
        columns: Record<string, string>,
        references: Relationship[],
    ): Promise<void>
    exists(table: string, conditions: Record<string, any>): Promise<boolean>
    get<T>(table: string, conditions: Record<string, string>): Promise<T[]>
    getFirst<T>(table: string, conditions: Record<string, any>): Promise<T>
    insert(table: string, data: Record<string, any>): Promise<void>
}
