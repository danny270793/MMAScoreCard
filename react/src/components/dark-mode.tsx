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
        {/* Debug Component - Remove this when dark mode is working */}
        <div className="fixed top-0 right-0 z-50 p-4 m-4 bg-red-500 dark:bg-green-500 text-white text-sm rounded shadow-lg max-w-xs">
          <div className="font-bold mb-2">Debug Info</div>
          <div>Theme: <span className="font-mono">{theme}</span></div>
          <div>Dark class: <span className="font-mono">{document.documentElement.classList.contains('dark') ? 'YES' : 'NO'}</span></div>
          <div className="mt-2 p-2 border border-white/30 rounded">
            <div className="dark:hidden text-yellow-300">🌞 Tailwind: Light Active</div>
            <div className="hidden dark:block text-blue-300">🌙 Tailwind: Dark Active</div>
          </div>
          <div className="mt-2 p-2 border border-white/30 rounded test-dark-mode">
            Custom CSS Test
          </div>
          <div className="mt-2 space-y-1">
            <button
              onClick={() => {
                document.documentElement.classList.add('dark')
                console.log('🟢 Force added dark class')
              }}
              className="w-full px-2 py-1 bg-gray-800 text-white rounded text-xs"
            >
              Force Dark
            </button>
            <button
              onClick={() => {
                document.documentElement.classList.remove('dark')
                console.log('🔴 Force removed dark class')
              }}
              className="w-full px-2 py-1 bg-gray-200 text-black rounded text-xs"
            >
              Force Light
            </button>
          </div>
        </div>
        
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
