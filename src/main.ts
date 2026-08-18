import { createApp } from 'vue'
import App from './App.vue'
import { i18n } from './locales'
import { inject } from '@vercel/analytics'
import './style.css'

inject()

createApp(App).use(i18n).mount('#app')
