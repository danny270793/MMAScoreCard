import { type FC } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowLeft, faShieldAlt } from '@fortawesome/free-solid-svg-icons'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

export const PrivacyPolicyPage: FC = () => {
  const { t } = useTranslation()
  const navigate = useNavigate()

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Header */}
      <header className="sticky top-0 z-50 bg-white dark:bg-gray-900 border-b border-gray-200 dark:border-gray-800 shadow-sm" style={{ paddingTop: 'env(safe-area-inset-top)' }}>
        <div className="px-4 sm:px-6 lg:px-8 py-4 sm:py-6">
          <div className="flex items-center gap-4">
            <button
              onClick={() => navigate(-1)}
              className="p-2 rounded-lg bg-gray-100 dark:bg-gray-800 text-gray-600 dark:text-gray-300 hover:bg-gray-200 dark:hover:bg-gray-700 transition-colors duration-200 min-w-[40px] min-h-[40px] flex items-center justify-center"
            >
              <FontAwesomeIcon icon={faArrowLeft} className="w-4 h-4" />
            </button>

            <div className="flex items-center gap-3 flex-1 min-w-0">
              <div className="w-10 h-10 sm:w-12 sm:h-12 rounded-lg bg-red-600 dark:bg-red-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faShieldAlt} className="w-5 h-5 sm:w-6 sm:h-6 text-white" />
              </div>
              <div className="flex-1 min-w-0">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {t('privacyPolicy', { postProcess: 'capitalize' })}
                </h1>
                <p className="text-xs sm:text-sm text-gray-600 dark:text-gray-400">
                  {t('appName')}
                </p>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Content */}
      <main className="px-4 sm:px-6 lg:px-8 py-6 sm:py-8 max-w-4xl mx-auto">
        {/* Introduction */}
        <div className="bg-gradient-to-r from-red-50 to-pink-50 dark:from-red-900/20 dark:to-pink-900/20 rounded-lg border border-red-200 dark:border-red-800 p-6 sm:p-8 text-center mb-8 sm:mb-12">
          <div className="w-16 h-16 rounded-full bg-red-100 dark:bg-red-900/30 mx-auto mb-4 flex items-center justify-center">
            <FontAwesomeIcon icon={faShieldAlt} className="w-8 h-8 text-red-600 dark:text-red-400" />
          </div>
          <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
            Política de Privacidad
          </h2>
          <p className="text-lg text-red-700 dark:text-red-300 font-semibold">
            MMA Scorecard App
          </p>
          <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
            Última actualización: {new Date().toLocaleDateString('es-ES')}
          </p>
        </div>

        {/* Privacy Policy Content */}
        <div className="space-y-8">
          {/* Section 1: Introduction */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              1. Introducción
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                En MMA Scorecard, respetamos su privacidad y nos comprometemos a proteger su información personal. 
                Esta Política de Privacidad explica cómo recopilamos, usamos, divulgamos y protegemos su información 
                cuando utiliza nuestra aplicación móvil MMA Scorecard.
              </p>
            </div>
          </section>

          {/* Section 2: Information We Collect */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              2. Información que Recopilamos
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-red-500 dark:bg-red-400 mt-2 flex-shrink-0"></div>
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-1">Información de Uso</h4>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    Recopilamos información sobre cómo utiliza la aplicación, incluidas las páginas visitadas y las funciones utilizadas.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-red-500 dark:bg-red-400 mt-2 flex-shrink-0"></div>
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-1">Información del Dispositivo</h4>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    Podemos recopilar información sobre su dispositivo, incluyendo el modelo, sistema operativo y versión de la aplicación.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-red-500 dark:bg-red-400 mt-2 flex-shrink-0"></div>
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-1">Preferencias de Usuario</h4>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    Almacenamos sus preferencias de configuración, como el idioma y el tema seleccionado, localmente en su dispositivo.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Section 3: How We Use Information */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              3. Cómo Utilizamos la Información
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-blue-500 dark:bg-blue-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Mejorar la aplicación:</strong> Utilizamos la información para mejorar la funcionalidad y la experiencia del usuario.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-blue-500 dark:bg-blue-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Personalización:</strong> Usamos sus preferencias para personalizar su experiencia en la aplicación.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-blue-500 dark:bg-blue-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Soporte técnico:</strong> La información nos ayuda a proporcionar soporte técnico y resolver problemas.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Section 4: Data Security */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              4. Seguridad de los Datos
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Implementamos medidas de seguridad técnicas y organizativas apropiadas para proteger su información 
                personal contra el acceso no autorizado, alteración, divulgación o destrucción. La mayoría de sus 
                datos se almacenan localmente en su dispositivo y no se transmiten a servidores externos.
              </p>
            </div>
          </section>

          {/* Section 5: Data Sharing */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              5. Compartir Información
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                No vendemos, comercializamos ni transferimos su información personal a terceros. Podemos compartir 
                información únicamente en las siguientes circunstancias:
              </p>
              <ul className="list-disc list-inside text-gray-600 dark:text-gray-400 mt-4 space-y-2">
                <li>Con su consentimiento explícito</li>
                <li>Para cumplir con obligaciones legales</li>
                <li>Para proteger nuestros derechos o seguridad</li>
                <li>En caso de fusión o adquisición empresarial</li>
              </ul>
            </div>
          </section>

          {/* Section 6: Your Rights */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              6. Sus Derechos
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-green-500 dark:bg-green-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Acceso:</strong> Puede acceder a la información que tenemos sobre usted.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-green-500 dark:bg-green-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Rectificación:</strong> Puede solicitar la corrección de información inexacta.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-green-500 dark:bg-green-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Eliminación:</strong> Puede solicitar la eliminación de sus datos personales.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Section 7: Contact */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              7. Contacto
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Si tiene preguntas sobre esta Política de Privacidad o sobre cómo manejamos su información personal, 
                puede contactarnos a través de:
              </p>
              <div className="mt-4 p-4 bg-gray-50 dark:bg-gray-800/50 rounded-lg">
                <p className="text-gray-900 dark:text-white font-semibold">MMA Scorecard Team</p>
                <p className="text-gray-600 dark:text-gray-400">Email: privacy@mmascorecard.app</p>
              </div>
            </div>
          </section>

          {/* Last Updated */}
          <div className="bg-gradient-to-r from-gray-50 to-slate-50 dark:from-gray-800/50 dark:to-slate-800/50 rounded-lg border border-gray-200 dark:border-gray-700 p-6 sm:p-8 text-center">
            <div className="w-12 h-12 rounded-full bg-gray-100 dark:bg-gray-800 mx-auto mb-4 flex items-center justify-center">
              <FontAwesomeIcon icon={faShieldAlt} className="w-6 h-6 text-gray-600 dark:text-gray-400" />
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              Actualizaciones de la Política
            </h3>
            <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">
              Esta política de privacidad puede actualizarse periódicamente. Le notificaremos sobre cambios significativos 
              a través de la aplicación.
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded bg-red-600 dark:bg-red-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faShieldAlt} className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-lg font-semibold text-gray-900 dark:text-white">
                  {t('appName')}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  Protegemos tu privacidad
                </div>
              </div>
            </div>
            <div className="text-sm text-gray-500 dark:text-gray-400">
              © 2024 MMA Scorecard. Todos los derechos reservados.
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}
