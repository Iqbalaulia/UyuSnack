<template>
  <svg xmlns="http://www.w3.org/2000/svg" :width="size" :height="size" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
    <path d="M12 2l9 4.5v11L12 22l-9-4.5v-11L12 2z"/>
    <path d="M12 22V11"/>
    <path d="M12 11L3 6.5"/>
    <path d="M12 11l9-4.5"/>
    <path d="M9 4L3 7"/>
    <path d="M15 4l6 3"/>
  </svg>
</template>

<script setup>
defineProps({
  size: { type: [Number, String], default: 32 }
})
</script>
