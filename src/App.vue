<template>
  <div class="app">
    <Navbar />
    <main>
      <Hero />
      <About />
      <Features />
      <ProductCatalog />
      <Testimonials />
      <HowToOrder />
      <CTA />
    </main>
    <Footer />
  </div>
</template>

<script setup>
import Navbar from './components/Navbar.vue'
import Hero from './components/Hero.vue'
import About from './components/About.vue'
import Features from './components/Features.vue'
import ProductCatalog from './components/ProductCatalog.vue'
import Testimonials from './components/Testimonials.vue'
import HowToOrder from './components/HowToOrder.vue'
import CTA from './components/CTA.vue'
import Footer from './components/Footer.vue'
</script>
