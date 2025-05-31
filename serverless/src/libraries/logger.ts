export class Logger {
    private name: string
    constructor(name: string) {
        this.name = name
    }
    write(tag: 'ERROR' | 'DEBUG', message: string): void {
        const output: string = `${new Date()} ${tag} ${this.name} ${message}`
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
