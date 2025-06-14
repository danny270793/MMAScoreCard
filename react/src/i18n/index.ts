import i18Next from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import { es } from './langs/es'
import { capitalizeProcessor } from './post-processors/capitalize'

export const i18n = i18Next
  .use(LanguageDetector)
  .use(initReactI18next)
  .use(capitalizeProcessor)
  .init({
    resources: {
      es: {
        translation: es,
      },
    },
    fallbackLng: 'es',
    interpolation: {
      escapeValue: false,
    },
  })
