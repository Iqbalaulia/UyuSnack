<template>
  <section id="blog" class="blog section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">{{ t('blog.title') }}</h2>
        <p class="section-subtitle">{{ t('blog.subtitle') }}</p>
      </SectionReveal>

      <div v-if="loading" class="blog__status">{{ t('blog.loading') }}</div>
      <div v-else-if="error && !usingFallback" class="blog__status blog__status--error">
        {{ t('blog.error') }}
        <button class="blog__retry" @click="fetchPosts">{{ t('blog.retry') }}</button>
      </div>

      <div v-if="usingFallback" class="blog__fallback">{{ t('blog.fallback') }}</div>

      <div class="blog__grid">
        <SectionReveal v-for="(post, index) in posts" :key="post.id" :style="{ transitionDelay: `${index * 100}ms` }">
          <article class="blog-card">
            <div class="blog-card__image">
              <LazyImage :src="post.image" :alt="title(post)" loading="lazy" />
            </div>
            <div class="blog-card__body">
              <h3 class="blog-card__title">{{ title(post) }}</h3>
              <div class="blog-card__meta">
                <time v-if="post.published_at">{{ formatDate(post.published_at) }}</time>
                <span v-if="post.published_at && post.read_time_minutes">·</span>
                <span v-if="post.read_time_minutes">{{ post.read_time_minutes }} {{ t('blog.readTime') }}</span>
              </div>
              <p class="blog-card__excerpt">{{ excerpt(post) }}</p>
              <a :href="`#/blog/${post.slug}`" class="blog-card__link">
                {{ t('blog.readMore') }}
              </a>
            </div>
          </article>
        </SectionReveal>
      </div>
    </div>
  </section>
</template>

<script setup>
import { useI18n } from 'vue-i18n'
import SectionReveal from './SectionReveal.vue'
import LazyImage from './LazyImage.vue'
import { useBlogPosts } from '../composables/useBlogPosts'

const { t, locale } = useI18n()
const { posts, loading, error, usingFallback, fetchPosts } = useBlogPosts()

const title = (post) => (locale.value === 'en' ? post.title_en : post.title_id)
const excerpt = (post) => (locale.value === 'en' ? post.excerpt_en : post.excerpt_id)
const formatDate = (d) => new Date(d).toLocaleDateString(locale.value === 'en' ? 'en-US' : 'id-ID', { dateStyle: 'medium' })
</script>

<style scoped>
.blog {
  background: var(--color-bg);
}

.blog__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
}

.blog__status {
  text-align: center;
  color: var(--color-text-light);
  margin-bottom: 1rem;
}

.blog__status--error {
  color: #dc2626;
}

.blog__retry {
  display: inline-block;
  margin-left: 0.5rem;
  color: var(--color-primary-dark);
  font-weight: 700;
  text-decoration: underline;
}

.blog__fallback {
  text-align: center;
  font-size: 0.85rem;
  color: var(--color-text-light);
  margin-bottom: 1rem;
}

.blog-card {
  background: var(--color-white);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow);
  transition: var(--transition);
}

.blog-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.blog-card__image {
  aspect-ratio: 16 / 9;
  overflow: hidden;
}

.blog-card__image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.blog-card:hover .blog-card__image img {
  transform: scale(1.05);
}

.blog-card__body {
  padding: 1.25rem;
}

.blog-card__title {
  font-size: 1.05rem;
  font-weight: 800;
  margin-bottom: 0.35rem;
  line-height: 1.4;
}

.blog-card__meta {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.78rem;
  color: var(--color-text-light);
  margin-bottom: 0.6rem;
}

.blog-card__excerpt {
  font-size: 0.9rem;
  color: var(--color-text-light);
  line-height: 1.5;
  margin-bottom: 1rem;
}

.blog-card__link {
  color: var(--color-primary-dark);
  font-weight: 700;
  font-size: 0.9rem;
}

.blog-card__link:hover {
  text-decoration: underline;
}

@media (min-width: 640px) {
  .blog__grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .blog__grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
