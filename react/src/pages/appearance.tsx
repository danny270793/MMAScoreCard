import { type FC, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faArrowLeft,
  faPalette,
  faCheck,
  faSun,
  faMoon,
  faDesktop,
  faEye,
} from '@fortawesome/free-solid-svg-icons'

type Theme = 'light' | 'dark' | 'system'

export const AppearancePage: FC = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()
  
  const [currentTheme, setCurrentTheme] = useState<Theme>(() => {
    const saved = localStorage.getItem('theme')
    return (saved as Theme) || 'system'
  })

  const themes = [
    {
      value: 'system' as Theme,
      name: t('systemTheme', { postProcess: 'capitalize' }),
      description: t('systemThemeDescription'),
      icon: faDesktop,
      color: 'text-blue-600 dark:text-blue-400',
      bgColor: 'bg-blue-100 dark:bg-blue-900/30',
      preview: '🖥️'
    },
    {
      value: 'light' as Theme,
      name: t('lightTheme', { postProcess: 'capitalize' }),
      description: t('lightThemeDescription'),
      icon: faSun,
      color: 'text-yellow-600 dark:text-yellow-400',
      bgColor: 'bg-yellow-100 dark:bg-yellow-900/30',
      preview: '☀️'
    },
    {
      value: 'dark' as Theme,
      name: t('darkTheme', { postProcess: 'capitalize' }),
      description: t('darkThemeDescription'),
      icon: faMoon,
      color: 'text-indigo-600 dark:text-indigo-400',
      bgColor: 'bg-indigo-100 dark:bg-indigo-900/30',
      preview: '🌙'
    }
  ]

  const handleThemeChange = (theme: Theme) => {
    setCurrentTheme(theme)
    localStorage.setItem('theme', theme)
    
    // Dispatch custom event to notify main app component
    const themeChangeEvent = new CustomEvent('themechange', { detail: theme })
    globalThis.dispatchEvent(themeChangeEvent)
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Clean header */}
      <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 shadow-sm" style={{ paddingTop: 'env(safe-area-inset-top)' }}>
        <div className="px-4 sm:px-6 py-4 sm:py-5">
          <div className="flex items-center gap-3 sm:gap-4">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200 min-w-[40px] min-h-[40px] flex items-center justify-center"
            >
              <FontAwesomeIcon icon={faArrowLeft} className="w-4 h-4" />
            </button>
            <div className="flex items-center gap-3 flex-1">
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {t('appearance', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  {t('chooseTheme', { postProcess: 'capitalize' })}
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        
        {/* Current Theme Info */}
        <section className="mb-8">
          <div className="bg-gradient-to-r from-purple-50 to-indigo-50 dark:from-purple-900/20 dark:to-indigo-900/20 rounded-lg border border-purple-200 dark:border-purple-800 p-6 sm:p-8 text-center">
            <div className="flex justify-center mb-4">
              <div className="w-16 h-16 rounded-full bg-gradient-to-r from-purple-500 to-indigo-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faEye} className="w-8 h-8 text-white" />
              </div>
            </div>
            <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              {t('currentTheme', { postProcess: 'capitalize' })}
            </h2>
            <p className="text-lg text-purple-700 dark:text-purple-300 font-semibold">
              {themes.find(theme => theme.value === currentTheme)?.name || t('systemTheme')}
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
              {t('selectThemeDescription')}
            </p>
          </div>
        </section>

        {/* Theme Options */}
        <section>
          <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-6">
            {t('availableThemes', { postProcess: 'capitalize' })}
          </h3>
          
          <div className="space-y-4">
            {themes.map((theme) => (
              <button
                key={theme.value}
                onClick={() => handleThemeChange(theme.value)}
                className={`group w-full p-4 sm:p-6 rounded-lg border shadow-sm transition-all duration-200 text-left ${
                  currentTheme === theme.value
                    ? 'bg-purple-50 dark:bg-purple-900/20 border-purple-200 dark:border-purple-700 ring-2 ring-purple-500 dark:ring-purple-400'
                    : 'bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-800 hover:shadow-md hover:border-gray-300 dark:hover:border-gray-700'
                }`}
              >
                <div className="flex items-center gap-4">
                  <div className={`w-12 h-12 rounded-lg ${theme.bgColor} flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition-transform duration-200`}>
                    <FontAwesomeIcon icon={theme.icon} className={`w-6 h-6 ${theme.color}`} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="text-lg font-semibold text-gray-900 dark:text-white mb-1 group-hover:text-gray-700 dark:group-hover:text-gray-200 transition-colors duration-200">
                      {theme.name}
                    </h4>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      {theme.description}
                    </p>
                  </div>
                  <div className="flex-shrink-0 flex items-center gap-3">
                    <span className="text-2xl">{theme.preview}</span>
                    {currentTheme === theme.value && (
                      <div className="w-6 h-6 rounded-full bg-purple-500 flex items-center justify-center">
                        <FontAwesomeIcon icon={faCheck} className="w-3 h-3 text-white" />
                      </div>
                    )}
                  </div>
                </div>
              </button>
            ))}
          </div>
        </section>

        {/* Theme Info Section */}
        <section className="mt-12">
          <div className="bg-gradient-to-r from-gray-50 to-slate-50 dark:from-gray-800/50 dark:to-slate-800/50 rounded-lg border border-gray-200 dark:border-gray-700 p-6 sm:p-8 text-center">
            <div className="flex justify-center mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-r from-gray-500 to-slate-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faPalette} className="w-6 h-6 text-white" />
              </div>
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              {t('themeCustomization')}
            </h3>
            <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">
              {t('themeCustomizationDescription')}
            </p>
          </div>
        </section>
      </main>

      {/* Clean footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded bg-purple-600 flex items-center justify-center">
                <FontAwesomeIcon icon={faPalette} className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-lg font-semibold text-gray-900 dark:text-white">
                  {t('appearance', { postProcess: 'capitalize' })}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  {themes.find(theme => theme.value === currentTheme)?.name || t('systemTheme')}
                </div>
              </div>
            </div>
            
            <div className="text-sm text-gray-500 dark:text-gray-400">
              {t('appName')}
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
