<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Pengeluaran</h2>
      <button class="admin-btn admin-btn--primary" @click="openForm()">+ Pengeluaran</button>
    </div>

    <p class="admin-muted" style="margin-bottom:1rem">
      Biaya operasional di luar bahan baku (packaging, gaji, marketing, dll). Dipakai untuk menghitung laba bersih di Dashboard.
    </p>

    <div class="admin-stats">
      <div class="admin-stat">
        <div class="admin-stat__value">{{ formatPrice(totalThisMonth) }}</div>
        <div class="admin-stat__label">Total Bulan Ini</div>
      </div>
      <div class="admin-stat">
        <div class="admin-stat__value">{{ formatPrice(totalAll) }}</div>
        <div class="admin-stat__label">Total Keseluruhan</div>
      </div>
    </div>

    <p v-if="loading" class="admin-muted">Memuat...</p>
    <div v-else-if="expenses.length === 0" class="admin-card admin-empty">Belum ada pengeluaran.</div>
    <div v-else class="admin-card" style="overflow-x:auto">
      <table class="admin-table">
        <thead>
          <tr><th>Tanggal</th><th>Nama</th><th>Kategori</th><th>Jumlah</th><th></th></tr>
        </thead>
        <tbody>
          <tr v-for="e in paged" :key="e.id">
            <td>{{ formatDate(e.expense_date) }}</td>
            <td><strong>{{ e.name }}</strong><div v-if="e.notes" class="admin-muted">{{ e.notes }}</div></td>
            <td><span class="admin-badge admin-badge--processing">{{ e.category }}</span></td>
            <td>{{ formatPrice(e.amount) }}</td>
            <td style="white-space:nowrap">
              <button class="admin-btn admin-btn--sm" @click="openForm(e)">Edit</button>
              <button class="admin-btn admin-btn--danger admin-btn--sm" @click="remove(e)">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
      <AdminPagination v-model:page="page" :total-pages="totalPages" :total="total" />
    </div>

    <teleport to="body">
      <div v-if="showForm" class="admin-modal-overlay" @click.self="showForm = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">{{ form.id ? 'Edit Pengeluaran' : 'Pengeluaran Baru' }}</h3>
          <form class="admin-form" @submit.prevent="save">
            <div>
              <label>Nama *</label>
              <input v-model="form.name" class="admin-input" required placeholder="Beli box packaging" />
            </div>
            <div class="admin-form__row">
              <div>
                <label>Kategori *</label>
                <select v-model="form.category" class="admin-input">
                  <option value="operasional">Operasional</option>
                  <option value="packaging">Packaging</option>
                  <option value="gaji">Gaji</option>
                  <option value="marketing">Marketing</option>
                  <option value="transport">Transport</option>
                  <option value="lainnya">Lainnya</option>
                </select>
              </div>
              <div>
                <label>Jumlah (Rp) *</label>
                <input v-model.number="form.amount" type="number" min="0" class="admin-input" required />
              </div>
            </div>
            <div>
              <label>Tanggal *</label>
              <input v-model="form.expense_date" type="date" class="admin-input" required />
            </div>
            <div>
              <label>Catatan</label>
              <textarea v-model="form.notes" class="admin-input" rows="2"></textarea>
            </div>
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

interface Expense { id: number; name: string; category: string; amount: number; expense_date: string; notes: string | null }

const expenses = ref<Expense[]>([])
const loading = ref(false)
const saving = ref(false)
const showForm = ref(false)
const toast = ref('')
const today = () => new Date().toISOString().slice(0, 10)
const emptyForm = () => ({
  id: null as number | null,
  name: '', category: 'operasional', amount: 0, expense_date: today(), notes: '',
})
const form = ref(emptyForm())

const { page, total, totalPages, paged } = usePagination(expenses, 10)
const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const totalAll = computed(() => expenses.value.reduce((s, e) => s + e.amount, 0))
const totalThisMonth = computed(() => {
  const m = today().slice(0, 7)
  return expenses.value.filter((e) => e.expense_date.slice(0, 7) === m).reduce((s, e) => s + e.amount, 0)
})

const fetchExpenses = async () => {
  loading.value = true
  const { data, error } = await supabase.from('expenses').select('*').order('expense_date', { ascending: false })
  if (error) showToast('Gagal memuat: ' + error.message)
  else expenses.value = (data || []) as Expense[]
  loading.value = false
}

const openForm = (e?: Expense) => {
  form.value = e ? { ...e, notes: e.notes || '' } : emptyForm()
  showForm.value = true
}

const save = async () => {
  saving.value = true
  const { id, ...payload } = form.value
  const body = { ...payload, notes: payload.notes || null }
  const { error } = id
    ? await supabase.from('expenses').update(body).eq('id', id)
    : await supabase.from('expenses').insert(body)
  saving.value = false
  if (error) return showToast('Gagal: ' + error.message)
  showForm.value = false
  showToast('Pengeluaran tersimpan ✓')
  fetchExpenses()
}

const remove = async (e: Expense) => {
  if (!confirm(`Hapus pengeluaran "${e.name}"?`)) return
  const { data, error } = await supabase.from('expenses').delete().eq('id', e.id).select()
  if (error) return showToast('Gagal: ' + error.message)
  if (!data || data.length === 0) return showToast('Gagal: database menolak (RLS)')
  expenses.value = expenses.value.filter((x) => x.id !== e.id)
  showToast('Pengeluaran dihapus ✓')
}

const formatDate = (d: string) => new Date(d).toLocaleDateString('id-ID', { dateStyle: 'medium' })

onMounted(fetchExpenses)
</script>
