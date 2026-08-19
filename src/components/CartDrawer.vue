<template>
  <teleport to="body">
    <transition name="cart-overlay">
      <div v-if="isOpen" class="cart-overlay" @click.self="close"></div>
    </transition>
    <transition name="cart-drawer">
      <aside v-if="isOpen" class="cart-drawer">
        <div class="cart-drawer__header">
          <h3 class="cart-drawer__title">{{ t('cart.title') }}</h3>
          <button class="cart-drawer__close" @click="close" :aria-label="t('cart.title')">
            <CloseIcon :size="24" />
          </button>
        </div>

        <div v-if="cart.items.length === 0" class="cart-drawer__empty">
          <CartIcon :size="48" />
          <p>{{ t('cart.empty') }}</p>
          <a href="#menu" class="btn btn-primary" @click="close">{{ t('cart.viewMenu') }}</a>
        </div>

        <div v-else class="cart-drawer__body">
          <div class="cart-drawer__items">
            <div v-for="item in cart.items" :key="item.id" class="cart-item">
              <img :src="item.image" :alt="item.name" class="cart-item__image" />
              <div class="cart-item__details">
                <h4 class="cart-item__name">{{ item.name }}</h4>
                <p class="cart-item__price">{{ formatPrice(item.price) }}</p>
                <div class="cart-item__qty">
                  <button @click="updateQty(item.id, item.qty - 1)" aria-label="-">−</button>
                  <span>{{ item.qty }}</span>
                  <button @click="updateQty(item.id, item.qty + 1)" aria-label="+">+</button>
                </div>
              </div>
              <button class="cart-item__remove" @click="removeFromCart(item.id)" aria-label="x">
                <TrashIcon :size="18" />
              </button>
            </div>
          </div>

          <div class="cart-drawer__footer">
            <div class="cart-drawer__total">
              <span>{{ t('cart.total') }}</span>
              <strong>{{ formatPrice(totalPrice) }}</strong>
            </div>
            <input v-model="customerName" type="text" class="cart-drawer__input" :placeholder="t('cart.namePlaceholder')" />
            <input v-model="customerPhone" type="tel" class="cart-drawer__input" :placeholder="t('cart.phonePlaceholder')" />
            <button
              class="btn btn-primary cart-drawer__checkout"
              :disabled="submitting"
              @click="checkout"
            >
              {{ submitting ? '...' : t('cart.checkout') }}
            </button>
            <button class="cart-drawer__clear" @click="clearCart">{{ t('cart.clear') }}</button>
          </div>
        </div>
      </aside>
    </transition>
  </teleport>
</template>

<script setup>
import { computed, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { cart, removeFromCart, updateQty, clearCart, totalPrice } from '../stores/cart.ts'
import { formatPrice, WHATSAPP_NUMBER } from '../data/products.ts'
import { supabase } from '../lib/supabase.ts'
import { track } from '../lib/track.ts'
import CloseIcon from './icons/CloseIcon.vue'
import CartIcon from './icons/CartIcon.vue'
import TrashIcon from './icons/TrashIcon.vue'

const { t } = useI18n()

const props = defineProps({
  isOpen: { type: Boolean, default: false },
})

const emit = defineEmits(['close'])

const close = () => emit('close')

const getWhatsAppOrderMessage = () => {
  if (cart.items.length === 0) return ''
  const lines = cart.items.map(
    (item) => `- ${item.name} x${item.qty} = ${formatPrice(item.price * item.qty)}`
  )
  return `${t('cart.orderMessage')}\n${lines.join('\n')}\n\n${t('cart.total')}: ${formatPrice(totalPrice.value)}\n\n${t('cart.availability')}`
}

const orderLink = computed(() => {
  return `https://wa.me/${WHATSAPP_NUMBER}?text=${encodeURIComponent(getWhatsAppOrderMessage())}`
})

const customerName = ref('')
const customerPhone = ref('')
const submitting = ref(false)

const checkout = async () => {
  if (cart.items.length === 0) return
  track('checkout_start', { cartValue: totalPrice.value })
  submitting.value = true
  try {
    await supabase.from('orders').insert({
      customer_name: customerName.value || 'WhatsApp Customer',
      customer_phone: customerPhone.value || '-',
      items: cart.items.map((i) => ({ id: i.id, name: i.name, price: i.price, qty: i.qty })),
      total_price: totalPrice.value,
    })
  } catch (err) {
    console.warn('Gagal simpan order:', err)
  } finally {
    submitting.value = false
    window.open(orderLink.value, '_blank', 'noopener')
    close()
  }
}
</script>

<style scoped>
.cart-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.4);
  z-index: 1001;
}

