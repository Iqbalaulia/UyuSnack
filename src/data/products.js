export const categories = [
  { id: 'all', name: 'Semua' },
  { id: 'sweet', name: 'Manis' },
  { id: 'savory', name: 'Gurih' },
  { id: 'package', name: 'Paket' },
]

export const products = [
  {
    id: 1,
    name: 'Brownies Lumer',
    category: 'sweet',
    price: 35000,
    description: 'Brownies legit dengan topping keju meleleh, cocok untuk teman ngopi.',
    image: '/assets/brownies-lumer.jpg',
    badge: 'Best Seller',
  },
  {
    id: 2,
    name: 'Cireng Isi Ayam Suwir',
    category: 'savory',
    price: 28000,
    description: 'Cireng renyah diluar kenyal didalam dengan isian ayam suwir pedas.',
    image: '/assets/cireng-ayam.jpg',
    badge: null,
  },
  {
    id: 3,
    name: 'Kue Kering Mix',
    category: 'sweet',
    price: 45000,
    description: 'Aneka kue kering lembut untuk hampers atau suguhan keluarga.',
    image: '/assets/kue-kering.jpg',
    badge: 'Terlaris',
  },
  {
    id: 4,
    name: 'Baso Aci Tulang Rangu',
    category: 'savory',
    price: 25000,
    description: 'Baso aci kenyal dengan tulang rangu renyah dan bumbu pedas nendang.',
    image: '/assets/baso-aci.jpg',
    badge: null,
  },
  {
    id: 5,
    name: 'Paket Ngopi Sore',
    category: 'package',
    price: 65000,
    description: 'Kombinasi brownies lumer + kue kering mix dalam kemasan cantik.',
    image: '/assets/paket-ngopi.jpg',
    badge: 'Hemat 10%',
  },
  {
    id: 6,
    name: 'Keripik Singkong Balado',
    category: 'savory',
    price: 22000,
    description: 'Keripik singkong tipis renyah dengan bumbu balado gurih pedas.',
    image: '/assets/keripik-balado.jpg',
    badge: null,
  },
]

export const formatPrice = (price) => {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(price)
}
