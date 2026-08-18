export interface BlogPost {
  id: number
  title_id: string
  title_en: string
  excerpt_id: string
  excerpt_en: string
  image: string
  is_active: boolean
  sort_order: number
}

export const blogPosts: BlogPost[] = [
  {
    id: 1,
    title_id: 'Cara Menyimpan Burnt Cheesecake Agar Tetap Lembut',
    title_en: 'How to Store Burnt Cheesecake to Keep It Soft',
    excerpt_id:
      'Simpan dalam kulkas dan biarkan suhu ruang 10-15 menit sebelum disantap untuk tekstur terbaik.',
    excerpt_en:
      'Store in the refrigerator and let it reach room temperature for 10-15 minutes before serving for the best texture.',
    image: '/assets/burnt-cheesecake-original.jpg',
    is_active: true,
    sort_order: 1,
  },
  {
    id: 2,
    title_id: 'Ide Hampers Simpel untuk Orang Tersayang',
    title_en: 'Simple Hampers Ideas for Loved Ones',
    excerpt_id:
      'Kombinasi burnt cheesecake dengan kartu ucapan kecil bisa jadi hadiah yang berkesan.',
    excerpt_en:
      'A combination of burnt cheesecake with a small greeting card can be a memorable gift.',
    image: '/assets/burnt-cheesecake-chocobery.jpg',
    is_active: true,
    sort_order: 2,
  },
  {
    id: 3,
    title_id: 'Paduan Terbaik Burnt Cheesecake dengan Minuman',
    title_en: 'Best Drinks to Pair with Burnt Cheesecake',
    excerpt_id:
      'Cobain dinikmati bersama kopi hitam atau teh tarik untuk pengalaman rasa yang lebih nikmat.',
    excerpt_en:
      'Try enjoying it with black coffee or tarik tea for a more delightful taste experience.',
    image: '/assets/burnt-cheesecake-chocoregal.jpg',
    is_active: true,
    sort_order: 3,
  },
]
