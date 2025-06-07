import type { Dispatch } from '@reduxjs/toolkit'
import { useEffect, useState, type ChangeEvent, type FC } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import type { Event } from '../models/event'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faClose,
  faLocation,
  faMap,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'
import { useTranslation } from 'react-i18next'
import { Modal } from '../components/modal'

export const Home: FC = () => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()
  const [filter, setFilter] = useState<string>('')
  const [showFilter, setShowFilter] = useState<boolean>(false)

  useEffect(() => {
    dispatch(backendActions.getEvents())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  const events: Event[] = useSelector(backendSelectors.getEvents)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const onCloseErrorModalClicked = () => {
    dispatch(backendActions.clearError())
  }

  return (
    <>
      {state === 'getting_events_error' && (
        <Modal
          type="error"
          title={t('error', { postProcess: 'capitalize' })}
          onClose={onCloseErrorModalClicked}
        >
          {error?.message}
        </Modal>
      )}
      <div className="fixed top-0 left-0 navbar bg-base-100 shadow-sm z-100">
        <div className="flex-1">
          {t('events', { postProcess: 'capitalize' })}
        </div>
        <div className="flex gap-2">
          {showFilter && (
            <div className="join">
              <label className="input">
                <svg
                  className="h-[1em] opacity-50"
                  xmlns="http://www.w3.org/2000/svg"
                  viewBox="0 0 24 24"
                >
                  <g
                    strokeLinejoin="round"
                    strokeLinecap="round"
                    strokeWidth="2.5"
                    fill="none"
                    stroke="currentColor"
                  >
                    <circle cx="11" cy="11" r="8"></circle>
                    <path d="m21 21-4.3-4.3"></path>
                  </g>
                </svg>
                <input
                  type="search"
                  required
                  value={filter}
                  onChange={(e: ChangeEvent<HTMLInputElement>) =>
                    setFilter(e.target.value)
                  }
                  placeholder={t('search', { postProcess: 'capitalize' })}
                />
              </label>
              <button
                className="btn btn-neutral join-item"
                onClick={() => setShowFilter(false)}
              >
                <FontAwesomeIcon icon={faClose} />
              </button>
            </div>
          )}
          {!showFilter && (
            <button
              className="btn btn-ghost btn-circle"
              onClick={() => setShowFilter(true)}
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                className="h-5 w-5"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                {' '}
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth="2"
                  d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z"
                />{' '}
              </svg>
            </button>
          )}
        </div>
      </div>
      <br />
      <br />
      <br />

      <ul className="list max-w-xl mx-auto bg-base-100">
        {state === 'getting_events' &&
          [1, 2, 3, 4, 5, 6, 7].map((i: number) => (
            <li className="list-row" key={i}>
              <div className="list-col-grow">
                <div className="flex flex-col gap-4">
                  <div className="skeleton h-2 w-64 shrink-0" />
                  <br />
                  <div className="skeleton h-2 w-48 shrink-0" />
                  <div className="skeleton h-2 w-48 shrink-0" />
                  <div className="skeleton h-2 w-48 shrink-0" />
                </div>
              </div>
            </li>
          ))}
        {state === 'getting_events_success' &&
          events
            .filter(
              (event: Event) =>
                event.name.toLowerCase().includes(filter.toLowerCase()) ||
                event.fight?.toLowerCase().includes(filter.toLowerCase()) ||
                event.location?.name
                  .toLowerCase()
                  .includes(filter.toLowerCase()) ||
                event.location?.city.name
                  .toLowerCase()
                  .includes(filter.toLowerCase()) ||
                event.location?.city.country.name
                  .toLowerCase()
                  .includes(filter.toLowerCase()),
            )
            .map((event: Event) => (
              <li className="list-row" key={event.id}>
                <div className="list-col-grow">
                  <div>{event.name}</div>
                  {event.fight && (
                    <>
                      <div className="font-semibold opacity-60">
                        {event.fight}
                      </div>
                    </>
                  )}
                  <br />
                  <div>
                    <FontAwesomeIcon className="w-4" icon={faCalendar} />{' '}
                    <span className="opacity-60">
                      {event.date.toISOString().split('T')[0]}
                    </span>{' '}
                    <span className="opacity-60">
                      {t('inXXDays', {
                        days: DateUtils.daysBetween(event.date, new Date()),
                      })}
                    </span>
                  </div>
                  <div>
                    <FontAwesomeIcon className="w-4" icon={faMap} />{' '}
                    <span className=" opacity-60">
                      {event.location.city.country.name} -{' '}
                      {event.location.city.name}
                    </span>
                  </div>
                  <div>
                    {event.location.name !== '' && (
                      <>
                        <FontAwesomeIcon className="w-4" icon={faLocation} />{' '}
                        <span className="opacity-60">
                          {event.location.name}
                        </span>
                      </>
                    )}
                  </div>
                </div>
                {event.status === 'uppcoming' && (
                  <div className="badge badge-dash badge-error">
                    <div>{t('upcoming', { postProcess: 'capitalize' })}</div>
                  </div>
                )}
              </li>
            ))}
      </ul>
    </>
  )
}
