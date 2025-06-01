import { Utils } from './utils'

export class Logger {
    private name: string
    private enable: boolean
    constructor(name: string, enable: boolean = true) {
        this.name = name
        this.enable = enable
    }
    write(tag: 'ERROR' | 'DEBUG', message: string): void {
        if (!this.enable) {
            return
        }

        const output: string = `${Utils.toYYYYMMDDHHMMSSUUUU(new Date())} ${tag} ${this.name} ${message}`
        if (tag === 'ERROR') {
            console.error(output)
        } else {
            console.log(output)
        }
    }
    debug(message: string): void {
        this.write('DEBUG', message)
    }
    error(message: string, error?: Error): void {
        if (error) {
            console.error(error)
        }
        this.write('ERROR', message)
    }
}
