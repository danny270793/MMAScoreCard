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
      className="block bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700 p-6 hover:border-gray-300 dark:hover:border-gray-600 transition-colors duration-200"
    >
      <div className="flex justify-between items-start mb-4">
        <div className="flex-1 min-w-0">
          <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1 truncate">
            {event.name}
          </h3>
          <p className="text-sm text-gray-600 dark:text-gray-400">
            {event.fight || 'Fight details TBD'}
          </p>
        </div>
        {isUpcoming && (
          <span className="text-xs font-medium text-blue-600 dark:text-blue-400 bg-blue-50 dark:bg-blue-900/30 px-2 py-1 rounded">
            {t('upcoming', { postProcess: 'capitalize' })}
          </span>
        )}
      </div>

      <div className="space-y-3">
        <div className="flex items-center gap-3 text-sm text-gray-600 dark:text-gray-400">
          <FontAwesomeIcon icon={faCalendar} className="w-4 h-4" />
          <span>
            {new Date(event.date).toLocaleDateString('en-US', { 
              year: 'numeric', 
              month: 'short', 
              day: 'numeric' 
            })}
          </span>
          {isUpcoming && daysUntil > 0 && (
            <>
              <span>•</span>
              <span className="text-blue-600 dark:text-blue-400 font-medium">
                {t('inXXDays', { days: daysUntil })}
              </span>
            </>
          )}
        </div>

        <div className="flex items-center gap-3 text-sm text-gray-600 dark:text-gray-400">
          <FontAwesomeIcon icon={faMap} className="w-4 h-4" />
          <span>
            {event.location.city.country.name}, {event.location.city.name}
          </span>
        </div>

        {event.location.name && (
          <div className="flex items-center gap-3 text-sm text-gray-600 dark:text-gray-400">
            <FontAwesomeIcon icon={faLocation} className="w-4 h-4" />
            <span>{event.location.name}</span>
          </div>
        )}
      </div>
    </a>
  )
}

const SkeletonCard: FC = () => (
  <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-700 p-6 animate-pulse">
    <div className="flex justify-between items-start mb-4">
      <div className="flex-1">
        <div className="h-5 bg-gray-200 dark:bg-gray-700 rounded mb-2 w-3/4"></div>
        <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2"></div>
      </div>
      <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-16"></div>
    </div>

    <div className="space-y-3">
      <div className="flex items-center gap-3">
        <div className="w-4 h-4 bg-gray-200 dark:bg-gray-700 rounded"></div>
        <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-32"></div>
      </div>
      <div className="flex items-center gap-3">
        <div className="w-4 h-4 bg-gray-200 dark:bg-gray-700 rounded"></div>
        <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-40"></div>
      </div>
      <div className="flex items-center gap-3">
        <div className="w-4 h-4 bg-gray-200 dark:bg-gray-700 rounded"></div>
        <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-36"></div>
      </div>
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
      <header className="bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-700 sticky top-0 z-50">
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <h1 className="text-2xl font-bold text-gray-900 dark:text-white">
              {t('events', { postProcess: 'capitalize' })}
            </h1>
            
            <div className="flex items-center gap-3">
              <button
                onClick={() => setIsSearchOpen(!isSearchOpen)}
                className="p-2 text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                <FontAwesomeIcon icon={isSearchOpen ? faTimes : faSearch} className="w-5 h-5" />
              </button>
              <a
                href="/about"
                className="p-2 text-gray-600 dark:text-gray-300 hover:text-gray-900 dark:hover:text-white transition-colors"
              >
                <FontAwesomeIcon icon={faInfo} className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Clean Search Bar */}
          {isSearchOpen && (
            <div className="mt-4">
              <div className="relative">
                <FontAwesomeIcon 
                  icon={faSearch} 
                  className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-gray-400"
                />
                <input
                  type="text"
                  placeholder={`${t('search', { postProcess: 'capitalize' })} events...`}
                  value={searchQuery}
                  onChange={(e) => setSearchQuery(e.target.value)}
                  className="w-full pl-10 pr-10 py-3 bg-gray-50 dark:bg-gray-800 border border-gray-200 dark:border-gray-700 rounded-lg text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:border-transparent"
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
      <main className="px-6 py-6 max-w-4xl mx-auto">
        {/* Simple refresh button */}
        <div className="flex justify-center mb-6">
          <button
            onClick={handleRefresh}
            disabled={state === 'getting_events'}
            className="px-6 py-2 text-sm font-medium text-gray-700 dark:text-gray-300 bg-white dark:bg-gray-800 border border-gray-300 dark:border-gray-600 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 disabled:opacity-50 transition-colors"
          >
            {state === 'getting_events' ? 'Loading...' : 'Refresh'}
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

        {/* No Events State */}
        {state !== 'getting_events' && filteredEvents.length === 0 && (
          <div className="text-center py-16">
            <FontAwesomeIcon 
              icon={searchQuery ? faSearch : faCalendar} 
              className="w-12 h-12 text-gray-400 mx-auto mb-4"
            />
            <h3 className="text-lg font-medium text-gray-900 dark:text-white mb-2">
              {searchQuery ? 'No events found' : 'No events available'}
            </h3>
            <p className="text-gray-500 dark:text-gray-400 mb-4">
              {searchQuery 
                ? 'Try different search terms' 
                : 'Check back later for upcoming events'
              }
            </p>
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="text-blue-600 dark:text-blue-400 hover:text-blue-700 dark:hover:text-blue-300 font-medium"
              >
                View all events
              </button>
            )}
          </div>
        )}

        {/* Events List */}
        {state !== 'getting_events' && filteredEvents.length > 0 && (
          <>
            {searchQuery && (
              <div className="mb-4 text-sm text-gray-600 dark:text-gray-400">
                {filteredEvents.length} result{filteredEvents.length === 1 ? '' : 's'} for "{searchQuery}"
              </div>
            )}
            <div className="space-y-4">
              {filteredEvents.map((event) => (
                <EventCard key={event.id} event={event} t={t} />
              ))}
            </div>
          </>
        )}
      </main>

      {/* Simple Footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-700 px-6 py-4">
        <div className="max-w-4xl mx-auto text-center">
          {state !== 'getting_events' && (
            <span className="text-sm text-gray-500 dark:text-gray-400">
              {t('eventsCounter', { count: filteredEvents.length })}
              {filteredEvents.length > 0 && (
                <> • {filteredEvents.filter(e => e.status === 'uppcoming').length} upcoming</>
              )}
            </span>
          )}
        </div>
      </footer>
    </div>
  )
}
