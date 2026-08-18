import { createI18n } from 'vue-i18n'
import { id, en } from './messages'

const savedLocale = localStorage.getItem('uyu-snack-locale') || 'id'

export const i18n = createI18n({
  legacy: false,
  locale: savedLocale,
  fallbackLocale: 'id',
  messages: {
    id,
    en,
  },
})

export const availableLocales = ['id', 'en'] as const
