import type { Dispatch } from '@reduxjs/toolkit'
import { useEffect, type FC } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import type { Event } from '../models/event'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faLocation,
  faMap,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'

export const Home: FC = () => {
  const dispatch: Dispatch = useDispatch()

  useEffect(() => {
    dispatch(backendActions.getEvents())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const events: Event[] = useSelector(backendSelectors.getEvents)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  return (
    <>
      {state === 'getting_events' && <div>Loading events...</div>}
      {state === 'getting_events_error' && (
        <div>Error loading events: {error?.message}</div>
      )}
      {state === 'getting_events_success' && (
        <ul>
          {events.map((event: Event) => (
            <li className="border-b border-gray-200" key={event.id}>
              {event.status === 'uppcoming' && (
                <div className="float-right">
                  <div className="text-sm bg-red-500 p-1 text-white">
                    {event.status}
                  </div>
                </div>
              )}
              <div className=" py-4 px-4">
                <div className="font-bold">{event.name}</div>
                {event.fight && (
                  <>
                    <div className="text-sm text-gray-500">{event.fight}</div>
                  </>
                )}
                <br />
                <div>
                  <FontAwesomeIcon icon={faCalendar} />{' '}
                  <span className="text-sm text-gray-500">
                    {event.date.toISOString().split('T')[0]}
                  </span>{' '}
                  <span className="text-sm text-gray-500">
                    (in {DateUtils.daysBetween(event.date, new Date())} days)
                  </span>
                </div>
                <div>
                  <FontAwesomeIcon icon={faMap} />{' '}
                  <span className="text-sm text-gray-500">
                    {event.location.city.country.name} -{' '}
                    {event.location.city.name}
                  </span>
                </div>
                {event.location.name !== '' && (
                  <div>
                    <FontAwesomeIcon icon={faLocation} />{' '}
                    <span className="text-sm text-gray-500">
                      {event.location.name}
                    </span>
                  </div>
                )}
              </div>
            </li>
          ))}
        </ul>
      )}
    </>
  )
}
