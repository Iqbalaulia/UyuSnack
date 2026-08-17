<template>
  <div class="lazy-image" :class="{ 'lazy-image--loaded': loaded }">
    <img
      :src="src"
      :alt="alt"
      :loading="loading"
      @load="loaded = true"
      @error="loaded = true"
    />
  </div>
</template>

<script setup>
import { ref } from 'vue'

defineProps({
  src: { type: String, required: true },
  alt: { type: String, default: '' },
  loading: { type: String, default: 'lazy' },
})

const loaded = ref(false)
</script>

<style scoped>
.lazy-image {
  position: relative;
  background: linear-gradient(110deg, #f0f0f0 8%, #fafafa 18%, #f0f0f0 33%);
  background-size: 200% 100%;
  animation: shimmer 1.5s infinite linear;
  overflow: hidden;
}

.lazy-image--loaded {
  animation: none;
  background: transparent;
}

.lazy-image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  opacity: 0;
  transition: opacity 0.4s ease;
}

.lazy-image--loaded img {
  opacity: 1;
}

@keyframes shimmer {
  0% {
    background-position: 200% 0;
  }
  100% {
    background-position: -200% 0;
  }
}
</style>
