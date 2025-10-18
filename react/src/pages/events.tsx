import type { Dispatch } from '@reduxjs/toolkit'
import { useEffect, useState, type FC } from 'react'
import { useDispatch, useSelector } from 'react-redux'
import { Link } from 'react-router-dom'
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
  faFire,
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
    <Link
      to={`/events/${event.id}`}
      className="block hover:bg-gray-50 dark:hover:bg-gray-800/50 transition-colors duration-200"
    >
      <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
        
        {/* Header */}
        <div className="mb-4">
          <div className="flex justify-between items-start gap-3 mb-2">
            <h3 className="text-lg sm:text-xl font-semibold text-gray-900 dark:text-white line-clamp-2 flex-1">
              {event.name}
            </h3>
            {isUpcoming && (
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
            <p className="text-sm font-medium text-gray-600 dark:text-gray-400 line-clamp-1 flex-1">
              {event.fight || 'Fight details TBD'}
            </p>
          </div>
        </div>

        {/* Information grid */}
        <div className="space-y-2">
          
          {/* Date info */}
          <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
            <div className="w-7 h-7 rounded bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0">
              <FontAwesomeIcon icon={faCalendar} className="w-3 h-3 text-blue-600 dark:text-blue-400" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                <span className="text-sm font-medium text-gray-900 dark:text-white">
                  {new Date(event.date).toLocaleDateString('en-US', { 
                    month: 'short', 
                    day: 'numeric',
                    year: 'numeric'
                  })}
                </span>
                {isUpcoming && daysUntil > 0 && (
                  <span className="px-2 py-0.5 bg-green-100 dark:bg-green-900/30 text-green-700 dark:text-green-300 text-xs font-medium rounded">
                    {daysUntil} days
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
              <div className="text-sm font-medium text-gray-900 dark:text-white truncate">
                {event.location.city.country.name}
              </div>
              <div className="text-xs text-gray-600 dark:text-gray-400 truncate">
                {event.location.city.name}
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
                <div className="text-sm font-medium text-gray-900 dark:text-white truncate">
                  {event.location.name}
                </div>
              </div>
            </div>
          )}
        </div>
      </div>
    </Link>
  )
}

