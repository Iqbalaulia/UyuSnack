export interface BlogPost {
  id: number
  slug: string
  title_id: string
  title_en: string
  excerpt_id: string
  excerpt_en: string
  content_id: string
  content_en: string
  image: string
  published_at: string
  read_time_minutes: number
  is_active: boolean
  sort_order: number
}

export const blogPosts: BlogPost[] = [
  {
    id: 1,
    slug: 'cara-menyimpan-burnt-cheesecake',
    title_id: 'Cara Menyimpan Burnt Cheesecake Agar Tetap Lembut',
    title_en: 'How to Store Burnt Cheesecake to Keep It Soft',
    excerpt_id:
      'Simpan dalam kulkas dan biarkan suhu ruang 10-15 menit sebelum disantap untuk tekstur terbaik.',
    excerpt_en:
      'Store in the refrigerator and let it reach room temperature for 10-15 minutes before serving for the best texture.',
    content_id:
      '<p>Burnt cheesecake terbaik dinikmati dalam suhu ruang. Simpan dalam kulkas maksimal 3 hari dalam wadah kedap udara.</p><p>Keluarkan dari kulkas 10-15 menit sebelum disantap agar tekstur kembali lembut dan creamy. Hindari memasukkan ke freezer karena dapat mengubah tekstur.</p>',
    content_en:
      '<p>Burnt cheesecake is best enjoyed at room temperature. Store in the refrigerator for up to 3 days in an airtight container.</p><p>Remove from the fridge 10-15 minutes before serving so the texture becomes soft and creamy again. Avoid freezing as it changes the texture.</p>',
    image: '/assets/burnt-cheesecake-original.jpg',
    published_at: new Date().toISOString().slice(0, 10),
    read_time_minutes: 2,
    is_active: true,
    sort_order: 1,
  },
  {
    id: 2,
    slug: 'ide-hampers-simpel-untuk-orang-tersayang',
    title_id: 'Ide Hampers Simpel untuk Orang Tersayang',
    title_en: 'Simple Hampers Ideas for Loved Ones',
    excerpt_id:
      'Kombinasi burnt cheesecake dengan kartu ucapan kecil bisa jadi hadiah yang berkesan.',
    excerpt_en:
      'A combination of burnt cheesecake with a small greeting card can be a memorable gift.',
    content_id:
      '<p>Hampers tidak perlu mahal untuk terasa berkesan. Pilih 2-3 varian burnt cheesecake, tambahkan kartu ucapan tulisan tangan, dan kemas dalam box minimalis.</p><p>Cocok untuk ulang tahun, anniversary, atau hadiah rutin. Pesan satu hari sebelumnya agar pengiriman tepat waktu.</p>',
    content_en:
      '<p>Hampers do not have to be expensive to feel meaningful. Choose 2-3 burnt cheesecake variants, add a handwritten greeting card, and pack them in a minimalist box.</p><p>Perfect for birthdays, anniversaries, or casual gifts. Order one day in advance for on-time delivery.</p>',
    image: '/assets/burnt-cheesecake-chocobery.jpg',
    published_at: new Date().toISOString().slice(0, 10),
    read_time_minutes: 2,
    is_active: true,
    sort_order: 2,
  },
  {
    id: 3,
    slug: 'paduan-terbaik-burnt-cheesecake-dengan-minuman',
    title_id: 'Paduan Terbaik Burnt Cheesecake dengan Minuman',
    title_en: 'Best Drinks to Pair with Burnt Cheesecake',
    excerpt_id:
      'Cobain dinikmati bersama kopi hitam atau teh tarik untuk pengalaman rasa yang lebih nikmat.',
    excerpt_en:
      'Try enjoying it with black coffee or tarik tea for a more delightful taste experience.',
    content_id:
      '<p>Burnt cheesecake yang creamy dan sedikit pahit cocok dipadukan dengan minuman yang menyegarkan.</p><p>Kopi hitam tanpa gula menyeimbangkan rasa manis, teh tarik memberikan sentuhan klasik, sedangkan susu dingin cocok untuk yang tidak suka kafein.</p>',
    content_en:
      '<p>The creamy and slightly bitter burnt cheesecake pairs well with refreshing drinks.</p><p>Black coffee without sugar balances the sweetness, tarik tea gives a classic touch, while cold milk is perfect for those who avoid caffeine.</p>',
    image: '/assets/burnt-cheesecake-chocoregal.jpg',
    published_at: new Date().toISOString().slice(0, 10),
    read_time_minutes: 2,
    is_active: true,
    sort_order: 3,
  },
]
