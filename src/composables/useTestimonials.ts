import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import {
  testimonials as localTestimonials,
  type Testimonial,
} from '../data/testimonials'

export function useTestimonials() {
  const testimonials = ref<Testimonial[]>([])
  const loading = ref<boolean>(true)
  const error = ref<string | null>(null)
  const usingFallback = ref<boolean>(false)

  const fetchTestimonials = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: supaError } = await supabase
        .from('testimonials')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (supaError) throw supaError

      if (data && data.length > 0) {
        testimonials.value = data as Testimonial[]
        usingFallback.value = false
      } else {
        throw new Error('No testimonials found')
      }
    } catch (err) {
      console.warn('Failed to fetch testimonials from Supabase:', (err as Error).message)
      testimonials.value = localTestimonials
      usingFallback.value = true
      error.value = (err as Error).message
    } finally {
      loading.value = false
    }
  }

  onMounted(() => {
    fetchTestimonials()
  })

  return {
    testimonials,
    loading,
    error,
    usingFallback,
    fetchTestimonials,
  }
}
