<template>
  <article class="blog-post">
    <div class="blog-post__hero">
      <img :src="post.image" :alt="title" class="blog-post__image" />
    </div>

    <div class="container blog-post__container">
      <button class="blog-post__back" @click="goHome">
        ← {{ t('blog.backToHome') }}
      </button>

      <header class="blog-post__header">
        <h1 class="blog-post__title">{{ title }}</h1>
        <div class="blog-post__meta">
          <time :datetime="post.published_at">{{ formatDate(post.published_at) }}</time>
          <span>·</span>
          <span>{{ post.read_time_minutes }} {{ t('blog.readTime') }}</span>
        </div>
      </header>

      <div class="blog-post__content" v-html="sanitizedContent"></div>

      <footer class="blog-post__footer">
        <button class="blog-post__cta" @click="goHome">
          {{ t('blog.backToHome') }}
        </button>
      </footer>
    </div>
  </article>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useI18n } from 'vue-i18n'
import DOMPurify from 'dompurify'
import { supabase } from '../lib/supabase'
import { blogPosts as localBlogPosts, type BlogPost } from '../data/blog'

const props = defineProps<{ slug: string }>()
const { t, locale } = useI18n()

const post = ref<BlogPost>(localBlogPosts[0])
const loading = ref(true)
const error = ref<string | null>(null)

const title = computed(() => (locale.value === 'en' ? post.value.title_en : post.value.title_id))
const content = computed(() => (locale.value === 'en' ? post.value.content_en : post.value.content_id))
const sanitizedContent = computed(() => DOMPurify.sanitize(content.value || ''))

const formatDate = (d: string) => new Date(d).toLocaleDateString(locale.value === 'en' ? 'en-US' : 'id-ID', { dateStyle: 'long' })
const goHome = () => { window.location.hash = '' }

const jsonLd = computed(() =>
  JSON.stringify({
    '@context': 'https://schema.org',
    '@type': 'Article',
    headline: title.value,
    description: locale.value === 'en' ? post.value.excerpt_en : post.value.excerpt_id,
    image: post.value.image,
    datePublished: post.value.published_at,
    author: { '@type': 'Organization', name: 'Uyu Snack' },
    publisher: { '@type': 'Organization', name: 'Uyu Snack' },
  })
)

onMounted(async () => {
  try {
    const { data, error: supaError } = await supabase
      .from('blog_posts')
      .select('*')
      .eq('slug', props.slug)
      .eq('is_active', true)
      .single()

    if (supaError) throw supaError
    if (data) post.value = data as BlogPost
  } catch (err) {
    error.value = (err as Error).message
    const local = localBlogPosts.find((b) => b.slug === props.slug)
    if (local) post.value = local
  } finally {
    loading.value = false
  }

  const script = document.createElement('script')
  script.setAttribute('type', 'application/ld+json')
  script.textContent = jsonLd.value
  document.head.appendChild(script)
})
</script>

<style scoped>
.blog-post {
  min-height: 100vh;
  background: var(--color-bg);
  padding-bottom: 3rem;
}
.blog-post__hero {
  width: 100%;
  max-height: 420px;
  overflow: hidden;
}
.blog-post__image {
  width: 100%;
  height: 100%;
  max-height: 420px;
  object-fit: cover;
}
.blog-post__container {
  max-width: 720px;
  margin: 0 auto;
  padding: 1.5rem;
}
.blog-post__back {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  background: none;
  border: none;
  color: var(--color-primary-dark);
  font-weight: 700;
  font-size: 0.9rem;
  cursor: pointer;
  margin-bottom: 1.25rem;
  padding: 0;
}
.blog-post__back:hover {
  text-decoration: underline;
}
.blog-post__header {
  margin-bottom: 1.5rem;
}
.blog-post__title {
  font-size: 1.75rem;
  font-weight: 800;
  line-height: 1.25;
  color: var(--color-accent);
  margin-bottom: 0.75rem;
}
.blog-post__meta {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--color-text-light);
  font-size: 0.9rem;
}
.blog-post__content {
  background: var(--color-white);
  border-radius: var(--radius-md);
  padding: 1.5rem;
  box-shadow: var(--shadow);
  line-height: 1.8;
  color: var(--color-text);
}
.blog-post__content :deep(p) {
  margin-bottom: 1rem;
}
.blog-post__content :deep(p:last-child) {
  margin-bottom: 0;
}
.blog-post__content :deep(img) {
  max-width: 100%;
  height: auto;
  border-radius: 8px;
  margin: 1rem 0;
}
.blog-post__content :deep(h1),
.blog-post__content :deep(h2),
.blog-post__content :deep(h3) {
  margin-top: 1.5rem;
  margin-bottom: 0.75rem;
  color: var(--color-accent);
}
.blog-post__content :deep(ul),
.blog-post__content :deep(ol) {
  margin-left: 1.25rem;
  margin-bottom: 1rem;
}
.blog-post__content :deep(li) {
  margin-bottom: 0.35rem;
}
.blog-post__content :deep(a) {
  color: var(--color-primary-dark);
  text-decoration: underline;
}
.blog-post__footer {
  margin-top: 2rem;
  text-align: center;
}
.blog-post__cta {
  display: inline-block;
  padding: 0.75rem 1.5rem;
  border-radius: 9999px;
  background: var(--color-primary);
  color: var(--color-white);
  font-weight: 700;
  border: none;
  cursor: pointer;
}
.blog-post__cta:hover {
  background: var(--color-primary-dark);
}
@media (min-width: 640px) {
  .blog-post__title {
    font-size: 2.25rem;
  }
  .blog-post__content {
    padding: 2rem;
  }
}
</style>
