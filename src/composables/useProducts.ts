import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import {
  products as localProducts,
  formatPrice,
  WHATSAPP_NUMBER,
  getWhatsAppLink,
  type Product,
} from '../data/products'

export function useProducts() {
  const products = ref<Product[]>([])
  const loading = ref<boolean>(true)
  const error = ref<string | null>(null)
  const usingFallback = ref<boolean>(false)

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
        products.value = data as Product[]
        usingFallback.value = false
      } else {
        throw new Error('No products found')
      }
    } catch (err) {
      console.warn('Failed to fetch products from Supabase:', (err as Error).message)
      products.value = localProducts
      usingFallback.value = true
      error.value = (err as Error).message
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
    formatPrice,
    WHATSAPP_NUMBER,
    getWhatsAppLink,
    fetchProducts,
  }
}
