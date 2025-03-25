import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Event, Sherdog } from "../services/sherdog";

const EventsPage = () => {
  const [events, setEvents] = useState<Event[]>([])

  const init = async () => {
    const events: Event[] = await Sherdog.getEvents()
    setEvents(events)
  }

  useEffect(() => {
    init()
  }, [])

  return (
    <div>
      <h2>Events</h2>
      <ul>
        {events.map((event: Event, index: number) => (
          <li key={index}>
            {event.figth && <div>
              {event.figth}
            </div>}
            <div>
              {event.name}
            </div>
            <div>
              {event.date.toISOString().split('T')[0]}
            </div>
            <Link to={`/events/${event.name}`}>
              see more
            </Link>
          </li>
        ))}
      </ul>
    </div>
  );
};

export default EventsPage;
