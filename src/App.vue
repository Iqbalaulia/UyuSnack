<template>
  <AdminView v-if="isAdmin" />
  <div v-else class="app">
    <Navbar @open-cart="isCartOpen = true" />
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

<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import AdminView from './views/AdminView.vue'
import Navbar from './components/Navbar.vue'
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

const isCartOpen = ref(false)

const isAdmin = ref(window.location.hash.startsWith('#/admin') || window.location.hash.startsWith('#admin'))
const onHashChange = () => {
  isAdmin.value = window.location.hash.startsWith('#/admin') || window.location.hash.startsWith('#admin')
}
onMounted(() => window.addEventListener('hashchange', onHashChange))
onUnmounted(() => window.removeEventListener('hashchange', onHashChange))
</script>
