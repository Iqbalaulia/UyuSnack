<template>
  <section id="beranda" class="hero">
    <div class="container hero__container">
      <div class="hero__content">
        <span class="hero__tag"><SparkleIcon :size="16" /> Homemade & Halal</span>
        <h1 class="hero__title">
          Camilan Lezat untuk Setiap Momen Bahagia
        </h1>
        <p class="hero__description">
          Uyu Snack menyajikan aneka camilan manis dan gurih buatan rumah dengan bahan berkualitas. 
          Pesan sekarang, nikmati kelezatannya di rumah!
        </p>
        <div class="hero__actions">
          <a href="#menu" class="btn btn-primary hero__btn">
            Lihat Menu
          </a>
          <a
            href="https://wa.me/6281216593329?text=Halo%20Uyu%20Snack,%20saya%20mau%20pesan"
            target="_blank"
            rel="noopener noreferrer"
            class="btn btn-secondary hero__btn"
          >
            Pesan via WhatsApp
          </a>
        </div>
        <div class="hero__stats">
          <div class="hero__stat">
            <strong>500+</strong>
            <span>Order Terkirim</span>
          </div>
          <div class="hero__stat">
            <strong>100%</strong>
            <span>Homemade</span>
          </div>
          <div class="hero__stat">
            <strong>4.9</strong>
            <span>Rating Puas</span>
          </div>
        </div>
      </div>
      <div class="hero__image">
        <div class="hero__image-wrapper">
          <img
            src="/assets/images/burnt_cheesecake_chocoregal.jpg"
            alt="Aneka camilan Uyu Snack"
            loading="eager"
          />
          <div class="hero__floating-badge">
            <FireIcon :size="18" class="hero__fire" />
            <p>Best Seller minggu ini</p>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import SparkleIcon from './icons/SparkleIcon.vue'
import FireIcon from './icons/FireIcon.vue'
</script>

<style scoped>
.hero {
  padding-top: calc(var(--header-height) + 3rem);
  padding-bottom: 3rem;
  background: linear-gradient(180deg, var(--color-secondary) 0%, var(--color-bg) 100%);
  overflow: hidden;
}

.hero__container {
  display: grid;
  gap: 2.5rem;
  align-items: center;
}

.hero__tag {
  display: inline-flex;
  align-items: center;
  gap: 0.35rem;
  background: var(--color-white);
  color: var(--color-primary-dark);
  padding: 0.5rem 1rem;
  border-radius: 9999px;
  font-size: 0.85rem;
  font-weight: 700;
  margin-bottom: 1rem;
  box-shadow: var(--shadow);
}

.hero__title {
  font-size: 2.25rem;
  font-weight: 900;
  line-height: 1.15;
  color: var(--color-text);
  margin-bottom: 1rem;
}

.hero__description {
  color: var(--color-text-light);
  font-size: 1rem;
  margin-bottom: 1.5rem;
  max-width: 480px;
}

.hero__actions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 2rem;
}

.hero__btn {
  width: 100%;
}

.hero__stats {
  display: flex;
  gap: 1.5rem;
}

.hero__stat {
  display: flex;
  flex-direction: column;
}

.hero__stat strong {
  font-size: 1.5rem;
  color: var(--color-primary-dark);
}

.hero__stat span {
  font-size: 0.8rem;
  color: var(--color-text-light);
}

.hero__image {
  position: relative;
}

.hero__image-wrapper {
  position: relative;
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow-lg);
  transform: rotate(2deg);
}

.hero__image-wrapper img {
  width: 100%;
  aspect-ratio: 4 / 5;
  object-fit: cover;
}

.hero__floating-badge {
  position: absolute;
  bottom: 1rem;
  left: 1rem;
  background: var(--color-white);
  padding: 0.75rem 1rem;
  border-radius: var(--radius-md);
  box-shadow: var(--shadow);
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--color-text);
}

.hero__fire {
  color: var(--color-primary);
  flex-shrink: 0;
}

@media (min-width: 768px) {
  .hero {
    padding-top: calc(var(--header-height) + 5rem);
    padding-bottom: 5rem;
  }

  .hero__container {
    grid-template-columns: 1fr 1fr;
    gap: 4rem;
  }

  .hero__title {
    font-size: 3.25rem;
  }

  .hero__description {
    font-size: 1.1rem;
  }

  .hero__actions {
    flex-direction: row;
  }

  .hero__btn {
    width: auto;
  }
}
</style>
