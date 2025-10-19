import { type FC } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faArrowLeft,
  faCog,
  faInfoCircle,
  faPalette,
  faLanguage,
  faShieldAlt,
  faFileAlt,
  faChevronRight,
} from '@fortawesome/free-solid-svg-icons'

export const SettingsPage: FC = () => {
  const navigate = useNavigate()
  const { t } = useTranslation()

  const settingsOptions = [
    {
      name: t('information', { postProcess: 'capitalize' }),
      description: t('informationDescription', { postProcess: 'capitalize' }),
      url: '/about',
      icon: faInfoCircle,
      color: 'text-blue-600 dark:text-blue-400',
      bgColor: 'bg-blue-100 dark:bg-blue-900/30'
    },
    {
      name: t('appearance', { postProcess: 'capitalize' }),
      description: t('appearanceDescription', { postProcess: 'capitalize' }),
      url: '/appearance',
      icon: faPalette,
      color: 'text-purple-600 dark:text-purple-400',
      bgColor: 'bg-purple-100 dark:bg-purple-900/30'
    },
    {
      name: t('language', { postProcess: 'capitalize' }),
      description: t('changeAppLanguageDescription', { postProcess: 'capitalize' }),
      url: '/language',
      icon: faLanguage,
      color: 'text-indigo-600 dark:text-indigo-400',
      bgColor: 'bg-indigo-100 dark:bg-indigo-900/30'
    },
    {
      name: t('privacyPolicy', { postProcess: 'capitalize' }),
      description: t('privacyPolicyDescription', { postProcess: 'capitalize' }),
      url: '/privacy-policy',
      icon: faShieldAlt,
      color: 'text-red-600 dark:text-red-400',
      bgColor: 'bg-red-100 dark:bg-red-900/30'
    },
    {
      name: t('termsConditions', { postProcess: 'capitalize' }),
      description: t('termsConditionsDescription', { postProcess: 'capitalize' }),
      url: '/terms-conditions',
      icon: faFileAlt,
      color: 'text-orange-600 dark:text-orange-400',
      bgColor: 'bg-orange-100 dark:bg-orange-900/30'
    }
  ]

  return (
    <div className="bg-gray-50 dark:bg-gray-900" style={{ paddingTop: 'env(safe-area-inset-top)' }}>
      {/* Clean header */}
      <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 shadow-sm">
        <div className="px-4 sm:px-6 py-4 sm:py-5">
          <div className="flex items-center gap-3 sm:gap-4">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200 min-w-[40px] min-h-[40px] flex items-center justify-center"
            >
              <FontAwesomeIcon icon={faArrowLeft} className="w-4 h-4" />
            </button>
            <div className="flex items-center gap-3 flex-1">
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-gray-600 dark:bg-gray-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faCog} className="w-4 h-4 sm:w-5 sm:h-5 text-white" />
              </div>
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {t('settings', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  {t('appPreferencesConfiguration', { postProcess: 'capitalize' })}
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        
        {/* Settings Options */}
        <section>
          <div className="space-y-3">
            {settingsOptions.map((option) => (
              option.url === '#' ? (
                <div
                  key={option.name}
                  className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm opacity-60"
                >
                  <div className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-lg ${option.bgColor} flex items-center justify-center flex-shrink-0`}>
                      <FontAwesomeIcon icon={option.icon} className={`w-5 h-5 ${option.color}`} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
                        {option.name}
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {option.description}
                      </p>
                    </div>
                    <div className="text-gray-400 dark:text-gray-500">
                      <span className="text-xs text-gray-500 dark:text-gray-400">{t('comingSoon', { postProcess: 'capitalize' })}</span>
                    </div>
                  </div>
                </div>
              ) : (
                <Link
                  key={option.name}
                  to={option.url}
                  className="group bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm hover:shadow-md hover:border-gray-300 dark:hover:border-gray-700 transition-all duration-200 block"
                >
                  <div className="flex items-center gap-4">
                    <div className={`w-10 h-10 rounded-lg ${option.bgColor} flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition-transform duration-200`}>
                      <FontAwesomeIcon icon={option.icon} className={`w-5 h-5 ${option.color}`} />
                    </div>
                    <div className="flex-1 min-w-0">
                      <h3 className="text-lg font-semibold text-gray-900 dark:text-white mb-1 group-hover:text-gray-700 dark:group-hover:text-gray-200 transition-colors duration-200">
                        {option.name}
                      </h3>
                      <p className="text-sm text-gray-600 dark:text-gray-400">
                        {option.description}
                      </p>
                    </div>
                    <div className="text-gray-400 dark:text-gray-500 group-hover:text-gray-600 dark:group-hover:text-gray-300 transition-colors duration-200">
                      <FontAwesomeIcon icon={faChevronRight} className="w-4 h-4" />
                    </div>
                  </div>
                </Link>
              )
            ))}
          </div>
        </section>

        {/* App Info Section */}
        <section className="mt-12">
          <div className="bg-gradient-to-r from-gray-50 to-slate-50 dark:from-gray-800/50 dark:to-slate-800/50 rounded-lg border border-gray-200 dark:border-gray-700 p-6 sm:p-8 text-center">
            <div className="flex justify-center mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-r from-gray-500 to-slate-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faCog} className="w-6 h-6 text-white" />
              </div>
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              {t('mmaScoreCardSettings')}
            </h3>
            <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">
              {t('customizeExperienceDescription', { postProcess: 'capitalize' })}
            </p>
          </div>
        </section>
      </main>

      {/* Clean footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded bg-gray-600 flex items-center justify-center">
                <FontAwesomeIcon icon={faCog} className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-lg font-semibold text-gray-900 dark:text-white">
                  {t('settings', { postProcess: 'capitalize' })}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  {t('appConfiguration', { postProcess: 'capitalize' })}
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
