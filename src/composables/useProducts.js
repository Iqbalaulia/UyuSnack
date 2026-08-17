import { ref, computed, onMounted } from 'vue'
import { supabase } from '../lib/supabase.js'
import { products as localProducts, formatPrice, stockLabels, WHATSAPP_NUMBER, getWhatsAppLink } from '../data/products.js'

export function useProducts() {
  const products = ref([])
  const loading = ref(true)
  const error = ref(null)
  const usingFallback = ref(false)

  const categories = [
    { id: 'all', name: 'Semua' },
    { id: 'best-seller', name: 'Best Seller' },
    { id: 'new', name: 'New Variant' },
  ]

  const fetchProducts = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: supaError } = await supabase
        .from('products')
        .select('*')
        .eq('is_active', true)
        .order('id', { ascending: true })

      if (supaError) throw supaError

      if (data && data.length > 0) {
        products.value = data
        usingFallback.value = false
      } else {
        throw new Error('No products found')
      }
    } catch (err) {
      console.warn('Failed to fetch products from Supabase:', err.message)
      products.value = localProducts
      usingFallback.value = true
      error.value = err.message
    } finally {
      loading.value = false
    }
  }

  onMounted(() => {
    fetchProducts()
  })

  return {
    products,
    loading,
    error,
    usingFallback,
    categories,
    formatPrice,
    stockLabels,
    WHATSAPP_NUMBER,
    getWhatsAppLink,
    fetchProducts,
  }
}
