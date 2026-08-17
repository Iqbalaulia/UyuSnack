<template>
  <svg xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <rect x="3" y="4" width="18" height="5" rx="2"/>
    <rect x="3" y="14" width="12" height="5" rx="2"/>
  </svg>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 32 }
})
</script>
