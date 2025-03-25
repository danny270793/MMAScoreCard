import { useParams } from "react-router-dom";

const Event = () => {
  const { id } = useParams();

  return (
    <div>
      <h2>Event {id}</h2>
    </div>
  );
};

export default Event;
