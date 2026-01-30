export class DateUtils {
  static secondsToHHMMSS(seconds: number): string {
    const hours: number = Math.floor(seconds / 3600)
    const minutes: number = Math.floor((seconds % 3600) / 60)
    const secs: number = seconds % 60

    const paddedHours: string = String(hours).padStart(2, '0')
    const paddedMinutes: string = String(minutes).padStart(2, '0')
    const paddedSeconds: string = String(secs).padStart(2, '0')

    return `${paddedHours}h${paddedMinutes}m${paddedSeconds}s`
  }
  static daysBetween(date1: Date, date2: Date): number {
    const diffTime: number = Math.abs(date2.getTime() - date1.getTime())
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24))
  }
  static secondsToMMSS(totalSeconds: number): string {
    const minutes: number = Math.floor(totalSeconds / 60)
    const seconds: number = totalSeconds % 60

    const paddedMinutes: string = String(minutes).padStart(2, '0')
    const paddedSeconds: string = String(seconds).padStart(2, '0')

    return `${paddedMinutes}:${paddedSeconds}`
  }
}
