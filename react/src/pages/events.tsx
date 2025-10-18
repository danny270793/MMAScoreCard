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
      className="group block relative bg-gradient-to-br from-white via-white to-gray-50 dark:from-gray-800 dark:via-gray-800 dark:to-gray-900 rounded-2xl shadow-lg border border-gray-200/50 dark:border-gray-700/50 p-6 mb-6 hover:shadow-2xl hover:scale-[1.02] transition-all duration-300 ease-out overflow-hidden"
    >
      {/* Gradient Overlay */}
      <div className="absolute inset-0 bg-gradient-to-r from-red-500/5 via-transparent to-blue-500/5 opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
      
      {/* Status Indicator Line */}
      <div className={`absolute top-0 left-0 w-full h-1 ${isUpcoming ? 'bg-gradient-to-r from-blue-500 to-cyan-400' : 'bg-gradient-to-r from-gray-400 to-gray-500'}`}></div>
      
      <div className="relative">
        <div className="flex justify-between items-start mb-4">
          <div className="flex-1 min-w-0">
            <h3 className="text-xl font-black text-gray-900 dark:text-white truncate mb-2 group-hover:text-red-600 dark:group-hover:text-red-400 transition-colors duration-200">
              {event.name}
            </h3>
            <div className="flex items-center gap-2 mb-3">
              <div className="w-8 h-8 rounded-full bg-gradient-to-br from-red-500 to-red-600 dark:from-red-400 dark:to-red-500 flex items-center justify-center shadow-lg">
                <FontAwesomeIcon icon={faFistRaised} className="w-4 h-4 text-white" />
              </div>
              <p className="text-sm font-semibold text-gray-700 dark:text-gray-300">
                {event.fight || 'Fight details TBD'}
              </p>
            </div>
          </div>
          <div className="flex-shrink-0 ml-4">
            {isUpcoming ? (
              <div className="relative">
                <span className="inline-flex items-center px-4 py-2 rounded-full text-sm font-bold bg-gradient-to-r from-blue-500 to-cyan-400 text-white shadow-lg">
                  <div className="w-2 h-2 bg-white rounded-full mr-2 animate-pulse"></div>
                  {t('upcoming', { postProcess: 'capitalize' })}
                </span>
              </div>
            ) : (
              <span className="inline-flex items-center px-4 py-2 rounded-full text-sm font-medium bg-gradient-to-r from-gray-100 to-gray-200 text-gray-700 dark:from-gray-700 dark:to-gray-600 dark:text-gray-300 shadow-md">
                Past Event
              </span>
            )}
          </div>
        </div>

        <div className="grid grid-cols-1 gap-3">
          <div className="flex items-center gap-3 p-3 rounded-xl bg-blue-50/70 dark:bg-blue-900/20 border border-blue-100 dark:border-blue-800/50">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-400 to-blue-600 flex items-center justify-center shadow-md">
              <FontAwesomeIcon icon={faCalendar} className="w-4 h-4 text-white" />
            </div>
            <div className="flex-1">
              <span className="text-sm font-semibold text-blue-900 dark:text-blue-100">
                {new Date(event.date).toLocaleDateString('en-US', { 
                  weekday: 'short',
                  year: 'numeric', 
                  month: 'short', 
                  day: 'numeric' 
                })}
              </span>
              {isUpcoming && daysUntil > 0 && (
                <div className="flex items-center gap-2 mt-1">
                  <FontAwesomeIcon icon={faClock} className="w-3 h-3 text-emerald-500" />
                  <span className="text-xs font-bold text-emerald-600 dark:text-emerald-400 bg-emerald-50 dark:bg-emerald-900/30 px-2 py-0.5 rounded-full">
                    {t('inXXDays', { days: daysUntil })}
                  </span>
                </div>
              )}
            </div>
          </div>

          <div className="flex items-center gap-3 p-3 rounded-xl bg-orange-50/70 dark:bg-orange-900/20 border border-orange-100 dark:border-orange-800/50">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-orange-400 to-orange-600 flex items-center justify-center shadow-md">
              <FontAwesomeIcon icon={faMap} className="w-4 h-4 text-white" />
            </div>
            <div className="flex-1">
              <span className="text-sm font-semibold text-orange-900 dark:text-orange-100">
                {event.location.city.country.name}
              </span>
              <div className="text-xs text-orange-700 dark:text-orange-300 mt-0.5">
                {event.location.city.name}
              </div>
            </div>
          </div>

          {event.location.name && (
            <div className="flex items-center gap-3 p-3 rounded-xl bg-red-50/70 dark:bg-red-900/20 border border-red-100 dark:border-red-800/50">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-red-400 to-red-600 flex items-center justify-center shadow-md">
                <FontAwesomeIcon icon={faLocation} className="w-4 h-4 text-white" />
              </div>
              <div className="flex-1">
                <span className="text-sm font-semibold text-red-900 dark:text-red-100">
                  {event.location.name}
                </span>
              </div>
            </div>
          )}
        </div>

        {/* Hover Arrow */}
        <div className="absolute top-1/2 right-4 transform -translate-y-1/2 opacity-0 group-hover:opacity-100 transition-opacity duration-200">
          <div className="w-8 h-8 rounded-full bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center shadow-lg">
            <FontAwesomeIcon icon={faFistRaised} className="w-3 h-3 text-white transform rotate-12" />
          </div>
        </div>
      </div>
    </a>
  )
}

