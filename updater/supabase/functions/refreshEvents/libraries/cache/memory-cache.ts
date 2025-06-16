import { Cache } from "./index.ts";

export class MemoryCache implements Cache {
  private data: any = {};

  keysCount(): number {
    return Object.keys(this.data).length;
  }
  has(key: string): boolean {
    return this.data.hasOwnProperty(key);
  }
  get(key: string): any {
    return this.data[key];
  }
  set(key: string, value: any): void {
    this.data[key] = value;
  }
}
