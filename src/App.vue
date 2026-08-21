<template>
  <AdminView v-if="isAdmin" />
  <BlogPostView v-else-if="blogSlug" :slug="blogSlug" />
  <div v-else class="app" :class="{ 'has-announcement': !!activeBatch }">
    <AnnouncementBar :batch="activeBatch" :days-left="daysLeft" />
    <Navbar @open-cart="openCart" />
    <main>
      <Hero />
      <About />
      <Features />
      <ProductCatalog />
      <Testimonials />
      <InstagramFeed />
      <Blog />
      <FAQ />
      <HowToOrder />
      <Shipping />
      <CTA />
    </main>
    <Footer />
    <WhatsAppFloat />
    <MobileStickyBar />
    <CartDrawer :is-open="isCartOpen" @close="isCartOpen = false" />
  </div>
</template>

<style>
/* Saat announcement bar tampil: geser navbar & konten ke bawah setinggi bar. */
:root {
  --ann-height: 2.75rem;
}
.has-announcement .header {
  top: var(--ann-height);
}
.has-announcement main {
  padding-top: var(--ann-height);
}
@media (max-width: 600px) {
  :root {
    --ann-height: 3.75rem;
  }
}
</style>

<script setup>
import { ref, onMounted, onUnmounted, defineAsyncComponent } from 'vue'
const AdminView = defineAsyncComponent(() => import('./views/AdminView.vue'))
const BlogPostView = defineAsyncComponent(() => import('./views/BlogPostView.vue'))
import Navbar from './components/Navbar.vue'
import AnnouncementBar from './components/AnnouncementBar.vue'
import Hero from './components/Hero.vue'
import About from './components/About.vue'
import Features from './components/Features.vue'
import ProductCatalog from './components/ProductCatalog.vue'
import Testimonials from './components/Testimonials.vue'
import InstagramFeed from './components/InstagramFeed.vue'
import Blog from './components/Blog.vue'
import FAQ from './components/FAQ.vue'
import HowToOrder from './components/HowToOrder.vue'
import Shipping from './components/Shipping.vue'
import CTA from './components/CTA.vue'
import Footer from './components/Footer.vue'
import WhatsAppFloat from './components/WhatsAppFloat.vue'
import MobileStickyBar from './components/MobileStickyBar.vue'
import CartDrawer from './components/CartDrawer.vue'
import { useActiveBatch } from './composables/useActiveBatch.ts'
import { track } from './lib/track.ts'

const isCartOpen = ref(false)
const openCart = () => {
  track('open_cart')
  isCartOpen.value = true
}
const { batch: activeBatch, daysLeft } = useActiveBatch()

const parseHash = () => {
  const hash = window.location.hash
  return {
    isAdmin: hash.startsWith('#/admin') || hash.startsWith('#admin'),
    blogSlug: (hash.match(/^#\/blog\/(.+)$/) || [])[1] || null,
  }
}

const isAdmin = ref(parseHash().isAdmin)
const blogSlug = ref(parseHash().blogSlug)

const onHashChange = () => {
  const parsed = parseHash()
  isAdmin.value = parsed.isAdmin
  blogSlug.value = parsed.blogSlug
}

onMounted(() => window.addEventListener('hashchange', onHashChange))
onUnmounted(() => window.removeEventListener('hashchange', onHashChange))
</script>
