import i18Next from 'i18next'
import { initReactI18next } from 'react-i18next'
import LanguageDetector from 'i18next-browser-languagedetector'
import { es } from './langs/es'
import { en } from './langs/en'
import { capitalizeProcessor } from './post-processors/capitalize'
import { uppercaseProcessor } from './post-processors/uppercase'

export const i18n = i18Next
  .use(LanguageDetector)
  .use(initReactI18next)
  .use(capitalizeProcessor)
  .use(uppercaseProcessor)
  .init({
    resources: {
      es: {
        translation: es,
      },
      en: {
        translation: en,
      },
    },
    fallbackLng: 'es',
    interpolation: {
      escapeValue: false,
    },
  })
