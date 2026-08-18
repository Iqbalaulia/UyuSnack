<template>
  <section id="pengiriman" class="shipping section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">{{ t('shipping.title') }}</h2>
        <p class="section-subtitle">{{ t('shipping.subtitle') }}</p>
      </SectionReveal>

      <div class="shipping__grid">
        <SectionReveal v-for="(courier, index) in couriers" :key="courier.key" :style="{ transitionDelay: `${index * 100}ms` }">
          <div class="shipping-card">
            <div class="shipping-card__logo">
              <img :src="courier.logo" :alt="courier.name" loading="lazy" />
            </div>
            <p class="shipping-card__desc">{{ t(`shipping.couriers.${courier.key}.desc`) }}</p>
          </div>
        </SectionReveal>
      </div>

      <SectionReveal>
        <div class="shipping__notes">
          <div class="shipping__note">
            <MapPinIcon :size="20" />
            <span>{{ t('shipping.area') }}</span>
          </div>
          <div class="shipping__note">
            <TruckIcon :size="20" />
            <span>{{ t('shipping.cost') }}</span>
          </div>
        </div>
      </SectionReveal>
    </div>
  </section>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import SectionReveal from './SectionReveal.vue'
import MapPinIcon from './icons/MapPinIcon.vue'
import TruckIcon from './icons/TruckIcon.vue'

const { t } = useI18n()

const couriers = [
  { key: 'paxel', name: 'Paxel', logo: '/assets/couriers/paxel.png' },
  { key: 'gosend', name: 'GoSend', logo: '/assets/couriers/gosend.png' },
  { key: 'grab', name: 'Grab', logo: '/assets/couriers/grab.svg' },
  { key: 'maxim', name: 'Maxim', logo: '/assets/couriers/maxim.png' },
]
</script>

<style scoped>
.shipping {
  background: linear-gradient(180deg, var(--color-white) 0%, var(--color-bg) 100%);
}

.shipping__grid {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  grid-auto-rows: 1fr;
  gap: 1rem;
  margin-bottom: 2rem;
}

.shipping-card {
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  height: 100%;
  background: var(--color-white);
  border-radius: var(--radius-md);
  padding: 1.25rem;
  text-align: center;
  box-shadow: var(--shadow);
  transition: var(--transition);
}

.shipping-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.shipping-card__logo {
  display: flex;
  align-items: center;
  justify-content: center;
  height: 3rem;
  margin-bottom: 0.75rem;
}

.shipping-card__logo img {
  max-width: 100%;
  max-height: 100%;
  object-fit: contain;
}

.shipping-card__desc {
  font-size: 0.85rem;
  color: var(--color-text-light);
  line-height: 1.5;
}

.shipping__notes {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  max-width: 640px;
  margin: 0 auto;
}

.shipping__note {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: var(--color-white);
  padding: 1rem 1.25rem;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow);
  color: var(--color-text);
  font-size: 0.95rem;
  font-weight: 600;
}

.shipping__note svg {
  flex-shrink: 0;
  color: var(--color-primary);
}

@media (min-width: 768px) {
  .shipping__grid {
    grid-template-columns: repeat(4, 1fr);
  }

  .shipping__notes {
    flex-direction: row;
    justify-content: center;
  }
}
</style>
