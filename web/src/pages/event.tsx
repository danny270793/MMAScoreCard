import { useParams } from "react-router-dom";
import { Event, Fight, Sherdog } from "../services/sherdog";
import { useEffect, useState } from "react";

const EventPage = () => {
  const { name } = useParams();

  const [fights, setFights] = useState<Fight[]>([])

  const init = async () => {
    const event: Event = await Sherdog.getEvent(name!)
    const fights: Fight[] = await Sherdog.getFights(event)
    setFights(fights)
  }

  useEffect(() => {
    init()
  }, [])

  return (
    <div>
      <h2>Event {name}</h2>
            <ul>
              {fights.map((fight: Fight, index: number) => (
                <li key={index}>
                  <div>
                  {fight.fighter1.name} vs {fight.fighter2.name}
                  </div>
                  <div>
                  {fight.division}
                  </div>
                  <div>
                  {fight.method} - {fight.referee}
                  </div>
                  <div>
                  Round {fight.round} at {fight.time}
                  </div>
                </li>
              ))}
            </ul>
    </div>
  );
};

export default EventPage;
