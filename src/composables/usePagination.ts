import { ref, computed, watch, type Ref, type ComputedRef } from 'vue'

// Pagination client-side sederhana untuk tabel admin.
export function usePagination<T>(source: Ref<T[]> | ComputedRef<T[]>, perPage = 10) {
  const page = ref(1)

  const total = computed(() => source.value.length)
  const totalPages = computed(() => Math.max(1, Math.ceil(total.value / perPage)))

  // Kembali ke halaman valid saat data berubah (mis. setelah filter/hapus).
  watch(total, () => {
    if (page.value > totalPages.value) page.value = totalPages.value
  })

  const paged = computed(() =>
    source.value.slice((page.value - 1) * perPage, page.value * perPage)
  )

  return { page, total, totalPages, paged, perPage }
}
