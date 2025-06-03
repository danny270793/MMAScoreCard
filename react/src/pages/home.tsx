import type { Dispatch } from "@reduxjs/toolkit";
import { useEffect, type FC } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
  actions as backnedActions,
  selectors as backendSelectors,
} from "../reducers/backned";

export const Home: FC = () => {
  const dispatch: Dispatch = useDispatch();

  useEffect(() => {
    dispatch(backnedActions.getEvents());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const events: string[] = useSelector(backendSelectors.getEvents);
  const error: Error | undefined = useSelector(backendSelectors.getError);
  const state: string = useSelector(backendSelectors.getState);

  return (
    <>
      {state === "getting_events" && <div>Loading events...</div>}
      {state === "getting_events_error" && (
        <div>Error loading events: {error?.message}</div>
      )}
      {state === "getting_events_success" && (
        <ul>
          {events.map((event) => (
            <li key={event}>{event}</li>
          ))}
        </ul>
      )}
    </>
  );
};
