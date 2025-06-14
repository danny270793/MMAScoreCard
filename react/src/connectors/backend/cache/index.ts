export interface Cache {
  has(key: string): Promise<boolean>
  get(key: string): Promise<string>
  set(key: string, value: unknown): Promise<void>
}
