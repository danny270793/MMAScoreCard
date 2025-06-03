import type { Event } from "./models/event";
import Events from './assets/events.json'
export class Backend {
    static async getEvents(): Promise<Event[]> {
        return Events.map((event: any) => event as Event);
    }
}
