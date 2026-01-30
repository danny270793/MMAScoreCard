export class StringUtils {
  static capitalize(s: string) {
    return s.replace(/\p{L}/u, (c: string) => c.toUpperCase())
  }
  static upper(s: string) {
    return s.toUpperCase()
  }
}
