import {
  BlockTitle,
  f7,
  List,
  ListItem,
  Navbar,
  Page,
  Toolbar,
} from 'framework7-react'
import { useEffect, type FC } from 'react'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import { EmptyFight, type Fight } from '../models/fight'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import { EmptyEvent, type Event } from '../models/event'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faClock,
  faLocation,
  faMap,
  faPersonChalkboard,
  faWeight,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'
import { Faker } from '../utils/faker'
import { Logger } from '../utils/logger'
import { TranslationUtils } from '../utils/translations'

const logger: Logger = new Logger('/src/pages/event.tsx')

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
    logger.debug(`props.id=${props.id}`)
    dispatch(backendActions.getEvent(props.id))
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

  useEffect(() => {
    if (!error) {
      return
    }

    logger.error('error on component', error)
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
      <List dividers mediaList strong inset>
        {state === 'getting_event' && (
          <ListItem
            className="skeleton-text skeleton-effect-wave"
            title={EmptyEvent.name}
            subtitle={EmptyEvent.fight}
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
        )}
        {state !== 'getting_event' && event && (
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
        )}
      </List>

      <BlockTitle>{t('fights', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividers mediaList strong inset>
        {state === 'getting_event' &&
          Faker.arrayOfNumbers(5).map((i: number) => (
            <ListItem
              className="skeleton-text skeleton-effect-wave"
              key={i}
              chevronCenter
              title={`${EmptyFight.fighterOne.name} vs. ${EmptyFight.fighterTwo.name}`}
              subtitle="EmptyFight.titleFight"
            >
              <br />
              {EmptyFight.category && (
                <div>
                  {EmptyFight.category.name} ({EmptyFight.category.weight} lbs)
                </div>
              )}
              {EmptyFight.type === 'done' && (
                <>
                  <div>
                    {EmptyFight.decision} ({EmptyFight.method})
                  </div>
                  {EmptyFight.decision !== 'Decision' && (
                    <div>
                      {t('round', { postProcess: 'capitalize' })}{' '}
                      {EmptyFight.round} {t('at')}{' '}
                      {DateUtils.secondsToMMSS(EmptyFight.time!)}
                    </div>
                  )}
                </>
              )}
            </ListItem>
          ))}

        {state !== 'getting_event' && fights.length === 0 && (
          <ListItem
            subtitle={t('fightsNotFound', { postProcess: 'capitalize' })}
          />
        )}
        {state !== 'getting_event' &&
          fights.map((fight: Fight) => (
            <ListItem
              key={fight.id}
              link={`/fights/${fight.id}`}
              chevronCenter
              title={`${fight.fighterOne.name} vs. ${fight.fighterTwo.name}`}
              subtitle={
                fight.titleFight
                  ? t('titleFight', { postProcess: 'capitalize' })
                  : ''
              }
            >
              <br />
              {fight.category && (
                <div>
                  <FontAwesomeIcon className="w-4" icon={faWeight} />{' '}
                  {TranslationUtils.getCategoryName(t, fight.category.name)} (
                  {fight.category.weight} lbs)
                </div>
              )}
              {fight.type === 'done' && (
                <>
                  <div>
                    <FontAwesomeIcon
                      className="w-4"
                      icon={faPersonChalkboard}
                    />{' '}
                    {fight.decision &&
                      TranslationUtils.getDecisionName(t, fight.decision)}{' '}
                    (
                    {fight.method &&
                      TranslationUtils.getDecisionMethodName(t, fight.method)}
                    )
                  </div>
                  {fight.decision !== 'Decision' && (
                    <div>
                      <FontAwesomeIcon className="w-4" icon={faClock} />{' '}
                      {t('round', { postProcess: 'capitalize' })} {fight.round}{' '}
                      {t('at')} {DateUtils.secondsToMMSS(fight.time!)}
                    </div>
                  )}
                </>
              )}
            </ListItem>
          ))}
      </List>
      <Toolbar bottom>
        <div />
        {state === 'getting_event' && (
          <div className="skeleton-text skeleton-effect-wave">
            {t('fightsCounter', { count: 0 })}
          </div>
        )}
        {state !== 'getting_event' && (
          <div>{t('fightsCounter', { count: fights.length })}</div>
        )}
        <div />
      </Toolbar>
    </Page>
  )
}
