import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import { blogPosts as localBlogPosts, type BlogPost } from '../data/blog'

export function useBlogPosts() {
  const posts = ref<BlogPost[]>([])
  const loading = ref<boolean>(true)
  const error = ref<string | null>(null)
  const usingFallback = ref<boolean>(false)

  const fetchPosts = async () => {
    loading.value = true
    error.value = null

    try {
      const { data, error: supaError } = await supabase
        .from('blog_posts')
        .select('*')
        .eq('is_active', true)
        .order('sort_order', { ascending: true })

      if (supaError) throw supaError

      if (data && data.length > 0) {
        posts.value = data as BlogPost[]
        usingFallback.value = false
      } else {
        throw new Error('No blog posts found')
      }
    } catch (err) {
      console.warn('Failed to fetch blog posts from Supabase:', (err as Error).message)
      posts.value = localBlogPosts
      usingFallback.value = true
      error.value = (err as Error).message
    } finally {
      loading.value = false
    }
  }

  onMounted(() => {
    fetchPosts()
  })

  return {
    posts,
    loading,
    error,
    usingFallback,
    fetchPosts,
  }
}
