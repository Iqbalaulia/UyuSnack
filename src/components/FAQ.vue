<template>
  <section id="faq" class="faq section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">{{ t('faq.title') }}</h2>
        <p class="section-subtitle">{{ t('faq.subtitle') }}</p>
      </SectionReveal>

      <div class="faq__list">
        <SectionReveal
          v-for="(key, index) in faqKeys"
          :key="key"
          :style="{ transitionDelay: `${index * 80}ms` }"
        >
          <div
            class="faq__item"
            :class="{ 'faq__item--open': openIndex === index }"
          >
            <button
              class="faq__question"
              @click="toggle(index)"
              :aria-expanded="openIndex === index"
            >
              <span>{{ t(`faq.items.${key}.q`) }}</span>
              <span class="faq__icon" :class="{ 'faq__icon--open': openIndex === index }">
                <ChevronIcon :size="20" />
              </span>
            </button>
            <transition name="faq">
              <div v-show="openIndex === index" class="faq__answer">
                <p>{{ t(`faq.items.${key}.a`) }}</p>
              </div>
            </transition>
          </div>
        </SectionReveal>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import { useI18n } from 'vue-i18n'
import ChevronIcon from './icons/ChevronIcon.vue'
import SectionReveal from './SectionReveal.vue'

const { t } = useI18n()

const openIndex = ref(0)

const toggle = (index) => {
  openIndex.value = openIndex.value === index ? -1 : index
}

const faqKeys = ['halal', 'shelfLife', 'shipping', 'hampers', 'payment']
</script>

<style scoped>
.faq {
  background: var(--color-white);
}

.faq__list {
  max-width: 720px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.faq__item {
  background: var(--color-bg);
  border-radius: var(--radius-md);
  overflow: hidden;
  border: 1px solid var(--color-border);
}

.faq__question {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1rem 1.25rem;
  text-align: left;
  font-weight: 700;
  font-size: 0.95rem;
  color: var(--color-text);
}

.faq__icon {
  display: inline-flex;
  color: var(--color-primary);
  transition: transform 0.3s ease;
  flex-shrink: 0;
}

.faq__icon--open {
  transform: rotate(180deg);
}

.faq__answer {
  padding: 0 1.25rem 1.25rem;
  color: var(--color-text-light);
  font-size: 0.9rem;
  line-height: 1.6;
}

.faq-enter-active,
.faq-leave-active {
  transition: opacity 0.25s ease, max-height 0.25s ease;
}

.faq-enter-from,
.faq-leave-to {
  opacity: 0;
}
</style>
