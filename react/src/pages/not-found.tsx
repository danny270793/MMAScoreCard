import { type FC } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faArrowLeft,
  faExclamationTriangle,
  faHome,
  faSearch,
  faFistRaised,
  faInfoCircle,
  faRedo,
} from '@fortawesome/free-solid-svg-icons'

export const NotFound: FC = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()

  const handleRefresh = () => {
    window.location.reload()
  }

  const quickLinks = [
    {
      name: t('events', { postProcess: 'capitalize' }),
      url: '/events',
      icon: faFistRaised,
      color: 'text-red-600 dark:text-red-400',
      bgColor: 'bg-red-100 dark:bg-red-900/30',
      description: t('browseUpcomingEvents', { postProcess: 'capitalize' })
    },
    {
      name: t('home', { postProcess: 'capitalize' }),
      url: '/',
      icon: faHome,
      color: 'text-blue-600 dark:text-blue-400',
      bgColor: 'bg-blue-100 dark:bg-blue-900/30',
      description: t('goBackToMainPage', { postProcess: 'capitalize' })
    },
    {
      name: t('about', { postProcess: 'capitalize' }),
      url: '/about',
      icon: faInfoCircle,
      color: 'text-purple-600 dark:text-purple-400',
      bgColor: 'bg-purple-100 dark:bg-purple-900/30',
      description: t('learnMoreAboutApp', { postProcess: 'capitalize' })
    }
  ]

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
                  {t('notFound', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  {t('pageNotFound', { postProcess: 'capitalize' })}
                </p>
              </div>
            </div>
            <button
              onClick={handleRefresh}
              className="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 hover:bg-yellow-50 dark:hover:bg-yellow-900/30 text-gray-600 dark:text-gray-300 hover:text-yellow-600 dark:hover:text-yellow-400 transition-colors duration-200 min-w-[40px] min-h-[40px] flex items-center justify-center"
            >
              <FontAwesomeIcon icon={faRedo} className="w-4 h-4" />
            </button>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        
        {/* 404 Hero Section */}
        <section className="text-center mb-12">
          <div className="mb-8">
            <div className="w-24 h-24 sm:w-32 sm:h-32 rounded-full bg-gradient-to-r from-yellow-100 to-orange-100 dark:from-yellow-900/30 dark:to-orange-900/30 flex items-center justify-center mx-auto mb-6">
              <FontAwesomeIcon icon={faExclamationTriangle} className="w-12 h-12 sm:w-16 sm:h-16 text-yellow-600 dark:text-yellow-400" />
            </div>
            <h2 className="text-4xl sm:text-5xl md:text-6xl font-bold text-gray-900 dark:text-white mb-4">
              404
            </h2>
            <h3 className="text-xl sm:text-2xl font-semibold text-gray-800 dark:text-gray-200 mb-3">
              {t('oopsPageNotFound', { postProcess: 'capitalize' })}
            </h3>
            <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto text-base sm:text-lg">
              {t('pageNotFoundDescription', { postProcess: 'capitalize' })}
            </p>
          </div>

          {/* Current Path Display */}
          <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm mb-8">
            <div className="flex items-center justify-center gap-3 mb-2">
              <FontAwesomeIcon icon={faSearch} className="w-4 h-4 text-gray-500 dark:text-gray-400" />
              <span className="text-sm font-medium text-gray-600 dark:text-gray-400">{t('requestedUrl', { postProcess: 'capitalize' })}</span>
            </div>
            <code className="text-sm sm:text-base font-mono bg-gray-100 dark:bg-gray-800 text-gray-800 dark:text-gray-200 px-3 py-2 rounded-md break-all">
              {globalThis.location.pathname}
            </code>
          </div>
        </section>

        {/* Quick Navigation Section */}
        <section className="mb-8">
          <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-6 text-center">
            {t('whereWouldYouLikeToGo', { postProcess: 'capitalize' })}
          </h3>
          
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4">
            {quickLinks.map((link) => (
              <Link
                key={link.name}
                to={link.url}
                className="group bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 shadow-sm hover:shadow-md hover:border-gray-300 dark:hover:border-gray-700 transition-all duration-200 text-center"
              >
                <div className={`w-12 h-12 rounded-lg ${link.bgColor} flex items-center justify-center mx-auto mb-4 group-hover:scale-105 transition-transform duration-200`}>
                  <FontAwesomeIcon icon={link.icon} className={`w-6 h-6 ${link.color}`} />
                </div>
                <h4 className="text-lg font-semibold text-gray-900 dark:text-white mb-2 group-hover:text-gray-700 dark:group-hover:text-gray-200 transition-colors duration-200">
                  {link.name}
                </h4>
                <p className="text-sm text-gray-600 dark:text-gray-400">
                  {link.description}
                </p>
              </Link>
            ))}
          </div>
        </section>

        {/* Help Section */}
        <section>
          <div className="bg-gradient-to-r from-blue-50 to-indigo-50 dark:from-blue-900/20 dark:to-indigo-900/20 rounded-lg border border-blue-200 dark:border-blue-800 p-6 sm:p-8 text-center">
            <div className="flex justify-center mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-r from-blue-500 to-indigo-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faInfoCircle} className="w-6 h-6 text-white" />
              </div>
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              {t('stillLost', { postProcess: 'capitalize' })}
            </h3>
            <p className="text-gray-600 dark:text-gray-400 mb-4">
              {t('stillLostDescription', { postProcess: 'capitalize' })}
            </p>
            <div className="flex flex-col sm:flex-row gap-3 justify-center">
              <button
                onClick={() => navigate(-1)}
                className="px-4 py-2 bg-blue-600 hover:bg-blue-700 text-white font-medium rounded-lg transition-colors duration-200"
              >
                {t('goBack', { postProcess: 'capitalize' })}
              </button>
              <button
                onClick={handleRefresh}
                className="px-4 py-2 bg-gray-600 hover:bg-gray-700 text-white font-medium rounded-lg transition-colors duration-200"
              >
                {t('refreshPage', { postProcess: 'capitalize' })}
              </button>
            </div>
          </div>
        </section>
      </main>

      {/* Clean footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded bg-yellow-600 flex items-center justify-center">
                <FontAwesomeIcon icon={faExclamationTriangle} className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-lg font-semibold text-gray-900 dark:text-white">
                  {t('pageNotFound', { postProcess: 'capitalize' })}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  {t('error404', { postProcess: 'capitalize' })}
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
