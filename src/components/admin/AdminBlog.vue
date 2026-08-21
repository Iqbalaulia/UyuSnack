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
            <th>Slug</th>
            <th>Tgl Publikasi</th>
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
            <td class="admin-muted">/{{ b.slug }}</td>
            <td>{{ formatDate(b.published_at) }}</td>
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
            <div>
              <label>Slug / URL *</label>
              <div style="display:flex; gap:.5rem">
                <input v-model="form.slug" class="admin-input" required placeholder="cara-menyimpan-burnt-cheesecake" />
                <button type="button" class="admin-btn admin-btn--sm" @click="generateSlug">Generate</button>
              </div>
              <p class="admin-muted">URL bersih untuk artikel: /#/blog/&lt;slug&gt;</p>
            </div>
            <div>
              <label>Konten Lengkap (ID) *</label>
              <RichEditor v-model="form.content_id" placeholder="Tulis konten artikel bahasa Indonesia..." />
            </div>
            <div>
              <label>Konten Lengkap (EN) *</label>
              <RichEditor v-model="form.content_en" placeholder="Write article content in English..." />
            </div>
            <div class="admin-form__row">
              <div>
                <label>URL Gambar Thumbnail *</label>
                <div style="display:flex; gap:.5rem">
                  <input v-model="form.image" class="admin-input" placeholder="/assets/nama-file.jpg" required />
                  <input ref="thumbInput" type="file" accept="image/*" style="display:none" @change="onThumbSelected" />
                  <button
                    type="button"
                    class="admin-btn admin-btn--sm"
                    :disabled="uploadingThumb"
                    @click="thumbInput?.click()"
                  >
                    {{ uploadingThumb ? '...' : 'Upload' }}
                  </button>
                </div>
                <p class="admin-muted">Upload otomatis ke Supabase Storage atau isi URL manual.</p>
              </div>
              <div>
                <label>Tanggal Publikasi *</label>
                <input v-model="form.published_at" type="date" class="admin-input" required />
              </div>
            </div>
            <div class="admin-form__row">
              <div>
                <label>Waktu Baca (menit) *</label>
                <input v-model.number="form.read_time_minutes" type="number" min="1" class="admin-input" required />
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
import RichEditor from './RichEditor.vue'

interface BlogPost {
  id: number; slug: string; title_id: string; title_en: string; excerpt_id: string; excerpt_en: string
  content_id: string; content_en: string; image: string; published_at: string; read_time_minutes: number
  is_active: boolean; sort_order: number
}

const posts = ref<BlogPost[]>([])
const loading = ref(false)
const saving = ref(false)
const showForm = ref(false)
const toast = ref('')
const uploadingThumb = ref(false)
const thumbInput = ref<HTMLInputElement | null>(null)
const emptyForm = () => ({
  id: null as number | null,
  slug: '', title_id: '', title_en: '', excerpt_id: '', excerpt_en: '',
  content_id: '', content_en: '', image: '', published_at: new Date().toISOString().slice(0, 10),
  read_time_minutes: 1, is_active: true, sort_order: 0,
})
const form = ref(emptyForm())

const { page, total, totalPages, paged } = usePagination(posts, 10)
const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const formatDate = (d: string) => new Date(d).toLocaleDateString('id-ID', { dateStyle: 'medium' })

const slugify = (text: string) =>
  text
    .toLowerCase()
    .trim()
    .replace(/[^a-z0-9\s-]/g, '')
    .replace(/\s+/g, '-')
    .replace(/-+/g, '-')

const generateSlug = () => {
  if (!form.value.title_id) return showToast('Isi Judul (ID) dulu')
  form.value.slug = slugify(form.value.title_id)
}

const uploadFileToStorage = async (file: File): Promise<string | null> => {
  const ext = file.name.split('.').pop() || 'png'
  const path = `thumbs/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`
  const { error } = await supabase.storage.from('blog-images').upload(path, file)
  if (error) {
    showToast('Gagal upload: ' + error.message)
    return null
  }
  const { data } = supabase.storage.from('blog-images').getPublicUrl(path)
  return data.publicUrl
}

const onThumbSelected = async (e: Event) => {
  const input = e.target as HTMLInputElement
  const file = input.files?.[0]
  if (!file) return
  uploadingThumb.value = true
  const url = await uploadFileToStorage(file)
  uploadingThumb.value = false
  if (url) form.value.image = url
  input.value = ''
}

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
  if (!form.value.slug) return showToast('Slug wajib diisi')
  form.value.slug = slugify(form.value.slug)
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
