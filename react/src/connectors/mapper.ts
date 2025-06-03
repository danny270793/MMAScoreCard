import type { Event } from "../models/event";
import type { Event as BackendEvent } from "./backend/models/event";

export const mapper = {
    toEvent(event: BackendEvent): Event {
        return {
            id: event.id,
            name: event.name,
            fight: event.fight,
        };
    }
}
