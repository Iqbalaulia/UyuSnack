<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Bahan Baku</h2>
      <button class="admin-btn admin-btn--primary" @click="openForm()">+ Bahan Baru</button>
    </div>

    <p class="admin-muted" style="margin-bottom:1rem">
      Kelola daftar bahan & harga per unit. Harga ini dipakai untuk menghitung HPP produk lewat menu "Resep" di halaman Produk.
    </p>

    <p v-if="loading" class="admin-muted">Memuat...</p>
    <div v-else-if="materials.length === 0" class="admin-card admin-empty">Belum ada bahan baku.</div>
    <div v-else class="admin-card" style="overflow-x:auto">
      <table class="admin-table">
        <thead>
          <tr>
            <th>Nama Bahan</th>
            <th>Unit</th>
            <th>Harga / Unit</th>
            <th>Aktif</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="m in paged" :key="m.id" :class="{ 'admin-row-inactive': !m.is_active }">
            <td><strong>{{ m.name }}</strong></td>
            <td>{{ m.unit }}</td>
            <td>{{ formatPrice(m.price_per_unit) }}</td>
            <td>
              <input type="checkbox" :checked="m.is_active" @change="quickUpdate(m.id, { is_active: ($event.target as HTMLInputElement).checked })" />
            </td>
            <td style="white-space:nowrap">
              <button class="admin-btn admin-btn--sm" @click="openForm(m)">Edit</button>
              <button class="admin-btn admin-btn--danger admin-btn--sm" @click="remove(m)">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
      <AdminPagination v-model:page="page" :total-pages="totalPages" :total="total" />
    </div>

    <teleport to="body">
      <div v-if="showForm" class="admin-modal-overlay" @click.self="showForm = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">{{ form.id ? 'Edit Bahan' : 'Bahan Baru' }}</h3>
          <form class="admin-form" @submit.prevent="save">
            <div>
              <label>Nama Bahan *</label>
              <input v-model="form.name" class="admin-input" required placeholder="Cream cheese" />
            </div>
            <div class="admin-form__row">
              <div>
                <label>Unit *</label>
                <input v-model="form.unit" class="admin-input" required placeholder="gram / ml / pcs" list="unit-list" />
                <datalist id="unit-list">
                  <option value="gram" /><option value="kg" /><option value="ml" /><option value="liter" /><option value="pcs" /><option value="butir" />
                </datalist>
              </div>
              <div>
                <label>Harga per Unit (Rp) *</label>
                <input v-model.number="form.price_per_unit" type="number" min="0" step="any" class="admin-input" required />
              </div>
            </div>
            <label class="admin-check">
              <input v-model="form.is_active" type="checkbox" />
              Aktif (bisa dipakai di resep)
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
import { ref, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'
import { formatPrice } from '../../data/products'
import { usePagination } from '../../composables/usePagination'
import AdminPagination from './AdminPagination.vue'

interface Material { id: number; name: string; unit: string; price_per_unit: number; is_active: boolean }

const materials = ref<Material[]>([])
const loading = ref(false)
const saving = ref(false)
const showForm = ref(false)
const toast = ref('')
const emptyForm = () => ({ id: null as number | null, name: '', unit: 'gram', price_per_unit: 0, is_active: true })
const form = ref(emptyForm())

const { page, total, totalPages, paged } = usePagination(materials, 10)
const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const fetchMaterials = async () => {
  loading.value = true
  const { data, error } = await supabase.from('materials').select('*').order('name')
  if (error) showToast('Gagal memuat: ' + error.message)
  else materials.value = (data || []) as Material[]
  loading.value = false
}

const quickUpdate = async (id: number, patch: Partial<Material>) => {
  const { error } = await supabase.from('materials').update(patch).eq('id', id)
  if (error) return showToast('Gagal: ' + error.message)
  Object.assign(materials.value.find((x) => x.id === id) || {}, patch)
  showToast('Tersimpan ✓')
}

const openForm = (m?: Material) => {
  form.value = m ? { ...m } : emptyForm()
  showForm.value = true
}

const save = async () => {
  saving.value = true
  const { id, ...body } = form.value
  const { error } = id
    ? await supabase.from('materials').update(body).eq('id', id)
    : await supabase.from('materials').insert(body)
  saving.value = false
  if (error) return showToast('Gagal: ' + error.message)
  showForm.value = false
  showToast('Bahan tersimpan ✓')
  fetchMaterials()
}

const remove = async (m: Material) => {
  if (!confirm(`Hapus bahan "${m.name}"? Resep produk yang memakainya akan ikut terhapus.`)) return
  const { data, error } = await supabase.from('materials').delete().eq('id', m.id).select()
  if (error) return showToast('Gagal: ' + error.message)
  if (!data || data.length === 0) return showToast('Gagal: database menolak (RLS)')
  materials.value = materials.value.filter((x) => x.id !== m.id)
  showToast('Bahan dihapus ✓')
}

onMounted(fetchMaterials)
</script>
