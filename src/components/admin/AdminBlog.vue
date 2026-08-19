<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Blog (Tips & Resep)</h2>
      <button class="admin-btn admin-btn--primary" @click="openForm()">+ Artikel Baru</button>
    </div>

    <p v-if="loading" class="admin-muted">Memuat...</p>
    <div v-else-if="posts.length === 0" class="admin-card admin-empty">Belum ada artikel.</div>
    <div v-else class="admin-card" style="overflow-x:auto">
      <table class="admin-table">
        <thead>
          <tr>
            <th>Artikel</th>
            <th>Urutan</th>
            <th>Tampil</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="b in paged" :key="b.id" :class="{ 'admin-row-inactive': !b.is_active }">
            <td>
              <div class="blog__name">
                <img :src="b.image" :alt="b.title_id" class="admin-thumb" />
                <div>
                  <strong>{{ b.title_id }}</strong>
                  <div class="admin-muted">{{ b.title_en }}</div>
                </div>
              </div>
            </td>
            <td>{{ b.sort_order }}</td>
            <td>
              <input type="checkbox" :checked="b.is_active" @change="quickUpdate(b.id, { is_active: ($event.target as HTMLInputElement).checked })" />
            </td>
            <td style="white-space:nowrap">
              <button class="admin-btn admin-btn--sm" @click="openForm(b)">Edit</button>
              <button class="admin-btn admin-btn--danger admin-btn--sm" @click="remove(b)">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
      <AdminPagination v-model:page="page" :total-pages="totalPages" :total="total" />
    </div>

    <teleport to="body">
      <div v-if="showForm" class="admin-modal-overlay" @click.self="showForm = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">{{ form.id ? 'Edit Artikel' : 'Artikel Baru' }}</h3>
          <form class="admin-form" @submit.prevent="save">
            <div>
              <label>Judul (ID) *</label>
              <input v-model="form.title_id" class="admin-input" required />
            </div>
            <div>
              <label>Judul (EN) *</label>
              <input v-model="form.title_en" class="admin-input" required />
            </div>
            <div>
              <label>Ringkasan (ID) *</label>
              <textarea v-model="form.excerpt_id" class="admin-input" rows="2" required></textarea>
            </div>
            <div>
              <label>Ringkasan (EN) *</label>
              <textarea v-model="form.excerpt_en" class="admin-input" rows="2" required></textarea>
            </div>
            <div class="admin-form__row">
              <div>
                <label>URL Gambar *</label>
                <input v-model="form.image" class="admin-input" placeholder="/assets/nama-file.jpg" required />
              </div>
              <div>
                <label>Urutan</label>
                <input v-model.number="form.sort_order" type="number" min="0" class="admin-input" />
              </div>
            </div>
            <img v-if="form.image" :src="form.image" class="admin-thumb" />
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
import { usePagination } from '../../composables/usePagination'
import AdminPagination from './AdminPagination.vue'

interface BlogPost {
  id: number; title_id: string; title_en: string; excerpt_id: string; excerpt_en: string
  image: string; is_active: boolean; sort_order: number
}

const posts = ref<BlogPost[]>([])
const loading = ref(false)
const saving = ref(false)
const showForm = ref(false)
const toast = ref('')
const emptyForm = () => ({
  id: null as number | null,
  title_id: '', title_en: '', excerpt_id: '', excerpt_en: '',
  image: '', is_active: true, sort_order: 0,
})
const form = ref(emptyForm())

const { page, total, totalPages, paged } = usePagination(posts, 10)
const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const fetchPosts = async () => {
  loading.value = true
  const { data, error } = await supabase.from('blog_posts').select('*').order('sort_order')
  if (error) showToast('Gagal memuat: ' + error.message)
  else posts.value = (data || []) as BlogPost[]
  loading.value = false
}

const quickUpdate = async (id: number, patch: Partial<BlogPost>) => {
  const { error } = await supabase.from('blog_posts').update(patch).eq('id', id)
  if (error) return showToast('Gagal: ' + error.message)
  Object.assign(posts.value.find((x) => x.id === id) || {}, patch)
  showToast('Tersimpan ✓')
}

const openForm = (b?: BlogPost) => {
  form.value = b ? { ...b } : emptyForm()
  showForm.value = true
}

const save = async () => {
  saving.value = true
  const { id, ...body } = form.value
  const { error } = id
    ? await supabase.from('blog_posts').update(body).eq('id', id)
    : await supabase.from('blog_posts').insert(body)
  saving.value = false
  if (error) return showToast('Gagal: ' + error.message)
  showForm.value = false
  showToast('Artikel tersimpan ✓')
  fetchPosts()
}

const remove = async (b: BlogPost) => {
  if (!confirm(`Hapus artikel "${b.title_id}"?`)) return
  const { data, error } = await supabase.from('blog_posts').delete().eq('id', b.id).select()
  if (error) return showToast('Gagal: ' + error.message)
  if (!data || data.length === 0) return showToast('Gagal: database menolak (RLS)')
  posts.value = posts.value.filter((x) => x.id !== b.id)
  showToast('Artikel dihapus ✓')
}

onMounted(fetchPosts)
</script>

<style scoped>
.blog__name {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  min-width: 220px;
}
</style>
