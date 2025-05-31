import Fs from 'fs'
import { Cache } from '.'

export class FileCache implements Cache {
    private path: string
    private data: any

    constructor(path: string) {
        this.path = path

        if (!Fs.existsSync(path)) {
            Fs.writeFileSync(path, JSON.stringify({}, null, 2), 'utf8')
        }

        const content: string = Fs.readFileSync(path, 'utf8')
        this.data = JSON.parse(content)
    }
    has(key: string): boolean {
        return this.data.hasOwnProperty(key)
    }
    get(key: string): any {
        return this.data[key]
    }
    set(key: string, value: any): void {
        this.data[key] = value
        Fs.writeFileSync(this.path, JSON.stringify(this.data, null, 2), 'utf8')
    }
}
