import { reactive, computed } from 'vue'

export const cart = reactive({
  items: [],
})

export const addToCart = (product) => {
  const existing = cart.items.find((item) => item.id === product.id)
  if (existing) {
    existing.qty += 1
  } else {
    cart.items.push({ ...product, qty: 1 })
  }
}

export const removeFromCart = (productId) => {
  const index = cart.items.findIndex((item) => item.id === productId)
  if (index !== -1) {
    cart.items.splice(index, 1)
  }
}

export const updateQty = (productId, qty) => {
  const item = cart.items.find((item) => item.id === productId)
  if (!item) return
  if (qty <= 0) {
    removeFromCart(productId)
  } else {
    item.qty = qty
  }
}

export const totalItems = computed(() => {
  return cart.items.reduce((sum, item) => sum + item.qty, 0)
})

export const totalPrice = computed(() => {
  return cart.items.reduce((sum, item) => sum + item.price * item.qty, 0)
})

export const clearCart = () => {
  cart.items = []
}

export const getWhatsAppOrderMessage = () => {
  if (cart.items.length === 0) return ''

  const lines = cart.items.map(
    (item) => `- ${item.name} x${item.qty} = ${formatCurrency(item.price * item.qty)}`
  )

  return `Halo Uyu Snack, saya mau pesan:\n${lines.join('\n')}\n\nTotal: ${formatCurrency(totalPrice.value)}\n\nApakah bisa diproses?`
}

const formatCurrency = (value) => {
  return new Intl.NumberFormat('id-ID', {
    style: 'currency',
    currency: 'IDR',
    minimumFractionDigits: 0,
  }).format(value)
}
