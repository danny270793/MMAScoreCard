export class Utils {
  static toYYYYMMDDHHMMSSUUUU(date: Date): string {
    const pad = (n: number, len = 2) => n.toString().padStart(len, "0");

    const year: number = date.getFullYear();
    const month: string = pad(date.getMonth() + 1); // Months are 0-based
    const day: string = pad(date.getDate());

    const hours: string = pad(date.getHours());
    const minutes: string = pad(date.getMinutes());
    const seconds: string = pad(date.getSeconds());

    const milliseconds: string = pad(date.getMilliseconds(), 3); // 3 digits
    const microseconds: string = pad(parseInt(milliseconds) * 1000, 4); // Simulate UUUU

    return `${year}/${month}/${day} ${hours}:${minutes}:${seconds}.${microseconds}`;
  }
  static timeToSeconds(input: string): number {
    const match = input.match(/^(\d{1,2}):(\d{2})$/);
    if (!match) return 0;
    const [_, minutesStr, secondsStr] = match;
    const minutes = parseInt(minutesStr, 10);
    const seconds = parseInt(secondsStr, 10);
    return minutes * 60 + seconds;
  }
  static parseCompactDate(input: string): Date | null {
    const match = input.match(/^([A-Za-z]{3})(\d{2})(\d{4})$/);
    if (!match) return null;

    const [_, monthStr, dayStr, yearStr] = match;
    const date = new Date(`${monthStr} ${dayStr}, ${yearStr}`);
    return isNaN(date.getTime()) ? null : date;
  }
  static parseDate(input: string): Date | null {
    const match = input.match(/([A-Za-z]{3} \d{1,2}, \d{4})/);
    if (!match) return null;

    const date = new Date(match[1]);
    return isNaN(date.getTime()) ? null : date;
  }
}
