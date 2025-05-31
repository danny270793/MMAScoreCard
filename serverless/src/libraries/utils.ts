export class Utils {
    static parseCompactDate(input: string): Date | null {
        const match = input.match(/^([A-Za-z]{3})(\d{2})(\d{4})$/)
        if (!match) return null

        const [_, monthStr, dayStr, yearStr] = match
        const date = new Date(`${monthStr} ${dayStr}, ${yearStr}`)
        return isNaN(date.getTime()) ? null : date
    }
}
