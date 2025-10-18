import { useEffect, type FC } from 'react'
import { useParams, useNavigate, Link } from 'react-router-dom'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import { Logger } from '../utils/logger'
import { type Fighter } from '../models/fighter'
import type { Fight } from '../models/fight'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { TranslationUtils } from '../utils/translations'
import {
  faHandshake,
  faNotdef,
  faPersonChalkboard,
  faThumbsDown,
  faThumbsUp,
  faWeight,
  faArrowLeft,
  faFistRaised,
  faTrophy,
  faUser,
  faFlag,
  faMapMarkerAlt,
  faRuler,
  faBalanceScale,
  faChartLine,
  faHistory,
  faCrown,
  faStopwatch,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'
import { PullToRefresh } from '../components/pull-to-refresh'

const logger: Logger = new Logger('/src/pages/fighter.tsx')

interface Streak {
  type: 'win' | 'loss'
  count: number
}

export const FighterPage: FC = () => {
  const { id } = useParams<{ id: string }>()
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()
  const navigate = useNavigate()

  const fighter: Fighter | undefined = useSelector(backendSelectors.getFighter)
  const fights: Fight[] = useSelector(backendSelectors.getFights)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const handleRefresh = () => {
    if (id) {
      dispatch(backendActions.getFighter(id))
    }
  }

  useEffect(() => {
    if (id) {
      logger.debug(`id=${id}`)
      dispatch(backendActions.getFighter(id))
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [id])

  useEffect(() => {
    if (!error) {
      return
    }

    logger.error('error on component', error)
    alert(error?.message || t('unknownError', { postProcess: 'capitalize' }))
        dispatch(backendActions.clearError())
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
    <div className="bg-gray-50 dark:bg-gray-900" style={{ marginTop: 'env(safe-area-inset-top)' }}>
      <PullToRefresh onRefresh={handleRefresh} isRefreshing={state === 'getting_fighter'}>
      {/* Clean header */}
      <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 shadow-sm">
        <div className="px-4 sm:px-6 py-4 sm:py-5">
          <div className="flex items-center gap-3 sm:gap-4">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200 min-w-[40px] min-h-[40px] flex items-center justify-center"
            >
              <FontAwesomeIcon icon={faArrowLeft} className="w-4 h-4" />
            </button>
            <div className="flex items-center gap-3 flex-1">
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {fighter ? fighter.name : t('fighter', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  {fighter?.nickname ? `"${fighter.nickname}"` : t('fighter', { postProcess: 'capitalize' }) + ' ' + t('profile', { postProcess: 'capitalize' })}
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        
        {/* Fighter Info Section */}
        <section className="mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
            {t('fighter', { postProcess: 'capitalize' })}
          </h2>
          
          {/* Fighter Loading State */}
      {state === 'getting_fighter' && (
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
              <div className="space-y-3">
                {[1, 2, 3, 4, 5, 6].map((i) => (
                  <div key={i} className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                    <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
                    <div className="flex-1 min-w-0">
                      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3 animate-pulse"></div>
                    </div>
                    <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/4 animate-pulse"></div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* Fighter Details */}
      {state !== 'getting_fighter' && fighter && (
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
              <div className="space-y-3">
                {/* Name */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faUser} className="w-3 h-3 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm text-gray-600 dark:text-gray-400">{t('name', { postProcess: 'capitalize' })}</span>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {fighter.name}
                  </div>
                </div>

                {/* Nickname */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faFistRaised} className="w-3 h-3 text-purple-600 dark:text-purple-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm text-gray-600 dark:text-gray-400">{t('nickname', { postProcess: 'capitalize' })}</span>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {fighter.nickname || t('notFound', { postProcess: 'capitalize' })}
                  </div>
                </div>

                {/* Country */}
          {fighter.city?.country && (
                  <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                    <div className="w-7 h-7 rounded bg-green-100 dark:bg-green-900/30 flex items-center justify-center flex-shrink-0">
                      <FontAwesomeIcon icon={faFlag} className="w-3 h-3 text-green-600 dark:text-green-400" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <span className="text-sm text-gray-600 dark:text-gray-400">{t('country', { postProcess: 'capitalize' })}</span>
                    </div>
                    <div className="text-sm font-medium text-gray-900 dark:text-white">
                      {fighter.city.country.name}
                    </div>
                  </div>
                )}

                {/* City */}
          {fighter.city && (
                  <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                    <div className="w-7 h-7 rounded bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center flex-shrink-0">
                      <FontAwesomeIcon icon={faMapMarkerAlt} className="w-3 h-3 text-orange-600 dark:text-orange-400" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <span className="text-sm text-gray-600 dark:text-gray-400">{t('city', { postProcess: 'capitalize' })}</span>
                    </div>
                    <div className="text-sm font-medium text-gray-900 dark:text-white">
                      {fighter.city.name}
                    </div>
                  </div>
                )}

                {/* Height */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faRuler} className="w-3 h-3 text-indigo-600 dark:text-indigo-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm text-gray-600 dark:text-gray-400">{t('height', { postProcess: 'capitalize' })}</span>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
              {cmToFeetInches(fighter.height)} / {fighter.height} cm
                  </div>
                </div>

                {/* Weight */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-red-100 dark:bg-red-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faBalanceScale} className="w-3 h-3 text-red-600 dark:text-red-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm text-gray-600 dark:text-gray-400">{t('weight', { postProcess: 'capitalize' })}</span>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
              {(fighter.weight * 2.2).toFixed(2)} lbs / {fighter.weight} kgs
                  </div>
                </div>
              </div>
            </div>
          )}
        </section>

        {/* Record Section */}
        <section className="mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
            {t('record', { postProcess: 'capitalize' })}
          </h2>
          
          {/* Record Loading State */}
      {state === 'getting_fighter' && (
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              {[1, 2, 3, 4].map((i) => (
                <div key={i} className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 shadow-sm">
                  <div className="text-center">
                    <div className="w-8 h-8 rounded bg-gray-200 dark:bg-gray-700 animate-pulse mx-auto mb-2"></div>
                    <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-8 mx-auto mb-2 animate-pulse"></div>
                    <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-12 mx-auto animate-pulse"></div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* Record Stats */}
      {state !== 'getting_fighter' && fighter && (
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-4">
              {/* Wins */}
              <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 shadow-sm">
                <div className="text-center">
                  <div className="w-8 h-8 rounded bg-green-100 dark:bg-green-900/30 flex items-center justify-center mx-auto mb-2">
                    <FontAwesomeIcon icon={faThumbsUp} className="w-4 h-4 text-green-600 dark:text-green-400" />
                  </div>
                  <div className="text-2xl font-bold text-green-600 dark:text-green-400 mb-1">
                    {getWins(fighter, fights)}
                  </div>
                  <div className="text-xs text-gray-600 dark:text-gray-400">
                    {t('wins', { postProcess: 'capitalize' })}
                  </div>
                </div>
              </div>

              {/* Losses */}
              <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 shadow-sm">
                <div className="text-center">
                  <div className="w-8 h-8 rounded bg-red-100 dark:bg-red-900/30 flex items-center justify-center mx-auto mb-2">
                    <FontAwesomeIcon icon={faThumbsDown} className="w-4 h-4 text-red-600 dark:text-red-400" />
                  </div>
                  <div className="text-2xl font-bold text-red-600 dark:text-red-400 mb-1">
                    {getLosses(fighter, fights)}
                  </div>
                  <div className="text-xs text-gray-600 dark:text-gray-400">
                    {t('losses', { postProcess: 'capitalize' })}
                  </div>
                </div>
              </div>

              {/* Draws */}
              <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 shadow-sm">
                <div className="text-center">
                  <div className="w-8 h-8 rounded bg-yellow-100 dark:bg-yellow-900/30 flex items-center justify-center mx-auto mb-2">
                    <FontAwesomeIcon icon={faHandshake} className="w-4 h-4 text-yellow-600 dark:text-yellow-400" />
                  </div>
                  <div className="text-2xl font-bold text-yellow-600 dark:text-yellow-400 mb-1">
                    {getDraws(fights)}
                  </div>
                  <div className="text-xs text-gray-600 dark:text-gray-400">
                    {t('draws', { postProcess: 'capitalize' })}
                  </div>
                </div>
              </div>

              {/* No Contest */}
              <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 shadow-sm">
                <div className="text-center">
                  <div className="w-8 h-8 rounded bg-gray-100 dark:bg-gray-700 flex items-center justify-center mx-auto mb-2">
                    <FontAwesomeIcon icon={faNotdef} className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                  </div>
                  <div className="text-2xl font-bold text-gray-600 dark:text-gray-400 mb-1">
                    {getNoContest(fights)}
                  </div>
                  <div className="text-xs text-gray-600 dark:text-gray-400">
                    {t('noContest', { postProcess: 'capitalize' })}
                  </div>
                </div>
              </div>
            </div>
          )}
        </section>

        {/* Stats Section */}
        <section className="mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
            {t('stats', { postProcess: 'capitalize' })}
          </h2>
          
          {state !== 'getting_fighter' && fighter && (
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
                
                {/* Win Methods */}
                <div className="space-y-3">
                  <h3 className="text-sm font-semibold text-green-600 dark:text-green-400 flex items-center gap-2">
                    <FontAwesomeIcon icon={faThumbsUp} className="w-3 h-3" />
                    {t('winMethods', { postProcess: 'capitalize' })}
                  </h3>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('winsByKos', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {fights.filter((fight: Fight) => ['KO', 'TKO'].includes(fight.decision || '') && fight.fighterOne.id === fighter.id).length}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('winsBySubmissions', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {fights.filter((fight: Fight) => ['Submission'].includes(fight.decision || '') && fight.fighterOne.id === fighter.id).length}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('winsByDecisions', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {fights.filter((fight: Fight) => ['Decision'].includes(fight.decision || '') && fight.fighterOne.id === fighter.id).length}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Loss Methods */}
                <div className="space-y-3">
                  <h3 className="text-sm font-semibold text-red-600 dark:text-red-400 flex items-center gap-2">
                    <FontAwesomeIcon icon={faThumbsDown} className="w-3 h-3" />
                    {t('lossMethods', { postProcess: 'capitalize' })}
                  </h3>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('lossesByKos', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {fights.filter((fight: Fight) => ['KO', 'TKO'].includes(fight.decision || '') && fight.fighterTwo.id === fighter.id).length}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('lossesBySubmissions', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {fights.filter((fight: Fight) => ['Submission'].includes(fight.decision || '') && fight.fighterTwo.id === fighter.id).length}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('lossesByDecisions', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {fights.filter((fight: Fight) => ['Decision'].includes(fight.decision || '') && fight.fighterTwo.id === fighter.id).length}
                      </span>
                    </div>
                  </div>
                </div>

                {/* Streaks & Performance */}
                <div className="space-y-3 sm:col-span-2 lg:col-span-1">
                  <h3 className="text-sm font-semibold text-blue-600 dark:text-blue-400 flex items-center gap-2">
                    <FontAwesomeIcon icon={faChartLine} className="w-3 h-3" />
                    {t('performance', { postProcess: 'capitalize' })}
                  </h3>
                  <div className="space-y-2">
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('currentStreak', { postProcess: 'capitalize' })}</span>
                      <span className={`font-medium ${currentStreak.type === 'win' ? 'text-green-600 dark:text-green-400' : 'text-red-600 dark:text-red-400'}`}>
                        {currentStreak.count} {currentStreak.type === 'win' ? t(currentStreak.count > 1 ? 'wins' : 'win') : t(currentStreak.count > 1 ? 'losses' : 'loss')}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('bestWinStreak', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-green-600 dark:text-green-400">
                        {bestWinStreak.count} {t(bestWinStreak.count > 1 ? 'wins' : 'win')}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('worstLossStreak', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-red-600 dark:text-red-400">
                        {worstLossStreak.count} {t(worstLossStreak.count > 1 ? 'losses' : 'loss')}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('titleFights', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-yellow-600 dark:text-yellow-400">
                        {titleFights} {t(titleFights > 1 ? 'fights' : 'fight')}
                      </span>
                    </div>
                    <div className="flex justify-between text-sm">
                      <span className="text-gray-600 dark:text-gray-400">{t('octagonTime', { postProcess: 'capitalize' })}</span>
                      <span className="font-medium text-gray-900 dark:text-white">
                        {octagonTime}
                      </span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          )}
        </section>

        {/* Fight History Section */}
        <section>
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <FontAwesomeIcon icon={faHistory} className="w-5 h-5" />
            {t('fights', { postProcess: 'capitalize' })}
          </h2>
          
          {state !== 'getting_fighter' && fighter && (
            <div className="space-y-4">
              {fights.map((fight: Fight) => (
                <Link
                    key={fight.id}
                  to={`/fights/${fight.id}`}
                  className="block hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors duration-200"
                >
                  <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
                    
                    {/* Fight Header */}
                    <div className="flex items-center justify-between mb-4">
                      <div className="flex items-center gap-3">
                        <div className="text-sm text-gray-500 dark:text-gray-400">
                          {fight.event.date.toLocaleDateString('en-US', { 
                            month: 'short', 
                            day: 'numeric',
                            year: 'numeric'
                          })}
                        </div>
                        {fight.titleFight && (
                          <div className="px-2 py-1 bg-gradient-to-r from-yellow-100 to-amber-100 dark:from-yellow-900/30 dark:to-amber-900/30 border border-yellow-200 dark:border-yellow-800 rounded text-xs font-semibold text-yellow-800 dark:text-yellow-200 flex items-center gap-1">
                            <FontAwesomeIcon icon={faCrown} className="w-3 h-3" />
                            {t('titleFight', { postProcess: 'capitalize' })}
                          </div>
                        )}
                      </div>
                      
                      {/* Result Icon */}
                      <div className="flex items-center">
                      {!fight.winner && fight.decision === 'Draw' && (
                          <div className="w-8 h-8 rounded-full bg-yellow-100 dark:bg-yellow-900/30 flex items-center justify-center">
                            <FontAwesomeIcon icon={faHandshake} className="w-4 h-4 text-yellow-600 dark:text-yellow-400" />
                          </div>
                      )}
                      {!fight.winner && fight.decision === 'No Contest' && (
                          <div className="w-8 h-8 rounded-full bg-gray-100 dark:bg-gray-700 flex items-center justify-center">
                            <FontAwesomeIcon icon={faNotdef} className="w-4 h-4 text-gray-600 dark:text-gray-400" />
                          </div>
                        )}
                        {fight.winner && ((fight.fighterOne.id === fighter.id && fight.winner === 1) || (fight.fighterTwo.id === fighter.id && fight.winner === 2)) && (
                          <div className="w-8 h-8 rounded-full bg-green-100 dark:bg-green-900/30 flex items-center justify-center">
                            <FontAwesomeIcon icon={faTrophy} className="w-4 h-4 text-green-600 dark:text-green-400" />
                          </div>
                        )}
                        {fight.winner && ((fight.fighterOne.id === fighter.id && fight.winner === 2) || (fight.fighterTwo.id === fighter.id && fight.winner === 1)) && (
                          <div className="w-8 h-8 rounded-full bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
                            <FontAwesomeIcon icon={faThumbsDown} className="w-4 h-4 text-red-600 dark:text-red-400" />
                          </div>
                        )}
                      </div>
                    </div>

                    {/* Opponent */}
                    <div className="mb-3">
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white">
                        vs. {fight.fighterTwo.id === fighter.id ? fight.fighterOne.name : fight.fighterTwo.name}
                      </h3>
                    </div>

                    {/* Fight Details */}
                    <div className="space-y-2">
                      {/* Weight Class */}
                      {fight.category && (
                        <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                          <FontAwesomeIcon icon={faWeight} className="w-3 h-3" />
                          <span>
                            {TranslationUtils.getCategoryName(t, fight.category.name)} ({fight.category.weight} lbs)
                          </span>
                        </div>
                      )}

                      {/* Result Details */}
                      {fight.type === 'done' && (
                        <>
                          <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                            <FontAwesomeIcon icon={faPersonChalkboard} className="w-3 h-3" />
                            <span>
                              {fight.decision && TranslationUtils.getDecisionName(t, fight.decision)} (
                              {fight.method && TranslationUtils.getDecisionMethodName(t, fight.method)})
                            </span>
                          </div>
                          
                          {fight.decision !== 'Decision' && (
                            <div className="flex items-center gap-2 text-sm text-gray-600 dark:text-gray-400">
                              <FontAwesomeIcon icon={faStopwatch} className="w-3 h-3" />
                              <span>
                                {t('round', { postProcess: 'capitalize' })} {fight.round} {t('at')} {DateUtils.secondsToMMSS(fight.time!)}
                              </span>
                          </div>
                        )}
                      </>
                    )}
                    </div>
                  </div>
                </Link>
              ))}
            </div>
          )}
        </section>
      </main>

      {/* Clean footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          {state !== 'getting_fighter' && fighter && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded bg-blue-600 flex items-center justify-center">
                  <FontAwesomeIcon icon={faUser} className="w-4 h-4 text-white" />
                </div>
                <div>
                  <div className="text-lg font-semibold text-gray-900 dark:text-white">
                    {fighter.name}
                  </div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">
                    {getWins(fighter, fights)}-{getLosses(fighter, fights)}-{getDraws(fights)}
                  </div>
                </div>
              </div>
              
              <div className="text-sm text-gray-500 dark:text-gray-400">
                {t('appName')}
              </div>
            </div>
          )}
        </div>
      </footer>
      </PullToRefresh>
      </div>
  )
}