.cart-drawer {
  position: fixed;
  top: 0;
  right: 0;
  width: 100%;
  max-width: 420px;
  height: 100vh;
  background: var(--color-white);
  z-index: 1002;
  display: flex;
  flex-direction: column;
  box-shadow: -5px 0 30px rgba(0, 0, 0, 0.1);
}

.cart-drawer__header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding: 1.25rem;
  border-bottom: 1px solid var(--color-border);
}

.cart-drawer__title {
  font-size: 1.25rem;
  font-weight: 800;
}

.cart-drawer__close {
  display: inline-flex;
  color: var(--color-text-light);
}

.cart-drawer__close:hover {
  color: var(--color-text);
}

.cart-drawer__empty {
  flex: 1;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  gap: 1rem;
  padding: 2rem;
  color: var(--color-text-light);
  text-align: center;
}

.cart-drawer__body {
  flex: 1;
  display: flex;
  flex-direction: column;
  overflow: hidden;
}

.cart-drawer__items {
  flex: 1;
  overflow-y: auto;
  padding: 1.25rem;
}

.cart-item {
  display: flex;
  gap: 1rem;
  padding: 1rem 0;
  border-bottom: 1px solid var(--color-border);
}

.cart-item__image {
  width: 4rem;
  height: 4rem;
  object-fit: cover;
  border-radius: var(--radius-sm);
  flex-shrink: 0;
}

.cart-item__details {
  flex: 1;
}

.cart-item__name {
  font-size: 0.95rem;
  font-weight: 700;
  margin-bottom: 0.25rem;
}

.cart-item__price {
  font-size: 0.85rem;
  color: var(--color-primary-dark);
  font-weight: 700;
  margin-bottom: 0.5rem;
}

.cart-item__qty {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  border: 1px solid var(--color-border);
  border-radius: 9999px;
  padding: 0.25rem;
}

.cart-item__qty button {
  width: 1.75rem;
  height: 1.75rem;
  border-radius: 50%;
  background: var(--color-bg);
  color: var(--color-text);
  font-weight: 700;
  display: flex;
  align-items: center;
  justify-content: center;
}

.cart-item__qty span {
  min-width: 1.5rem;
  text-align: center;
  font-size: 0.9rem;
  font-weight: 700;
}

.cart-item__remove {
  color: var(--color-text-light);
  align-self: flex-start;
}

.cart-item__remove:hover {
  color: #ef4444;
}

.cart-drawer__footer {
  padding: 1.25rem;
  border-top: 1px solid var(--color-border);
  background: var(--color-bg);
}

.cart-drawer__total {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 1rem;
  font-size: 1.1rem;
}

.cart-drawer__total strong {
  color: var(--color-primary-dark);
  font-size: 1.25rem;
}

.cart-drawer__input {
  width: 100%;
  padding: 0.6rem 0.75rem;
  margin-bottom: 0.5rem;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  font: inherit;
}

.cart-drawer__checkout {
  width: 100%;
  margin-bottom: 0.75rem;
}

.cart-drawer__checkout:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.cart-drawer__clear {
  width: 100%;
  color: var(--color-text-light);
  font-size: 0.85rem;
  text-decoration: underline;
}

.cart-drawer__clear:hover {
  color: var(--color-text);
}

.cart-overlay-enter-active,
.cart-overlay-leave-active {
  transition: opacity 0.3s ease;
}

.cart-overlay-enter-from,
.cart-overlay-leave-to {
  opacity: 0;
}

.cart-drawer-enter-active,
.cart-drawer-leave-active {
  transition: transform 0.3s ease;
}

.cart-drawer-enter-from,
.cart-drawer-leave-to {
  transform: translateX(100%);
}
</style>
