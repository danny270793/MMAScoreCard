import type { Dispatch } from '@reduxjs/toolkit'
import { useEffect, useState, type FC } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import {
  actions as backendActions,
  selectors as backendSelectors,
} from '../reducers/backend'
import { useTranslation } from 'react-i18next'
import { type Event } from '../models/event'
import { Faker } from '../utils/faker'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faCalendar,
  faInfo,
  faLocation,
  faMap,
  faSearch,
  faTimes,
  faFistRaised,
  faClock,
} from '@fortawesome/free-solid-svg-icons'
import { DateUtils } from '../utils/date-utils'
import { Logger } from '../utils/logger'

const logger: Logger = new Logger('/src/pages/events.tsx')

interface EventCardProps {
  event: Event
  t: any
}

const EventCard: FC<EventCardProps> = ({ event, t }) => {
  const daysUntil = DateUtils.daysBetween(event.date, new Date())
  const isUpcoming = event.status === 'uppcoming'

  return (
    <a
      href={`/events/${event.id}`}
      className="block bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-4 mb-4 hover:shadow-md transition-all duration-200 active:scale-[0.98]"
    >
      <div className="flex justify-between items-start mb-3">
        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-bold text-gray-900 dark:text-white truncate mb-1">
            {event.name}
          </h3>
          <p className="text-sm font-medium text-red-600 dark:text-red-400 flex items-center gap-1">
            <FontAwesomeIcon icon={faFistRaised} className="w-3 h-3" />
            {event.fight || 'Fight details TBD'}
          </p>
        </div>
        <div className="flex-shrink-0 ml-3">
          {isUpcoming ? (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200">
              {t('upcoming', { postProcess: 'capitalize' })}
            </span>
          ) : (
            <span className="inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium bg-gray-100 text-gray-800 dark:bg-gray-700 dark:text-gray-200">
              Past
            </span>
          )}
        </div>
      </div>

      <div className="space-y-2">
        <div className="flex items-center gap-2">
          <FontAwesomeIcon icon={faCalendar} className="w-4 h-4 text-blue-500" />
          <span className="text-sm text-gray-600 dark:text-gray-300">
            {event.date.toISOString().split('T')[0]}
          </span>
          {isUpcoming && daysUntil > 0 && (
            <>
              <span className="text-gray-300 dark:text-gray-600">•</span>
              <div className="flex items-center gap-1">
                <FontAwesomeIcon icon={faClock} className="w-3 h-3 text-green-500" />
                <span className="text-sm font-medium text-green-600 dark:text-green-400">
                  {t('inXXDays', { days: daysUntil })}
                </span>
              </div>
            </>
          )}
        </div>

        <div className="flex items-center gap-2">
          <FontAwesomeIcon icon={faMap} className="w-4 h-4 text-orange-500" />
          <span className="text-sm text-gray-600 dark:text-gray-300">
            {event.location.city.country.name} - {event.location.city.name}
          </span>
        </div>

        {event.location.name && (
          <div className="flex items-center gap-2">
            <FontAwesomeIcon icon={faLocation} className="w-4 h-4 text-red-500" />
            <span className="text-sm text-gray-600 dark:text-gray-300">
              {event.location.name}
            </span>
          </div>
        )}
      </div>
    </a>
  )
}

const SkeletonCard: FC = () => (
  <div className="bg-white dark:bg-gray-800 rounded-xl shadow-sm border border-gray-100 dark:border-gray-700 p-4 mb-4 animate-pulse">
    <div className="flex justify-between items-start mb-3">
      <div className="flex-1">
        <div className="h-5 bg-gray-200 dark:bg-gray-700 rounded mb-2 w-3/4"></div>
        <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2"></div>
      </div>
      <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded-full w-16"></div>
    </div>
    <div className="space-y-2">
      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3"></div>
      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4"></div>
      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2"></div>
    </div>
  </div>
)

