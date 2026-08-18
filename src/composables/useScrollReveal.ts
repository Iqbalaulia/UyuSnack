import { ref, onMounted, onUnmounted } from 'vue'

interface UseScrollRevealOptions {
  once?: boolean
  threshold?: number
  rootMargin?: string
}

export function useScrollReveal(options: UseScrollRevealOptions = {}) {
  const el = ref<HTMLElement | null>(null)
  const isVisible = ref<boolean>(false)

  let observer: IntersectionObserver | null = null

  onMounted(() => {
    if (!el.value) return

    observer = new IntersectionObserver(
      ([entry]) => {
        if (entry.isIntersecting) {
          isVisible.value = true
          if (options.once !== false && el.value) {
            observer!.unobserve(el.value)
          }
        } else if (options.once === false) {
          isVisible.value = false
        }
      },
      {
        threshold: options.threshold || 0.15,
        rootMargin: options.rootMargin || '0px 0px -50px 0px',
      }
    )

    observer.observe(el.value)
  })

  onUnmounted(() => {
    if (observer && el.value) {
      observer.unobserve(el.value)
    }
  })

  return { el, isVisible }
}
