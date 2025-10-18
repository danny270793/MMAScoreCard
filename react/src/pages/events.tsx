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
  faStar,
  faFire,
  faGem,
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
      className="group block active:scale-95 transition-transform duration-150"
    >
      {/* Mobile-optimized card */}
      <div className="relative bg-white/90 dark:bg-gray-900/90 backdrop-blur-lg rounded-2xl border border-white/30 dark:border-gray-700/40 p-4 sm:p-6 shadow-lg shadow-black/5 dark:shadow-black/15 active:shadow-xl transition-all duration-300">
        
        {/* Status indicator line - thicker for mobile */}
        <div className={`absolute top-0 left-4 right-4 h-1 rounded-full ${isUpcoming ? 'bg-gradient-to-r from-violet-500 via-blue-500 to-cyan-500' : 'bg-gradient-to-r from-gray-300 to-gray-400 dark:from-gray-600 dark:to-gray-700'}`}></div>

        {/* Header with title and status */}
        <div className="mb-4 pt-2">
          <div className="flex justify-between items-start gap-3 mb-3">
            <h3 className="text-lg sm:text-xl font-bold text-gray-900 dark:text-white line-clamp-2 flex-1">
              {event.name}
            </h3>
            {isUpcoming && (
              <div className="flex-shrink-0">
                <span className="inline-flex items-center gap-1.5 px-3 py-1.5 bg-gradient-to-r from-violet-500 to-blue-500 text-white text-xs font-bold rounded-full shadow-lg">
                  <FontAwesomeIcon icon={faStar} className="w-2.5 h-2.5" />
                  <span className="hidden sm:inline">{t('upcoming', { postProcess: 'capitalize' })}</span>
                  <span className="sm:hidden">Live</span>
                </span>
              </div>
            )}
          </div>
          
          {/* Fight info - mobile optimized */}
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 sm:w-9 sm:h-9 rounded-xl bg-gradient-to-br from-red-500 to-rose-600 flex items-center justify-center shadow-md">
              <FontAwesomeIcon icon={faFistRaised} className="w-3.5 h-3.5 sm:w-4 sm:h-4 text-white" />
            </div>
            <p className="text-sm sm:text-base font-medium text-gray-700 dark:text-gray-300 line-clamp-1 flex-1">
              {event.fight || 'Fight details TBD'}
            </p>
          </div>
        </div>

        {/* Compact information grid for mobile */}
        <div className="space-y-3">
          
          {/* Date info - mobile layout */}
          <div className="flex items-center gap-3 p-3 rounded-xl bg-gradient-to-r from-blue-50/80 to-indigo-50/80 dark:from-blue-900/30 dark:to-indigo-900/30 border border-blue-100/50 dark:border-blue-800/40">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-500 to-indigo-600 flex items-center justify-center shadow-md flex-shrink-0">
              <FontAwesomeIcon icon={faCalendar} className="w-4 h-4 text-white" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="flex items-center gap-2 flex-wrap">
                <span className="text-sm sm:text-base font-semibold text-blue-900 dark:text-blue-100 whitespace-nowrap">
                  {new Date(event.date).toLocaleDateString('en-US', { 
                    month: 'short', 
                    day: 'numeric',
                    year: window.innerWidth < 640 ? undefined : 'numeric'
                  })}
                </span>
                {isUpcoming && daysUntil > 0 && (
                  <div className="flex items-center gap-1.5 px-2 py-1 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-lg">
                    <FontAwesomeIcon icon={faClock} className="w-2.5 h-2.5 text-white" />
                    <span className="text-xs font-bold text-white whitespace-nowrap">
                      {daysUntil}d
                    </span>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Location info - mobile layout */}
          <div className="flex items-center gap-3 p-3 rounded-xl bg-gradient-to-r from-orange-50/80 to-amber-50/80 dark:from-orange-900/30 dark:to-amber-900/30 border border-orange-100/50 dark:border-orange-800/40">
            <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-orange-500 to-amber-600 flex items-center justify-center shadow-md flex-shrink-0">
              <FontAwesomeIcon icon={faMap} className="w-4 h-4 text-white" />
            </div>
            <div className="flex-1 min-w-0">
              <div className="text-sm sm:text-base font-semibold text-orange-900 dark:text-orange-100 truncate">
                {event.location.city.country.name}
              </div>
              <div className="text-xs sm:text-sm text-orange-700 dark:text-orange-300 truncate">
                {event.location.city.name}
              </div>
            </div>
          </div>

          {/* Venue info - mobile layout */}
          {event.location.name && (
            <div className="flex items-center gap-3 p-3 rounded-xl bg-gradient-to-r from-rose-50/80 to-pink-50/80 dark:from-rose-900/30 dark:to-pink-900/30 border border-rose-100/50 dark:border-rose-800/40">
              <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-rose-500 to-pink-600 flex items-center justify-center shadow-md flex-shrink-0">
                <FontAwesomeIcon icon={faLocation} className="w-4 h-4 text-white" />
              </div>
              <div className="flex-1 min-w-0">
                <div className="text-sm sm:text-base font-semibold text-rose-900 dark:text-rose-100 truncate">
                  {event.location.name}
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Mobile tap indicator */}
        <div className="absolute bottom-3 right-3 w-6 h-6 rounded-full bg-gradient-to-br from-violet-500/20 to-purple-600/20 border border-violet-300/30 dark:border-violet-600/40 flex items-center justify-center opacity-60 sm:opacity-0 transition-opacity">
          <div className="w-1.5 h-1.5 rounded-full bg-violet-500"></div>
        </div>
      </div>
    </a>
  )
}

