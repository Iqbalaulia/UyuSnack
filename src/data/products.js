export const products = [
  {
    id: 1,
    name: "Burnt Cheesecake Original",
    category: "best-seller",
    price: 21000,
    description:
      "Classic variant dengan tekstur lembut dan permukaan karamelisasi yang sempurna. Diameter 10cm, tinggi 3cm.",
    image: "/assets/burnt-cheesecake-original.jpg",
    badge: "Best Seller",
    stock: "preorder",
  },
  {
    id: 2,
    name: "Burnt Cheesecake Chocobery",
    category: "new",
    price: 23500,
    description:
      "Perpaduan lembut burnt cheesecake dengan topping selai stroberi manis dan lilitan cokelat premium.",
    image: "/assets/burnt-cheesecake-chocobery.jpg",
    badge: "New Variant",
    stock: "preorder",
  },
  {
    id: 3,
    name: "Burnt Cheesecake Chocolate Regal",
    category: "new",
    price: 23500,
    description:
      "Burnt cheesecake cokelat dengan topping cokelat lumer, biskuit Regal utuh, dan remahan biskuit renyah.",
    image: "/assets/burnt-cheesecake-chocoregal.jpg",
    badge: "New Variant",
    stock: "preorder",
  },
];

export const formatPrice = (price) => {
  return new Intl.NumberFormat("id-ID", {
    style: "currency",
    currency: "IDR",
    minimumFractionDigits: 0,
  }).format(price);
};

export const WHATSAPP_NUMBER = "6281216593329";

export const getWhatsAppLink = (message) => {
  return `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(message)}`;
};
