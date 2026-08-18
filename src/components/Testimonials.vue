<template>
  <section class="testimonials section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">{{ t('testimonials.title') }}</h2>
        <p class="section-subtitle">{{ t('testimonials.subtitle') }}</p>
      </SectionReveal>

      <div v-if="loading" class="testimonials__status">{{ t('testimonials.loading') }}</div>
      <div v-else-if="error && !usingFallback" class="testimonials__status testimonials__status--error">
        {{ t('testimonials.error') }}
        <button class="testimonials__retry" @click="fetchTestimonials">{{ t('testimonials.retry') }}</button>
      </div>

      <div v-if="usingFallback" class="testimonials__fallback">{{ t('testimonials.fallback') }}</div>

      <div class="testimonials__grid">
        <SectionReveal v-for="(testi, index) in testimonials" :key="testi.id" :style="{ transitionDelay: `${index * 100}ms` }">
          <div class="testimonial-card">
            <div class="testimonial-card__stars">
              <StarIcon v-for="n in 5" :key="n" :size="16" />
            </div>
            <p class="testimonial-card__text">"{{ text(testi) }}"</p>
            <div class="testimonial-card__author">
              <LazyImage :src="testi.avatar" :alt="testi.name" class="testimonial-card__avatar" loading="lazy" />
              <div>
                <h4 class="testimonial-card__name">{{ testi.name }}</h4>
                <span class="testimonial-card__role">{{ role(testi) }}</span>
              </div>
            </div>
          </div>
        </SectionReveal>
      </div>
    </div>
  </section>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import StarIcon from './icons/StarIcon.vue'
import SectionReveal from './SectionReveal.vue'
import LazyImage from './LazyImage.vue'
import { useTestimonials } from '../composables/useTestimonials'

const { t, locale } = useI18n()
const { testimonials, loading, error, usingFallback, fetchTestimonials } = useTestimonials()

const text = (testi) => (locale.value === 'en' ? testi.text_en : testi.text_id)
const role = (testi) => (locale.value === 'en' ? testi.role_en : testi.role_id)
</script>

<style scoped>
.testimonials {
  background: var(--color-white);
}

.testimonials__grid {
  display: grid;
  gap: 1.25rem;
}

.testimonials__status {
  text-align: center;
  color: var(--color-text-light);
  margin-bottom: 1rem;
}

.testimonials__status--error {
  color: #dc2626;
}

.testimonials__retry {
  display: inline-block;
  margin-left: 0.5rem;
  color: var(--color-primary-dark);
  font-weight: 700;
  text-decoration: underline;
}

.testimonials__fallback {
  text-align: center;
  font-size: 0.85rem;
  color: var(--color-text-light);
  margin-bottom: 1rem;
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
