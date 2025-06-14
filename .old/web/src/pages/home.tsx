import { Link } from "react-router-dom";

const Home = () => {
  return (
    <ul>
      <li>
        <Link to="/events">
          Events
        </Link>
      </li>
    </ul>
  );
};

export default Home;
