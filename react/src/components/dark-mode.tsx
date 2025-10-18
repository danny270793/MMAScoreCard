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
    globalThis.scrollTo(0, 0)
  }, [location])

  return null
}

type Theme = 'light' | 'dark' | 'system'

// Theme application function
const applyTheme = (currentTheme: Theme) => {
  console.log('🎨 Applying theme:', currentTheme)
  console.log('📄 Before - document classes:', document.documentElement.className)
  console.log('🌙 Before - has dark class:', document.documentElement.classList.contains('dark'))
  
  if (currentTheme === 'system') {
    const prefersDark = globalThis.matchMedia('(prefers-color-scheme: dark)').matches
    console.log('💻 System prefers dark:', prefersDark)
    if (prefersDark) {
      document.documentElement.classList.add('dark')
    } else {
      document.documentElement.classList.remove('dark')
    }
  } else if (currentTheme === 'dark') {
    document.documentElement.classList.add('dark')
    console.log('🌙 Added dark class explicitly')
  } else {
    document.documentElement.classList.remove('dark')
    console.log('☀️ Removed dark class (light mode)')
  }
  
  console.log('📄 After - document classes:', document.documentElement.className)
  console.log('🌙 After - has dark class:', document.documentElement.classList.contains('dark'))
  console.log('🎯 Theme application complete for:', currentTheme)
}

// Get theme from localStorage safely
const getThemeFromStorage = (): Theme => {
  try {
    if (typeof globalThis !== 'undefined' && globalThis.localStorage) {
      const savedTheme = globalThis.localStorage.getItem('theme') as Theme
      return savedTheme || 'system'
    }
  } catch (error) {
    console.error('Error accessing localStorage:', error)
  }
  return 'system'
}

// Apply theme immediately on module load
if (typeof document !== 'undefined') {
  const initialTheme = getThemeFromStorage()
  console.log('🚀 Module load - applying initial theme:', initialTheme)
  applyTheme(initialTheme)
}

export const DarkMode: FC = () => {
  const [theme, setTheme] = useState<Theme>(() => {
    return getThemeFromStorage()
  })

  // Apply theme on mount and theme changes
  useEffect(() => {
    applyTheme(theme)
  }, [theme])

  // Listen for system preference changes when system theme is selected
  useEffect(() => {
    if (theme === 'system') {
      const mediaQuery = globalThis.matchMedia('(prefers-color-scheme: dark)')
      const handler = () => applyTheme('system')

      mediaQuery.addEventListener('change', handler)
      return () => mediaQuery.removeEventListener('change', handler)
    }
  }, [theme])

  // Listen for localStorage changes and custom theme change events
  useEffect(() => {
    const handleStorageChange = () => {
      const newTheme = getThemeFromStorage()
      if (newTheme !== theme) {
        setTheme(newTheme)
      }
    }

    const handleThemeChange = (event: CustomEvent<string>) => {
      const newTheme = event.detail as Theme
      if (newTheme !== theme) {
        setTheme(newTheme)
      }
    }

    // Listen for storage changes (cross-tab sync)
    globalThis.addEventListener('storage', handleStorageChange)
    // Listen for custom theme change events (same-page sync)
    globalThis.addEventListener('themechange', handleThemeChange as EventListener)
    
    return () => {
      globalThis.removeEventListener('storage', handleStorageChange)
      globalThis.removeEventListener('themechange', handleThemeChange as EventListener)
    }
  }, [theme])

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
