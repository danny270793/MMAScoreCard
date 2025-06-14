import type { Dispatch } from '@reduxjs/toolkit'
import {
  Link,
  List,
  ListItem,
  Navbar,
  NavRight,
  Page,
  Searchbar,
  f7,
  Toolbar,
} from 'framework7-react'
import { useEffect, type FC } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useTranslation } from 'react-i18next'
import { EmptyEvent, type Event } from '../models/event'
import { Faker } from '../utils/faker'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faLocation,
  faMap,
  faSearch,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'

export const EventsPage: FC = () => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

  const events: Event[] = useSelector(backendSelectors.getEvents)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const onPullRefreshed = async (done: () => void) => {
    dispatch(backendActions.getEvents())
    done()
  }

  useEffect(() => {
    dispatch(backendActions.getEvents())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    if (!error) {
      return
    }

    console.error(error)
    f7.dialog.alert(
      error?.message || t('unknownError', { postProcess: 'capitalize' }),
      () => {
        dispatch(backendActions.clearError())
      },
    )
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [error])

  return (
    <Page ptr ptrMousewheel={true} onPtrRefresh={onPullRefreshed}>
      <Navbar title={t('events', { postProcess: 'capitalize' })} large>
        <NavRight>
          <Link searchbarEnable=".searchbar">
            <FontAwesomeIcon icon={faSearch} />
          </Link>
        </NavRight>
        <Searchbar
          className="searchbar"
          expandable
          placeholder={t('search', { postProcess: 'capitalize' })}
          disableButtonText={t('cancel', { postProcess: 'capitalize' })}
          searchContainer=".search-list"
          searchIn=".item-title, .item-subtitle"
        />
      </Navbar>
      <List
        className="searchbar-not-found"
        dividersIos
        mediaList
        strongIos
        inset
      >
        <ListItem
          subtitle={t('eventsNotFound', { postProcess: 'capitalize' })}
        />
      </List>
      <List
        className="search-list searchbar-found"
        dividersIos
        mediaList
        strongIos
        inset
      >
        {state === 'getting_events' &&
          Faker.arrayOfNumbers(5).map((i: number) => (
            <ListItem
              className="skeleton-text skeleton-effect-wave"
              title={EmptyEvent.name}
              subtitle={EmptyEvent.fight}
              key={`skeleton-${i}`}
              after={'uppcoming'}
            >
              <br />
              <div>
                {EmptyEvent.date.toISOString().split('T')[0]}
                {' in 34 days'}
              </div>
              <div>
                {EmptyEvent.location.city.country.name} -{' '}
                {EmptyEvent.location.city.name}
              </div>
              <div>
                {EmptyEvent.location.name !== '' && EmptyEvent.location.name}
              </div>
            </ListItem>
          ))}
        {state !== 'getting_events' && events.length === 0 && (
          <ListItem
            subtitle={t('eventsNotFound', { postProcess: 'capitalize' })}
          />
        )}
        {state !== 'getting_events' &&
          events.map((event: Event) => (
            <ListItem
              title={event.name}
              subtitle={event.fight}
              key={event.id}
              link={`/events/${event.id}`}
              chevronCenter
              after={
                event.status === 'uppcoming'
                  ? t('upcoming', { postProcess: 'capitalize' })
                  : ''
              }
            >
              <br />
              <div>
                <FontAwesomeIcon className="w-4" icon={faCalendar} />{' '}
                <span className="opacity-60">
                  {event.date.toISOString().split('T')[0]}
                </span>{' '}
                {event.status === 'uppcoming' && (
                  <span className="opacity-60">
                    {t('inXXDays', {
                      days: DateUtils.daysBetween(event.date, new Date()),
                    })}
                  </span>
                )}
              </div>
              <div>
                <FontAwesomeIcon className="w-4" icon={faMap} />{' '}
                <span className="opacity-60">
                  {event.location.city.country.name} -{' '}
                  {event.location.city.name}
                </span>
              </div>
              <div>
                {event.location.name !== '' && (
                  <>
                    <FontAwesomeIcon className="w-4" icon={faLocation} />{' '}
                    <span className="opacity-60">{event.location.name}</span>
                  </>
                )}
              </div>
            </ListItem>
          ))}
      </List>
      <Toolbar bottom>
        <div />
        {state === 'getting_events' && (
          <div className="skeleton-text skeleton-effect-wave">
            {t('eventsCounter', { events: 0 })}
          </div>
        )}
        {state !== 'getting_events' && (
          <div>{t('eventsCounter', { events: events.length })}</div>
        )}
        <div />
      </Toolbar>
    </Page>
  )
}
