import type { Event } from "./models/event";

export class Backend {
    static async getEvents(): Promise<Event[]> {
        return new Promise((resolve) => {
            setTimeout(() => resolve([{id: '1', name: 'UFC 300', fight: 'Alex Perira vs Israel Adesanya'}]), 1000);
        });
    }
}
