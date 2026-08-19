<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Orders</h2>
      <div style="display:flex; gap:.5rem">
        <button class="admin-btn" @click="fetchOrders">↻ Refresh</button>
        <button class="admin-btn admin-btn--primary" @click="openCreate">+ Order Manual</button>
      </div>
    </div>

    <div class="admin-stats">
      <div class="admin-stat">
        <div class="admin-stat__value">{{ orders.length }}</div>
        <div class="admin-stat__label">Total Order</div>
      </div>
      <div class="admin-stat">
        <div class="admin-stat__value">{{ countBy('pending') }}</div>
        <div class="admin-stat__label">Order Baru</div>
      </div>
      <div class="admin-stat">
        <div class="admin-stat__value">{{ countBy('processing') + countBy('confirmed') }}</div>
        <div class="admin-stat__label">Sedang Diproses</div>
      </div>
      <div class="admin-stat">
        <div class="admin-stat__value">{{ formatPrice(revenue) }}</div>
        <div class="admin-stat__label">Omzet (non-batal)</div>
      </div>
    </div>

    <div class="admin-toolbar">
      <input v-model="search" class="admin-input" placeholder="Cari nama / no. HP..." />
      <button
        v-for="s in ['', ...ORDER_STATUSES]"
        :key="s"
        class="admin-chip"
        :class="{ 'admin-chip--active': statusFilter === s }"
        @click="statusFilter = s"
      >
        {{ s ? STATUS_LABELS[s] : 'Semua' }}
      </button>
    </div>

    <p v-if="loading" class="admin-muted">Memuat...</p>
    <div v-else-if="filtered.length === 0" class="admin-card admin-empty">Belum ada order.</div>

    <div v-else style="display:flex; flex-direction:column; gap:1rem">
      <article v-for="o in paged" :key="o.id" class="admin-card order">
        <div class="order__head">
          <div>
            <strong>#{{ o.id }} — {{ o.customer_name }}</strong>
            <span class="admin-badge" :class="`admin-badge--${o.status}`">{{ STATUS_LABELS[o.status] }}</span>
            <p class="admin-muted" style="margin-top:.25rem">
              {{ formatDate(o.created_at) }}
              <template v-if="o.customer_address"> · {{ o.customer_address }}</template>
            </p>
            <a class="order__wa" :href="`https://wa.me/${normalizePhone(o.customer_phone)}`" target="_blank" rel="noopener">
              💬 {{ o.customer_phone }}
            </a>
          </div>
          <div class="order__actions">
            <select class="admin-input order__status" :value="o.status" @change="setStatus(o.id, ($event.target as HTMLSelectElement).value)">
              <option v-for="s in ORDER_STATUSES" :key="s" :value="s">{{ STATUS_LABELS[s] }}</option>
            </select>
            <button class="admin-btn admin-btn--danger admin-btn--sm" @click="remove(o)">Hapus</button>
          </div>
        </div>

        <ul class="order__items">
          <li v-for="(it, i) in o.items" :key="i">
            <span>{{ it.name }} × {{ it.qty }}</span>
            <span>{{ formatPrice(it.price * it.qty) }}</span>
          </li>
        </ul>

        <div class="order__notes" v-if="editingNotes === o.id">
          <textarea v-model="notesDraft" class="admin-input" rows="2" placeholder="Catatan internal..."></textarea>
          <div style="display:flex; gap:.5rem; margin-top:.4rem">
            <button class="admin-btn admin-btn--primary admin-btn--sm" @click="saveNotes(o.id)">Simpan</button>
            <button class="admin-btn admin-btn--sm" @click="editingNotes = null">Batal</button>
          </div>
        </div>
        <p v-else class="admin-muted order__notes-label" @click="startNotes(o)">
          📝 {{ o.notes || 'Tambah catatan...' }}
        </p>

        <div class="order__total">Total: <strong>{{ formatPrice(o.total_price) }}</strong></div>
      </article>
      <AdminPagination v-model:page="page" :total-pages="totalPages" :total="total" />
    </div>

    <!-- Modal: order manual -->
    <teleport to="body">
      <div v-if="showForm" class="admin-modal-overlay" @click.self="showForm = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">Order Manual</h3>
          <form class="admin-form" @submit.prevent="saveOrder">
            <div class="admin-form__row">
              <div>
                <label>Nama Customer *</label>
                <input v-model="form.customer_name" class="admin-input" required />
              </div>
              <div>
                <label>No. WhatsApp *</label>
                <input v-model="form.customer_phone" class="admin-input" required />
              </div>
            </div>
            <div>
              <label>Alamat</label>
              <input v-model="form.customer_address" class="admin-input" />
            </div>

            <div>
              <label>Item Pesanan *</label>
              <div class="order__item-builder">
                <select v-model="builderProductId" class="admin-input">
                  <option :value="null" disabled>Pilih produk...</option>
                  <option v-for="p in products" :key="p.id" :value="p.id">{{ p.name }} — {{ formatPrice(p.price) }}</option>
                </select>
                <input v-model.number="builderQty" type="number" min="1" class="admin-input order__qty" />
                <button type="button" class="admin-btn" @click="addItem">+</button>
              </div>
              <ul v-if="form.items.length" class="order__items" style="margin-top:.5rem">
                <li v-for="(it, i) in form.items" :key="i">
                  <span>{{ it.name }} × {{ it.qty }}</span>
                  <span>
                    {{ formatPrice(it.price * it.qty) }}
                    <button type="button" class="admin-btn admin-btn--danger admin-btn--sm" @click="form.items.splice(i, 1)">×</button>
                  </span>
                </li>
              </ul>
              <p v-else class="admin-muted" style="margin-top:.4rem">Belum ada item.</p>
            </div>

            <div>
              <label>Catatan</label>
              <textarea v-model="form.notes" class="admin-input" rows="2"></textarea>
            </div>

            <div class="order__total">Total: <strong>{{ formatPrice(formTotal) }}</strong></div>

            <div class="admin-form__actions">
              <button type="button" class="admin-btn" @click="showForm = false">Batal</button>
              <button class="admin-btn admin-btn--primary" :disabled="saving || form.items.length === 0">
                {{ saving ? 'Menyimpan...' : 'Simpan Order' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </teleport>

    <div v-if="toast" class="admin-toast">{{ toast }}</div>
  </section>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'
import { formatPrice } from '../../data/products'
import { usePagination } from '../../composables/usePagination'
import AdminPagination from './AdminPagination.vue'

interface OrderItem { id: number; name: string; price: number; qty: number }
interface Order {
  id: number
  customer_name: string
  customer_phone: string
  customer_address: string | null
  items: OrderItem[]
  total_price: number
  status: string
  notes: string | null
  created_at: string
}
interface ProductLite { id: number; name: string; price: number }

const ORDER_STATUSES = ['pending', 'confirmed', 'processing', 'shipped', 'completed', 'cancelled']
const STATUS_LABELS: Record<string, string> = {
  pending: 'Baru', confirmed: 'Dikonfirmasi', processing: 'Diproses',
  shipped: 'Dikirim', completed: 'Selesai', cancelled: 'Dibatalkan',
}

const orders = ref<Order[]>([])
const products = ref<ProductLite[]>([])
const loading = ref(false)
const search = ref('')
const statusFilter = ref('')
const toast = ref('')
const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const editingNotes = ref<number | null>(null)
const notesDraft = ref('')

const showForm = ref(false)
const saving = ref(false)
const form = ref({ customer_name: '', customer_phone: '', customer_address: '', notes: '', items: [] as OrderItem[] })
const builderProductId = ref<number | null>(null)
const builderQty = ref(1)

const filtered = computed(() => {
  let list = orders.value
  if (statusFilter.value) list = list.filter((o) => o.status === statusFilter.value)
  const q = search.value.trim().toLowerCase()
  if (q) list = list.filter((o) => o.customer_name.toLowerCase().includes(q) || o.customer_phone.includes(q))
  return list
})

const { page, total, totalPages, paged } = usePagination(filtered, 8)

const countBy = (s: string) => orders.value.filter((o) => o.status === s).length
const revenue = computed(() =>
  orders.value.filter((o) => o.status !== 'cancelled').reduce((sum, o) => sum + o.total_price, 0)
)
const formTotal = computed(() => form.value.items.reduce((sum, i) => sum + i.price * i.qty, 0))

const fetchOrders = async () => {
  loading.value = true
  const { data, error } = await supabase.from('orders').select('*').order('created_at', { ascending: false })
  if (error) showToast('Gagal memuat: ' + error.message)
  else orders.value = (data || []) as Order[]
  loading.value = false
}

const setStatus = async (id: number, status: string) => {
  const { error } = await supabase.from('orders').update({ status }).eq('id', id)
  if (error) return showToast('Gagal: ' + error.message)
  const o = orders.value.find((x) => x.id === id)
  if (o) o.status = status
  showToast('Status diperbarui ✓')
}

const remove = async (o: Order) => {
  if (!confirm(`Hapus order #${o.id} milik ${o.customer_name}?`)) return
  const { data, error } = await supabase.from('orders').delete().eq('id', o.id).select()
  if (error) return showToast('Gagal: ' + error.message)
  if (!data || data.length === 0) {
    return showToast('Gagal: database menolak (RLS). Jalankan ulang policy orders di schema.sql')
  }
  orders.value = orders.value.filter((x) => x.id !== o.id)
  showToast('Order dihapus ✓')
}

const startNotes = (o: Order) => {
  editingNotes.value = o.id
  notesDraft.value = o.notes || ''
}
const saveNotes = async (id: number) => {
  const { error } = await supabase.from('orders').update({ notes: notesDraft.value }).eq('id', id)
  if (error) return showToast('Gagal: ' + error.message)
  const o = orders.value.find((x) => x.id === id)
  if (o) o.notes = notesDraft.value
  editingNotes.value = null
  showToast('Catatan tersimpan ✓')
}

const openCreate = () => {
  form.value = { customer_name: '', customer_phone: '', customer_address: '', notes: '', items: [] }
  builderProductId.value = null
  builderQty.value = 1
  showForm.value = true
}

const addItem = () => {
  const p = products.value.find((x) => x.id === builderProductId.value)
  if (!p || builderQty.value < 1) return
  const existing = form.value.items.find((i) => i.id === p.id)
  if (existing) existing.qty += builderQty.value
  else form.value.items.push({ id: p.id, name: p.name, price: p.price, qty: builderQty.value })
  builderProductId.value = null
  builderQty.value = 1
}

const saveOrder = async () => {
  saving.value = true
  const { error } = await supabase.from('orders').insert({
    customer_name: form.value.customer_name,
    customer_phone: form.value.customer_phone,
    customer_address: form.value.customer_address || null,
    notes: form.value.notes || null,
    items: form.value.items,
    total_price: formTotal.value,
  })
  saving.value = false
  if (error) return showToast('Gagal: ' + error.message)
  showForm.value = false
  showToast('Order tersimpan ✓')
  fetchOrders()
}

const normalizePhone = (phone: string) => phone.replace(/\D/g, '').replace(/^0/, '62')
const formatDate = (iso: string) =>
  new Date(iso).toLocaleString('id-ID', { dateStyle: 'medium', timeStyle: 'short' })

onMounted(async () => {
  fetchOrders()
  const { data } = await supabase.from('products').select('id, name, price').eq('is_active', true).order('id')
  products.value = (data || []) as ProductLite[]
})
</script>

<style scoped>
.order__head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  flex-wrap: wrap;
}
.order__wa {
  display: inline-block;
  color: var(--color-primary-dark);
  font-size: 0.9rem;
  font-weight: 600;
  margin-top: 0.25rem;
}
.order__actions {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}
.order__status {
  width: auto;
  font-weight: 700;
  font-size: 0.85rem;
  padding: 0.45rem 0.6rem;
}
.order__items {
  list-style: none;
  padding: 0;
  margin: 0.85rem 0;
  border-top: 1px dashed var(--color-border);
}
.order__items li {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.4rem 0;
  font-size: 0.9rem;
  border-bottom: 1px dashed var(--color-border);
}
.order__total {
  text-align: right;
  font-size: 1.05rem;
  margin-top: 0.5rem;
}
.order__notes-label {
  cursor: pointer;
  margin-top: 0.25rem;
}
.order__notes-label:hover {
  color: var(--color-text);
}
.order__item-builder {
  display: flex;
  gap: 0.5rem;
}
.order__qty {
  width: 70px;
  flex-shrink: 0;
}
</style>