const SkeletonCard: FC = () => (
  <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
    
    {/* Status indicator skeleton */}
    <div className="w-2 h-2 bg-gray-300 dark:bg-gray-600 rounded-full mb-3 animate-pulse"></div>

    {/* Header skeleton */}
    <div className="mb-4">
      <div className="flex justify-between items-start gap-3 mb-2">
        <div className="h-6 bg-gray-200 dark:bg-gray-700 rounded w-3/4 animate-pulse"></div>
        <div className="h-5 w-16 bg-gray-200 dark:bg-gray-700 rounded animate-pulse"></div>
      </div>
      
      {/* Fight info skeleton */}
      <div className="flex items-center gap-2">
        <div className="w-6 h-6 rounded bg-gray-200 dark:bg-gray-700 animate-pulse"></div>
        <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/2 animate-pulse"></div>
      </div>
    </div>

    {/* Information grid skeleton */}
    <div className="space-y-2">
      
      {/* Date info skeleton */}
      <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
        <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
        <div className="flex-1">
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3 animate-pulse"></div>
        </div>
      </div>

      {/* Location info skeleton */}
      <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
        <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
        <div className="flex-1">
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-3/4 animate-pulse mb-1"></div>
          <div className="h-3 bg-gray-200 dark:bg-gray-700 rounded w-1/2 animate-pulse"></div>
        </div>
      </div>

      {/* Venue info skeleton */}
      <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
        <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
        <div className="flex-1">
          <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-4/5 animate-pulse"></div>
        </div>
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

      {/* Clean header */}
      <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 shadow-sm">
        <div className="px-4 sm:px-6 py-4 sm:py-5">
          <div className="flex items-center justify-between mb-4 sm:mb-5">
            <div className="flex items-center gap-3 sm:gap-4 flex-1">
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-blue-600 dark:bg-blue-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faFistRaised} className="w-4 h-4 sm:w-5 sm:h-5 text-white" />
              </div>
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl lg:text-3xl font-bold text-gray-900 dark:text-white truncate">
                  {t('events', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm md:text-base text-gray-600 dark:text-gray-400 hidden sm:block">
                  MMA Fight Events
                </p>
              </div>
            </div>
            
            {/* Clean action buttons */}
            <div className="flex items-center gap-2 sm:gap-3">
              <button
                onClick={() => setIsSearchOpen(!isSearchOpen)}
                className={`p-3 rounded-lg transition-colors duration-200 min-w-[44px] min-h-[44px] flex items-center justify-center ${
                  isSearchOpen 
                    ? 'bg-blue-600 text-white' 
                    : 'bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700'
                }`}
              >
                <FontAwesomeIcon icon={isSearchOpen ? faTimes : faSearch} className="w-4 h-4" />
              </button>
              <Link
                to="/about"
                className="p-3 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200 min-w-[44px] min-h-[44px] flex items-center justify-center"
              >
                <FontAwesomeIcon icon={faInfo} className="w-4 h-4" />
              </Link>
            </div>
          </div>

          {/* Clean search bar */}
          {isSearchOpen && (
            <div className="animate-in slide-in-from-top-2 duration-300">
              <div className="relative bg-white dark:bg-gray-800 rounded-lg border border-gray-200 dark:border-gray-700 shadow-sm overflow-hidden">
                <div className="flex items-center min-h-[48px]">
                  <FontAwesomeIcon 
                    icon={faSearch} 
                    className="absolute left-4 w-4 h-4 text-gray-400"
                  />
                  <input
                    type="text"
                    placeholder="Search events..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-12 pr-12 py-3 bg-transparent border-0 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none text-base"
                    autoFocus
                  />
                  <button
                    onClick={() => {
                      setIsSearchOpen(false)
                      setSearchQuery('')
                    }}
                    className="absolute right-4 p-1.5 rounded-md bg-gray-100 dark:bg-gray-700 hover:bg-gray-200 dark:hover:bg-gray-600 text-gray-600 dark:text-gray-400 transition-colors duration-150 min-w-[32px] min-h-[32px] flex items-center justify-center"
                  >
                    <FontAwesomeIcon icon={faTimes} className="w-3 h-3" />
                  </button>
                </div>
              </div>
              
              {/* Clean search suggestions */}
              <div className="mt-3 flex items-center justify-center gap-2 flex-wrap">
                {['UFC', 'Vegas', 'Title Fight'].map((tag) => (
                  <button
                    key={tag}
                    onClick={() => setSearchQuery(tag)}
                    className="px-3 py-1.5 bg-gray-100 dark:bg-gray-800 rounded-md border border-gray-200 dark:border-gray-700 text-xs font-medium text-gray-700 dark:text-gray-300 hover:bg-blue-50 hover:border-blue-200 hover:text-blue-700 dark:hover:bg-blue-900/20 dark:hover:border-blue-700 dark:hover:text-blue-300 transition-colors duration-200"
                  >
                    {tag}
                  </button>
                ))}
              </div>
            </div>
          )}
        </div>
      </header>

      {/* Content */}
      <main className="relative px-4 sm:px-6 lg:px-8 py-6 sm:py-8 lg:py-12 max-w-6xl mx-auto">
        {/* Clean refresh button */}
        <div className="flex justify-center mb-6 sm:mb-8">
          <button
            onClick={handleRefresh}
            disabled={state === 'getting_events'}
            className="px-6 py-3 bg-blue-600 hover:bg-blue-700 disabled:bg-gray-400 text-white rounded-lg font-medium transition-colors duration-200 flex items-center gap-3 disabled:cursor-not-allowed min-h-[44px]"
          >
            <FontAwesomeIcon 
              icon={faFire} 
              className={`w-4 h-4 transition-transform duration-300 ${state === 'getting_events' ? 'animate-spin' : ''}`}
            />
            <span className="text-sm sm:text-base">
              {state === 'getting_events' ? 'Loading...' : 'Refresh Events'}
            </span>
          </button>
        </div>

        {/* Loading State */}
        {state === 'getting_events' && (
          <div className="space-y-4 sm:space-y-6 lg:space-y-8">
            <div className="text-center mb-12">
              <div className="relative inline-block">
                <div className="absolute inset-0 bg-gradient-to-br from-violet-500 to-purple-600 rounded-full blur-2xl opacity-30 animate-pulse"></div>
                <div className="relative w-24 h-24 rounded-full bg-gradient-to-br from-violet-500 via-purple-500 to-blue-500 flex items-center justify-center shadow-2xl shadow-violet-500/30">
                  <FontAwesomeIcon icon={faFistRaised} className="w-12 h-12 text-white animate-pulse" />
                </div>
              </div>
              <h3 className="text-3xl font-black bg-gradient-to-r from-violet-600 via-purple-600 to-blue-600 bg-clip-text text-transparent mt-6 mb-4">
                Loading Premium Events
              </h3>
              <p className="text-xl text-gray-600 dark:text-gray-300">
                Preparing the most exciting MMA fights for you...
              </p>
            </div>
            {Faker.arrayOfNumbers(3).map((i) => (
              <SkeletonCard key={`skeleton-${i}`} />
            ))}
          </div>
        )}

        {/* Stunning No Events State */}
        {state !== 'getting_events' && filteredEvents.length === 0 && (
          <div className="text-center py-24">
            <div className="relative inline-block mb-12">
              <div className="absolute inset-0 bg-gradient-to-br from-gray-400/20 to-gray-600/20 rounded-full blur-3xl"></div>
              <div className="relative w-32 h-32 rounded-full bg-gradient-to-br from-gray-100 via-gray-200 to-gray-300 dark:from-gray-700 dark:via-gray-800 dark:to-gray-900 flex items-center justify-center shadow-2xl">
                <FontAwesomeIcon 
                  icon={searchQuery ? faSearch : faCalendar} 
                  className="w-16 h-16 text-gray-400 dark:text-gray-500"
                />
              </div>
            </div>
            <h3 className="text-4xl font-black bg-gradient-to-r from-gray-600 via-gray-700 to-gray-800 dark:from-gray-300 dark:via-gray-200 dark:to-gray-100 bg-clip-text text-transparent mb-6">
              {searchQuery ? 'No Epic Fights Found' : 'No Events Available Yet'}
            </h3>
            <p className="text-xl text-gray-500 dark:text-gray-400 mb-8 max-w-md mx-auto">
              {searchQuery 
                ? 'Try different search terms to discover amazing fights' 
                : 'The next legendary battles are coming soon'
              }
            </p>
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="px-6 py-3 bg-blue-600 hover:bg-blue-700 text-white rounded-lg font-medium transition-colors duration-200"
              >
                View All Events
              </button>
            )}
          </div>
        )}

        {/* Events List */}
        {state !== 'getting_events' && filteredEvents.length > 0 && (
          <>
            {searchQuery && (
              <div className="mb-8 text-center">
                <div className="inline-flex items-center gap-3 px-6 py-3 bg-gradient-to-r from-blue-50 via-indigo-50 to-violet-50 dark:from-blue-900/20 dark:via-indigo-900/20 dark:to-violet-900/20 rounded-2xl border border-blue-200/50 dark:border-blue-700/30 shadow-lg">
                  <FontAwesomeIcon icon={faSearch} className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                  <span className="text-lg font-semibold text-blue-900 dark:text-blue-100">
                    Found {filteredEvents.length} premium event{filteredEvents.length === 1 ? '' : 's'} for "{searchQuery}"
                  </span>
                </div>
              </div>
            )}
            <div className="space-y-4 sm:space-y-6">
              {filteredEvents.map((event) => (
                <EventCard key={event.id} event={event} t={t} />
              ))}
              </div>
                  </>
                )}
      </main>

      {/* Clean footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-6xl mx-auto">
          {state !== 'getting_events' && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded bg-blue-600 flex items-center justify-center">
                  <FontAwesomeIcon icon={faCalendar} className="w-4 h-4 text-white" />
                </div>
                <div>
                  <div className="text-lg font-semibold text-gray-900 dark:text-white">
                    {filteredEvents.length} event{filteredEvents.length === 1 ? '' : 's'}
                  </div>
                  {filteredEvents.length > 0 && (
                    <div className="text-sm text-gray-600 dark:text-gray-400">
                      {filteredEvents.filter(e => e.status === 'uppcoming').length} upcoming
                    </div>
                  )}
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
