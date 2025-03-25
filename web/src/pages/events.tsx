import { Link } from "react-router-dom";

const Events = () => {
  return (
    <div>
      <h2>Events</h2>
      <ul>
        <li>
          <Link to="/events/1">
            Event 1
          </Link>
        </li>
      </ul>
    </div>
  );
};

export default Events;
