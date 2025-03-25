import { Link, useParams } from "react-router-dom";
import { Event, Fight, Sherdog } from "../services/sherdog";
import { useEffect, useState } from "react";
import { Loader } from "../component/loader";
import { Appbar } from "../component/appbar";

const EventPage = () => {
  const { name } = useParams();
  const [loading, setLoading] = useState<boolean>(true)
  const [error, setError] = useState<string|undefined>(undefined)

  const [event, setEvent] = useState<Event|undefined>(undefined)
  const [fights, setFights] = useState<Fight[]>([])

  const init = async () => {
    setLoading(true)
    try {
      const event: Event = await Sherdog.getEvent(name!)
      setEvent(event)

      const fights: Fight[] = await Sherdog.getFights(event)
      setFights(fights)
    } catch(error) {
      console.error(error)
      setError('Error getting fights')
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    init()
  }, [])

  return (
    <>
      <Appbar title={name!}/>
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
        {!loading && <>
          <h5>
            Event
          </h5>
          <div className="w3-card-4 w3-white">
            <form className="w3-padding">
              <label>
                Name
              </label>
              <input className="w3-input w3-border" type="text" value={event!.name} disabled/>
              {event?.figth && <>
                <label>
                  Fight
                </label>
                <input className="w3-input w3-border" type="text" value={event!.figth!} disabled/>
              </>}
              <label>
                Location
              </label>
              <input className="w3-input w3-border" type="text" value={event!.location} disabled/>
              <label>
                Date
              </label>
              <input className="w3-input w3-border" type="text" value={event!.date.toISOString().split('T')[0]} disabled/>
            </form>
          </div>

          <h5>
            Fights
          </h5>
          <ul className="w3-ul w3-card-4 w3-white w3-hoverable">
            {fights.length === 0 && <li>
              No fights yet
            </li>}
          {fights.map((fight: Fight, index: number) => (
            <li key={index}>
              <Link to={`/events/${event!.name}`} style={{textDecoration: 'none'}}>
                <div>
                  {fight.fighter1.name} vs {fight.fighter2.name}
                </div>
                <div>
                  {fight.method}
                </div>
                <div>
                  Round {fight.round} at {fight.time}
                </div>
                <div>
                  {fight.division}
                </div>
              </Link>
            </li>
          ))}
        </ul>
        </>}
      </div>
    </>
  );
};

export default EventPage;
