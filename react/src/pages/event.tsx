import { BlockTitle, f7, List, ListItem, Navbar, Page } from 'framework7-react'
import { useEffect, type FC } from 'react'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import type { Fight } from '../models/fight'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import type { Event } from '../models/event'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faLocation,
  faMap,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'

type EventPageProps = {
  id: string
}

export const EventPage: FC<EventPageProps> = (props: EventPageProps) => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

  const event: Event | undefined = useSelector(backendSelectors.getEvent)
  const fights: Fight[] = useSelector(backendSelectors.getFights)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const onPullRefreshed = async (done: () => void) => {
    dispatch(backendActions.getEvent(props.id))
    done()
  }

  useEffect(() => {
    dispatch(backendActions.getEvent(props.id))
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
      <Navbar
        title={event?.name ?? t('event', { postProcess: 'capitalize' })}
        large
        backLink
      />
      <BlockTitle>{t('event', { postProcess: 'capitalize' })}</BlockTitle>
      {event && (
        <List dividersIos mediaList strongIos inset>
          <ListItem
            key={event.id}
            title={event.name}
            subtitle={event.fight}
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
                {event.location.city.country.name} - {event.location.city.name}
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
        </List>
      )}
      <BlockTitle>{t('fights', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        {state === 'getting_fights' && 'Skeleton'}
        {fights.length === 0 && (
          <ListItem
            subtitle={t('fightsNotFound', { postProcess: 'capitalize' })}
          />
        )}
        {fights.map((fight: Fight) => (
          <ListItem
            key={fight.id}
            title={`${fight.fighterOne.name} vs. ${fight.fighterTwo.name}`}
            subtitle={fight.category.name}
          >
            {fight.type === 'done' && (
              <>
                <div>
                  {fight.decision} ({fight.method})
                </div>
                <div>
                  {t('round', { postProcess: 'capitalize' })} {fight.round}{' '}
                  {t('at')} {DateUtils.secondsToMMSS(fight.time!)}
                </div>
              </>
            )}
          </ListItem>
        ))}
      </List>
    </Page>
  )
}
