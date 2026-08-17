<template>
  <div class="app">
    <Navbar />
    <main>
      <Hero />
      <About />
      <Features />
      <ProductCatalog />
      <Testimonials />
      <FAQ />
      <HowToOrder />
      <CTA />
    </main>
    <Footer />
    <WhatsAppFloat />
    <MobileStickyBar />
  </div>
</template>

<script setup>
import Navbar from './components/Navbar.vue'
import Hero from './components/Hero.vue'
import About from './components/About.vue'
import Features from './components/Features.vue'
import ProductCatalog from './components/ProductCatalog.vue'
import Testimonials from './components/Testimonials.vue'
import FAQ from './components/FAQ.vue'
import HowToOrder from './components/HowToOrder.vue'
import CTA from './components/CTA.vue'
import Footer from './components/Footer.vue'
import WhatsAppFloat from './components/WhatsAppFloat.vue'
import MobileStickyBar from './components/MobileStickyBar.vue'
</script>
