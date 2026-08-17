<template>
  <footer class="footer">
    <div class="container footer__container">
      <div class="footer__brand">
        <a href="#" class="footer__logo">
          <LogoIcon :size="28" />
          <strong>Uyu Snack</strong>
        </a>
        <p class="footer__tagline">
          Camilan homemade manis & gurih untuk momen bahagiamu.
        </p>
      </div>

      <div class="footer__links">
        <h4>Menu</h4>
        <a href="#beranda">Beranda</a>
        <a href="#tentang">Tentang</a>
        <a href="#menu">Katalog</a>
        <a href="#cara-pesan">Cara Pesan</a>
      </div>

      <div class="footer__links">
        <h4>Kontak</h4>
        <a href="https://www.instagram.com/uyu_snack/" target="_blank" rel="noopener noreferrer">
          Instagram: @uyu_snack
        </a>
        <a href="https://wa.me/6281216593329" target="_blank" rel="noopener noreferrer">
          WhatsApp: 0812-1659-3329
        </a>
        <span class="footer__location"><MapPinIcon :size="16" /> Indonesia</span>
      </div>
    </div>

    <div class="footer__bottom">
      <div class="container">
        <p class="footer__love">© {{ new Date().getFullYear() }} Uyu Snack. Dibuat dengan <HeartIcon :size="14" /></p>
      </div>
    </div>
  </footer>
</template>

<script setup>
import LogoIcon from './icons/LogoIcon.vue'
import MapPinIcon from './icons/MapPinIcon.vue'
import HeartIcon from './icons/HeartIcon.vue'
</script>

<style scoped>
.footer {
  background: var(--color-text);
  color: var(--color-white);
  padding-top: 3rem;
}

.footer__container {
  display: grid;
  gap: 2rem;
  padding-bottom: 2rem;
}

.footer__logo {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.25rem;
  margin-bottom: 0.75rem;
  color: var(--color-primary);
}

.footer__tagline {
  color: #b0b0b0;
  font-size: 0.9rem;
  max-width: 280px;
}

.footer__links {
  display: flex;
  flex-direction: column;
  gap: 0.5rem;
}

.footer__links h4 {
  font-size: 1rem;
  margin-bottom: 0.5rem;
  color: var(--color-primary);
}

.footer__links a,
.footer__links span {
  color: #b0b0b0;
  font-size: 0.9rem;
  transition: var(--transition);
}

.footer__links a:hover {
  color: var(--color-white);
}

.footer__location {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
}

.footer__love {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  gap: 0.35rem;
  color: #b0b0b0;
}

.footer__love svg {
  color: var(--color-primary);
}

.footer__bottom {
  border-top: 1px solid #3d3d3d;
  padding: 1.25rem 0;
  text-align: center;
  font-size: 0.85rem;
  color: #b0b0b0;
}

@media (min-width: 768px) {
  .footer__container {
    grid-template-columns: 2fr 1fr 1fr;
  }
}
</style>
