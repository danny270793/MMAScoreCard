export class Faker {
  static numberBetween(min: number, max: number): number {
    return Math.floor(Math.random() * (max - min + 1)) + min
  }
  static arrayOf<T>(length: number, generator: () => T): T[] {
    return Array.from({ length }, generator)
  }
  static arrayOfNumbers(length: number): number[] {
    return Faker.arrayOf(length, () => Faker.numberBetween(1, 100))
  }
}
