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
      className="group relative block overflow-hidden"
    >
      {/* Animated background gradient */}
      <div className="absolute inset-0 bg-gradient-to-br from-violet-600/5 via-blue-500/5 to-cyan-400/5 group-hover:from-violet-600/10 group-hover:via-blue-500/10 group-hover:to-cyan-400/10 transition-all duration-700"></div>
      
      {/* Glass morphism card */}
      <div className="relative bg-white/80 dark:bg-gray-900/80 backdrop-blur-xl rounded-3xl border border-white/20 dark:border-gray-700/30 p-8 shadow-xl shadow-black/5 dark:shadow-black/20 group-hover:shadow-2xl group-hover:shadow-violet-500/10 dark:group-hover:shadow-violet-500/20 group-hover:border-violet-200/30 dark:group-hover:border-violet-700/40 transition-all duration-500 group-hover:scale-[1.02] group-hover:-translate-y-1">
        
        {/* Floating orbs decoration */}
        <div className="absolute top-4 right-4 flex gap-1">
          <div className="w-2 h-2 rounded-full bg-gradient-to-r from-violet-500 to-purple-500 animate-pulse"></div>
          <div className="w-2 h-2 rounded-full bg-gradient-to-r from-blue-500 to-cyan-500 animate-pulse" style={{animationDelay: '0.5s'}}></div>
          <div className="w-2 h-2 rounded-full bg-gradient-to-r from-emerald-500 to-teal-500 animate-pulse" style={{animationDelay: '1s'}}></div>
        </div>

        {/* Status indicator line */}
        <div className={`absolute top-0 left-8 right-8 h-0.5 rounded-full ${isUpcoming ? 'bg-gradient-to-r from-violet-500 via-blue-500 to-cyan-500' : 'bg-gradient-to-r from-gray-300 to-gray-400 dark:from-gray-600 dark:to-gray-700'}`}></div>

        <div className="flex justify-between items-start mb-6">
          <div className="flex-1 min-w-0 pr-4">
            {/* Main title with gradient */}
            <h3 className="text-2xl font-bold bg-gradient-to-r from-gray-900 via-gray-800 to-gray-900 dark:from-white dark:via-gray-100 dark:to-white bg-clip-text text-transparent mb-3 truncate group-hover:from-violet-600 group-hover:via-blue-600 group-hover:to-cyan-600 dark:group-hover:from-violet-400 dark:group-hover:via-blue-400 dark:group-hover:to-cyan-400 transition-all duration-300">
              {event.name}
            </h3>
            
            {/* Fight info with icon */}
            <div className="flex items-center gap-3 mb-4">
              <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-red-500 via-red-600 to-rose-600 flex items-center justify-center shadow-lg shadow-red-500/25 group-hover:shadow-red-500/40 transition-all duration-300 group-hover:scale-110">
                <FontAwesomeIcon icon={faFistRaised} className="w-5 h-5 text-white" />
              </div>
              <p className="text-lg font-medium text-gray-700 dark:text-gray-300 group-hover:text-gray-900 dark:group-hover:text-white transition-colors duration-300">
                {event.fight || 'Fight details TBD'}
              </p>
            </div>
          </div>

          {/* Status badge */}
          {isUpcoming && (
            <div className="relative">
              <div className="absolute inset-0 bg-gradient-to-r from-violet-500 to-blue-500 rounded-2xl blur opacity-30"></div>
              <span className="relative inline-flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-violet-500 to-blue-500 text-white text-sm font-bold rounded-2xl shadow-lg">
                <FontAwesomeIcon icon={faStar} className="w-3 h-3 animate-pulse" />
                {t('upcoming', { postProcess: 'capitalize' })}
              </span>
            </div>
          )}
        </div>

        {/* Information grid */}
        <div className="grid grid-cols-1 gap-4">
          
          {/* Date info */}
          <div className="group/item flex items-center gap-4 p-4 rounded-2xl bg-gradient-to-r from-blue-50/50 via-indigo-50/50 to-violet-50/50 dark:from-blue-900/20 dark:via-indigo-900/20 dark:to-violet-900/20 border border-blue-100/50 dark:border-blue-800/30 group-hover:border-blue-200/80 dark:group-hover:border-blue-700/50 transition-all duration-300">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-500 via-indigo-500 to-violet-500 flex items-center justify-center shadow-lg shadow-blue-500/25 group-hover/item:shadow-blue-500/40 group-hover/item:scale-110 transition-all duration-300">
              <FontAwesomeIcon icon={faCalendar} className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <div className="flex items-center gap-3">
                <span className="text-lg font-semibold text-blue-900 dark:text-blue-100">
                  {new Date(event.date).toLocaleDateString('en-US', { 
                    weekday: 'short',
                    year: 'numeric', 
                    month: 'short', 
                    day: 'numeric' 
                  })}
                </span>
                {isUpcoming && daysUntil > 0 && (
                  <>
                    <div className="w-1 h-1 rounded-full bg-emerald-500"></div>
                    <div className="flex items-center gap-2 px-3 py-1 bg-gradient-to-r from-emerald-500 to-teal-500 rounded-xl">
                      <FontAwesomeIcon icon={faClock} className="w-3 h-3 text-white" />
                      <span className="text-sm font-bold text-white">
                        {t('inXXDays', { days: daysUntil })}
                      </span>
                    </div>
                  </>
                )}
              </div>
            </div>
          </div>

          {/* Location info */}
          <div className="group/item flex items-center gap-4 p-4 rounded-2xl bg-gradient-to-r from-orange-50/50 via-amber-50/50 to-yellow-50/50 dark:from-orange-900/20 dark:via-amber-900/20 dark:to-yellow-900/20 border border-orange-100/50 dark:border-orange-800/30 group-hover:border-orange-200/80 dark:group-hover:border-orange-700/50 transition-all duration-300">
            <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-orange-500 via-amber-500 to-yellow-500 flex items-center justify-center shadow-lg shadow-orange-500/25 group-hover/item:shadow-orange-500/40 group-hover/item:scale-110 transition-all duration-300">
              <FontAwesomeIcon icon={faMap} className="w-5 h-5 text-white" />
            </div>
            <div className="flex-1">
              <div className="text-lg font-semibold text-orange-900 dark:text-orange-100">
                {event.location.city.country.name}
              </div>
              <div className="text-sm text-orange-700 dark:text-orange-300">
                {event.location.city.name}
              </div>
            </div>
          </div>

          {/* Venue info */}
          {event.location.name && (
            <div className="group/item flex items-center gap-4 p-4 rounded-2xl bg-gradient-to-r from-rose-50/50 via-pink-50/50 to-red-50/50 dark:from-rose-900/20 dark:via-pink-900/20 dark:to-red-900/20 border border-rose-100/50 dark:border-rose-800/30 group-hover:border-rose-200/80 dark:group-hover:border-rose-700/50 transition-all duration-300">
              <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-rose-500 via-pink-500 to-red-500 flex items-center justify-center shadow-lg shadow-rose-500/25 group-hover/item:shadow-rose-500/40 group-hover/item:scale-110 transition-all duration-300">
                <FontAwesomeIcon icon={faLocation} className="w-5 h-5 text-white" />
              </div>
              <div className="flex-1">
                <div className="text-lg font-semibold text-rose-900 dark:text-rose-100">
                  {event.location.name}
                </div>
                <div className="text-sm text-rose-700 dark:text-rose-300">
                  Fight Venue
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Hover indicator */}
        <div className="absolute bottom-6 right-6 opacity-0 group-hover:opacity-100 transition-opacity duration-300">
          <div className="w-10 h-10 rounded-full bg-gradient-to-br from-violet-500 to-purple-600 flex items-center justify-center shadow-lg">
            <FontAwesomeIcon icon={faGem} className="w-4 h-4 text-white animate-pulse" />
          </div>
        </div>
      </div>
    </a>
  )
}

