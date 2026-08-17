<template>
  <div class="language-toggle">
    <button
      v-for="lang in availableLocales"
      :key="lang"
      class="language-toggle__btn"
      :class="{ 'language-toggle__btn--active': locale === lang }"
      @click="setLocale(lang)"
    >
      {{ $t(`language.${lang}`) }}
    </button>
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import { availableLocales } from '../locales/index.js'

const { locale } = useI18n()

const setLocale = (lang) => {
  locale.value = lang
  localStorage.setItem('uyu-snack-locale', lang)
}
</script>

<style scoped>
.language-toggle {
  display: flex;
  align-items: center;
  gap: 0.25rem;
  border: 1px solid var(--color-border);
  border-radius: 9999px;
  padding: 0.2rem;
  background: var(--color-white);
}

.language-toggle__btn {
  padding: 0.35rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--color-text-light);
  transition: var(--transition);
}

.language-toggle__btn--active {
  background: var(--color-primary);
  color: var(--color-white);
}
</style>
