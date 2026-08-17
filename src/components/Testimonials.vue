<template>
  <section class="testimonials section">
    <div class="container">
      <h2 class="section-title">Apa Kata Pelanggan?</h2>
      <p class="section-subtitle">Ulasan dari teman-teman yang sudah mencoba Uyu Snack.</p>
      <div class="testimonials__grid">
        <div v-for="testi in testimonials" :key="testi.name" class="testimonial-card">
          <div class="testimonial-card__stars">
            <span v-for="n in 5" :key="n" class="testimonial-card__star">★</span>
          </div>
          <p class="testimonial-card__text">"{{ testi.text }}"</p>
          <div class="testimonial-card__author">
            <div class="testimonial-card__avatar">{{ testi.avatar }}</div>
            <div>
              <h4 class="testimonial-card__name">{{ testi.name }}</h4>
              <span class="testimonial-card__role">{{ testi.role }}</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
const testimonials = [
  {
    text: 'Brownies Lumernya enak banget, lembut dan nggak eneg. Sudah repeat order 3 kali!',
    name: 'Dinda A.',
    role: 'Pelanggan Setia',
    avatar: 'D',
  },
  {
    text: 'Kemasannya gemesin, pas buat oleh-oleh. Cireng isinya juga banyak dan bumbunya meresap.',
    name: 'Rizky M.',
    role: 'Pembeli Pertama',
    avatar: 'R',
  },
  {
    text: 'Pesan hampers untuk ultah teman, dikirim tepat waktu dan penerima senang banget.',
    name: 'Siti N.',
    role: 'Pembeli Hampers',
    avatar: 'S',
  },
]
</script>

<style scoped>
.testimonials {
  background: var(--color-white);
}

.testimonials__grid {
  display: grid;
  gap: 1.25rem;
}

.testimonial-card {
  background: var(--color-bg);
  padding: 1.5rem;
  border-radius: var(--radius-md);
}

.testimonial-card__stars {
  color: var(--color-accent);
  margin-bottom: 0.75rem;
  font-size: 1.1rem;
}

.testimonial-card__text {
  font-size: 0.95rem;
  color: var(--color-text);
  margin-bottom: 1.25rem;
  line-height: 1.6;
}

.testimonial-card__author {
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.testimonial-card__avatar {
  width: 2.5rem;
  height: 2.5rem;
  background: var(--color-primary);
  color: var(--color-white);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 800;
}

.testimonial-card__name {
  font-size: 0.95rem;
  font-weight: 800;
}

.testimonial-card__role {
  font-size: 0.8rem;
  color: var(--color-text-light);
}

@media (min-width: 768px) {
  .testimonials__grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
