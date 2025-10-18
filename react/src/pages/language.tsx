import { type FC } from 'react'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faArrowLeft,
  faLanguage,
  faCheck,
  faGlobe,
} from '@fortawesome/free-solid-svg-icons'

export const LanguagePage: FC = () => {
  const { t, i18n } = useTranslation()
  const navigate = useNavigate()

  const languages = [
    {
      code: 'en',
      name: 'English',
      nativeName: 'English',
      flag: '🇺🇸'
    },
    {
      code: 'es',
      name: 'Spanish',
      nativeName: 'Español',
      flag: '🇪🇸'
    }
  ]

  const currentLanguage = i18n.language

  const handleLanguageChange = (languageCode: string) => {
    i18n.changeLanguage(languageCode)
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
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
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-indigo-600 dark:bg-indigo-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faLanguage} className="w-4 h-4 sm:w-5 sm:h-5 text-white" />
              </div>
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {t('language', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  {t('chooseLanguage', { postProcess: 'capitalize' })}
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        
        {/* Current Language Info */}
        <section className="mb-8">
          <div className="bg-gradient-to-r from-indigo-50 to-blue-50 dark:from-indigo-900/20 dark:to-blue-900/20 rounded-lg border border-indigo-200 dark:border-indigo-800 p-6 sm:p-8 text-center">
            <div className="flex justify-center mb-4">
              <div className="w-16 h-16 rounded-full bg-gradient-to-r from-indigo-500 to-blue-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faGlobe} className="w-8 h-8 text-white" />
              </div>
            </div>
            <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              {t('currentLanguage', { postProcess: 'capitalize' })}
            </h2>
            <p className="text-lg text-indigo-700 dark:text-indigo-300 font-semibold">
              {languages.find(lang => lang.code === currentLanguage)?.nativeName || 'English'}
            </p>
            <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
              {t('selectLanguageDescription', { postProcess: 'capitalize' })}
            </p>
          </div>
        </section>

        {/* Language Options */}
        <section>
          <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-6">
            {t('availableLanguages', { postProcess: 'capitalize' })}
          </h3>
          
          <div className="space-y-4">
            {languages.map((language) => (
              <button
                key={language.code}
                onClick={() => handleLanguageChange(language.code)}
                className={`group w-full p-4 sm:p-6 rounded-lg border shadow-sm transition-all duration-200 text-left ${
                  currentLanguage === language.code
                    ? 'bg-indigo-50 dark:bg-indigo-900/20 border-indigo-200 dark:border-indigo-700 ring-2 ring-indigo-500 dark:ring-indigo-400'
                    : 'bg-white dark:bg-gray-900 border-gray-200 dark:border-gray-800 hover:shadow-md hover:border-gray-300 dark:hover:border-gray-700'
                }`}
              >
                <div className="flex items-center gap-4">
                  <div className="text-3xl flex-shrink-0">
                    {language.flag}
                  </div>
                  <div className="flex-1 min-w-0">
                    <h4 className="text-lg font-semibold text-gray-900 dark:text-white mb-1">
                      {language.nativeName}
                    </h4>
                    <p className="text-sm text-gray-600 dark:text-gray-400">
                      {language.name}
                    </p>
                  </div>
                  {currentLanguage === language.code && (
                    <div className="flex-shrink-0">
                      <div className="w-6 h-6 rounded-full bg-indigo-500 flex items-center justify-center">
                        <FontAwesomeIcon icon={faCheck} className="w-3 h-3 text-white" />
                      </div>
                    </div>
                  )}
                </div>
              </button>
            ))}
          </div>
        </section>

        {/* Language Info Section */}
        <section className="mt-12">
          <div className="bg-gradient-to-r from-gray-50 to-slate-50 dark:from-gray-800/50 dark:to-slate-800/50 rounded-lg border border-gray-200 dark:border-gray-700 p-6 sm:p-8 text-center">
            <div className="flex justify-center mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-r from-gray-500 to-slate-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faLanguage} className="w-6 h-6 text-white" />
              </div>
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              {t('multilingualSupport', { postProcess: 'capitalize' })}
            </h3>
            <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">
              {t('multilingualDescription')}
            </p>
          </div>
        </section>
      </main>

      {/* Clean footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded bg-indigo-600 flex items-center justify-center">
                <FontAwesomeIcon icon={faLanguage} className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-lg font-semibold text-gray-900 dark:text-white">
                  {t('languageSettings', { postProcess: 'capitalize' })}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  {languages.find(lang => lang.code === currentLanguage)?.nativeName || 'English'}
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
