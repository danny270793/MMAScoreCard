import { useEffect, useState } from "react";
import { Link } from "react-router-dom";
import { Event, Sherdog } from "../services/sherdog";
import { Loader } from "../component/loader";
import { Appbar } from "../component/appbar";

const EventsPage = () => {
  const [loading, setLoading] = useState<boolean>(true)
  const [events, setEvents] = useState<Event[]>([])
  const [error, setError] = useState<string|undefined>(undefined)

  const init = async () => {
    setLoading(true)
    try {
      const events: Event[] = await Sherdog.getEvents()
      setEvents(events)
    } catch(error) {
      console.error(error)
      setError('Error getting events')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    init()
  }, [])

  return (
    <>
      <Appbar title="Events"/>
      {error && <div className="w3-modal" style={{display: 'block'}}>
        <div className="w3-modal-content w3-card-4">
          <div className="w3-container">
            <span onClick={() => setError(undefined)} className="w3-button w3-display-topright w3-red">
              &times;
            </span>
            <h1>
              Error
            </h1>
            <div>
              {error}
            </div>
            <br/>
          </div>
        </div>
      </div>}
      <div className="w3-padding">
        {loading && <Loader/>}
        <ul className="w3-ul w3-card-4 w3-white w3-hoverable">
          {events.length === 0 && <li>
            No events yet
          </li>}
          {events.map((event: Event, index: number) => (
            <li key={index}>
              <Link to={`/events/${event.name}`} style={{textDecoration: 'none'}}>
                <div>
                  {event.figth && event.figth}
                  {!event.figth && event.name}
                </div>
                {event.figth && <div>
                  {event.name}
                </div>}
                <div>
                  {event.date.toISOString().split('T')[0]}
                </div>
              </Link>
            </li>
          ))}
        </ul>
      </div>
    </>
  );
};

export default EventsPage;
