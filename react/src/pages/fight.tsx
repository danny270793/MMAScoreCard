import { BlockTitle, f7, List, ListItem, Navbar, Page } from 'framework7-react'
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
  faCrown,
  faGavel,
  faLocation,
  faMap,
  faThumbsDown,
  faThumbsUp,
  faWeight,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'

type FightPageProps = {
  id: string
}

export const FightPage: FC<FightPageProps> = (props: FightPageProps) => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

  const event: Event | undefined = useSelector(backendSelectors.getEvent)
  const fight: Fight | undefined = useSelector(backendSelectors.getFight)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const onPullRefreshed = async (done: () => void) => {
    dispatch(backendActions.getFight(props.id))
    done()
  }

  useEffect(() => {
    dispatch(backendActions.getFight(props.id))
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
        title={
          fight
            ? `${fight.fighterOne.name} vs. ${fight.fighterTwo.name}`
            : t('fight', { postProcess: 'capitalize' })
        }
        large
        backLink
      />
      <BlockTitle>{t('event', { postProcess: 'capitalize' })}</BlockTitle>

      <List dividersIos mediaList strongIos inset>
        {state === 'getting_fight' && (
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
        {event && state !== 'getting_fight' && (
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
      <BlockTitle>{t('fight', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        {state === 'getting_fight' && (
          <ListItem
            key={1}
            className="skeleton-text skeleton-effect-wave"
            chevronCenter
            title={`${EmptyFight.fighterOne.name} vs. ${EmptyFight.fighterTwo.name}`}
            subtitle="fight.titleFight"
          >
            <br />
            <div>
              {EmptyFight.category.name} ({EmptyFight.category.weight} lbs)
            </div>
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
        )}
        {fight && state !== 'getting_fight' && (
          <ListItem key={fight.id}>
            {fight.titleFight && (
              <div>
                <FontAwesomeIcon className="w-4" icon={faCrown} />{' '}
                {t('titleFight', { postProcess: 'capitalize' })}
              </div>
            )}
            <div>
              <FontAwesomeIcon className="w-4" icon={faWeight} />{' '}
              {fight.category.name} ({fight.category.weight} lbs)
            </div>
            {fight.type === 'done' && (
              <>
                <div>
                  <FontAwesomeIcon className="w-4" icon={faGavel} />{' '}
                  {fight.decision} ({fight.method})
                </div>
                {fight.decision !== 'Decision' && (
                  <div>
                    <FontAwesomeIcon className="w-4" icon={faClock} />{' '}
                    {t('round', { postProcess: 'capitalize' })} {fight.round}{' '}
                    {t('at')} {DateUtils.secondsToMMSS(fight.time!)}
                  </div>
                )}
                {fight.referee && (
                  <div>
                    <FontAwesomeIcon className="w-4" icon={faGavel} />{' '}
                    {fight.referee.name}
                  </div>
                )}
              </>
            )}
          </ListItem>
        )}
      </List>
      <BlockTitle>{t('fighters', { postProcess: 'capitalize' })}</BlockTitle>
      <List dividersIos mediaList strongIos inset>
        {state === 'getting_fight' && (
          <ListItem className="skeleton-text skeleton-effect-wave"></ListItem>
        )}
        {fight && state !== 'getting_fight' && (
          <ListItem
            chevronCenter
            link={`/fighters/${fight.fighterOne.id}`}
            title={fight.fighterOne.name}
            subtitle={fight.fighterOne.nickname}
          >
            <div slot="media">
              <FontAwesomeIcon className="w-4" icon={faThumbsUp} />
            </div>
          </ListItem>
        )}
        {fight && state !== 'getting_fight' && (
          <ListItem
            chevronCenter
            link={`/fighters/${fight.fighterTwo.id}`}
            title={fight.fighterTwo.name}
            subtitle={fight.fighterTwo.nickname}
          >
            <div slot="media">
              <FontAwesomeIcon className="w-4" icon={faThumbsDown} />
            </div>
          </ListItem>
        )}
      </List>
    </Page>
  )
}
