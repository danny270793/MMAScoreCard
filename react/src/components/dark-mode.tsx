import { useEffect, useState, type FC } from 'react'
import { BrowserRouter, Routes, Route, useLocation } from 'react-router-dom'
import { EventsPage } from '../pages/events'
import { EventPage } from '../pages/event'
import { FightPage } from '../pages/fight'
import { FighterPage } from '../pages/fighter'
import { NotFound } from '../pages/not-found'
import { AboutPage } from '../pages/about'
import { SettingsPage } from '../pages/settings'
import { LanguagePage } from '../pages/language'
import { AppearancePage } from '../pages/appearance'

// Component to scroll to top on route changes
const ScrollToTop: FC = () => {
  const location = useLocation()
  
  useEffect(() => {
    window.scrollTo(0, 0)
  }, [location])

  return null
}

export const DarkMode: FC = () => {
  const [darkMode, setDarkMode] = useState(
    () => window.matchMedia('(prefers-color-scheme: dark)').matches,
  )

  useEffect(() => {
    const mediaQuery = window.matchMedia('(prefers-color-scheme: dark)')
    const handler = (event: MediaQueryListEvent) => setDarkMode(event.matches)

    mediaQuery.addEventListener('change', handler)

    return () => mediaQuery.removeEventListener('change', handler)
  }, [])

  // Apply dark mode class to document
  useEffect(() => {
    if (darkMode) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  }, [darkMode])

  return (
    <BrowserRouter>
      <ScrollToTop />
      <div className="min-h-screen">
        <Routes>
          <Route path="/" element={<EventsPage />} />
          <Route path="/events" element={<EventsPage />} />
          <Route path="/events/:id" element={<EventPage />} />
          <Route path="/fights/:id" element={<FightPage />} />
          <Route path="/fighters/:id" element={<FighterPage />} />
          <Route path="/settings" element={<SettingsPage />} />
          <Route path="/language" element={<LanguagePage />} />
          <Route path="/appearance" element={<AppearancePage />} />
          <Route path="/about" element={<AboutPage />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </div>
    </BrowserRouter>
  )
}
