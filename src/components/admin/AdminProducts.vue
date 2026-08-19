<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Open PO & Produk</h2>
      <div style="display:flex; gap:.5rem">
        <button class="admin-btn" @click="fetchProducts">↻ Refresh</button>
        <button class="admin-btn admin-btn--primary" @click="openForm()">+ Produk Baru</button>
      </div>
    </div>

    <div class="admin-stats">
      <div class="admin-stat">
        <div class="admin-stat__value">{{ countStock('preorder') }}</div>
        <div class="admin-stat__label">Open PO</div>
      </div>
      <div class="admin-stat">
        <div class="admin-stat__value">{{ countStock('available') }}</div>
        <div class="admin-stat__label">Tersedia</div>
      </div>
      <div class="admin-stat">
        <div class="admin-stat__value">{{ countStock('soldout') }}</div>
        <div class="admin-stat__label">Habis</div>
      </div>
      <div class="admin-stat">
        <div class="admin-stat__value">{{ products.filter((p) => p.is_active).length }}</div>
        <div class="admin-stat__label">Produk Tampil</div>
      </div>
    </div>

    <p class="admin-muted" style="margin-bottom:1rem">
      Ubah status stok langsung dari dropdown — tersimpan otomatis. Produk "Open PO" tampil dengan label Pre-Order di landing page.
    </p>

    <p v-if="loading" class="admin-muted">Memuat...</p>
    <div v-else class="admin-card" style="overflow-x:auto">
      <table class="admin-table">
        <thead>
          <tr>
            <th>Produk</th>
            <th>Harga</th>
            <th>HPP</th>
            <th>Margin</th>
            <th>Status</th>
            <th>Tampil</th>
            <th></th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="p in paged" :key="p.id" :class="{ 'admin-row-inactive': !p.is_active }">
            <td>
              <div class="po__name">
                <img :src="p.image" :alt="p.name" class="admin-thumb" />
                <div>
                  <strong>{{ p.name }}</strong>
                  <div v-if="p.badge" class="admin-muted">{{ p.badge }}</div>
                </div>
              </div>
            </td>
            <td>{{ formatPrice(p.price) }}</td>
            <td>{{ formatPrice(p.hpp) }}</td>
            <td :style="{ color: p.price - p.hpp >= 0 ? '#047857' : '#b91c1c', fontWeight: 700 }">
              {{ formatPrice(p.price - p.hpp) }}
              <div class="admin-muted" v-if="p.price">{{ Math.round(((p.price - p.hpp) / p.price) * 100) }}%</div>
            </td>
            <td>
              <select class="admin-input po__stock" :value="p.stock" @change="quickUpdate(p.id, { stock: ($event.target as HTMLSelectElement).value })">
                <option value="available">Tersedia</option>
                <option value="preorder">Open PO</option>
                <option value="soldout">Habis</option>
              </select>
            </td>
            <td>
              <input type="checkbox" :checked="p.is_active" @change="quickUpdate(p.id, { is_active: ($event.target as HTMLInputElement).checked })" />
            </td>
            <td style="white-space:nowrap">
              <button class="admin-btn admin-btn--sm" @click="openRecipe(p)">Resep</button>
              <button class="admin-btn admin-btn--sm" @click="openForm(p)">Edit</button>
              <button class="admin-btn admin-btn--danger admin-btn--sm" @click="remove(p)">Hapus</button>
            </td>
          </tr>
        </tbody>
      </table>
      <AdminPagination v-model:page="page" :total-pages="totalPages" :total="total" />
    </div>

    <!-- Modal: create/edit produk -->
    <teleport to="body">
      <div v-if="showForm" class="admin-modal-overlay" @click.self="showForm = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">{{ form.id ? 'Edit Produk' : 'Produk Baru' }}</h3>
          <form class="admin-form" @submit.prevent="save">
            <div>
              <label>Nama Produk *</label>
              <input v-model="form.name" class="admin-input" required />
            </div>
            <div class="admin-form__row">
              <div>
                <label>Kategori *</label>
                <select v-model="form.category" class="admin-input" required>
                  <option value="best-seller">Best Seller</option>
                  <option value="new">New Variant</option>
                </select>
              </div>
              <div>
                <label>Harga (Rp) *</label>
                <input v-model.number="form.price" type="number" min="0" class="admin-input" required />
              </div>
            </div>
            <div>
              <label>Deskripsi *</label>
              <textarea v-model="form.description" class="admin-input" rows="3" required></textarea>
            </div>
            <div>
              <label>URL Gambar *</label>
              <input v-model="form.image" class="admin-input" placeholder="/assets/nama-file.jpg" required />
              <img v-if="form.image" :src="form.image" class="admin-thumb" style="margin-top:.4rem" />
            </div>
            <div class="admin-form__row">
              <div>
                <label>Badge (opsional)</label>
                <input v-model="form.badge" class="admin-input" placeholder="Best Seller" />
              </div>
              <div>
                <label>Status Stok *</label>
                <select v-model="form.stock" class="admin-input">
                  <option value="available">Tersedia</option>
                  <option value="preorder">Open PO</option>
                  <option value="soldout">Habis</option>
                </select>
              </div>
            </div>
            <label class="admin-check">
              <input v-model="form.is_active" type="checkbox" />
              Tampilkan di landing page
            </label>
            <div class="admin-form__actions">
              <button type="button" class="admin-btn" @click="showForm = false">Batal</button>
              <button class="admin-btn admin-btn--primary" :disabled="saving">
                {{ saving ? 'Menyimpan...' : 'Simpan' }}
              </button>
            </div>
          </form>
        </div>
      </div>
    </teleport>

    <!-- Modal: resep / HPP -->
    <teleport to="body">
      <div v-if="showRecipe" class="admin-modal-overlay" @click.self="showRecipe = false">
        <div class="admin-modal">
          <h3 class="admin-modal__title">Resep & HPP — {{ recipeProduct?.name }}</h3>
          <p v-if="materials.length === 0" class="admin-muted" style="margin-bottom:.75rem">
            Belum ada bahan baku. Tambahkan dulu di menu "Bahan Baku".
          </p>
          <div class="admin-form">
            <div v-for="(r, i) in recipeRows" :key="i" class="recipe__row">
              <select v-model.number="r.material_id" class="admin-input">
                <option :value="null" disabled>Pilih bahan...</option>
                <option v-for="m in materials" :key="m.id" :value="m.id">
                  {{ m.name }} ({{ formatPrice(m.price_per_unit) }}/{{ m.unit }})
                </option>
              </select>
              <input v-model.number="r.quantity" type="number" min="0" step="any" class="admin-input recipe__qty" placeholder="Qty" />
              <span class="recipe__sub">{{ formatPrice((matById(r.material_id)?.price_per_unit || 0) * (r.quantity || 0)) }}</span>
              <button type="button" class="admin-btn admin-btn--danger admin-btn--sm" @click="recipeRows.splice(i, 1)">×</button>
            </div>
            <button type="button" class="admin-btn admin-btn--sm" @click="addRecipeRow">+ Tambah bahan</button>

            <div class="recipe__total">
              <span>HPP per produk:</span>
              <strong>{{ formatPrice(Math.round(recipeHpp)) }}</strong>
            </div>
            <div class="admin-form__actions">
              <button type="button" class="admin-btn" @click="showRecipe = false">Batal</button>
              <button class="admin-btn admin-btn--primary" :disabled="savingRecipe" @click="saveRecipe">
                {{ savingRecipe ? 'Menyimpan...' : 'Simpan Resep' }}
              </button>
            </div>
          </div>
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

