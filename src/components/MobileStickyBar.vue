<template>
  <div class="mobile-sticky">
    <a href="#menu" class="mobile-sticky__btn mobile-sticky__btn--menu">
      <MenuIcon :size="18" />
      <span>{{ t('nav.menu') }}</span>
    </a>
    <a
      :href="waLink"
      target="_blank"
      rel="noopener noreferrer"
      class="mobile-sticky__btn mobile-sticky__btn--whatsapp"
    >
      <WhatsAppIcon :size="18" />
      <span>{{ t('menu.order') }}</span>
    </a>
  </div>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import MenuIcon from './icons/MenuIcon.vue'
import WhatsAppIcon from './icons/WhatsAppIcon.vue'
import { getWhatsAppLink } from '../data/products.js'

const { t } = useI18n()
const waLink = getWhatsAppLink(t('cart.orderMessage'))
</script>

<style scoped>
.mobile-sticky {
  position: fixed;
  bottom: 0;
  left: 0;
  right: 0;
  z-index: 998;
  display: none;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
  padding: 0.75rem 1rem;
  background: var(--color-white);
  box-shadow: 0 -4px 20px rgba(0, 0, 0, 0.08);
}

.mobile-sticky__btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  padding: 0.75rem 1rem;
  border-radius: 9999px;
  font-weight: 700;
  font-size: 0.85rem;
  transition: var(--transition);
}

.mobile-sticky__btn--menu {
  background: var(--color-secondary);
  color: var(--color-primary-dark);
}

.mobile-sticky__btn--menu:hover {
  background: var(--color-primary);
  color: var(--color-white);
}

.mobile-sticky__btn--whatsapp {
  background: #25d366;
  color: var(--color-white);
}

.mobile-sticky__btn--whatsapp:hover {
  background: #1da851;
}

@media (max-width: 767px) {
  .mobile-sticky {
    display: grid;
  }
}
</style>
