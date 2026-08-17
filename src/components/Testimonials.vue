<template>
  <section class="testimonials section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">Apa Kata Pelanggan?</h2>
        <p class="section-subtitle">Ulasan dari teman-teman yang sudah mencoba Uyu Snack.</p>
      </SectionReveal>
      <div class="testimonials__grid">
        <SectionReveal v-for="(testi, index) in testimonials" :key="testi.name" :style="{ transitionDelay: `${index * 100}ms` }">
          <div class="testimonial-card">
          <div class="testimonial-card__stars">
            <StarIcon v-for="n in 5" :key="n" :size="16" />
          </div>
          <p class="testimonial-card__text">"{{ testi.text }}"</p>
          <div class="testimonial-card__author">
            <LazyImage :src="testi.avatar" :alt="testi.name" class="testimonial-card__avatar" loading="lazy" />
            <div>
              <h4 class="testimonial-card__name">{{ testi.name }}</h4>
              <span class="testimonial-card__role">{{ testi.role }}</span>
            </div>
          </div>
          </div>
        </SectionReveal>
      </div>
    </div>
  </section>
</template>

<script setup>
import StarIcon from './icons/StarIcon.vue'
import SectionReveal from './SectionReveal.vue'
import LazyImage from './LazyImage.vue'

const testimonials = [
  {
    text: 'Burnt Cheesecake Original-nya enak banget, lembut dan nggak eneg. Sudah repeat order 3 kali!',
    name: 'Dinda A.',
    role: 'Pelanggan Setia',
    avatar: '/assets/burnt-cheesecake-original.jpg',
  },
  {
    text: 'Chocobery-nya manisnya pas, topping stroberi dan cokelatnya melimpah. Favorit keluarga!',
    name: 'Rizky M.',
    role: 'Pembeli Pertama',
    avatar: '/assets/burnt-cheesecake-chocobery.jpg',
  },
  {
    text: 'Pesan Chocolate Regal untuk hadiah teman, dikirim tepat waktu dan penerima senang banget.',
    name: 'Siti N.',
    role: 'Pembeli Hampers',
    avatar: '/assets/burnt-cheesecake-chocoregal.jpg',
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
  display: flex;
  gap: 0.15rem;
  color: var(--color-accent);
  margin-bottom: 0.75rem;
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
  border-radius: 50%;
  object-fit: cover;
  border: 2px solid var(--color-border);
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
