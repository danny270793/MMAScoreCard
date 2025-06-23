import { BlockTitle, f7, List, ListItem, Navbar, Page } from 'framework7-react'
import { useEffect, type FC } from 'react'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import { Logger } from '../utils/logger'
import { EmptyFighter, type Fighter } from '../models/fighter'
import type { Fight } from '../models/fight'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { TranslationUtils } from '../utils/translations'
import {
  faClock,
  faHandshake,
  faNotdef,
  faPersonChalkboard,
  faThumbsDown,
  faThumbsUp,
  faWeight,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'

const logger: Logger = new Logger('/src/pages/fighter.tsx')

type FighterPageProps = {
  id: string
}

interface Streak {
  type: 'win' | 'loss'
  count: number
}

export const FighterPage: FC<FighterPageProps> = (props: FighterPageProps) => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

  const fighter: Fighter | undefined = useSelector(backendSelectors.getFighter)
  const fights: Fight[] = useSelector(backendSelectors.getFights)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const onPullRefreshed = async (done: () => void) => {
    dispatch(backendActions.getFighter(props.id))
    done()
  }

  useEffect(() => {
    logger.debug(`props.id=${props.id}`)
    dispatch(backendActions.getFighter(props.id))
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

  const cmToFeetInches = (cm: number): string => {
    const totalInches: number = cm / 2.54
    const feet: number = Math.floor(totalInches / 12)
    const inches: number = Math.round(totalInches % 12)
    return `${feet}'${inches}''`
  }

  const getWins = (fighter: Fighter, fights: Fight[]): number => {
    return fights.filter(
      (fight) =>
        (fight.winner === 1 && fight.fighterOne.id === fighter.id) ||
        (fight.winner === 2 && fight.fighterTwo.id === fighter.id),
    ).length
  }
  const getLosses = (fighter: Fighter, fights: Fight[]): number => {
    return fights.filter(
      (fight) =>
        (fight.winner === 2 && fight.fighterOne.id === fighter.id) ||
        (fight.winner === 1 && fight.fighterTwo.id === fighter.id),
    ).length
  }

  const getDraws = (fights: Fight[]): number => {
    return fights.filter((fight) => fight.decision === 'Draw').length
  }

  const getNoContest = (fights: Fight[]): number => {
    return fights.filter((fight) => fight.decision === 'No Contest').length
  }

  const computeStreaks = (fighter: Fighter, fights: Fight[]): Streak[] => {
    const results: string[] = fights.map((fight: Fight) =>
      fight.winner && fight.fighterOne.id === fighter.id
        ? 'win'
        : fight.winner && fight.fighterTwo.id === fighter.id
          ? 'loss'
          : 'no important',
    )

    const streaks: Streak[] = []
    results.forEach((result: string) => {
      if (streaks.length === 0) {
        streaks.push({ type: result as 'win' | 'loss', count: 1 })
      } else {
        if (result === streaks[streaks.length - 1].type) {
          streaks[streaks.length - 1].count += 1
        } else {
          streaks.push({ type: result as 'win' | 'loss', count: 1 })
        }
      }
    })

    return streaks
  }

  const streaks: Streak[] = fighter ? computeStreaks(fighter, fights) : []
  const currentStreak: Streak =
    streaks.length > 0 ? streaks[0] : { type: 'win', count: 0 }
  const bestWinStreak: Streak = streaks
    .filter((streak: Streak) => streak.type === 'win')
    .sort((a: Streak, b: Streak) => b.count - a.count)[0] || {
    type: 'win',
    count: 0,
  }
  const worstLossStreak: Streak = streaks
    .filter((streak: Streak) => streak.type === 'loss')
    .sort((b: Streak, a: Streak) => a.count - b.count)[0] || {
    type: 'loss',
    count: 0,
  }
  const titleFights: number = fights.filter(
    (fight: Fight) => fight.titleFight,
  ).length
  const octagonTime: string = DateUtils.secondsToHHMMSS(
    fights
      .map(
        (fight: Fight) => ((fight.round || 1) - 1) * 5 * 60 + (fight.time || 0),
      )
      .reduce((acc: number, time: number | undefined) => acc + (time || 0), 0),
  )

  return (
    <Page ptr ptrMousewheel={true} onPtrRefresh={onPullRefreshed}>
      <Navbar
        title={
          fighter
            ? `${fighter.name}`
            : t('fighter', { postProcess: 'capitalize' })
        }
        large
        backLink
      />

      <BlockTitle>{t('fighter', { postProcess: 'capitalize' })}</BlockTitle>
      {state === 'getting_fighter' && (
        <List
          className="skeleton-text skeleton-effect-wave"
          dividersIos
          mediaList
          strongIos
          inset
        >
          <ListItem
            after={EmptyFighter.name}
            title={t('name', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={EmptyFighter.nickname}
            title={t('nickname', { postProcess: 'capitalize' })}
          />
          {EmptyFighter.city?.country && (
            <ListItem
              after={EmptyFighter.city.country.name}
              title={t('country', { postProcess: 'capitalize' })}
            />
          )}
          {EmptyFighter.city && (
            <ListItem
              after={EmptyFighter.city.name}
              title={t('city', { postProcess: 'capitalize' })}
            />
          )}
          <ListItem
            after={EmptyFighter.weight}
            title={t('weight', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={EmptyFighter.height}
            title={t('height', { postProcess: 'capitalize' })}
          />
        </List>
      )}
      {state !== 'getting_fighter' && fighter && (
        <List dividersIos mediaList strongIos inset>
          <ListItem
            after={fighter.name}
            title={t('name', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={fighter.nickname}
            title={t('nickname', { postProcess: 'capitalize' })}
          />
          {fighter.city?.country && (
            <ListItem
              after={fighter.city.country.name}
              title={t('country', { postProcess: 'capitalize' })}
            />
          )}
          {fighter.city && (
            <ListItem
              after={fighter.city.name}
              title={t('city', { postProcess: 'capitalize' })}
            />
          )}
          <ListItem title={t('height', { postProcess: 'capitalize' })}>
            <span slot="after">
              {cmToFeetInches(fighter.height)} / {fighter.height} cm
            </span>
          </ListItem>
          <ListItem title={t('weight', { postProcess: 'capitalize' })}>
            <span slot="after">
              {(fighter.weight * 2.2).toFixed(2)} lbs / {fighter.weight} kgs
            </span>
          </ListItem>
        </List>
      )}

      <BlockTitle>{t('record', { postProcess: 'capitalize' })}</BlockTitle>
      {state !== 'getting_fighter' && fighter && (
        <List dividersIos mediaList strongIos inset>
          <ListItem
            after={`${getWins(fighter, fights)}`}
            title={t('wins', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${getLosses(fighter, fights)}`}
            title={t('losses', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${getDraws(fights)}`}
            title={t('draws', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${getNoContest(fights)}`}
            title={t('noContest', { postProcess: 'capitalize' })}
          />
        </List>
      )}
      {state === 'getting_fighter' && (
        <List
          className="skeleton-text skeleton-effect-wave"
          dividersIos
          mediaList
          strongIos
          inset
        >
          <ListItem
            after={1}
            title={t('wins', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={1}
            title={t('losses', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={1}
            title={t('draws', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={1}
            title={t('noContest', { postProcess: 'capitalize' })}
          />
        </List>
      )}

      <BlockTitle>{t('stats', { postProcess: 'capitalize' })}</BlockTitle>
      {state !== 'getting_fighter' && fighter && (
        <List dividersIos mediaList strongIos inset>
          <ListItem
            after={`${
              fights.filter(
                (fight: Fight) =>
                  ['KO', 'TKO'].includes(fight.decision || '') &&
                  fight.fighterOne.id === fighter.id,
              ).length
            }`}
            title={t('winsByKos', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${
              fights.filter(
                (fight: Fight) =>
                  ['Submission'].includes(fight.decision || '') &&
                  fight.fighterOne.id === fighter.id,
              ).length
            }`}
            title={t('winsBySubmissions', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${
              fights.filter(
                (fight: Fight) =>
                  ['Decision'].includes(fight.decision || '') &&
                  fight.fighterOne.id === fighter.id,
              ).length
            }`}
            title={t('winsByDecisions', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${
              fights.filter(
                (fight: Fight) =>
                  ['KO', 'TKO'].includes(fight.decision || '') &&
                  fight.fighterTwo.id === fighter.id,
              ).length
            }`}
            title={t('lossesByKos', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${
              fights.filter(
                (fight: Fight) =>
                  ['Submission'].includes(fight.decision || '') &&
                  fight.fighterTwo.id === fighter.id,
              ).length
            }`}
            title={t('lossesBySubmissions', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${
              fights.filter(
                (fight: Fight) =>
                  ['Decision'].includes(fight.decision || '') &&
                  fight.fighterTwo.id === fighter.id,
              ).length
            }`}
            title={t('lossesByDecisions', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${currentStreak.count} ${currentStreak.type === 'win' ? t(currentStreak.count > 1 ? 'wins' : 'win') : t(currentStreak.count > 1 ? 'losses' : 'loss')}`}
            title={t('currentStreak', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${bestWinStreak.count} ${t(bestWinStreak.count > 1 ? 'wins' : 'win')}`}
            title={t('bestWinStreak', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${worstLossStreak.count} ${t(worstLossStreak.count > 1 ? 'losses' : 'loss')}`}
            title={t('worstLossStreak', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={`${titleFights} ${t(titleFights > 1 ? 'fights' : 'fight')}`}
            title={t('titleFights', { postProcess: 'capitalize' })}
          />
          <ListItem
            after={octagonTime}
            title={t('octagonTime', { postProcess: 'capitalize' })}
          />
        </List>
      )}

      <BlockTitle>{t('fights', { postProcess: 'capitalize' })}</BlockTitle>
      <div className="timeline">
        {state !== 'getting_fighter' &&
          fighter &&
          fights.map((fight: Fight) => (
            <div key={fight.id} className="timeline-item">
              <div className="timeline-item-date">
                {fight.event.date.toISOString().split('T')[0].replace('-', ' ')}
              </div>
              <div className="timeline-item-divider" />
              <div className="timeline-item-content">
                <List dividersIos mediaList strongIos inset>
                  <ListItem
                    key={fight.id}
                    title={
                      fight.fighterTwo.id === fighter.id
                        ? fight.fighterOne.name
                        : fight.fighterTwo.name
                    }
                    subtitle={
                      fight.titleFight
                        ? t('titleFight', { postProcess: 'capitalize' })
                        : ''
                    }
                  >
                    <span slot="after">
                      {!fight.winner && fight.decision === 'Draw' && (
                        <FontAwesomeIcon
                          className="w-4"
                          icon={faHandshake}
                          style={{ color: 'orange' }}
                        />
                      )}
                      {!fight.winner && fight.decision === 'No Contest' && (
                        <FontAwesomeIcon className="w-4" icon={faNotdef} />
                      )}
                      {fight.winner && fight.fighterOne.id === fighter.id && (
                        <FontAwesomeIcon
                          className="w-4"
                          icon={faThumbsUp}
                          style={{ color: 'green' }}
                        />
                      )}
                      {fight.winner && fight.fighterTwo.id === fighter.id && (
                        <FontAwesomeIcon
                          className="w-4"
                          icon={faThumbsDown}
                          style={{ color: 'red' }}
                        />
                      )}
                    </span>
                    <br />
                    {fight.category && (
                      <div>
                        <FontAwesomeIcon className="w-4" icon={faWeight} />{' '}
                        {TranslationUtils.getCategoryName(
                          t,
                          fight.category.name,
                        )}{' '}
                        ({fight.category.weight} lbs)
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
                            TranslationUtils.getDecisionName(
                              t,
                              fight.decision,
                            )}{' '}
                          (
                          {fight.method &&
                            TranslationUtils.getDecisionMethodName(
                              t,
                              fight.method,
                            )}
                          )
                        </div>
                        {fight.decision !== 'Decision' && (
                          <div>
                            <FontAwesomeIcon className="w-4" icon={faClock} />{' '}
                            {t('round', { postProcess: 'capitalize' })}{' '}
                            {fight.round} {t('at')}{' '}
                            {DateUtils.secondsToMMSS(fight.time!)}
                          </div>
                        )}
                      </>
                    )}
                  </ListItem>
                </List>
              </div>
            </div>
          ))}
      </div>
    </Page>
  )
}
