<template>
  <section class="instagram section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">{{ t('instagram.title') }}</h2>
        <p class="section-subtitle">{{ t('instagram.subtitle') }}</p>
      </SectionReveal>

      <div class="instagram__grid">
        <SectionReveal v-for="(image, index) in images" :key="index" :style="{ transitionDelay: `${index * 80}ms` }">
          <a
            href="https://www.instagram.com/uyu_snack/"
            target="_blank"
            rel="noopener noreferrer"
            class="instagram__item"
          >
            <LazyImage :src="image" :alt="`Instagram Uyu Snack ${index + 1}`" loading="lazy" />
            <div class="instagram__overlay">
              <InstagramIcon :size="24" />
            </div>
          </a>
        </SectionReveal>
      </div>

      <SectionReveal>
        <div class="instagram__cta">
          <a
            href="https://www.instagram.com/uyu_snack/"
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-primary"
          >
            <InstagramIcon :size="18" /> {{ t('instagram.follow') }}
          </a>
        </div>
      </SectionReveal>
    </div>
  </section>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import SectionReveal from './SectionReveal.vue'
import LazyImage from './LazyImage.vue'
import InstagramIcon from './icons/InstagramIcon.vue'

const { t } = useI18n()

const images = [
  '/assets/burnt-cheesecake-original.jpg',
  '/assets/burnt-cheesecake-chocobery.jpg',
  '/assets/burnt-cheesecake-chocoregal.jpg',
  '/assets/hero-menu.jpg',
  '/assets/logo.png',
  '/assets/images/about.jpg',
]
</script>

<style scoped>
.instagram {
  background: var(--color-white);
}

.instagram__grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 0.75rem;
  margin-bottom: 1.5rem;
}

.instagram__item {
  position: relative;
  display: block;
  aspect-ratio: 1 / 1;
  border-radius: var(--radius-md);
  overflow: hidden;
}

.instagram__item img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.4s ease;
}

.instagram__item:hover img {
  transform: scale(1.08);
}

.instagram__overlay {
  position: absolute;
  inset: 0;
  background: rgba(0, 0, 0, 0.35);
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--color-white);
  opacity: 0;
  transition: opacity 0.3s ease;
}

.instagram__item:hover .instagram__overlay {
  opacity: 1;
}

.instagram__cta {
  text-align: center;
}

@media (min-width: 640px) {
  .instagram__grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
