<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Testimoni</h2>
      <button class="admin-btn admin-btn--primary" @click="openForm()">+ Testimoni Baru</button>
    </div>

    <p v-if="loading" class="admin-muted">Memuat...</p>
    <div v-else-if="items.length === 0" class="admin-card admin-empty">Belum ada testimoni.</div>
    <div v-else class="admin-card" style="overflow-x:auto">
      <table class="admin-table">
        <thead>
          <tr>
            <th>Pelanggan</th>
            <th>Testimoni</th>
            <th>Urutan</th>
            <th>Tampil</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="t in items" :key="t.id" :class="{ 'admin-row-inactive': !t.is_active }">
            <td>
              <div class="tm__name">
                <img :src="t.avatar" :alt="t.name" class="admin-thumb" />
                <div>
                  <strong>{{ t.name }}</strong>
                  <div class="admin-muted">{{ t.role_id }}</div>
                </div>
              </div>
            </td>
            <td class="tm__text">{{ t.text_id }}</td>
            <td>{{ t.sort_order }}</td>
            <td>
              <input type="checkbox" :checked="t.is_active" @change="quickUpdate(t.id, { is_active: ($event.target as HTMLInputElement).checked })" />
            </td>
            <td style="white-space:nowrap">
              <button class="admin-btn admin-btn--sm" @click="openForm(t)">Edit</button>
              <button class="admin-btn admin-btn--danger admin-btn--sm" @click="remove(t)">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>

    <teleport to="body">
      <div v-if="showForm" class="admin-modal-overlay" @click.self="showForm = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">{{ form.id ? 'Edit Testimoni' : 'Testimoni Baru' }}</h3>
          <form class="admin-form" @submit.prevent="save">
            <div class="admin-form__row">
              <div>
                <label>Nama *</label>
                <input v-model="form.name" class="admin-input" required />
              </div>
              <div>
                <label>URL Avatar *</label>
                <input v-model="form.avatar" class="admin-input" placeholder="/assets/foto.jpg" required />
              </div>
            </div>
            <div class="admin-form__row">
              <div>
                <label>Peran (ID) *</label>
                <input v-model="form.role_id" class="admin-input" placeholder="Pelanggan Setia" required />
              </div>
              <div>
                <label>Peran (EN) *</label>
                <input v-model="form.role_en" class="admin-input" placeholder="Loyal Customer" required />
              </div>
            </div>
            <div>
              <label>Testimoni (ID) *</label>
              <textarea v-model="form.text_id" class="admin-input" rows="3" required></textarea>
            </div>
            <div>
              <label>Testimoni (EN) *</label>
              <textarea v-model="form.text_en" class="admin-input" rows="3" required></textarea>
            </div>
            <div>
              <label>Urutan</label>
              <input v-model.number="form.sort_order" type="number" min="0" class="admin-input" />
            </div>
            <label class="admin-check">
              <input v-model="form.is_active" type="checkbox" />
              Tampilkan di landing page
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

interface Testimonial {
  id: number; name: string; role_id: string; role_en: string
  text_id: string; text_en: string; avatar: string; is_active: boolean; sort_order: number
}

const items = ref<Testimonial[]>([])
const loading = ref(false)
const saving = ref(false)
const showForm = ref(false)
const toast = ref('')
const emptyForm = () => ({
  id: null as number | null,
  name: '', role_id: '', role_en: '', text_id: '', text_en: '',
  avatar: '', is_active: true, sort_order: 0,
})
const form = ref(emptyForm())

const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const fetchItems = async () => {
  loading.value = true
  const { data, error } = await supabase.from('testimonials').select('*').order('sort_order')
  if (error) showToast('Gagal memuat: ' + error.message)
  else items.value = (data || []) as Testimonial[]
  loading.value = false
}

const quickUpdate = async (id: number, patch: Partial<Testimonial>) => {
  const { error } = await supabase.from('testimonials').update(patch).eq('id', id)
  if (error) return showToast('Gagal: ' + error.message)
  Object.assign(items.value.find((x) => x.id === id) || {}, patch)
  showToast('Tersimpan ✓')
}

const openForm = (t?: Testimonial) => {
  form.value = t ? { ...t } : emptyForm()
  showForm.value = true
}

const save = async () => {
  saving.value = true
  const { id, ...body } = form.value
  const { error } = id
    ? await supabase.from('testimonials').update(body).eq('id', id)
    : await supabase.from('testimonials').insert(body)
  saving.value = false
  if (error) return showToast('Gagal: ' + error.message)
  showForm.value = false
  showToast('Testimoni tersimpan ✓')
  fetchItems()
}

const remove = async (t: Testimonial) => {
  if (!confirm(`Hapus testimoni dari "${t.name}"?`)) return
  const { data, error } = await supabase.from('testimonials').delete().eq('id', t.id).select()
  if (error) return showToast('Gagal: ' + error.message)
  if (!data || data.length === 0) return showToast('Gagal: database menolak (RLS)')
  items.value = items.value.filter((x) => x.id !== t.id)
  showToast('Testimoni dihapus ✓')
}

onMounted(fetchItems)
</script>

<style scoped>
.tm__name {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  min-width: 160px;
}
.tm__text {
  max-width: 320px;
}
</style>
