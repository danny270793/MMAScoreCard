import Fs from 'node:fs'
import { Cache } from '.'

export class FileCache implements Cache {
    private path: string
    private cachedData: {[key: string]: string} = {}
    constructor(path: string) {
        this.path = path
        this.loadCachedData()
    }
    loadCachedData(): void {
        if(!Fs.existsSync(this.path)) {
            return this.saveCachedData()
        }

        const buffer: Buffer = Fs.readFileSync(this.path)
        const text: string = buffer.toString()
        this.cachedData = JSON.parse(text)
    }
    saveCachedData(): void {
        const json: any = JSON.stringify(this.cachedData)
        Fs.writeFileSync(this.path, json)
    }
    async has(key: string): Promise<boolean> {
        return this.cachedData[key] !== undefined
    }
    async get(key: string): Promise<string|null> {
        return this.cachedData[key]
    }
    async set(key: string, value: string): Promise<void> {
        this.cachedData[key] = value
        this.saveCachedData()
    }
}