const SkeletonCard: FC = () => (
  <div className="relative bg-white/90 dark:bg-gray-900/90 backdrop-blur-lg rounded-2xl border border-white/30 dark:border-gray-700/40 p-4 sm:p-6 shadow-lg shadow-black/5 dark:shadow-black/15">
    
    {/* Status indicator line */}
    <div className="absolute top-0 left-4 right-4 h-1 rounded-full bg-gradient-to-r from-violet-300 via-blue-300 to-cyan-300 dark:from-violet-600 dark:via-blue-600 dark:to-cyan-600 animate-pulse"></div>

    {/* Header skeleton */}
    <div className="mb-4 pt-2">
      <div className="flex justify-between items-start gap-3 mb-3">
        <div className="h-6 sm:h-7 bg-gray-200 dark:bg-gray-700 rounded-lg w-3/4 animate-pulse"></div>
        <div className="h-6 w-12 bg-gradient-to-r from-violet-200 to-blue-200 dark:from-violet-700 dark:to-blue-700 rounded-full animate-pulse"></div>
      </div>
      
      {/* Fight info skeleton */}
      <div className="flex items-center gap-2.5">
        <div className="w-8 h-8 sm:w-9 sm:h-9 rounded-xl bg-gradient-to-br from-red-200 to-rose-300 dark:from-red-700 dark:to-rose-700 animate-pulse"></div>
        <div className="h-4 sm:h-5 bg-gray-200 dark:bg-gray-700 rounded w-1/2 animate-pulse"></div>
      </div>
    </div>

    {/* Compact information grid skeleton */}
    <div className="space-y-3">
      
      {/* Date info skeleton */}
      <div className="flex items-center gap-3 p-3 rounded-xl bg-gradient-to-r from-blue-50/80 to-indigo-50/80 dark:from-blue-900/30 dark:to-indigo-900/30 border border-blue-100/50 dark:border-blue-800/40">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-200 to-indigo-300 dark:from-blue-700 dark:to-indigo-700 animate-pulse flex-shrink-0"></div>
        <div className="flex-1">
          <div className="h-4 bg-blue-200 dark:bg-blue-800 rounded w-2/3 animate-pulse"></div>
        </div>
      </div>

      {/* Location info skeleton */}
      <div className="flex items-center gap-3 p-3 rounded-xl bg-gradient-to-r from-orange-50/80 to-amber-50/80 dark:from-orange-900/30 dark:to-amber-900/30 border border-orange-100/50 dark:border-orange-800/40">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-orange-200 to-amber-300 dark:from-orange-700 dark:to-amber-700 animate-pulse flex-shrink-0"></div>
        <div className="flex-1">
          <div className="h-4 bg-orange-200 dark:bg-orange-800 rounded w-3/4 animate-pulse mb-1"></div>
          <div className="h-3 bg-orange-100 dark:bg-orange-900 rounded w-1/2 animate-pulse"></div>
        </div>
      </div>

      {/* Venue info skeleton */}
      <div className="flex items-center gap-3 p-3 rounded-xl bg-gradient-to-r from-rose-50/80 to-pink-50/80 dark:from-rose-900/30 dark:to-pink-900/30 border border-rose-100/50 dark:border-rose-800/40">
        <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-rose-200 to-pink-300 dark:from-rose-700 dark:to-pink-700 animate-pulse flex-shrink-0"></div>
        <div className="flex-1">
          <div className="h-4 bg-rose-200 dark:bg-rose-800 rounded w-4/5 animate-pulse"></div>
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
    <div className="min-h-screen bg-gradient-to-br from-violet-50 via-blue-50 to-cyan-50 dark:from-gray-900 dark:via-purple-900/20 dark:to-blue-900/20 relative overflow-hidden">
      {/* Background decorative elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-br from-violet-400/10 to-purple-600/10 rounded-full blur-3xl"></div>
        <div className="absolute top-1/4 right-1/4 w-80 h-80 bg-gradient-to-br from-blue-400/10 to-cyan-600/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 left-1/3 w-72 h-72 bg-gradient-to-br from-emerald-400/10 to-teal-600/10 rounded-full blur-3xl"></div>
      </div>

      {/* Mobile-optimized header */}
      <header className="sticky top-0 z-50 bg-white/90 dark:bg-gray-900/90 backdrop-blur-lg border-b border-white/30 dark:border-gray-700/40 shadow-lg shadow-black/5 dark:shadow-black/15">
        <div className="px-4 sm:px-6 py-4 sm:py-5">
          <div className="flex items-center justify-between mb-4 sm:mb-5">
            <div className="flex items-center gap-3 sm:gap-4 flex-1">
              <div className="relative">
                <div className="w-10 h-10 sm:w-12 sm:h-12 md:w-14 md:h-14 rounded-2xl bg-gradient-to-br from-red-500 via-red-600 to-rose-600 flex items-center justify-center shadow-lg shadow-red-500/25">
                  <FontAwesomeIcon icon={faFistRaised} className="w-4 h-4 sm:w-5 sm:h-5 md:w-6 md:h-6 text-white" />
                </div>
                <div className="absolute -top-0.5 -right-0.5 w-3 h-3 sm:w-4 sm:h-4 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full flex items-center justify-center">
                  <FontAwesomeIcon icon={faStar} className="w-1.5 h-1.5 sm:w-2 sm:h-2 text-white" />
                </div>
              </div>
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl lg:text-3xl font-bold bg-gradient-to-r from-gray-900 via-purple-800 to-blue-900 dark:from-white dark:via-purple-200 dark:to-blue-200 bg-clip-text text-transparent truncate">
                  {t('events', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm md:text-base font-medium text-gray-600 dark:text-gray-300 hidden sm:block">
                  Premium MMA Fight Events
                </p>
              </div>
            </div>
            
            {/* Mobile action buttons */}
            <div className="flex items-center gap-2 sm:gap-3">
              <button
                onClick={() => setIsSearchOpen(!isSearchOpen)}
                className={`p-3 sm:p-3.5 rounded-xl sm:rounded-2xl transition-all duration-200 ${
                  isSearchOpen 
                    ? 'bg-gradient-to-br from-violet-500 to-purple-600 text-white shadow-lg shadow-violet-500/25 scale-105' 
                    : 'bg-white/80 dark:bg-gray-800/80 text-gray-700 dark:text-gray-300 active:bg-white dark:active:bg-gray-700 shadow-md'
                } min-w-[44px] min-h-[44px] flex items-center justify-center`}
              >
                <FontAwesomeIcon icon={isSearchOpen ? faTimes : faSearch} className="w-4 h-4 sm:w-5 sm:h-5" />
              </button>
              <a
                href="/about"
                className="p-3 sm:p-3.5 rounded-xl sm:rounded-2xl bg-white/80 dark:bg-gray-800/80 text-gray-700 dark:text-gray-300 active:bg-white dark:active:bg-gray-700 transition-all duration-200 shadow-md min-w-[44px] min-h-[44px] flex items-center justify-center"
              >
                <FontAwesomeIcon icon={faInfo} className="w-4 h-4 sm:w-5 sm:h-5" />
              </a>
            </div>
          </div>

          {/* Mobile search bar */}
          {isSearchOpen && (
            <div className="animate-in slide-in-from-top-2 duration-300">
              <div className="relative bg-white/90 dark:bg-gray-800/90 backdrop-blur-lg rounded-xl sm:rounded-2xl border border-white/50 dark:border-gray-700/50 shadow-lg overflow-hidden">
                <div className="flex items-center min-h-[48px]">
                  <FontAwesomeIcon 
                    icon={faSearch} 
                    className="absolute left-4 sm:left-5 w-4 h-4 sm:w-5 sm:h-5 text-violet-500 dark:text-violet-400"
                  />
                  <input
                    type="text"
                    placeholder="Search events..."
                    value={searchQuery}
                    onChange={(e) => setSearchQuery(e.target.value)}
                    className="w-full pl-12 sm:pl-14 pr-12 sm:pr-14 py-3 sm:py-4 bg-transparent border-0 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none text-base sm:text-lg font-medium"
                    autoFocus
                  />
                  <button
                    onClick={() => {
                      setIsSearchOpen(false)
                      setSearchQuery('')
                    }}
                    className="absolute right-4 sm:right-5 p-1.5 rounded-lg bg-gray-100 dark:bg-gray-700 active:bg-red-100 dark:active:bg-red-900/30 text-gray-600 dark:text-gray-400 transition-colors duration-150 min-w-[32px] min-h-[32px] flex items-center justify-center"
                  >
                    <FontAwesomeIcon icon={faTimes} className="w-3 h-3 sm:w-4 sm:h-4" />
                  </button>
                </div>
              </div>
              
              {/* Mobile search suggestions */}
              <div className="mt-4 flex items-center justify-center gap-2 flex-wrap px-2">
                <span className="text-xs sm:text-sm font-medium text-gray-600 dark:text-gray-400 hidden sm:inline">Popular:</span>
                {['UFC', 'Vegas', 'Title Fight'].map((tag) => (
                  <button
                    key={tag}
                    onClick={() => setSearchQuery(tag)}
                    className="px-3 py-1.5 sm:px-4 sm:py-2 bg-white/80 dark:bg-gray-800/80 backdrop-blur-lg rounded-lg sm:rounded-xl border border-white/50 dark:border-gray-700/50 text-xs sm:text-sm font-medium text-gray-700 dark:text-gray-300 active:bg-violet-500 active:text-white transition-all duration-200 shadow-sm"
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
        {/* Mobile-optimized refresh button */}
        <div className="flex justify-center mb-6 sm:mb-8 lg:mb-12">
          <button
            onClick={handleRefresh}
            disabled={state === 'getting_events'}
            className="group px-6 sm:px-8 lg:px-10 py-3 sm:py-4 bg-gradient-to-r from-violet-500 via-purple-500 to-blue-500 active:from-violet-600 active:via-purple-600 active:to-blue-600 disabled:from-gray-400 disabled:to-gray-500 text-white rounded-xl sm:rounded-2xl font-bold transition-all duration-200 flex items-center gap-3 sm:gap-4 shadow-lg shadow-violet-500/20 active:shadow-xl active:shadow-violet-500/30 active:scale-95 disabled:active:scale-100 disabled:cursor-not-allowed min-h-[44px]"
          >
            <FontAwesomeIcon 
              icon={faFire} 
              className={`w-4 h-4 sm:w-5 sm:h-5 lg:w-6 lg:h-6 transition-transform duration-300 ${state === 'getting_events' ? 'animate-spin' : ''}`}
            />
            <span className="text-sm sm:text-base lg:text-lg">
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
                className="group relative px-8 py-4 bg-gradient-to-r from-blue-500 to-cyan-500 hover:from-blue-600 hover:to-cyan-600 text-white rounded-2xl font-bold transition-all duration-300 shadow-2xl shadow-blue-500/25 hover:shadow-2xl hover:shadow-blue-500/40 hover:scale-105"
              >
                <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <span className="relative flex items-center gap-3">
                  <FontAwesomeIcon icon={faGem} className="w-5 h-5" />
                  View All Events
                </span>
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

      {/* Mobile-optimized footer */}
      <footer className="bg-white/90 dark:bg-gray-900/90 backdrop-blur-lg border-t border-white/30 dark:border-gray-700/40 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12 lg:mt-16">
        <div className="max-w-6xl mx-auto">
          {state !== 'getting_events' && (
            <div className="space-y-4 sm:space-y-0 sm:flex sm:items-center sm:justify-between">
              <div className="flex items-center gap-3 sm:gap-4">
                <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-xl sm:rounded-2xl bg-gradient-to-br from-violet-500 via-purple-500 to-blue-500 flex items-center justify-center shadow-lg shadow-violet-500/20">
                  <FontAwesomeIcon icon={faCalendar} className="w-4 h-4 sm:w-5 sm:h-5 lg:w-6 lg:h-6 text-white" />
                </div>
                <div className="min-w-0 flex-1">
                  <div className="text-lg sm:text-xl lg:text-2xl font-bold bg-gradient-to-r from-violet-600 via-purple-600 to-blue-600 dark:from-violet-400 dark:via-purple-400 dark:to-blue-400 bg-clip-text text-transparent">
                    {filteredEvents.length} event{filteredEvents.length === 1 ? '' : 's'}
                  </div>
                  {filteredEvents.length > 0 && (
                    <div className="flex items-center gap-2 sm:gap-3 text-xs sm:text-sm font-medium text-gray-600 dark:text-gray-300 mt-1">
                      <div className="flex items-center gap-1.5">
                        <FontAwesomeIcon icon={faClock} className="w-3 h-3 text-emerald-500" />
                        <span className="whitespace-nowrap">{filteredEvents.filter(e => e.status === 'uppcoming').length} upcoming</span>
                      </div>
                      <span className="text-gray-400 hidden sm:inline">•</span>
                      <div className="flex items-center gap-1.5 hidden sm:flex">
                        <FontAwesomeIcon icon={faFire} className="w-3 h-3 text-red-500" />
                        <span className="whitespace-nowrap">Premium Events</span>
                      </div>
                    </div>
                  )}
                </div>
              </div>
              
              {/* Mobile status indicators */}
              {filteredEvents.length > 0 && (
                <div className="flex items-center gap-3 sm:gap-4 lg:gap-6">
                  <div className="flex items-center gap-2 px-3 py-1.5 sm:px-4 sm:py-2 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/20 dark:to-teal-900/20 rounded-xl sm:rounded-2xl border border-emerald-200/50 dark:border-emerald-700/30">
                    <div className="w-2 h-2 sm:w-3 sm:h-3 rounded-full bg-gradient-to-r from-emerald-400 to-teal-500 animate-pulse"></div>
                    <span className="text-xs sm:text-sm font-medium text-emerald-700 dark:text-emerald-300 hidden sm:inline">Live Events</span>
                    <span className="text-xs font-medium text-emerald-700 dark:text-emerald-300 sm:hidden">Live</span>
                  </div>
                  <div className="flex items-center gap-2 px-3 py-1.5 sm:px-4 sm:py-2 bg-gradient-to-r from-violet-50 to-purple-50 dark:from-violet-900/20 dark:to-purple-900/20 rounded-xl sm:rounded-2xl border border-violet-200/50 dark:border-violet-700/30">
                    <div className="w-2 h-2 sm:w-3 sm:h-3 rounded-full bg-gradient-to-r from-violet-500 to-purple-600"></div>
                    <span className="text-xs sm:text-sm font-medium text-violet-700 dark:text-violet-300 hidden lg:inline">MMA Scorecard</span>
                    <span className="text-xs font-medium text-violet-700 dark:text-violet-300 lg:hidden">MMA</span>
                  </div>
                </div>
              )}
            </div>
          )}
        </div>
      </footer>
    </div>
  )
}
