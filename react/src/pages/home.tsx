import type { Dispatch } from "@reduxjs/toolkit";
import { useEffect, type FC } from "react";
import { useDispatch, useSelector } from "react-redux";
import {
  actions as backendActions,
  selectors as backendSelectors,
} from "../reducers/backend";
import type { Event } from "../models/event";

export const Home: FC = () => {
  const dispatch: Dispatch = useDispatch();

  useEffect(() => {
    dispatch(backendActions.getEvents());
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const events: Event[] = useSelector(backendSelectors.getEvents);
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
          {events.map((event: Event) => (
            <li key={event.id}>
              {event.name} {event.fight && `- ${event.fight}`}
            </li>
          ))}
        </ul>
      )}
    </>
  );
};
