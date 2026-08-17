<template>
  <svg xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <rect x="3" y="8" width="18" height="13" rx="2"/>
    <path d="M8 8V6a2 2 0 0 1 4 0v2"/>
    <path d="M12 8V6a2 2 0 0 1 4 0v2"/>
    <path d="M12 14v3"/>
  </svg>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 32 }
})
</script>