const SkeletonCard: FC = () => (
  <div className="relative bg-gradient-to-br from-white via-white to-gray-50 dark:from-gray-800 dark:via-gray-800 dark:to-gray-900 rounded-2xl shadow-lg border border-gray-200/50 dark:border-gray-700/50 p-6 mb-6 overflow-hidden">
    {/* Animated shimmer effect */}
    <div className="absolute inset-0 bg-gradient-to-r from-transparent via-white/20 to-transparent dark:via-gray-400/10 animate-pulse"></div>
    
    {/* Status Indicator Line */}
    <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-blue-300 to-cyan-300 dark:from-blue-600 dark:to-cyan-600 animate-pulse"></div>
    
    <div className="relative">
      <div className="flex justify-between items-start mb-4">
        <div className="flex-1">
          <div className="h-6 bg-gradient-to-r from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-600 rounded-lg mb-3 w-3/4 animate-pulse"></div>
          <div className="flex items-center gap-2 mb-3">
            <div className="w-8 h-8 rounded-full bg-gradient-to-br from-red-300 to-red-400 dark:from-red-600 dark:to-red-700 animate-pulse"></div>
            <div className="h-4 bg-gradient-to-r from-gray-200 to-gray-300 dark:from-gray-700 dark:to-gray-600 rounded w-1/2 animate-pulse"></div>
          </div>
        </div>
        <div className="h-8 bg-gradient-to-r from-blue-200 to-cyan-200 dark:from-blue-700 dark:to-cyan-700 rounded-full w-20 animate-pulse"></div>
      </div>

      <div className="grid grid-cols-1 gap-3">
        <div className="flex items-center gap-3 p-3 rounded-xl bg-blue-50/50 dark:bg-blue-900/10 border border-blue-100/50 dark:border-blue-800/30">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-blue-300 to-blue-400 dark:from-blue-600 dark:to-blue-700 animate-pulse"></div>
          <div className="flex-1 space-y-2">
            <div className="h-4 bg-blue-200 dark:bg-blue-800 rounded w-2/3 animate-pulse"></div>
            <div className="h-3 bg-blue-200 dark:bg-blue-800 rounded w-1/2 animate-pulse"></div>
          </div>
        </div>

        <div className="flex items-center gap-3 p-3 rounded-xl bg-orange-50/50 dark:bg-orange-900/10 border border-orange-100/50 dark:border-orange-800/30">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-orange-300 to-orange-400 dark:from-orange-600 dark:to-orange-700 animate-pulse"></div>
          <div className="flex-1 space-y-2">
            <div className="h-4 bg-orange-200 dark:bg-orange-800 rounded w-3/4 animate-pulse"></div>
            <div className="h-3 bg-orange-200 dark:bg-orange-800 rounded w-1/2 animate-pulse"></div>
          </div>
        </div>

        <div className="flex items-center gap-3 p-3 rounded-xl bg-red-50/50 dark:bg-red-900/10 border border-red-100/50 dark:border-red-800/30">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-br from-red-300 to-red-400 dark:from-red-600 dark:to-red-700 animate-pulse"></div>
          <div className="flex-1">
            <div className="h-4 bg-red-200 dark:bg-red-800 rounded w-4/5 animate-pulse"></div>
          </div>
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
    <div className="min-h-screen bg-gradient-to-br from-gray-50 via-white to-gray-100 dark:from-gray-900 dark:via-gray-900 dark:to-gray-800">
      {/* Header */}
      <header className="relative bg-gradient-to-r from-white via-white to-gray-50 dark:from-gray-800 dark:via-gray-800 dark:to-gray-900 shadow-xl border-b border-gray-200/50 dark:border-gray-700/50 sticky top-0 z-50 backdrop-blur-lg">
        {/* Gradient accent line */}
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-red-500 via-orange-500 to-red-600"></div>
        
        <div className="px-6 py-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-4">
              <div className="relative">
                <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-red-500 to-red-600 dark:from-red-400 dark:to-red-500 flex items-center justify-center shadow-xl">
                  <FontAwesomeIcon 
                    icon={faFistRaised} 
                    className="w-6 h-6 text-white" 
                  />
                </div>
                <div className="absolute -top-1 -right-1 w-4 h-4 bg-gradient-to-br from-blue-400 to-blue-500 rounded-full animate-pulse"></div>
              </div>
              <div>
                <h1 className="text-2xl font-black text-gray-900 dark:text-white bg-gradient-to-r from-red-600 to-red-500 dark:from-red-400 dark:to-red-300 bg-clip-text text-transparent">
                  {t('events', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-sm text-gray-600 dark:text-gray-400 font-medium">
                  MMA Fight Events
                </p>
              </div>
            </div>
            
            <div className="flex items-center gap-3">
              <button
                onClick={() => setIsSearchOpen(!isSearchOpen)}
                className={`p-3 rounded-xl transition-all duration-200 ${
                  isSearchOpen 
                    ? 'bg-gradient-to-br from-red-500 to-red-600 text-white shadow-lg shadow-red-500/25' 
                    : 'bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-600 dark:text-gray-300 hover:shadow-lg'
                }`}
              >
                <FontAwesomeIcon icon={isSearchOpen ? faTimes : faSearch} className="w-5 h-5" />
              </button>
              <a
                href="/about"
                className="p-3 rounded-xl bg-gray-100 hover:bg-gray-200 dark:bg-gray-700 dark:hover:bg-gray-600 text-gray-600 dark:text-gray-300 transition-all duration-200 hover:shadow-lg"
              >
                <FontAwesomeIcon icon={faInfo} className="w-5 h-5" />
              </a>
            </div>
          </div>

          {/* Enhanced Search Bar */}
          {isSearchOpen && (
            <div className="mt-6 animate-in slide-in-from-top-2 duration-300">
              <div className="relative max-w-2xl mx-auto">
                <div className="absolute inset-0 bg-gradient-to-r from-red-500/20 to-blue-500/20 rounded-2xl blur-xl"></div>
                <div className="relative bg-white/90 dark:bg-gray-800/90 backdrop-blur-md rounded-2xl border border-gray-200/50 dark:border-gray-700/50 shadow-2xl p-1">
                  <div className="relative">
                    <FontAwesomeIcon 
                      icon={faSearch} 
                      className="absolute left-4 top-1/2 transform -translate-y-1/2 w-5 h-5 text-red-500"
                    />
                    <input
                      type="text"
                      placeholder={`${t('search', { postProcess: 'capitalize' })} events, fighters, locations...`}
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full pl-12 pr-12 py-4 bg-transparent border-0 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none focus:ring-0 text-lg font-medium"
                      autoFocus
                    />
                    {searchQuery && (
                      <button
                        onClick={() => setSearchQuery('')}
                        className="absolute right-4 top-1/2 transform -translate-y-1/2 p-1 rounded-full bg-gray-200 dark:bg-gray-600 text-gray-500 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-500 transition-colors"
                      >
                        <FontAwesomeIcon icon={faTimes} className="w-3 h-3" />
                      </button>
                    )}
                  </div>
                </div>
                
                {/* Search suggestions hint */}
                <div className="mt-3 flex items-center justify-center gap-2 text-xs text-gray-500 dark:text-gray-400">
                  <span>Try searching for:</span>
                  <span className="px-2 py-1 bg-red-50 dark:bg-red-900/30 text-red-600 dark:text-red-400 rounded-md font-medium">UFC</span>
                  <span className="px-2 py-1 bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-400 rounded-md font-medium">Las Vegas</span>
                  <span className="px-2 py-1 bg-green-50 dark:bg-green-900/30 text-green-600 dark:text-green-400 rounded-md font-medium">Title Fight</span>
                </div>
              </div>
            </div>
          )}
        </div>
      </header>

      {/* Content */}
      <main className="px-6 py-8 max-w-4xl mx-auto">
        {/* Enhanced Pull to refresh indicator */}
        <div className="flex justify-center mb-8">
          <button
            onClick={handleRefresh}
            disabled={state === 'getting_events'}
            className="group relative px-8 py-4 bg-gradient-to-r from-red-500 to-red-600 hover:from-red-600 hover:to-red-700 disabled:from-red-400 disabled:to-red-500 text-white rounded-2xl font-bold transition-all duration-300 flex items-center gap-3 shadow-xl shadow-red-500/25 hover:shadow-2xl hover:shadow-red-500/30 hover:scale-105 disabled:hover:scale-100"
          >
            <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <FontAwesomeIcon 
              icon={faFistRaised} 
              className={`w-5 h-5 z-10 ${state === 'getting_events' ? 'animate-spin' : 'group-hover:scale-110 transition-transform'}`}
            />
            <span className="z-10 text-lg">
              {state === 'getting_events' ? 'Loading Events...' : 'Refresh Events'}
            </span>
          </button>
        </div>

        {/* Loading State */}
        {state === 'getting_events' && (
          <div className="space-y-6">
            <div className="text-center mb-8">
              <div className="w-16 h-16 mx-auto mb-4 rounded-full bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center animate-pulse">
                <FontAwesomeIcon icon={faFistRaised} className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">Loading Amazing Fights</h3>
              <p className="text-gray-600 dark:text-gray-400">Preparing the best MMA events for you...</p>
            </div>
            {Faker.arrayOfNumbers(5).map((i) => (
              <SkeletonCard key={`skeleton-${i}`} />
            ))}
          </div>
        )}

        {/* Enhanced No Events State */}
        {state !== 'getting_events' && filteredEvents.length === 0 && (
          <div className="text-center py-20">
            <div className="relative mb-8">
              <div className="w-32 h-32 mx-auto rounded-full bg-gradient-to-br from-gray-100 to-gray-200 dark:from-gray-700 dark:to-gray-800 flex items-center justify-center shadow-2xl">
                <FontAwesomeIcon 
                  icon={searchQuery ? faSearch : faCalendar} 
                  className="w-16 h-16 text-gray-400 dark:text-gray-500"
                />
              </div>
              <div className="absolute top-0 left-1/2 transform -translate-x-1/2 w-40 h-40 bg-gradient-to-r from-red-500/10 to-blue-500/10 rounded-full blur-3xl"></div>
            </div>
            <h3 className="text-3xl font-black text-gray-900 dark:text-white mb-4">
              {searchQuery ? 'No Fights Found' : 'No Events Available'}
            </h3>
            <p className="text-xl text-gray-500 dark:text-gray-400 mb-6 max-w-md mx-auto">
              {searchQuery 
                ? 'Try different search terms or browse all events' 
                : 'Check back later for upcoming MMA events and fights'
              }
            </p>
            {searchQuery && (
              <button
                onClick={() => setSearchQuery('')}
                className="px-6 py-3 bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white rounded-xl font-semibold transition-all duration-200 shadow-lg shadow-blue-500/25 hover:shadow-xl hover:scale-105"
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
              <div className="mb-6 p-4 bg-gradient-to-r from-blue-50 to-cyan-50 dark:from-blue-900/20 dark:to-cyan-900/20 rounded-2xl border border-blue-100 dark:border-blue-800/50">
                <div className="flex items-center gap-3">
                  <FontAwesomeIcon icon={faSearch} className="w-5 h-5 text-blue-600 dark:text-blue-400" />
                  <span className="text-blue-900 dark:text-blue-100 font-medium">
                    Found {filteredEvents.length} event{filteredEvents.length === 1 ? '' : 's'} matching "{searchQuery}"
                  </span>
                </div>
              </div>
            )}
            <div className="space-y-6">
              {filteredEvents.map((event) => (
                <EventCard key={event.id} event={event} t={t} />
              ))}
            </div>
          </>
        )}
      </main>

      {/* Enhanced Footer */}
      <footer className="relative bg-gradient-to-r from-white via-white to-gray-50 dark:from-gray-800 dark:via-gray-800 dark:to-gray-900 border-t border-gray-200/50 dark:border-gray-700/50 px-6 py-4 backdrop-blur-lg">
        {/* Gradient accent line */}
        <div className="absolute bottom-0 left-0 w-full h-1 bg-gradient-to-r from-red-500 via-orange-500 to-red-600"></div>
        
        <div className="max-w-4xl mx-auto">
          {state === 'getting_events' ? (
            <div className="flex items-center justify-center gap-3">
              <div className="w-6 h-6 rounded-full bg-gradient-to-br from-red-500 to-red-600 animate-pulse flex items-center justify-center">
                <FontAwesomeIcon icon={faFistRaised} className="w-3 h-3 text-white" />
              </div>
              <span className="text-gray-600 dark:text-gray-300 font-medium">Loading events...</span>
            </div>
          ) : (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded-xl bg-gradient-to-br from-red-500 to-red-600 flex items-center justify-center shadow-md">
                  <FontAwesomeIcon icon={faCalendar} className="w-4 h-4 text-white" />
                </div>
                <div>
                  <span className="font-bold text-gray-900 dark:text-white text-lg">
                    {t('eventsCounter', { count: filteredEvents.length })}
                  </span>
                  {filteredEvents.length > 0 && (
                    <div className="flex items-center gap-2 text-sm text-gray-500 dark:text-gray-400">
                      <FontAwesomeIcon icon={faClock} className="w-3 h-3 text-green-500" />
                      <span>
                        {filteredEvents.filter(e => e.status === 'uppcoming').length} upcoming fights
                      </span>
                    </div>
                  )}
                </div>
              </div>
              
              {filteredEvents.length > 0 && (
                <div className="hidden sm:flex items-center gap-4 text-xs text-gray-500 dark:text-gray-400">
                  <div className="flex items-center gap-1">
                    <div className="w-2 h-2 rounded-full bg-blue-500"></div>
                    <span>Live Events</span>
                  </div>
                  <div className="flex items-center gap-1">
                    <div className="w-2 h-2 rounded-full bg-red-500"></div>
                    <span>MMA Scorecard</span>
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
