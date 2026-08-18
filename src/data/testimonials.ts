export interface Testimonial {
  id: number
  name: string
  role_id: string
  role_en: string
  text_id: string
  text_en: string
  avatar: string
  is_active: boolean
  sort_order: number
}

export const testimonials: Testimonial[] = [
  {
    id: 1,
    name: 'Dinda A.',
    role_id: 'Pelanggan Setia',
    role_en: 'Loyal Customer',
    text_id:
      'Burnt Cheesecake Original-nya enak banget, lembut dan nggak eneg. Sudah repeat order 3 kali!',
    text_en:
      'The Burnt Cheesecake Original is so good, soft and not overwhelming. Already reordered 3 times!',
    avatar: '/assets/burnt-cheesecake-original.jpg',
    is_active: true,
    sort_order: 1,
  },
  {
    id: 2,
    name: 'Rizky M.',
    role_id: 'Pembeli Pertama',
    role_en: 'First-time Buyer',
    text_id:
      'Chocobery-nya manisnya pas, topping stroberi dan cokelatnya melimpah. Favorit keluarga!',
    text_en:
      'The Chocobery sweetness is just right, strawberry and chocolate toppings are abundant. Family favorite!',
    avatar: '/assets/burnt-cheesecake-chocobery.jpg',
    is_active: true,
    sort_order: 2,
  },
  {
    id: 3,
    name: 'Siti N.',
    role_id: 'Pembeli Hampers',
    role_en: 'Hampers Buyer',
    text_id:
      'Pesan Chocolate Regal untuk hadiah teman, dikirim tepat waktu dan penerima senang banget.',
    text_en:
      'Ordered Chocolate Regal as a gift for a friend, delivered on time and the recipient was very happy.',
    avatar: '/assets/burnt-cheesecake-chocoregal.jpg',
    is_active: true,
    sort_order: 3,
  },
]
