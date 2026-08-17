export const categories = [
  { id: "all", name: "Semua" },
  { id: "sweet", name: "Manis" },
  { id: "savory", name: "Gurih" },
  { id: "package", name: "Paket" },
];

export const products = [
  {
    id: 1,
    name: "Burnt Cheesecake OG",
    category: "sweet",
    price: 21000,
    description:
      "Brownies legit dengan topping keju meleleh, cocok untuk teman ngopi.",
    image: "/assets/images/burnt_cheesecake_original.jpg",
    badge: "Best Seller",
  },
  {
    id: 2,
    name: "Burnt Cheesecake Chocobery",
    category: "sweet",
    price: 23500,
    description:
      "Cireng renyah diluar kenyal didalam dengan isian ayam suwir pedas.",
    image: "/assets/images/burnt_cheesecake_chocobery.jpg",
    badge: "Best Seller",
  },
  {
    id: 3,
    name: "Burnt Cheesecake Chocolate Regal",
    category: "sweet",
    price: 23500,
    description: "Aneka kue kering lembut untuk hampers atau suguhan keluarga.",
    image: "/assets/images/burnt_cheesecake_chocoregal.jpg",
    badge: "Terlaris",
  },
];

export const formatPrice = (price) => {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(price);
};
