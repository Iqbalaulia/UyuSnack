<template>
  <div v-if="totalPages > 1 || total > 0" class="pg">
    <span class="pg__info">{{ total }} data · Hal {{ page }}/{{ totalPages }}</span>
    <div class="pg__controls">
      <button class="admin-btn admin-btn--sm" :disabled="page <= 1" @click="go(1)">«</button>
      <button class="admin-btn admin-btn--sm" :disabled="page <= 1" @click="go(page - 1)">‹</button>
      <button class="admin-btn admin-btn--sm" :disabled="page >= totalPages" @click="go(page + 1)">›</button>
      <button class="admin-btn admin-btn--sm" :disabled="page >= totalPages" @click="go(totalPages)">»</button>
    </div>
  </div>
</template>

<script setup lang="ts">
const props = defineProps<{ page: number; totalPages: number; total: number }>()
const emit = defineEmits<{ 'update:page': [n: number] }>()
const go = (n: number) => emit('update:page', Math.min(Math.max(1, n), props.totalPages))
</script>

<style scoped>
.pg {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  flex-wrap: wrap;
  margin-top: 1rem;
}
.pg__info {
  font-size: 0.82rem;
  color: var(--color-text-light);
}
.pg__controls {
  display: flex;
  gap: 0.35rem;
}
</style>
