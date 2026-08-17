<template>
  <section id="cara-pesan" class="how-to section">
    <div class="container">
      <h2 class="section-title">Cara Pesan</h2>
      <p class="section-subtitle">Pesananmu hanya butuh 3 langkah mudah.</p>
      <div class="how-to__steps">
        <div v-for="(step, index) in steps" :key="index" class="step-card">
          <div class="step-card__number">{{ index + 1 }}</div>
          <div class="step-card__icon">{{ step.icon }}</div>
          <h3 class="step-card__title">{{ step.title }}</h3>
          <p class="step-card__desc">{{ step.description }}</p>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const steps = [
  {
    icon: '📱',
    title: 'Pilih Menu',
    description: 'Lihat katalog menu dan pilih camilan favoritmu.',
  },
  {
    icon: '💬',
    title: 'Chat WhatsApp',
    description: 'Klik tombol pesan, otomatis terhubung ke WhatsApp kami.',
  },
  {
    icon: '🚚',
    title: 'Tunggu Diantar',
    description: 'Konfirmasi pembayaran, lalu kami proses dan kirim pesananmu.',
  },
]
</script>

<style scoped>
.how-to {
  background: linear-gradient(180deg, var(--color-bg) 0%, var(--color-secondary) 100%);
}

.how-to__steps {
  display: grid;
  gap: 1.25rem;
}

.step-card {
  position: relative;
  background: var(--color-white);
  padding: 2rem 1.5rem;
  border-radius: var(--radius-md);
  text-align: center;
  box-shadow: var(--shadow);
}

.step-card__number {
  position: absolute;
  top: -1rem;
  left: 50%;
  transform: translateX(-50%);
  width: 2rem;
  height: 2rem;
  background: var(--color-primary);
  color: var(--color-white);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
  font-size: 0.9rem;
}

.step-card__icon {
  font-size: 2.5rem;
  margin-bottom: 0.75rem;
}

.step-card__title {
  font-size: 1.1rem;
  font-weight: 800;
  margin-bottom: 0.5rem;
}

.step-card__desc {
  font-size: 0.9rem;
  color: var(--color-text-light);
  line-height: 1.5;
}

@media (min-width: 768px) {
  .how-to__steps {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
