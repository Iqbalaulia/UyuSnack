<template>
  <transition name="ann">
    <div v-if="batch" ref="barEl" class="ann">
      <div class="ann__inner">
        <span class="ann__dot" aria-hidden="true"></span>
        <span class="ann__text">
          <strong>{{ t('announcement.open') }}:</strong>
          {{ batch.name }}
          <span class="ann__sep">·</span>
          <span class="ann__deadline">
            {{ daysLeft === 0 ? t('announcement.closesToday') : t('announcement.closesIn', { n: daysLeft }) }}
          </span>
        </span>
        <a href="#menu" class="ann__cta">{{ t('announcement.order') }}</a>
      </div>
    </div>
  </transition>
</template>

<script setup>
import { ref, watch, nextTick, onBeforeUnmount } from 'vue'
import { useI18n } from 'vue-i18n'

const { t } = useI18n()
const props = defineProps({
  batch: { type: Object, default: null },
  daysLeft: { type: Number, default: null },
})

// Ukur tinggi bar yang sebenarnya (bisa lebih tinggi saat teks wrap di mobile)
// lalu set ke --ann-height agar navbar & konten selalu tergeser pas.
const barEl = ref(null)
let observer = null

const setHeight = (px) => document.documentElement.style.setProperty('--ann-height', px + 'px')
const clearHeight = () => document.documentElement.style.removeProperty('--ann-height')

watch(
  () => props.batch,
  async (b) => {
    observer?.disconnect()
    if (!b) return clearHeight()
    await nextTick()
    if (!barEl.value) return
    observer = new ResizeObserver(() => barEl.value && setHeight(barEl.value.offsetHeight))
    observer.observe(barEl.value)
    setHeight(barEl.value.offsetHeight)
  },
  { immediate: true }
)

onBeforeUnmount(() => {
  observer?.disconnect()
  clearHeight()
})
</script>

<style scoped>
.ann {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1003;
  background: linear-gradient(90deg, var(--color-primary-dark), var(--color-primary));
  color: #fff;
}
.ann__inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0.55rem 1rem;
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.6rem;
  flex-wrap: wrap;
  font-size: 0.9rem;
}
.ann__dot {
  width: 0.55rem;
  height: 0.55rem;
  border-radius: 50%;
  background: #fff;
  flex-shrink: 0;
  animation: ann-pulse 1.4s ease-in-out infinite;
}
@keyframes ann-pulse {
  0%, 100% { opacity: 1; transform: scale(1); }
  50% { opacity: 0.4; transform: scale(0.7); }
}
.ann__text {
  line-height: 1.3;
}
.ann__sep {
  opacity: 0.6;
  margin: 0 0.15rem;
}
.ann__deadline {
  font-weight: 700;
}
.ann__cta {
  background: #fff;
  color: var(--color-primary-dark);
  font-weight: 700;
  font-size: 0.82rem;
  padding: 0.3rem 0.9rem;
  border-radius: 9999px;
  white-space: nowrap;
}
.ann__cta:hover {
  background: var(--color-accent);
  color: var(--color-text);
}
.ann-enter-active {
  transition: all 0.4s ease;
}
.ann-enter-from {
  opacity: 0;
  transform: translateY(-100%);
}

@media (max-width: 600px) {
  .ann__inner {
    font-size: 0.82rem;
    gap: 0.4rem;
  }
}
</style>
