<template>
  <section class="features section">
    <div class="container">
      <h2 class="section-title">Kenapa Memilih Uyu Snack?</h2>
      <p class="section-subtitle">Kami fokus pada kualitas, rasa, dan pengalaman terbaik untukmu.</p>
      <div class="features__grid">
        <div v-for="feature in features" :key="feature.title" class="feature-card">
          <div class="feature-card__icon">{{ feature.icon }}</div>
          <h3 class="feature-card__title">{{ feature.title }}</h3>
          <p class="feature-card__desc">{{ feature.description }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const features = [
  {
    icon: '🏠',
    title: 'Homemade',
    description: 'Dibuat di dapur sendiri tanpa bahan pengawet, lebih sehat dan terjaga kebersihannya.',
  },
  {
    icon: '📦',
    title: 'Kemasan Aman',
    description: 'Setiap produk dikemas rapat dan higienis, cocok untuk dikirim ke luar kota.',
  },
  {
    icon: '💰',
    title: 'Harga Bersahabat',
    description: 'Camilan berkualitas dengan harga terjangkau, pas di kantong pelajar & karyawan.',
  },
  {
    icon: '🎁',
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
  font-size: 2.5rem;
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
