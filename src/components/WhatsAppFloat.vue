<template>
  <a
    :href="waLink"
    target="_blank"
    rel="noopener noreferrer"
    class="whatsapp-float"
    aria-label="Chat WhatsApp"
  >
    <WhatsAppIcon :size="28" />
    <span class="whatsapp-float__text">{{ t('menu.order') }}</span>
  </a>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import WhatsAppIcon from './icons/WhatsAppIcon.vue'
import { getWhatsAppLink } from '../data/products.ts'

const { t } = useI18n()
const waLink = getWhatsAppLink(t('cart.orderMessage'))
</script>

<style scoped>
.whatsapp-float {
  position: fixed;
  bottom: 1.25rem;
  right: 1.25rem;
  z-index: 999;
  display: flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  background: #25d366;
  color: #ffffff;
  border-radius: 9999px;
  box-shadow: 0 4px 20px rgba(37, 211, 102, 0.35);
  font-weight: 700;
  font-size: 0.9rem;
  transition: transform 0.2s ease, box-shadow 0.2s ease;
}

.whatsapp-float:hover {
  transform: translateY(-3px);
  box-shadow: 0 6px 24px rgba(37, 211, 102, 0.45);
}

.whatsapp-float__text {
  display: none;
}

@media (min-width: 768px) {
  .whatsapp-float {
    display: flex;
  }

  .whatsapp-float__text {
    display: inline;
  }
}

@media (max-width: 767px) {
  .whatsapp-float {
    display: none;
  }
}
</style>
