type LogType = 'debug' | 'error'

export class Logger {
  private name: string
  constructor(name: string) {
    this.name = name
  }
  write(type: LogType, message: string): void {
    if (import.meta.env.MODE === 'development') {
      const text: string = `${this.name} ${type} ${message}`
      if (type === 'error') {
        console.error(text)
      } else {
        console.log(text)
      }
    }
  }
  debug(message: string): void {
    this.write('debug', message)
  }
  error(message: string, error: Error | undefined = undefined): void {
    this.write('error', message)
    if (error) {
      console.error(error)
    }
  }
}
