<template>
  <svg xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M3 10.5V20a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-9.5"/>
    <path d="M2 10l10-7 10 7"/>
    <path d="M15 22v-6a2 2 0 0 0-2-2h-2a2 2 0 0 0-2 2v6"/>
  </svg>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 32 }
})
</script>