const SkeletonCard: FC = () => (
  <div className="relative overflow-hidden">
    {/* Animated background gradient */}
    <div className="absolute inset-0 bg-gradient-to-br from-violet-100/30 via-blue-100/30 to-cyan-100/30 dark:from-violet-900/10 dark:via-blue-900/10 dark:to-cyan-900/10"></div>
    
    {/* Glass morphism card */}
    <div className="relative bg-white/70 dark:bg-gray-900/70 backdrop-blur-xl rounded-3xl border border-white/30 dark:border-gray-700/20 p-8 shadow-xl shadow-black/5 dark:shadow-black/10">
      
      {/* Floating orbs decoration */}
      <div className="absolute top-4 right-4 flex gap-1">
        <div className="w-2 h-2 rounded-full bg-gradient-to-r from-violet-300 to-purple-300 dark:from-violet-600 dark:to-purple-600 animate-pulse"></div>
        <div className="w-2 h-2 rounded-full bg-gradient-to-r from-blue-300 to-cyan-300 dark:from-blue-600 dark:to-cyan-600 animate-pulse" style={{animationDelay: '0.5s'}}></div>
        <div className="w-2 h-2 rounded-full bg-gradient-to-r from-emerald-300 to-teal-300 dark:from-emerald-600 dark:to-teal-600 animate-pulse" style={{animationDelay: '1s'}}></div>
      </div>

      {/* Status indicator line */}
      <div className="absolute top-0 left-8 right-8 h-0.5 rounded-full bg-gradient-to-r from-violet-300 via-blue-300 to-cyan-300 dark:from-violet-600 dark:via-blue-600 dark:to-cyan-600 animate-pulse"></div>

      <div className="flex justify-between items-start mb-6">
        <div className="flex-1 pr-4">
          {/* Title skeleton */}
          <div className="h-8 bg-gradient-to-r from-gray-200 via-gray-300 to-gray-200 dark:from-gray-700 dark:via-gray-600 dark:to-gray-700 rounded-2xl mb-3 w-3/4 animate-pulse"></div>
          
          {/* Fight info skeleton */}
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-2xl bg-gradient-to-br from-red-200 to-rose-300 dark:from-red-700 dark:to-rose-700 animate-pulse"></div>
            <div className="h-6 bg-gradient-to-r from-gray-200 via-gray-300 to-gray-200 dark:from-gray-700 dark:via-gray-600 dark:to-gray-700 rounded-xl w-1/2 animate-pulse"></div>
          </div>
        </div>

        {/* Badge skeleton */}
        <div className="relative">
          <div className="absolute inset-0 bg-gradient-to-r from-violet-300 to-blue-300 dark:from-violet-600 dark:to-blue-600 rounded-2xl blur opacity-30 animate-pulse"></div>
          <div className="relative h-8 w-20 bg-gradient-to-r from-violet-200 to-blue-200 dark:from-violet-700 dark:to-blue-700 rounded-2xl animate-pulse"></div>
        </div>
      </div>

      {/* Information grid skeleton */}
      <div className="grid grid-cols-1 gap-4">
        
        {/* Date info skeleton */}
        <div className="flex items-center gap-4 p-4 rounded-2xl bg-gradient-to-r from-blue-50/30 via-indigo-50/30 to-violet-50/30 dark:from-blue-900/10 dark:via-indigo-900/10 dark:to-violet-900/10 border border-blue-100/30 dark:border-blue-800/20">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-blue-200 via-indigo-200 to-violet-200 dark:from-blue-700 dark:via-indigo-700 dark:to-violet-700 animate-pulse"></div>
          <div className="flex-1">
            <div className="h-5 bg-blue-200 dark:bg-blue-800 rounded-xl w-2/3 animate-pulse mb-2"></div>
            <div className="h-4 bg-blue-100 dark:bg-blue-900 rounded-lg w-1/2 animate-pulse"></div>
          </div>
        </div>

        {/* Location info skeleton */}
        <div className="flex items-center gap-4 p-4 rounded-2xl bg-gradient-to-r from-orange-50/30 via-amber-50/30 to-yellow-50/30 dark:from-orange-900/10 dark:via-amber-900/10 dark:to-yellow-900/10 border border-orange-100/30 dark:border-orange-800/20">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-orange-200 via-amber-200 to-yellow-200 dark:from-orange-700 dark:via-amber-700 dark:to-yellow-700 animate-pulse"></div>
          <div className="flex-1">
            <div className="h-5 bg-orange-200 dark:bg-orange-800 rounded-xl w-3/4 animate-pulse mb-2"></div>
            <div className="h-4 bg-orange-100 dark:bg-orange-900 rounded-lg w-1/2 animate-pulse"></div>
          </div>
        </div>

        {/* Venue info skeleton */}
        <div className="flex items-center gap-4 p-4 rounded-2xl bg-gradient-to-r from-rose-50/30 via-pink-50/30 to-red-50/30 dark:from-rose-900/10 dark:via-pink-900/10 dark:to-red-900/10 border border-rose-100/30 dark:border-rose-800/20">
          <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-rose-200 via-pink-200 to-red-200 dark:from-rose-700 dark:via-pink-700 dark:to-red-700 animate-pulse"></div>
          <div className="flex-1">
            <div className="h-5 bg-rose-200 dark:bg-rose-800 rounded-xl w-4/5 animate-pulse"></div>
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
    <div className="min-h-screen bg-gradient-to-br from-violet-50 via-blue-50 to-cyan-50 dark:from-gray-900 dark:via-purple-900/20 dark:to-blue-900/20 relative overflow-hidden">
      {/* Background decorative elements */}
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        <div className="absolute top-0 left-1/4 w-96 h-96 bg-gradient-to-br from-violet-400/10 to-purple-600/10 rounded-full blur-3xl"></div>
        <div className="absolute top-1/4 right-1/4 w-80 h-80 bg-gradient-to-br from-blue-400/10 to-cyan-600/10 rounded-full blur-3xl"></div>
        <div className="absolute bottom-1/4 left-1/3 w-72 h-72 bg-gradient-to-br from-emerald-400/10 to-teal-600/10 rounded-full blur-3xl"></div>
      </div>

      {/* Stunning Header */}
      <header className="relative bg-white/80 dark:bg-gray-900/80 backdrop-blur-2xl border-b border-white/20 dark:border-gray-700/30 sticky top-0 z-50 shadow-2xl shadow-violet-500/5 dark:shadow-purple-500/10">
        {/* Animated gradient border */}
        <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-violet-500 via-blue-500 via-cyan-500 via-emerald-500 to-violet-500 animate-pulse bg-[length:300%_100%]" 
             style={{animation: 'gradient 8s ease infinite'}}></div>
        
        <div className="px-8 py-6">
          <div className="flex items-center justify-between">
            {/* Beautiful title with icon */}
            <div className="flex items-center gap-4">
              <div className="relative">
                <div className="absolute inset-0 bg-gradient-to-br from-red-500 to-rose-600 rounded-3xl blur-lg opacity-30"></div>
                <div className="relative w-16 h-16 rounded-3xl bg-gradient-to-br from-red-500 via-red-600 to-rose-600 flex items-center justify-center shadow-2xl shadow-red-500/30">
                  <FontAwesomeIcon icon={faFistRaised} className="w-8 h-8 text-white" />
                </div>
                <div className="absolute -top-1 -right-1 w-5 h-5 bg-gradient-to-br from-emerald-400 to-teal-500 rounded-full flex items-center justify-center animate-pulse">
                  <FontAwesomeIcon icon={faStar} className="w-2 h-2 text-white" />
                </div>
              </div>
              <div>
                <h1 className="text-4xl font-black bg-gradient-to-r from-gray-900 via-purple-800 to-blue-900 dark:from-white dark:via-purple-200 dark:to-blue-200 bg-clip-text text-transparent">
                  {t('events', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-lg font-medium text-gray-600 dark:text-gray-300 mt-1">
                  Premium MMA Fight Events
                </p>
              </div>
            </div>
            
            {/* Beautiful action buttons */}
            <div className="flex items-center gap-3">
              <button
                onClick={() => setIsSearchOpen(!isSearchOpen)}
                className={`group relative p-4 rounded-2xl transition-all duration-300 ${
                  isSearchOpen 
                    ? 'bg-gradient-to-br from-violet-500 to-purple-600 text-white shadow-2xl shadow-violet-500/30 scale-105' 
                    : 'bg-white/80 dark:bg-gray-800/80 text-gray-700 dark:text-gray-300 hover:bg-white dark:hover:bg-gray-700 hover:shadow-xl hover:scale-105 shadow-lg'
                }`}
              >
                <div className="absolute inset-0 bg-gradient-to-br from-violet-500/20 to-purple-600/20 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <FontAwesomeIcon icon={isSearchOpen ? faTimes : faSearch} className="w-5 h-5 relative z-10" />
              </button>
              <a
                href="/about"
                className="group relative p-4 rounded-2xl bg-white/80 dark:bg-gray-800/80 text-gray-700 dark:text-gray-300 hover:bg-white dark:hover:bg-gray-700 transition-all duration-300 hover:shadow-xl hover:scale-105 shadow-lg"
              >
                <div className="absolute inset-0 bg-gradient-to-br from-blue-500/20 to-cyan-600/20 rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
                <FontAwesomeIcon icon={faInfo} className="w-5 h-5 relative z-10" />
              </a>
            </div>
          </div>

          {/* Stunning Search Bar */}
          {isSearchOpen && (
            <div className="mt-8 animate-in slide-in-from-top-4 duration-500">
              <div className="relative max-w-3xl mx-auto">
                {/* Glowing background */}
                <div className="absolute inset-0 bg-gradient-to-r from-violet-500/20 via-blue-500/20 to-cyan-500/20 rounded-3xl blur-2xl"></div>
                
                {/* Glass container */}
                <div className="relative bg-white/90 dark:bg-gray-800/90 backdrop-blur-2xl rounded-3xl border border-white/40 dark:border-gray-700/40 shadow-2xl overflow-hidden">
                  <div className="absolute inset-0 bg-gradient-to-r from-violet-500/5 via-blue-500/5 to-cyan-500/5"></div>
                  <div className="relative flex items-center">
                    <FontAwesomeIcon 
                      icon={faSearch} 
                      className="absolute left-6 w-6 h-6 text-violet-500 dark:text-violet-400"
                    />
                    <input
                      type="text"
                      placeholder={`${t('search', { postProcess: 'capitalize' })} events, fighters, locations...`}
                      value={searchQuery}
                      onChange={(e) => setSearchQuery(e.target.value)}
                      className="w-full pl-16 pr-16 py-6 bg-transparent border-0 text-gray-900 dark:text-white placeholder-gray-500 dark:placeholder-gray-400 focus:outline-none text-xl font-medium"
                      autoFocus
                    />
                    {searchQuery && (
                      <button
                        onClick={() => setSearchQuery('')}
                        className="absolute right-6 p-2 rounded-xl bg-gray-200/80 dark:bg-gray-600/80 text-gray-500 dark:text-gray-300 hover:bg-gray-300 dark:hover:bg-gray-500 transition-all duration-200 hover:scale-110"
                      >
                        <FontAwesomeIcon icon={faTimes} className="w-4 h-4" />
                      </button>
                    )}
                  </div>
                </div>
                
                {/* Search suggestions */}
                <div className="mt-6 flex items-center justify-center gap-3 flex-wrap">
                  <span className="text-sm font-medium text-gray-600 dark:text-gray-400">Popular:</span>
                  {['UFC', 'Las Vegas', 'Title Fight', 'Heavyweight'].map((tag) => (
                    <button
                      key={tag}
                      onClick={() => setSearchQuery(tag)}
                      className="px-4 py-2 bg-white/80 dark:bg-gray-800/80 backdrop-blur-lg rounded-2xl border border-white/40 dark:border-gray-700/40 text-sm font-medium text-gray-700 dark:text-gray-300 hover:bg-gradient-to-r hover:from-violet-500 hover:to-purple-600 hover:text-white transition-all duration-300 hover:scale-105 shadow-lg hover:shadow-xl"
                    >
                      {tag}
                    </button>
                  ))}
                </div>
              </div>
            </div>
          )}
        </div>
      </header>

      {/* Content */}
      <main className="relative px-8 py-12 max-w-6xl mx-auto">
        {/* Stunning refresh button */}
        <div className="flex justify-center mb-12">
          <button
            onClick={handleRefresh}
            disabled={state === 'getting_events'}
            className="group relative px-10 py-4 bg-gradient-to-r from-violet-500 via-purple-500 to-blue-500 hover:from-violet-600 hover:via-purple-600 hover:to-blue-600 disabled:from-gray-400 disabled:to-gray-500 text-white rounded-2xl font-bold transition-all duration-300 flex items-center gap-4 shadow-2xl shadow-violet-500/25 hover:shadow-2xl hover:shadow-violet-500/40 hover:scale-105 disabled:hover:scale-100 disabled:cursor-not-allowed"
          >
            <div className="absolute inset-0 bg-gradient-to-r from-white/20 to-transparent rounded-2xl opacity-0 group-hover:opacity-100 transition-opacity duration-300"></div>
            <div className="relative">
              <FontAwesomeIcon 
                icon={faFire} 
                className={`w-6 h-6 ${state === 'getting_events' ? 'animate-spin' : 'group-hover:scale-110 transition-transform'}`}
              />
            </div>
            <span className="relative text-lg">
              {state === 'getting_events' ? 'Loading Amazing Events...' : 'Refresh Events'}
            </span>
          </button>
        </div>

        {/* Loading State */}
        {state === 'getting_events' && (
          <div className="space-y-8">
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
            <div className="space-y-8">
              {filteredEvents.map((event) => (
                <EventCard key={event.id} event={event} t={t} />
              ))}
            </div>
          </>
        )}
      </main>

      {/* Stunning Footer */}
      <footer className="relative bg-white/80 dark:bg-gray-900/80 backdrop-blur-2xl border-t border-white/20 dark:border-gray-700/30 px-8 py-8 mt-16">
        {/* Animated gradient border */}
        <div className="absolute bottom-0 left-0 w-full h-1 bg-gradient-to-r from-violet-500 via-blue-500 via-cyan-500 via-emerald-500 to-violet-500 animate-pulse"></div>
        
        <div className="max-w-6xl mx-auto">
          {state !== 'getting_events' && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-4">
                <div className="w-12 h-12 rounded-2xl bg-gradient-to-br from-violet-500 via-purple-500 to-blue-500 flex items-center justify-center shadow-2xl shadow-violet-500/30">
                  <FontAwesomeIcon icon={faCalendar} className="w-6 h-6 text-white" />
                </div>
                <div>
                  <div className="text-2xl font-black bg-gradient-to-r from-violet-600 via-purple-600 to-blue-600 dark:from-violet-400 dark:via-purple-400 dark:to-blue-400 bg-clip-text text-transparent">
                    {t('eventsCounter', { count: filteredEvents.length })}
                  </div>
                  {filteredEvents.length > 0 && (
                    <div className="flex items-center gap-3 text-sm font-medium text-gray-600 dark:text-gray-300">
                      <div className="flex items-center gap-2">
                        <FontAwesomeIcon icon={faClock} className="w-4 h-4 text-emerald-500" />
                        <span>{filteredEvents.filter(e => e.status === 'uppcoming').length} upcoming fights</span>
                      </div>
                      <span className="text-gray-400">•</span>
                      <div className="flex items-center gap-2">
                        <FontAwesomeIcon icon={faFire} className="w-4 h-4 text-red-500" />
                        <span>Premium Events</span>
                      </div>
                    </div>
                  )}
                </div>
              </div>
              
              {/* Beautiful status indicators */}
              {filteredEvents.length > 0 && (
                <div className="hidden lg:flex items-center gap-6">
                  <div className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-emerald-50 to-teal-50 dark:from-emerald-900/20 dark:to-teal-900/20 rounded-2xl border border-emerald-200/50 dark:border-emerald-700/30">
                    <div className="w-3 h-3 rounded-full bg-gradient-to-r from-emerald-400 to-teal-500 animate-pulse"></div>
                    <span className="text-sm font-medium text-emerald-700 dark:text-emerald-300">Live Events</span>
                  </div>
                  <div className="flex items-center gap-2 px-4 py-2 bg-gradient-to-r from-violet-50 to-purple-50 dark:from-violet-900/20 dark:to-purple-900/20 rounded-2xl border border-violet-200/50 dark:border-violet-700/30">
                    <div className="w-3 h-3 rounded-full bg-gradient-to-r from-violet-500 to-purple-600"></div>
                    <span className="text-sm font-medium text-violet-700 dark:text-violet-300">MMA Scorecard</span>
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
