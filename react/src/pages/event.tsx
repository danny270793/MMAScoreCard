import { useEffect, type FC } from 'react'
import { useParams, Link } from 'react-router-dom'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useDispatch, useSelector } from 'react-redux'
import { type Fight } from '../models/fight'
import { useTranslation } from 'react-i18next'
import type { Dispatch } from '@reduxjs/toolkit'
import { type Event } from '../models/event'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faClock,
  faLocation,
  faMap,
  faPersonChalkboard,
  faWeight,
  faArrowLeft,
  faFistRaised,
  faFire,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'
import { Faker } from '../utils/faker'
import { Logger } from '../utils/logger'
import { TranslationUtils } from '../utils/translations'

const logger: Logger = new Logger('/src/pages/event.tsx')

export const EventPage: FC = () => {
  const { id } = useParams<{ id: string }>()
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()

  const event: Event | undefined = useSelector(backendSelectors.getEvent)
  const fights: Fight[] = useSelector(backendSelectors.getFights)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  const handleRefresh = () => {
    if (id) {
      dispatch(backendActions.getEvent(id))
    }
  }

  useEffect(() => {
    if (id) {
      logger.debug(`id=${id}`)
      dispatch(backendActions.getEvent(id))
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

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Clean header */}
      <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 shadow-sm">
        <div className="px-4 sm:px-6 py-4 sm:py-5">
          <div className="flex items-center gap-3 sm:gap-4">
            <Link
              to="/events"
              className="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200 min-w-[40px] min-h-[40px] flex items-center justify-center"
            >
              <FontAwesomeIcon icon={faArrowLeft} className="w-4 h-4" />
            </Link>
            <div className="flex items-center gap-3 flex-1">
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {event?.name ?? t('event', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  {t('event', { postProcess: 'capitalize' })} Details
                </p>
              </div>
            </div>
            <button
              onClick={handleRefresh}
              disabled={state === 'getting_event'}
              className="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-blue-50 dark:hover:bg-blue-900/30 text-gray-600 dark:text-gray-300 hover:text-blue-600 dark:hover:text-blue-400 disabled:opacity-50 transition-colors duration-200 min-w-[40px] min-h-[40px] flex items-center justify-center"
            >
              <FontAwesomeIcon icon={faFire} className={`w-4 h-4 ${state === 'getting_event' ? 'animate-spin' : ''}`} />
            </button>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        
        {/* Event Details Section */}
        <section className="mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
            {t('event', { postProcess: 'capitalize' })}
          </h2>
          
          {/* Loading State */}
          {state === 'getting_event' && (
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
              <div className="mb-4">
                <div className="flex justify-between items-start gap-3 mb-2">
                  <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-3/4 animate-pulse"></div>
                  <div className="h-5 w-16 bg-gray-200 dark:bg-gray-700 rounded animate-pulse"></div>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 rounded bg-gray-200 dark:bg-gray-700 animate-pulse"></div>
                  <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2 animate-pulse"></div>
                </div>
              </div>
              <div className="space-y-2">
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
                  <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3 animate-pulse"></div>
                </div>
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
                  <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4 animate-pulse"></div>
                </div>
              </div>
            </div>
          )}

          {/* Event Details */}
          {state !== 'getting_event' && event && (
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
              <div className="mb-4">
                <div className="flex justify-between items-start gap-3 mb-2">
                  <h3 className="text-lg sm:text-xl font-semibold text-gray-900 dark:text-white flex-1">
                    {event.name}
                  </h3>
                  {event.status === 'uppcoming' && (
                    <span className="px-2 py-1 bg-blue-100 dark:bg-blue-900/30 text-blue-700 dark:text-blue-300 text-xs font-medium rounded-md whitespace-nowrap">
                      {t('upcoming', { postProcess: 'capitalize' })}
                    </span>
                  )}
                </div>
                
                {/* Fight info */}
                <div className="flex items-center gap-2">
                  <div className="w-6 h-6 rounded bg-red-100 dark:bg-red-900/30 flex items-center justify-center">
                    <FontAwesomeIcon icon={faFistRaised} className="w-3 h-3 text-red-600 dark:text-red-400" />
                  </div>
                  <p className="text-sm font-medium text-gray-600 dark:text-gray-400">
                    {event.fight || 'Fight details TBD'}
                  </p>
                </div>
              </div>

              <div className="space-y-2">
                {/* Date info */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faCalendar} className="w-3 h-3 text-blue-600 dark:text-blue-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="flex items-center gap-2 flex-wrap">
                      <span className="text-sm font-medium text-gray-900 dark:text-white">
                        {event.date.toISOString().split('T')[0]}
                      </span>
                      {event.status === 'uppcoming' && (
                        <span className="px-2 py-0.5 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300 text-xs font-medium rounded">
                          {t('inXXDays', {
                            days: DateUtils.daysBetween(event.date, new Date()),
                          })}
                        </span>
                      )}
                    </div>
                  </div>
                </div>

                {/* Location info */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faMap} className="w-3 h-3 text-orange-600 dark:text-orange-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <div className="text-sm font-medium text-gray-900 dark:text-white">
                      {event.location.city.country.name}, {event.location.city.name}
                    </div>
                  </div>
                </div>

                {/* Venue info */}
                {event.location.name && (
                  <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                    <div className="w-7 h-7 rounded bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center flex-shrink-0">
                      <FontAwesomeIcon icon={faLocation} className="w-3 h-3 text-purple-600 dark:text-purple-400" />
                    </div>
                    <div className="flex-1 min-w-0">
                      <div className="text-sm font-medium text-gray-900 dark:text-white">
                        {event.location.name}
                      </div>
                    </div>
                  </div>
                )}
              </div>
            </div>
          )}
        </section>

        {/* Fights Section */}
        <section>
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
            {t('fights', { postProcess: 'capitalize' })}
          </h2>
          
          {/* Loading State */}
          {state === 'getting_event' && (
            <div className="space-y-4">
              {Faker.arrayOfNumbers(5).map((i: number) => (
                <div key={i} className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
                  <div className="mb-3">
                    <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-3/4 animate-pulse mb-2"></div>
                    <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2 animate-pulse"></div>
                  </div>
                  <div className="space-y-2">
                    <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                      <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
                      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/3 animate-pulse"></div>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          )}

          {/* No Fights */}
          {state !== 'getting_event' && fights.length === 0 && (
            <div className="text-center py-12 bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800">
              <div className="w-16 h-16 rounded-full bg-gray-100 dark:bg-gray-800 flex items-center justify-center mx-auto mb-4">
                <FontAwesomeIcon icon={faFistRaised} className="w-8 h-8 text-gray-400" />
              </div>
              <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-2">
                {t('fightsNotFound', { postProcess: 'capitalize' })}
              </h3>
            </div>
          )}

          {/* Fights List */}
          {state !== 'getting_event' && fights.length > 0 && (
            <div className="space-y-4">
              {fights.map((fight: Fight) => (
                <Link
                  key={fight.id}
                  to={`/fights/${fight.id}`}
                  className="block hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors duration-200"
                >
                  <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
                    <div className="mb-3">
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
                        {fight.fighterOne.name} vs. {fight.fighterTwo.name}
                      </h3>
                      {fight.titleFight && (
                        <span className="px-2 py-1 bg-yellow-100 dark:bg-yellow-900/30 text-yellow-700 dark:text-yellow-300 text-xs font-medium rounded-md">
                          {t('titleFight', { postProcess: 'capitalize' })}
                        </span>
                      )}
                    </div>
                    
                    <div className="space-y-2">
                      {/* Category */}
                      {fight.category && (
                        <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                          <div className="w-7 h-7 rounded bg-indigo-100 dark:bg-indigo-900/30 flex items-center justify-center flex-shrink-0">
                            <FontAwesomeIcon icon={faWeight} className="w-3 h-3 text-indigo-600 dark:text-indigo-400" />
                          </div>
                          <div className="flex-1 min-w-0">
                            <span className="text-sm font-medium text-gray-900 dark:text-white">
                              {TranslationUtils.getCategoryName(t, fight.category.name)} ({fight.category.weight} lbs)
                            </span>
                          </div>
                        </div>
                      )}

                      {/* Fight Result */}
                      {fight.type === 'done' && (
                        <>
                          <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                            <div className="w-7 h-7 rounded bg-green-100 dark:bg-green-900/30 flex items-center justify-center flex-shrink-0">
                              <FontAwesomeIcon icon={faPersonChalkboard} className="w-3 h-3 text-green-600 dark:text-green-400" />
                            </div>
                            <div className="flex-1 min-w-0">
                              <span className="text-sm font-medium text-gray-900 dark:text-white">
                                {fight.decision && TranslationUtils.getDecisionName(t, fight.decision)} (
                                {fight.method && TranslationUtils.getDecisionMethodName(t, fight.method)})
                              </span>
                            </div>
                          </div>
                          
                          {fight.decision !== 'Decision' && (
                            <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                              <div className="w-7 h-7 rounded bg-red-100 dark:bg-red-900/30 flex items-center justify-center flex-shrink-0">
                                <FontAwesomeIcon icon={faClock} className="w-3 h-3 text-red-600 dark:text-red-400" />
                              </div>
                              <div className="flex-1 min-w-0">
                                <span className="text-sm font-medium text-gray-900 dark:text-white">
                                  {t('round', { postProcess: 'capitalize' })} {fight.round} {t('at')} {DateUtils.secondsToMMSS(fight.time!)}
                                </span>
                              </div>
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
          {state !== 'getting_event' && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded bg-blue-600 flex items-center justify-center">
                  <FontAwesomeIcon icon={faFistRaised} className="w-4 h-4 text-white" />
                </div>
                <div>
                  <div className="text-lg font-semibold text-gray-900 dark:text-white">
                    {t('fightsCounter', { count: fights.length })}
                  </div>
                </div>
              </div>
              
              <div className="text-sm text-gray-500 dark:text-gray-400">
                MMA Scorecard
              </div>
            </div>
          )}
        </div>
      </footer>
    </div>
  )
}
