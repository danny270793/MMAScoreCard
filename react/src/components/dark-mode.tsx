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

// Apply theme immediately on module load
const applyThemeImmediate = (currentTheme: Theme) => {
  console.log('Applying theme immediately:', currentTheme)
  console.log('Current document classes before:', document.documentElement.className)
  
  if (currentTheme === 'system') {
    const prefersDark = globalThis.matchMedia('(prefers-color-scheme: dark)').matches
    console.log('System prefers dark:', prefersDark)
    if (prefersDark) {
      document.documentElement.classList.add('dark')
      console.log('Added dark class (immediate)')
    } else {
      document.documentElement.classList.remove('dark')
      console.log('Removed dark class (immediate)')
    }
  } else if (currentTheme === 'dark') {
    document.documentElement.classList.add('dark')
    console.log('Added dark class (explicit dark theme - immediate)')
  } else {
    document.documentElement.classList.remove('dark')
    console.log('Removed dark class (light theme - immediate)')
  }
  
  console.log('Current document classes after:', document.documentElement.className)
  console.log('Document has dark class:', document.documentElement.classList.contains('dark'))
}

// Apply theme on module load (with safety checks)
const getInitialTheme = (): Theme => {
  try {
    if (typeof globalThis !== 'undefined' && globalThis.localStorage) {
      const savedTheme = globalThis.localStorage.getItem('theme') as Theme
      console.log('Module load - theme from localStorage:', savedTheme)
      return savedTheme || 'system'
    }
  } catch (error) {
    console.error('Error accessing localStorage:', error)
  }
  return 'system'
}

const initialTheme = getInitialTheme()
console.log('Module load - initial theme:', initialTheme)
if (typeof document !== 'undefined') {
  applyThemeImmediate(initialTheme)
}

export const DarkMode: FC = () => {
  const [theme, setTheme] = useState<Theme>(() => {
    const savedTheme = getInitialTheme()
    console.log('Component init - theme:', savedTheme)
    return savedTheme
  })

  const applyTheme = (currentTheme: Theme) => {
    applyThemeImmediate(currentTheme)
  }

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
      const newTheme = getInitialTheme()
      console.log('Storage change detected:', newTheme, 'current theme:', theme)
      if (newTheme !== theme) {
        console.log('Updating theme from storage change:', newTheme)
        setTheme(newTheme)
      }
    }

    const handleThemeChange = (event: CustomEvent<string>) => {
      const newTheme = event.detail as Theme
      console.log('Received theme change event:', newTheme, 'current theme:', theme)
      if (newTheme !== theme) {
        console.log('Setting new theme:', newTheme)
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
