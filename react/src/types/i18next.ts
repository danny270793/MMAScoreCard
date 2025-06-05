import type { Lang } from '../i18n/langs'

declare module 'i18next' {
  interface CustomTypeOptions {
    resources: {
      translation: Lang
    }
  }
}
