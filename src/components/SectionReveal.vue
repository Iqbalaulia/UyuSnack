<template>
  <div ref="el" class="reveal" :class="[directionClass, { 'reveal--visible': isVisible }]">
    <slot />
  </div>
</template>

<script setup>
import { computed } from 'vue'
import { useScrollReveal } from '../composables/useScrollReveal.ts'

const props = defineProps({
  direction: { type: String, default: 'up' },
  once: { type: Boolean, default: true },
})

const { el, isVisible } = useScrollReveal({ once: props.once })

const directionClass = computed(() => {
  if (props.direction === 'left') return 'reveal--left'
  if (props.direction === 'right') return 'reveal--right'
  return ''
})
</script>
