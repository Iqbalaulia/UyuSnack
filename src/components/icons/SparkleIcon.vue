<template>
  <svg xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M12 2l1.5 4.5L18 8l-4.5 1.5L12 14l-1.5-4.5L6 8l4.5-1.5L12 2z"/>
    <path d="M19 14l1 2.5L22.5 18l-2.5 1.5L19 22l-1-2.5L15.5 18l2.5-1.5L19 14z"/>
    <path d="M5 16l.75 1.75L7.5 18.5l-1.75.75L5 21l-.75-1.75L2.5 18.5l1.75-.75L5 16z"/>
  </svg>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 18 }
})
</script>
