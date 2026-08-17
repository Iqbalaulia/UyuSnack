<template>
  <section id="tentang" class="about section">
    <div class="container about__container">
      <div class="about__image">
        <img
          src="/assets/images/menu.jpg"
          alt="Cerita Uyu Snack"
          loading="lazy"
        />
      </div>
      <div class="about__content">
        <span class="about__label">Tentang Kami</span>
        <h2 class="section-title about__title">Dari Dapur Kecil, untuk Cinta Besar</h2>
        <p class="about__text">
          Uyu Snack lahir dari kecintaan kami pada camilan rumahan yang dibuat dengan tangan sendiri. 
          Setiap gigitan adalah hasil dari resep teruji, bahan pilihan, dan proses higienis.
        </p>
        <p class="about__text">
          Kami percaya camilan bukan sekadar makanan ringan, tapi pembawa kebahagiaan sederhana. 
          Makanya, setiap pesanan kami kemas dengan penuh perhatian—seolah-olah untuk keluarga sendiri.
        </p>
        <ul class="about__list">
          <li v-for="item in highlights" :key="item">
            <span class="about__check"><CheckIcon :size="12" /></span>
            {{ item }}
          </li>
        </ul>
      </div>
    </div>
  </section>
</template>

<script setup>
import CheckIcon from './icons/CheckIcon.vue'

const highlights = [
  'Bahan premium & halal',
  'Dibuat fresh setiap hari',
  'Kemasan aman & menarik',
  'Bisa pesan untuk hampers',
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
