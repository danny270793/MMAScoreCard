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
import { useTranslation } from 'react-i18next'
import { Loader } from '../components/loader'
import { Modal } from '../components/modal'

export const Home: FC = () => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

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
      {state === 'getting_events' && <Loader />}
      {state === 'getting_events_error' && (
        <Modal
          type="error"
          title={t('error', { postProcess: 'capitalize' })}
          onClose={onCloseErrorModalClicked}
        >
          {error?.message}
        </Modal>
      )}
      {state === 'getting_events_success' && (
        <ul className="list max-w-xl mx-auto bg-base-100">
          {events.map((event: Event) => (
            <li className="list-row" key={event.id}>
              <div className="list-col-grow">
                <div>{event.name}</div>
                {event.fight && (
                  <>
                    <div className="text-xs font-semibold opacity-60">
                      {event.fight}
                    </div>
                  </>
                )}
                <br />
                <div className="text-xs">
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
                <div className="text-xs">
                  <FontAwesomeIcon className="w-4" icon={faMap} />{' '}
                  <span className=" opacity-60">
                    {event.location.city.country.name} -{' '}
                    {event.location.city.name}
                  </span>
                </div>
                {event.location.name !== '' && (
                  <div className="text-xs">
                    <FontAwesomeIcon className="w-4" icon={faLocation} />{' '}
                    <span className="opacity-60">{event.location.name}</span>
                  </div>
                )}
              </div>
              {event.status === 'uppcoming' && (
                <div className="badge badge-dash badge-error">
                  <div>{t('upcoming', { postProcess: 'capitalize' })}</div>
                </div>
              )}
            </li>
          ))}
        </ul>
      )}
    </>
  )
}
