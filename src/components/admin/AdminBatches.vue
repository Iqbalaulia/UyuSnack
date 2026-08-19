<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Batch Open PO</h2>
      <button class="admin-btn admin-btn--primary" @click="openForm()">+ Batch Baru</button>
    </div>

    <p class="admin-muted" style="margin-bottom:1rem">
      Tiap batch punya rentang tanggal buka PO. Order yang masuk di dalam rentang tanggal otomatis dihitung sebagai bagian batch tersebut.
    </p>

    <p v-if="loading" class="admin-muted">Memuat...</p>
    <div v-else-if="batches.length === 0" class="admin-card admin-empty">Belum ada batch PO.</div>

    <div v-else style="display:flex; flex-direction:column; gap:1rem">
      <article v-for="b in paged" :key="b.id" class="admin-card">
        <div class="batch__head">
          <div>
            <strong>{{ b.name }}</strong>
            <span class="admin-badge" :class="statusClass(b)">{{ statusLabel(b) }}</span>
            <p class="admin-muted" style="margin-top:.25rem">
              {{ formatDate(b.start_date) }} — {{ formatDate(b.end_date) }}
              <template v-if="b.notes"> · {{ b.notes }}</template>
            </p>
          </div>
          <div style="display:flex; gap:.5rem; align-items:center">
            <button class="admin-btn admin-btn--sm" @click="toggleOrders(b)">
              {{ openBatchId === b.id ? 'Tutup' : 'Lihat Order' }}
            </button>
            <button class="admin-btn admin-btn--sm" @click="openForm(b)">Edit</button>
            <button class="admin-btn admin-btn--danger admin-btn--sm" @click="remove(b)">Hapus</button>
          </div>
        </div>

        <div v-if="openBatchId === b.id" class="batch__orders">
          <p v-if="ordersLoading" class="admin-muted">Memuat order...</p>
          <template v-else>
            <div class="admin-stats" style="margin:.5rem 0">
              <div class="admin-stat"><div class="admin-stat__value">{{ batchOrders.length }}</div><div class="admin-stat__label">Order</div></div>
              <div class="admin-stat"><div class="admin-stat__value">{{ totalQty }}</div><div class="admin-stat__label">Total Item</div></div>
              <div class="admin-stat"><div class="admin-stat__value">{{ formatPrice(batchRevenue) }}</div><div class="admin-stat__label">Nilai PO (non-batal)</div></div>
            </div>

            <div v-if="recap.length" class="batch__recap">
              <strong>Rekap per produk:</strong>
              <ul>
                <li v-for="r in recap" :key="r.name"><span>{{ r.name }}</span><span>{{ r.qty }} pcs · {{ formatPrice(r.total) }}</span></li>
              </ul>
            </div>

            <p v-if="batchOrders.length === 0" class="admin-muted">Belum ada order di rentang tanggal ini.</p>
            <table v-else class="admin-table" style="margin-top:.5rem">
              <thead><tr><th>#</th><th>Customer</th><th>Status</th><th>Total</th></tr></thead>
              <tbody>
                <tr v-for="o in batchOrders" :key="o.id">
                  <td>#{{ o.id }}</td>
                  <td>{{ o.customer_name }}</td>
                  <td><span class="admin-badge" :class="`admin-badge--${o.status}`">{{ o.status }}</span></td>
                  <td>{{ formatPrice(o.total_price) }}</td>
                </tr>
              </tbody>
            </table>
          </template>
        </div>
      </article>
      <AdminPagination v-model:page="page" :total-pages="totalPages" :total="total" />
    </div>

    <teleport to="body">
      <div v-if="showForm" class="admin-modal-overlay" @click.self="showForm = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">{{ form.id ? 'Edit Batch' : 'Batch Baru' }}</h3>
          <form class="admin-form" @submit.prevent="save">
            <div>
              <label>Nama Batch *</label>
              <input v-model="form.name" class="admin-input" required placeholder="PO Batch Januari 2026" />
            </div>
            <div class="admin-form__row">
              <div>
                <label>Tanggal Mulai *</label>
                <input v-model="form.start_date" type="date" class="admin-input" required />
              </div>
              <div>
                <label>Tanggal Selesai *</label>
                <input v-model="form.end_date" type="date" class="admin-input" required />
              </div>
            </div>
            <div>
              <label>Catatan</label>
              <textarea v-model="form.notes" class="admin-input" rows="2"></textarea>
            </div>
            <label class="admin-check">
              <input v-model="form.is_active" type="checkbox" />
              Batch aktif
            </label>
            <div class="admin-form__actions">
              <button type="button" class="admin-btn" @click="showForm = false">Batal</button>
              <button class="admin-btn admin-btn--primary" :disabled="saving">{{ saving ? 'Menyimpan...' : 'Simpan' }}</button>
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

interface Batch { id: number; name: string; start_date: string; end_date: string; is_active: boolean; notes: string | null }
interface OrderItem { id: number; name: string; price: number; qty: number }
interface Order { id: number; customer_name: string; status: string; total_price: number; items: OrderItem[] }

