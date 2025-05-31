export class Utils {
    static timeToSeconds(input: string): number {
        const match = input.match(/^(\d{1,2}):(\d{2})$/)
        if (!match) return 0
        const [_, minutesStr, secondsStr] = match
        const minutes = parseInt(minutesStr, 10)
        const seconds = parseInt(secondsStr, 10)
        return minutes * 60 + seconds
    }
    static parseCompactDate(input: string): Date | null {
        const match = input.match(/^([A-Za-z]{3})(\d{2})(\d{4})$/)
        if (!match) return null

        const [_, monthStr, dayStr, yearStr] = match
        const date = new Date(`${monthStr} ${dayStr}, ${yearStr}`)
        return isNaN(date.getTime()) ? null : date
    }
}
