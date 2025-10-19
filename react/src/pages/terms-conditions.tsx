import { type FC } from 'react'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { faArrowLeft, faFileAlt } from '@fortawesome/free-solid-svg-icons'
import { useNavigate } from 'react-router-dom'
import { useTranslation } from 'react-i18next'

export const TermsConditionsPage: FC = () => {
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
              <div className="flex-1 min-w-0">
                <h1 className="text-lg sm:text-xl md:text-2xl font-bold text-gray-900 dark:text-white truncate">
                  {t('termsConditions', { postProcess: 'capitalize' })}
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
        <div className="bg-gradient-to-r from-orange-50 to-amber-50 dark:from-orange-900/20 dark:to-amber-900/20 rounded-lg border border-orange-200 dark:border-orange-800 p-6 sm:p-8 text-center mb-8 sm:mb-12">
          <div className="w-16 h-16 rounded-full bg-orange-100 dark:bg-orange-900/30 mx-auto mb-4 flex items-center justify-center">
            <FontAwesomeIcon icon={faFileAlt} className="w-8 h-8 text-orange-600 dark:text-orange-400" />
          </div>
          <h2 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
            Términos y Condiciones
          </h2>
          <p className="text-lg text-orange-700 dark:text-orange-300 font-semibold">
            MMA Scorecard App
          </p>
          <p className="text-sm text-gray-600 dark:text-gray-400 mt-2">
            Última actualización: {new Date().toLocaleDateString('es-ES')}
          </p>
        </div>

        {/* Terms Content */}
        <div className="space-y-8">
          {/* Section 1: Acceptance of Terms */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              1. Aceptación de los Términos
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Al descargar, instalar o utilizar la aplicación MMA Scorecard, usted acepta estar sujeto a estos 
                Términos y Condiciones. Si no está de acuerdo con alguno de estos términos, no debe utilizar 
                nuestra aplicación.
              </p>
            </div>
          </section>

          {/* Section 2: Description of Service */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              2. Descripción del Servicio
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-orange-500 dark:bg-orange-400 mt-2 flex-shrink-0"></div>
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-1">Información de Eventos MMA</h4>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    La aplicación proporciona información sobre eventos, peleas y luchadores de artes marciales mixtas.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-orange-500 dark:bg-orange-400 mt-2 flex-shrink-0"></div>
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-1">Funcionalidades</h4>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    Incluye visualización de resultados, estadísticas de luchadores, detalles de eventos y configuraciones personalizables.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-orange-500 dark:bg-orange-400 mt-2 flex-shrink-0"></div>
                <div>
                  <h4 className="font-semibold text-gray-900 dark:text-white mb-1">Disponibilidad</h4>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    El servicio se proporciona "tal como está" y puede estar sujeto a interrupciones ocasionales para mantenimiento.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Section 3: User Responsibilities */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              3. Responsabilidades del Usuario
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-blue-500 dark:bg-blue-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Uso apropiado:</strong> Utilizar la aplicación únicamente para los fines previstos y de manera legal.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-blue-500 dark:bg-blue-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Prohibiciones:</strong> No realizar ingeniería inversa, modificar o distribuir la aplicación sin autorización.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-blue-500 dark:bg-blue-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Seguridad:</strong> Mantener la seguridad de su dispositivo y no compartir accesos no autorizados.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Section 4: Intellectual Property */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              4. Propiedad Intelectual
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Todos los derechos de propiedad intelectual de la aplicación MMA Scorecard, incluyendo pero no limitado 
                a software, diseño, contenido, marcas comerciales y logotipos, son propiedad exclusiva de MMA Scorecard 
                o sus licenciantes. Está prohibida cualquier reproducción o uso no autorizado.
              </p>
            </div>
          </section>

          {/* Section 5: Data and Content */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              5. Datos y Contenido
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                La información proporcionada en la aplicación se obtiene de fuentes públicas y se presenta con fines 
                informativos. No garantizamos la exactitud, completitud o actualidad de toda la información. Los usuarios 
                deben verificar la información de fuentes oficiales para tomar decisiones importantes.
              </p>
            </div>
          </section>

          {/* Section 6: Disclaimers */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              6. Limitación de Responsabilidad
            </h3>
            <div className="space-y-4">
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-amber-500 dark:bg-amber-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Servicios "tal como están":</strong> La aplicación se proporciona sin garantías de ningún tipo.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-amber-500 dark:bg-amber-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Exención de responsabilidad:</strong> No seremos responsables por daños indirectos o consecuenciales.
                  </p>
                </div>
              </div>
              <div className="flex items-start gap-3 p-3 rounded-md bg-gray-50 dark:bg-gray-800/50">
                <div className="w-2 h-2 rounded-full bg-amber-500 dark:bg-amber-400 mt-2 flex-shrink-0"></div>
                <div>
                  <p className="text-gray-600 dark:text-gray-400 text-sm">
                    <strong className="text-gray-900 dark:text-white">Limitaciones:</strong> Nuestra responsabilidad máxima no excederá el costo de la aplicación.
                  </p>
                </div>
              </div>
            </div>
          </section>

          {/* Section 7: Termination */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              7. Terminación
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Podemos terminar o suspender su acceso a la aplicación en cualquier momento, con o sin causa, 
                con o sin aviso previo. Al terminar, debe dejar de usar la aplicación y eliminarla de su dispositivo. 
                Las disposiciones que por su naturaleza deben sobrevivir la terminación continuarán en vigor.
              </p>
            </div>
          </section>

          {/* Section 8: Governing Law */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              8. Ley Aplicable
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Estos términos se regirán e interpretarán de acuerdo con las leyes aplicables, sin tener en cuenta 
                las disposiciones sobre conflictos de leyes. Cualquier disputa se resolverá en los tribunales competentes.
              </p>
            </div>
          </section>

          {/* Section 9: Contact */}
          <section className="bg-white dark:bg-gray-900 rounded-lg border border-gray-200 dark:border-gray-800 p-6 sm:p-8 shadow-sm">
            <h3 className="text-xl sm:text-2xl font-bold text-gray-900 dark:text-white mb-4">
              9. Contacto
            </h3>
            <div className="prose prose-gray dark:prose-invert max-w-none">
              <p className="text-gray-600 dark:text-gray-400 leading-relaxed">
                Si tiene preguntas sobre estos Términos y Condiciones, puede contactarnos a través de:
              </p>
              <div className="mt-4 p-4 bg-gray-50 dark:bg-gray-800/50 rounded-lg">
                <p className="text-gray-900 dark:text-white font-semibold">MMA Scorecard Team</p>
                <p className="text-gray-600 dark:text-gray-400">Email: legal@mmascorecard.app</p>
              </div>
            </div>
          </section>

          {/* Changes to Terms */}
          <div className="bg-gradient-to-r from-gray-50 to-slate-50 dark:from-gray-800/50 dark:to-slate-800/50 rounded-lg border border-gray-200 dark:border-gray-700 p-6 sm:p-8 text-center">
            <div className="w-12 h-12 rounded-full bg-gray-100 dark:bg-gray-800 mx-auto mb-4 flex items-center justify-center">
              <FontAwesomeIcon icon={faFileAlt} className="w-6 h-6 text-gray-600 dark:text-gray-400" />
            </div>
            <h3 className="text-xl font-bold text-gray-900 dark:text-white mb-2">
              Cambios en los Términos
            </h3>
            <p className="text-gray-600 dark:text-gray-400 max-w-md mx-auto">
              Nos reservamos el derecho de modificar estos términos en cualquier momento. Los cambios significativos 
              serán notificados a través de la aplicación.
            </p>
          </div>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white dark:bg-gray-900 border-t border-gray-200 dark:border-gray-800 px-4 sm:px-6 lg:px-8 py-6 sm:py-8 mt-8 sm:mt-12">
        <div className="max-w-4xl mx-auto">
          <div className="flex flex-col sm:flex-row items-center justify-between gap-4">
            <div className="flex items-center gap-3">
              <div className="w-8 h-8 rounded bg-orange-600 dark:bg-orange-500 flex items-center justify-center">
                <FontAwesomeIcon icon={faFileAlt} className="w-4 h-4 text-white" />
              </div>
              <div>
                <div className="text-lg font-semibold text-gray-900 dark:text-white">
                  {t('appName')}
                </div>
                <div className="text-sm text-gray-500 dark:text-gray-400">
                  Términos transparentes
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
