import { useTranslation } from 'react-i18next'
import { App, type AppInfo } from '@capacitor/app'
import { useEffect, useState, type FC } from 'react'
import { useNavigate } from 'react-router-dom'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import {
  faArrowLeft,
  faUser,
  faEnvelope,
  faGlobe,
  faCode,
  faVideo,
  faBriefcase,
  faHeart,
  faMobile,
  faHashtag,
  faWrench,
} from '@fortawesome/free-solid-svg-icons'
import { PullToRefresh } from '../components/pull-to-refresh'

export const AboutPage: FC = () => {
  const { t } = useTranslation()
  const [appInfo, setAppInfo] = useState<AppInfo | undefined>(undefined)
  const [isRefreshing, setIsRefreshing] = useState(false)
  const navigate = useNavigate()

  const getAppInfo = async () => {
    try {
    const info: AppInfo = await App.getInfo()
    setAppInfo(info)
    } catch (error) {
      // Fallback for web environment when Capacitor is not available
      console.log('Using fallback app info for web environment:', error)
      setAppInfo({
        name: 'MMA Scorecard',
        id: 'com.dannymma.scorecard',
        build: '1',
        version: '1.0.0'
      })
    }
  }

  const handleRefresh = async () => {
    setIsRefreshing(true)
    await getAppInfo()
    setIsRefreshing(false)
  }

  useEffect(() => {
    getAppInfo()
  }, [])

  const socialLinks = [
    {
      name: 'Website',
      url: 'https://danny270793.github.io',
      icon: faGlobe,
      color: 'text-blue-600 dark:text-blue-400',
      bgColor: 'bg-blue-100 dark:bg-blue-900/30'
    },
    {
      name: 'GitHub',
      url: 'https://www.github.com/danny270793',
      icon: faCode,
      color: 'text-gray-800 dark:text-gray-200',
      bgColor: 'bg-gray-100 dark:bg-gray-800'
    },
    {
      name: 'YouTube',
      url: 'https://www.youtube.com/channel/UC5MAQWU2s2VESTXaUo-ysgg',
      icon: faVideo,
      color: 'text-red-600 dark:text-red-400',
      bgColor: 'bg-red-100 dark:bg-red-900/30'
    },
    {
      name: 'LinkedIn',
      url: 'https://www.linkedin.com/in/danny270793',
      icon: faBriefcase,
      color: 'text-blue-700 dark:text-blue-300',
      bgColor: 'bg-blue-100 dark:bg-blue-900/30'
    }
  ]

  return (
    <div className="bg-gray-50 dark:bg-gray-900" style={{ paddingTop: 'env(safe-area-inset-top)' }}>
      <PullToRefresh onRefresh={handleRefresh} isRefreshing={isRefreshing}>
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
              <div className="min-w-0 flex-1">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {t('about', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  App Information & Developer
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        
        {/* App Information Section */}
        <section className="mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <FontAwesomeIcon icon={faMobile} className="w-5 h-5" />
            {t('application', { postProcess: 'capitalize' })}
          </h2>
          
          {/* App Info Loading State */}
      {!appInfo && (
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
              <div className="space-y-3">
                {[1, 2, 3].map((i) => (
                  <div key={i} className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                    <div className="w-7 h-7 rounded bg-gray-200 dark:bg-gray-700 animate-pulse flex-shrink-0"></div>
                    <div className="flex-1 min-w-0">
                      <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-2/3 animate-pulse"></div>
                    </div>
                    <div className="h-4 bg-gray-200 dark:bg-gray-700 rounded w-1/4 animate-pulse"></div>
                  </div>
                ))}
              </div>
            </div>
          )}

          {/* App Info Details */}
          {appInfo && (
            <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
              <div className="space-y-3">
                {/* App Name */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-purple-100 dark:bg-purple-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faMobile} className="w-3 h-3 text-purple-600 dark:text-purple-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm text-gray-600 dark:text-gray-400">{t('name', { postProcess: 'capitalize' })}</span>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {appInfo.name}
                  </div>
                </div>

                {/* Version */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-green-100 dark:bg-green-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faHashtag} className="w-3 h-3 text-green-600 dark:text-green-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm text-gray-600 dark:text-gray-400">{t('version', { postProcess: 'capitalize' })}</span>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {appInfo.version}
                  </div>
                </div>

                {/* Build Number */}
                <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                  <div className="w-7 h-7 rounded bg-orange-100 dark:bg-orange-900/30 flex items-center justify-center flex-shrink-0">
                    <FontAwesomeIcon icon={faWrench} className="w-3 h-3 text-orange-600 dark:text-orange-400" />
                  </div>
                  <div className="flex-1 min-w-0">
                    <span className="text-sm text-gray-600 dark:text-gray-400">{t('buildNumber', { postProcess: 'capitalize' })}</span>
                  </div>
                  <div className="text-sm font-medium text-gray-900 dark:text-white">
                    {appInfo.build}
                  </div>
                </div>
              </div>
            </div>
          )}
        </section>

        {/* Developer Section */}
        <section className="mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <FontAwesomeIcon icon={faUser} className="w-5 h-5" />
            Developer
          </h2>
          
          <div className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm">
            <div className="space-y-3">
              {/* Developer Name */}
              <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-7 h-7 rounded bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center flex-shrink-0">
                  <FontAwesomeIcon icon={faUser} className="w-3 h-3 text-blue-600 dark:text-blue-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <span className="text-sm text-gray-600 dark:text-gray-400">{t('name', { postProcess: 'capitalize' })}</span>
                </div>
                <div className="text-sm font-medium text-gray-900 dark:text-white">
                  Danny Vaca
                </div>
              </div>

              {/* Email */}
              <div className="flex items-center gap-3 p-2 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-7 h-7 rounded bg-red-100 dark:bg-red-900/30 flex items-center justify-center flex-shrink-0">
                  <FontAwesomeIcon icon={faEnvelope} className="w-3 h-3 text-red-600 dark:text-red-400" />
                </div>
                <div className="flex-1 min-w-0">
                  <span className="text-sm text-gray-600 dark:text-gray-400">{t('email', { postProcess: 'capitalize' })}</span>
                </div>
                <div className="text-sm font-medium text-gray-900 dark:text-white">
                  <a 
                    href="mailto:danny270793@gmail.com"
                    className="hover:text-red-600 dark:hover:text-red-400 transition-colors duration-200"
                  >
                    danny270793@gmail.com
                  </a>
                </div>
              </div>
            </div>
          </div>
        </section>

        {/* Social Links Section */}
        <section className="mb-8">
          <h2 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4 flex items-center gap-2">
            <FontAwesomeIcon icon={faGlobe} className="w-5 h-5" />
            {t('social', { postProcess: 'capitalize' })}
          </h2>
          
          <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
            {socialLinks.map((link) => (
              <a
                key={link.name}
                href={link.url}
                target="_blank"
                rel="noopener noreferrer"
                className="group bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-4 sm:p-6 shadow-sm hover:shadow-md hover:border-gray-300 dark:hover:border-gray-700 transition-all duration-200"
              >
                <div className="flex items-center gap-4">
                  <div className={`w-10 h-10 rounded-lg ${link.bgColor} flex items-center justify-center flex-shrink-0 group-hover:scale-105 transition-transform duration-200`}>
                    <FontAwesomeIcon icon={link.icon} className={`w-5 h-5 ${link.color}`} />
                  </div>
                  <div className="flex-1 min-w-0">
                    <h3 className="text-lg font-semibold text-gray-900 dark:text-white group-hover:text-gray-700 dark:group-hover:text-gray-200 transition-colors duration-200">
                      {link.name}
                    </h3>
                    <p className="text-sm text-gray-600 dark:text-gray-400 truncate">
                      {link.url.replace('https://', '').replace('www.', '')}
                    </p>
                  </div>
                  <div className="text-gray-400 dark:text-gray-500 group-hover:text-gray-600 dark:group-hover:text-gray-300 transition-colors duration-200">
                    <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                      <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M10 6H6a2 2 0 00-2 2v10a2 2 0 002 2h10a2 2 0 002-2v-4M14 4h6m0 0v6m0-6L10 14" />
                    </svg>
                  </div>
                </div>
              </a>
            ))}
          </div>
        </section>

        {/* Thank You Section */}
        <section>
          <div className="bg-gradient-to-r from-purple-50 to-blue-50 dark:from-purple-900/20 dark:to-blue-900/20 rounded-lg border border-purple-200 dark:border-purple-800 p-6 sm:p-8 text-center">
            <div className="flex justify-center mb-4">
              <div className="w-12 h-12 rounded-full bg-gradient-to-r from-purple-500 to-blue-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faHeart} className="w-6 h-6 text-white" />
              </div>
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              Thank You for Using MMA Scorecard!
            </h3>
            <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">
              Built with passion for MMA fans. Follow the latest fights, track your favorite fighters, and stay updated with the world of mixed martial arts.
            </p>
          </div>
        </section>
      </main>

      {/* Clean footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          {appInfo && (
            <div className="flex items-center justify-between">
              <div className="flex items-center gap-3">
                <div className="w-8 h-8 rounded bg-purple-600 flex items-center justify-center">
                  <FontAwesomeIcon icon={faMobile} className="w-4 h-4 text-white" />
                </div>
                <div>
                  <div className="text-lg font-semibold text-gray-900 dark:text-white">
                    {appInfo.name}
                  </div>
                  <div className="text-sm text-gray-500 dark:text-gray-400">
                    v{appInfo.version} (Build {appInfo.build})
                  </div>
                </div>
              </div>
              
              <div className="text-sm text-gray-500 dark:text-gray-400">
                © 2024 Danny Vaca
              </div>
            </div>
          )}
        </div>
      </footer>
      </PullToRefresh>
    </div>
  )
}
