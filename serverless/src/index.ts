import { Cache } from "./libraries/cache";
import Path from 'node:path';
import { FileCache } from "./libraries/cache/file-cache";

const cachePath: string = Path.join(__dirname, '..', 'assets', 'cache.json');
const cache: Cache = new FileCache(cachePath);
console.log('loaded');
