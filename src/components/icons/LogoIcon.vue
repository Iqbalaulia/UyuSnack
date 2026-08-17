<template>
  <svg xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M4 10h16v8a2 2 0 0 1-2 2H6a2 2 0 0 1-2-2v-8z"/>
    <path d="M6 10V7a3 3 0 0 1 3-3h6a3 3 0 0 1 3 3v3"/>
    <path d="M8 4l2-2"/>
    <path d="M16 4l-2-2"/>
    <circle cx="9" cy="14" r="1.5" fill="currentColor" stroke="none"/>
    <circle cx="15" cy="14" r="1.5" fill="currentColor" stroke="none"/>
  </svg>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 24 }
})
</script>
