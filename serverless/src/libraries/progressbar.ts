export class ProgressBar {
    private total: number
    private current: number
    constructor(total: number) {
        this.total = total
        this.current = 0
    }
    public increase(label: string): void {
        this.current += 1
        this.render(label)
    }
    public reset(): void {
        this.current = 0
        console.log('')
    }
    public render(label: string): void {
        const percentage: number = (this.current / this.total) * 100
        const filledLength: number = Math.round((percentage / 100) * 20)
        const bar: string =
            '█'.repeat(filledLength) + '-'.repeat(20 - filledLength)
        process.stdout.write(
            `\r${label}: [${bar}] ${percentage.toFixed(2)}% (${this.current}/${this.total})`,
        )
    }
}