const batches = ref<Batch[]>([])
const loading = ref(false)
const saving = ref(false)
const showForm = ref(false)
const toast = ref('')
const emptyForm = () => ({
  id: null as number | null,
  name: '', start_date: '', end_date: '', is_active: true, notes: '',
})
const form = ref(emptyForm())

const openBatchId = ref<number | null>(null)
const batchOrders = ref<Order[]>([])
const ordersLoading = ref(false)

const { page, total, totalPages, paged } = usePagination(batches, 8)
const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const nonCancelled = computed(() => batchOrders.value.filter((o) => o.status !== 'cancelled'))
const batchRevenue = computed(() => nonCancelled.value.reduce((s, o) => s + o.total_price, 0))
const totalQty = computed(() =>
  nonCancelled.value.reduce((s, o) => s + o.items.reduce((a, i) => a + i.qty, 0), 0)
)
const recap = computed(() => {
  const map = new Map<string, { name: string; qty: number; total: number }>()
  nonCancelled.value.forEach((o) =>
    o.items.forEach((it) => {
      const r = map.get(it.name) || { name: it.name, qty: 0, total: 0 }
      r.qty += it.qty
      r.total += it.price * it.qty
      map.set(it.name, r)
    })
  )
  return [...map.values()].sort((a, b) => b.qty - a.qty)
})

const today = () => new Date().toISOString().slice(0, 10)
const statusLabel = (b: Batch) => {
  const t = today()
  if (!b.is_active) return 'Nonaktif'
  if (t < b.start_date) return 'Akan Datang'
  if (t > b.end_date) return 'Selesai'
  return 'Sedang Buka'
}
const statusClass = (b: Batch) => {
  const l = statusLabel(b)
  return l === 'Sedang Buka' ? 'admin-badge--available'
    : l === 'Akan Datang' ? 'admin-badge--preorder'
    : 'admin-badge--cancelled'
}

const fetchBatches = async () => {
  loading.value = true
  const { data, error } = await supabase.from('po_batches').select('*').order('start_date', { ascending: false })
  if (error) showToast('Gagal memuat: ' + error.message)
  else batches.value = (data || []) as Batch[]
  loading.value = false
}

const toggleOrders = async (b: Batch) => {
  if (openBatchId.value === b.id) { openBatchId.value = null; return }
  openBatchId.value = b.id
  ordersLoading.value = true
  // Order dianggap milik batch bila created_at ada di rentang tanggal batch (inklusif).
  const { data, error } = await supabase
    .from('orders')
    .select('id, customer_name, status, total_price, items, created_at')
    .gte('created_at', b.start_date)
    .lte('created_at', b.end_date + 'T23:59:59')
    .order('created_at', { ascending: false })
  if (error) showToast('Gagal memuat order: ' + error.message)
  else batchOrders.value = (data || []) as Order[]
  ordersLoading.value = false
}

const openForm = (b?: Batch) => {
  form.value = b ? { ...b, notes: b.notes || '' } : { ...emptyForm(), start_date: today(), end_date: today() }
  showForm.value = true
}

const save = async () => {
  if (form.value.end_date < form.value.start_date) return showToast('Tanggal selesai harus setelah tanggal mulai')
  saving.value = true
  const { id, ...payload } = form.value
  const body = { ...payload, notes: payload.notes || null }
  const { error } = id
    ? await supabase.from('po_batches').update(body).eq('id', id)
    : await supabase.from('po_batches').insert(body)
  saving.value = false
  if (error) return showToast('Gagal: ' + error.message)
  showForm.value = false
  showToast('Batch tersimpan ✓')
  fetchBatches()
}

const remove = async (b: Batch) => {
  if (!confirm(`Hapus batch "${b.name}"? (Order tidak ikut terhapus)`)) return
  const { data, error } = await supabase.from('po_batches').delete().eq('id', b.id).select()
  if (error) return showToast('Gagal: ' + error.message)
  if (!data || data.length === 0) return showToast('Gagal: database menolak (RLS)')
  batches.value = batches.value.filter((x) => x.id !== b.id)
  showToast('Batch dihapus ✓')
}

const formatDate = (d: string) => new Date(d).toLocaleDateString('id-ID', { dateStyle: 'medium' })

onMounted(fetchBatches)
</script>

<style scoped>
.batch__head {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  gap: 1rem;
  flex-wrap: wrap;
}
.batch__orders {
  margin-top: 1rem;
  border-top: 1px dashed var(--color-border);
  padding-top: 0.75rem;
}
.batch__recap {
  background: var(--color-bg);
  border-radius: 8px;
  padding: 0.75rem 1rem;
  font-size: 0.9rem;
}
.batch__recap ul {
  list-style: none;
  padding: 0;
  margin: 0.5rem 0 0;
}
.batch__recap li {
  display: flex;
  justify-content: space-between;
  gap: 1rem;
  padding: 0.3rem 0;
  border-bottom: 1px dashed var(--color-border);
}
</style>