export const EventsPage: FC = () => {
  const { t } = useTranslation()
  const dispatch: Dispatch = useDispatch()
  const [searchQuery, setSearchQuery] = useState('')
  const [isSearchOpen, setIsSearchOpen] = useState(false)

  const events: Event[] = useSelector(backendSelectors.getEvents)
  const error: Error | undefined = useSelector(backendSelectors.getError)
  const state: string = useSelector(backendSelectors.getState)

  // Filter events based on search query
  const filteredEvents = events.filter(event =>
    event.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    event.fight?.toLowerCase().includes(searchQuery.toLowerCase()) ||
    event.location.city.country.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    event.location.city.name.toLowerCase().includes(searchQuery.toLowerCase()) ||
    event.location.name.toLowerCase().includes(searchQuery.toLowerCase())
  )

  const handleRefresh = () => {
    dispatch(backendActions.getEvents())
  }

  useEffect(() => {
    dispatch(backendActions.getEvents())
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [])

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
      {/* Header */}
      <header className="bg-white dark:bg-gray-800 shadow-sm border-b border-gray-200 dark:border-gray-700 sticky top-0 z-50">
        <div className="px-4 py-3">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <FontAwesomeIcon 
                icon={faFistRaised} 
                className="w-6 h-6 text-red-600 dark:text-red-400" 
              />
              <h1 className="text-xl font-bold text-gray-900 dark:text-white">
                {t('events', { postProcess: 'capitalize' })}
              </h1>
            </div>
            
            <div className="flex items-center gap-2">
              <button
                onClick={() => setIsSearchOpen(!isSearchOpen)}
                className="p-2 rounded-lg text-gray-500 hover:text-gray-700 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-gray-200 dark:hover:bg-gray-700 transition-colors"
              >
                <FontAwesomeIcon icon={isSearchOpen ? faTimes : faSearch} className="w-5 h-5" />
              </button>
              <a
                href="/about"
                className="p-2 rounded-lg text-gray-500 hover:text-gray-700 hover:bg-gray-100 dark:text-gray-400 dark:hover:text-gray-200 dark:hover:bg-gray-700 transition-colors"
              >
                <FontAwesomeIcon icon={faInfo} className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Search Bar */}
          {isSearchOpen && (
            <div className="mt-3">
              <div className="relative">
                <FontAwesomeIcon 
                  icon={faSearch} 
                  className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400"
                />
                <input
                  type="text"
                  placeholder={`${t('search', { postProcess: 'capitalize' })} events, fighters, locations...`}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-4 py-2.5 bg-gray-100 dark:bg-gray-700 border border-gray-200 dark:border-gray-600 rounded-lg text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-red-500 focus:border-transparent"
                  autoFocus
                />
                {searchQuery && (
                  <button
                    onClick={() => setSearchQuery('')}
                    className="absolute right-3 top-1/2 transform -translate-y-1/2 text-gray-400 hover:text-gray-600 dark:hover:text-gray-200"
                  >
                    <FontAwesomeIcon icon={faTimes} className="w-4 h-4" />
                  </button>
                )}
              </div>
            </div>
          )}
        </div>
      </header>

      {/* Content */}
      <main className="px-4 py-6">
        {/* Pull to refresh indicator */}
        <div className="flex justify-center mb-4">
          <button
            onClick={handleRefresh}
            disabled={state === 'getting_events'}
            className="px-4 py-2 bg-red-600 hover:bg-red-700 disabled:bg-red-400 text-white rounded-lg font-medium transition-colors flex items-center gap-2"
          >
            <FontAwesomeIcon 
              icon={faFistRaised} 
              className={`w-4 h-4 ${state === 'getting_events' ? 'animate-spin' : ''}`}
            />
            {state === 'getting_events' ? 'Loading...' : 'Refresh Events'}
          </button>
        </div>

        {/* Loading State */}
        {state === 'getting_events' && (
          <div className="space-y-4">
            {Faker.arrayOfNumbers(5).map((i) => (
              <SkeletonCard key={`skeleton-${i}`} />
            ))}
          </div>
        )}

        {/* No Events */}
        {state !== 'getting_events' && filteredEvents.length === 0 && (
          <div className="text-center py-12">
            <FontAwesomeIcon 
              icon={faCalendar} 
              className="w-16 h-16 text-gray-300 dark:text-gray-600 mx-auto mb-4"
            />
            <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
              {searchQuery ? 'No matching events found' : t('eventsNotFound', { postProcess: 'capitalize' })}
            </h3>
            {searchQuery && (
              <p className="text-gray-500 dark:text-gray-400 mb-4">
                Try adjusting your search terms
              </p>
            )}
          </div>
        )}

        {/* Events List */}
        {state !== 'getting_events' && filteredEvents.length > 0 && (
          <div className="space-y-4">
            {filteredEvents.map((event) => (
              <EventCard key={event.id} event={event} t={t} />
            ))}
          </div>
        )}
      </main>

      {/* Footer */}
      <footer className="bg-white dark:bg-gray-800 border-t border-gray-200 dark:border-gray-700 px-4 py-3 sticky bottom-0">
        <div className="flex items-center justify-center">
          {state === 'getting_events' ? (
            <div className="flex items-center gap-2 text-gray-500 dark:text-gray-400">
              <div className="w-4 h-4 bg-gray-300 dark:bg-gray-600 rounded animate-pulse"></div>
              <span>Loading events...</span>
            </div>
          ) : (
            <div className="flex items-center gap-2 text-gray-600 dark:text-gray-300">
              <FontAwesomeIcon icon={faCalendar} className="w-4 h-4 text-red-500" />
              <span className="font-medium">
                {t('eventsCounter', { count: filteredEvents.length })}
              </span>
              {filteredEvents.length > 0 && (
                <>
                  <span className="text-gray-400">•</span>
                  <span className="text-sm">
                    {filteredEvents.filter(e => e.status === 'uppcoming').length} upcoming
                  </span>
                </>
              )}
            </div>
          )}
        </div>
      </footer>
    </div>
  )
}