interface Product {
  id: number; name: string; category: string; price: number; description: string
  image: string; badge: string | null; stock: string; is_active: boolean; hpp: number
}
interface Material { id: number; name: string; unit: string; price_per_unit: number }
interface RecipeRow { material_id: number | null; quantity: number }

const products = ref<Product[]>([])
const loading = ref(false)
const saving = ref(false)
const showForm = ref(false)
const toast = ref('')
const emptyForm = () => ({
  id: null as number | null,
  name: '', category: 'new', price: 0, description: '',
  image: '', badge: '', stock: 'preorder', is_active: true, hpp: 0,
})
const form = ref(emptyForm())

const { page, total, totalPages, paged } = usePagination(products, 8)

const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }
const countStock = (s: string) => products.value.filter((p) => p.stock === s && p.is_active).length

const fetchProducts = async () => {
  loading.value = true
  const { data, error } = await supabase.from('products').select('*').order('id')
  if (error) showToast('Gagal memuat: ' + error.message)
  else products.value = (data || []) as Product[]
  loading.value = false
}

const quickUpdate = async (id: number, patch: Partial<Product>) => {
  const { error } = await supabase.from('products').update(patch).eq('id', id)
  if (error) return showToast('Gagal: ' + error.message)
  Object.assign(products.value.find((x) => x.id === id) || {}, patch)
  showToast('Tersimpan ✓')
}

