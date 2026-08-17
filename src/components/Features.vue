<template>
  <section class="features section">
    <div class="container">
      <h2 class="section-title">Kenapa Memilih Uyu Snack?</h2>
      <p class="section-subtitle">Kami fokus pada kualitas, rasa, dan pengalaman terbaik untukmu.</p>
      <div class="features__grid">
        <div v-for="feature in features" :key="feature.title" class="feature-card">
          <div class="feature-card__icon">
            <component :is="feature.icon" :size="40" />
          </div>
          <h3 class="feature-card__title">{{ feature.title }}</h3>
          <p class="feature-card__desc">{{ feature.description }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import HomemadeIcon from './icons/HomemadeIcon.vue'
import PackageIcon from './icons/PackageIcon.vue'
import PriceIcon from './icons/PriceIcon.vue'
import HampersIcon from './icons/HampersIcon.vue'

const features = [
  {
    icon: HomemadeIcon,
    title: 'Homemade',
    description: 'Dibuat di dapur sendiri tanpa bahan pengawet, lebih sehat dan terjaga kebersihannya.',
  },
  {
    icon: PackageIcon,
    title: 'Kemasan Aman',
    description: 'Setiap produk dikemas rapat dan higienis, cocok untuk dikirim ke luar kota.',
  },
  {
    icon: PriceIcon,
    title: 'Harga Bersahabat',
    description: 'Camilan berkualitas dengan harga terjangkau, pas di kantong pelajar & karyawan.',
  },
  {
    icon: HampersIcon,
    title: 'Bisa Custom Hampers',
    description: 'Pilih isi dan desain kemasan sesuai kebutuhan untuk hadiah atau acara spesial.',
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
