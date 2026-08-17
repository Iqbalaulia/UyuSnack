<template>
  <svg xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M10 17h6V6H3v11h3"/>
    <circle cx="6.5" cy="17.5" r="2.5"/>
    <circle cx="17.5" cy="17.5" r="2.5"/>
    <path d="M16 6V3a1 1 0 0 0-1-1H7a1 1 0 0 0-1 1v3"/>
    <path d="M16 6h4l2 4v6h-2"/>
  </svg>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 32 }
})
</script>
