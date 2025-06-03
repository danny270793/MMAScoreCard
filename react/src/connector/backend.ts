export class Backend {
    static async getEvents(): Promise<string[]> {
        return new Promise((resolve) => {
            setTimeout(() => resolve(['Event 1', 'Event 2', 'Event 3', 'Event 4']), 1000);
        });
    }
}
