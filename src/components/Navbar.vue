<template>
  <header class="header" :class="{ 'header--scrolled': isScrolled }">
    <div class="container header__container">
      <a href="#" class="logo">
        <LogoIcon :size="28" class="logo__icon" />
        <span class="logo__text">Uyu Snack</span>
      </a>

      <button
        class="cart-btn"
        aria-label="Buka keranjang"
        @click="emit('open-cart')"
      >
        <CartIcon :size="22" />
        <span v-if="totalItems > 0" class="cart-btn__badge">{{ totalItems }}</span>
      </button>

      <button
        class="menu-toggle"
        aria-label="Toggle menu"
        @click="isMenuOpen = !isMenuOpen"
      >
        <span class="menu-toggle__bar" :class="{ 'open': isMenuOpen }"></span>
        <span class="menu-toggle__bar" :class="{ 'open': isMenuOpen }"></span>
        <span class="menu-toggle__bar" :class="{ 'open': isMenuOpen }"></span>
      </button>

      <nav class="nav" :class="{ 'nav--open': isMenuOpen }">
        <a
          v-for="item in menuItems"
          :key="item.href"
          :href="item.href"
          class="nav__link"
          @click="isMenuOpen = false"
        >
          {{ item.label }}
        </a>
        <a
          href="https://www.instagram.com/uyu_snack/"
          target="_blank"
          rel="noopener noreferrer"
          class="btn btn-primary nav__cta"
        >
          Instagram
        </a>
        <button
          class="cart-btn cart-btn--desktop"
          aria-label="Buka keranjang"
          @click="emit('open-cart')"
        >
          <CartIcon :size="22" />
          <span v-if="totalItems > 0" class="cart-btn__badge">{{ totalItems }}</span>
        </button>
      </nav>
    </div>
  </header>
</template>

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import LogoIcon from './icons/LogoIcon.vue'
import CartIcon from './icons/CartIcon.vue'
import { totalItems } from '../stores/cart.js'

const isMenuOpen = ref(false)
const isScrolled = ref(false)

const emit = defineEmits(['open-cart'])

const menuItems = [
  { label: 'Beranda', href: '#beranda' },
  { label: 'Tentang', href: '#tentang' },
  { label: 'Menu', href: '#menu' },
  { label: 'Cara Pesan', href: '#cara-pesan' },
]

const handleScroll = () => {
  isScrolled.value = window.scrollY > 20
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})
</script>

<style scoped>
.header {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  height: var(--header-height);
  background: transparent;
  transition: var(--transition);
}

.header--scrolled {
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  box-shadow: 0 2px 20px rgba(0, 0, 0, 0.05);
}

.header__container {
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 100%;
}

.logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-weight: 800;
  font-size: 1.25rem;
  color: var(--color-primary-dark);
}

.logo__icon {
  flex-shrink: 0;
  color: var(--color-primary);
}

.cart-btn {
  position: relative;
  display: inline-flex;
  align-items: center;
  justify-content: center;
  color: var(--color-primary-dark);
  padding: 0.5rem;
  margin-left: auto;
}

.cart-btn--desktop {
  display: none;
}

.cart-btn__badge {
  position: absolute;
  top: -2px;
  right: -2px;
  min-width: 1.1rem;
  height: 1.1rem;
  padding: 0 0.25rem;
  background: var(--color-primary);
  color: var(--color-white);
  border-radius: 9999px;
  font-size: 0.65rem;
  font-weight: 800;
  display: flex;
  align-items: center;
  justify-content: center;
}

.menu-toggle {
  display: flex;
  flex-direction: column;
  gap: 5px;
  padding: 0.5rem;
  z-index: 1001;
}

.menu-toggle__bar {
  display: block;
  width: 24px;
  height: 3px;
  background: var(--color-primary-dark);
  border-radius: 3px;
  transition: var(--transition);
}

.menu-toggle__bar.open:nth-child(1) {
  transform: translateY(8px) rotate(45deg);
}

.menu-toggle__bar.open:nth-child(2) {
  opacity: 0;
}

.menu-toggle__bar.open:nth-child(3) {
  transform: translateY(-8px) rotate(-45deg);
}

.nav {
  position: fixed;
  top: 0;
  right: -100%;
  width: 70%;
  max-width: 280px;
  height: 100vh;
  background: var(--color-white);
  box-shadow: -5px 0 30px rgba(0, 0, 0, 0.1);
  display: flex;
  flex-direction: column;
  padding: 5rem 1.5rem 2rem;
  gap: 1.5rem;
  transition: right 0.3s ease;
}

.nav--open {
  right: 0;
}

.nav__link {
  font-weight: 600;
  color: var(--color-text);
  padding: 0.5rem 0;
  border-bottom: 1px solid var(--color-border);
}

.nav__link:hover {
  color: var(--color-primary-dark);
}

.nav__cta {
  margin-top: auto;
  text-align: center;
}

@media (min-width: 768px) {
  .menu-toggle {
    display: none;
  }

  .cart-btn:not(.cart-btn--desktop) {
    display: none;
  }

  .cart-btn--desktop {
    display: inline-flex;
    margin-left: 0;
  }

  .nav {
    position: static;
    width: auto;
    max-width: none;
    height: auto;
    background: transparent;
    box-shadow: none;
    flex-direction: row;
    align-items: center;
    padding: 0;
    gap: 2rem;
  }

  .nav__link {
    border-bottom: none;
    padding: 0;
    font-size: 0.95rem;
  }

  .nav__cta {
    margin-top: 0;
  }
}
</style>