const openForm = (p?: Product) => {
  form.value = p ? { ...p, badge: p.badge || '' } : emptyForm()
  showForm.value = true
}

const save = async () => {
  saving.value = true
  const { id, hpp, ...payload } = form.value
  const body = { ...payload, badge: payload.badge || null }
  const { error } = id
    ? await supabase.from('products').update(body).eq('id', id)
    : await supabase.from('products').insert(body)
  saving.value = false
  if (error) return showToast('Gagal: ' + error.message)
  showForm.value = false
  showToast('Produk tersimpan ✓')
  fetchProducts()
}

const remove = async (p: Product) => {
  if (!confirm(`Hapus produk "${p.name}"? Tindakan ini tidak bisa dibatalkan.`)) return
  const { data, error } = await supabase.from('products').delete().eq('id', p.id).select()
  if (error) return showToast('Gagal: ' + error.message)
  if (!data || data.length === 0) return showToast('Gagal: database menolak (RLS)')
  products.value = products.value.filter((x) => x.id !== p.id)
  showToast('Produk dihapus ✓')
}

// ---------- Resep / HPP ----------
const showRecipe = ref(false)
const recipeProduct = ref<Product | null>(null)
const materials = ref<Material[]>([])
const recipeRows = ref<RecipeRow[]>([])
const savingRecipe = ref(false)

const matById = (id: number | null) => materials.value.find((m) => m.id === id)
const recipeHpp = computed(() =>
  recipeRows.value.reduce((sum, r) => {
    const m = matById(r.material_id)
    return sum + (m ? m.price_per_unit * (r.quantity || 0) : 0)
  }, 0)
)

const openRecipe = async (p: Product) => {
  recipeProduct.value = p
  showRecipe.value = true
  recipeRows.value = []
  if (materials.value.length === 0) {
    const { data } = await supabase.from('materials').select('*').eq('is_active', true).order('name')
    materials.value = (data || []) as Material[]
  }
  const { data } = await supabase.from('product_materials').select('material_id, quantity').eq('product_id', p.id)
  recipeRows.value = (data || []).map((r: any) => ({ material_id: r.material_id, quantity: Number(r.quantity) }))
  if (recipeRows.value.length === 0) recipeRows.value.push({ material_id: null, quantity: 0 })
}

const addRecipeRow = () => recipeRows.value.push({ material_id: null, quantity: 0 })

const saveRecipe = async () => {
  const p = recipeProduct.value
  if (!p) return
  savingRecipe.value = true
  const rows = recipeRows.value.filter((r) => r.material_id && r.quantity > 0)
  const hpp = Math.round(recipeHpp.value)

  await supabase.from('product_materials').delete().eq('product_id', p.id)
  if (rows.length) {
    const { error } = await supabase.from('product_materials').insert(
      rows.map((r) => ({ product_id: p.id, material_id: r.material_id, quantity: r.quantity }))
    )
    if (error) { savingRecipe.value = false; return showToast('Gagal: ' + error.message) }
  }
  await supabase.from('products').update({ hpp }).eq('id', p.id)
  const local = products.value.find((x) => x.id === p.id)
  if (local) local.hpp = hpp
  savingRecipe.value = false
  showRecipe.value = false
  showToast('Resep & HPP tersimpan ✓')
}

onMounted(fetchProducts)
</script>

<style scoped>
.po__name {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  min-width: 200px;
}
.po__stock {
  width: auto;
  font-weight: 700;
  font-size: 0.85rem;
  padding: 0.45rem 0.6rem;
}
.recipe__row {
  display: flex;
  gap: 0.5rem;
  align-items: center;
}
.recipe__qty {
  width: 90px;
  flex-shrink: 0;
}
.recipe__sub {
  font-size: 0.8rem;
  color: var(--color-text-light);
  min-width: 80px;
  text-align: right;
}
.recipe__total {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 0.75rem;
  background: var(--color-secondary);
  border-radius: 8px;
  font-size: 1.05rem;
}
.recipe__total strong {
  color: var(--color-primary-dark);
  font-size: 1.25rem;
}
</style>
