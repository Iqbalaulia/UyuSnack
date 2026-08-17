<template>
  <section id="tentang" class="about section">
    <div class="container about__container">
      <SectionReveal direction="left">
        <div class="about__image">
          <LazyImage
            src="/assets/images/about.jpg"
            alt="Tentang Uyu Snack"
            loading="lazy"
          />
        </div>
      </SectionReveal>
      <SectionReveal direction="right">
        <div class="about__content">
          <span class="about__label">{{ t('about.label') }}</span>
          <h2 class="section-title about__title">{{ t('about.title') }}</h2>
          <p class="about__text">{{ t('about.text1') }}</p>
          <p class="about__text">{{ t('about.text2') }}</p>
          <ul class="about__list">
            <li v-for="(item, index) in highlights" :key="index">
              <span class="about__check"><CheckIcon :size="12" /></span>
              {{ item }}
            </li>
          </ul>
        </div>
      </SectionReveal>
    </div>
  </section>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import CheckIcon from './icons/CheckIcon.vue'
import SectionReveal from './SectionReveal.vue'
import LazyImage from './LazyImage.vue'

const { t } = useI18n()

const highlights = [
  t('about.highlights[0]'),
  t('about.highlights[1]'),
  t('about.highlights[2]'),
  t('about.highlights[3]'),
]
</script>

<style scoped>
.about__container {
  display: grid;
  gap: 2.5rem;
  align-items: center;
}

.about__image {
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow);
}

.about__image img {
  width: 100%;
  aspect-ratio: 1 / 1;
  object-fit: cover;
}

.about__label {
  display: inline-block;
  color: var(--color-primary-dark);
  font-weight: 700;
  font-size: 0.85rem;
  margin-bottom: 0.5rem;
}

.about__title {
  text-align: left;
  margin-bottom: 1rem;
}

.about__text {
  color: var(--color-text-light);
  margin-bottom: 1rem;
  font-size: 0.95rem;
}

.about__list {
  list-style: none;
  display: grid;
  gap: 0.75rem;
  margin-top: 1.5rem;
}

.about__list li {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  font-weight: 600;
  font-size: 0.95rem;
}

.about__check {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  width: 1.5rem;
  height: 1.5rem;
  background: var(--color-primary);
  color: var(--color-white);
  border-radius: 50%;
  font-size: 0.75rem;
}

@media (min-width: 768px) {
  .about__container {
    grid-template-columns: 1fr 1fr;
    gap: 4rem;
  }
}
</style>
