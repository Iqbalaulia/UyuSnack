import { reactive, computed } from 'vue'
import type { Product } from '../data/products'

export interface CartItem extends Product {
  qty: number
}

export const cart = reactive<{
  items: CartItem[]
}>({
  items: [],
})

export const addToCart = (product: Product): void => {
  const existing = cart.items.find((item) => item.id === product.id)
  if (existing) {
    existing.qty += 1
  } else {
    cart.items.push({ ...product, qty: 1 })
  }
}

export const removeFromCart = (productId: number): void => {
  const index = cart.items.findIndex((item) => item.id === productId)
  if (index !== -1) {
    cart.items.splice(index, 1)
  }
}

export const updateQty = (productId: number, qty: number): void => {
  const item = cart.items.find((item) => item.id === productId)
  if (!item) return
  if (qty <= 0) {
    removeFromCart(productId)
  } else {
    item.qty = qty
  }
}

export const totalItems = computed<number>(() => {
  return cart.items.reduce((sum, item) => sum + item.qty, 0)
})

export const totalPrice = computed<number>(() => {
  return cart.items.reduce((sum, item) => sum + item.price * item.qty, 0)
})

export const clearCart = (): void => {
  cart.items = []
}
