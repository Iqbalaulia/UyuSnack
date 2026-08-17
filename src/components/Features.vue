<template>
  <section class="features section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">{{ t('features.title') }}</h2>
        <p class="section-subtitle">{{ t('features.subtitle') }}</p>
      </SectionReveal>
      <div class="features__grid">
        <SectionReveal v-for="(feature, index) in features" :key="feature.key" :style="{ transitionDelay: `${index * 100}ms` }">
          <div class="feature-card">
            <div class="feature-card__icon">
              <component :is="feature.icon" :size="40" />
            </div>
            <h3 class="feature-card__title">{{ t(`features.items.${feature.key}.title`) }}</h3>
            <p class="feature-card__desc">{{ t(`features.items.${feature.key}.desc`) }}</p>
          </div>
        </SectionReveal>
      </div>
    </div>
  </section>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import HomemadeIcon from './icons/HomemadeIcon.vue'
import PackageIcon from './icons/PackageIcon.vue'
import PriceIcon from './icons/PriceIcon.vue'
import HampersIcon from './icons/HampersIcon.vue'
import SectionReveal from './SectionReveal.vue'

const { t } = useI18n()

const features = [
  {
    icon: HomemadeIcon,
    key: 'homemade',
  },
  {
    icon: PackageIcon,
    key: 'packaging',
  },
  {
    icon: PriceIcon,
    key: 'price',
  },
  {
    icon: HampersIcon,
    key: 'hampers',
  },
]
</script>

<style scoped>
.features {
  background: var(--color-white);
}

.features__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
}

.feature-card {
  background: var(--color-bg);
  padding: 1.5rem;
  border-radius: var(--radius-md);
  text-align: center;
  transition: var(--transition);
}

.feature-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow);
}

.feature-card__icon {
  display: flex;
  justify-content: center;
  color: var(--color-primary);
  margin-bottom: 0.75rem;
}

.feature-card__title {
  font-size: 1.1rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
}

.feature-card__desc {
  font-size: 0.9rem;
  color: var(--color-text-light);
  line-height: 1.5;
}

@media (min-width: 640px) {
  .features__grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .features__grid {
    grid-template-columns: repeat(4, 1fr);
  }
}
</style>
