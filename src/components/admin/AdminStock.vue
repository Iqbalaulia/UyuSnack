<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Stok Bahan & Kapasitas Produksi</h2>
      <button class="admin-btn" @click="fetchAll">↻ Refresh</button>
    </div>

    <p class="admin-muted" style="margin-bottom:1rem">
      Tracking stok bahan baku sekaligus cek berapa pcs tiap produk yang bisa dibuat dari stok yang ada.
    </p>

    <p v-if="loading" class="admin-muted">Memuat...</p>

    <template v-else>
      <!-- Stok Bahan -->
      <h3 class="stock__section-title">Stok Bahan Baku</h3>
      <div v-if="materials.length === 0" class="admin-card admin-empty">Belum ada bahan baku.</div>
      <div v-else class="admin-card" style="overflow-x:auto; margin-bottom:1.5rem">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Nama Bahan</th>
              <th>Unit</th>
              <th>Harga / Unit</th>
              <th>Stok Tersedia</th>
              <th>Status</th>
              <th></th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="m in materials" :key="m.id" :class="{ 'admin-row-inactive': !m.is_active }">
              <td><strong>{{ m.name }}</strong></td>
              <td>{{ m.unit }}</td>
              <td>{{ formatPrice(m.price_per_unit) }}</td>
              <td>
                <input
                  v-model.number="draftStock[m.id]"
                  type="number"
                  min="0"
                  step="any"
                  class="admin-input stock__qty-input"
                  @change="markDirty(m.id)"
                />
              </td>
              <td>
                <span class="admin-badge" :class="statusClass(m)">{{ statusLabel(m) }}</span>
              </td>
              <td>
                <button
                  v-if="dirtyIds.has(m.id)"
                  class="admin-btn admin-btn--primary admin-btn--sm"
                  :disabled="savingId === m.id"
                  @click="saveStock(m.id)"
                >
                  {{ savingId === m.id ? '...' : 'Simpan' }}
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>

      <!-- Kapasitas Produksi -->
      <h3 class="stock__section-title">Kapasitas Produksi per Produk</h3>
      <div v-if="products.length === 0" class="admin-card admin-empty">Belum ada produk.</div>
      <div v-else class="admin-card" style="overflow-x:auto">
        <table class="admin-table">
          <thead>
            <tr>
              <th>Produk</th>
              <th>HPP</th>
              <th>Harga</th>
              <th>Margin</th>
              <th>Bisa Produksi</th>
              <th>Bahan Pembatas</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="cap in capacityList" :key="cap.product.id" :class="{ 'admin-row-inactive': !cap.product.is_active }">
              <td>
                <div class="stock__product">
                  <img :src="cap.product.image" :alt="cap.product.name" class="admin-thumb" />
                  <strong>{{ cap.product.name }}</strong>
                </div>
              </td>
              <td>{{ formatPrice(cap.product.hpp) }}</td>
              <td>{{ formatPrice(cap.product.price) }}</td>
              <td :style="{ color: cap.product.price - cap.product.hpp >= 0 ? '#047857' : '#b91c1c', fontWeight: 700 }">
                {{ formatPrice(cap.product.price - cap.product.hpp) }}
              </td>
              <td>
                <span class="admin-badge" :class="cap.badgeClass">{{ cap.label }}</span>
              </td>
              <td class="admin-muted">{{ cap.limiters }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </template>

    <div v-if="toast" class="admin-toast">{{ toast }}</div>
  </section>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'
import { formatPrice } from '../../data/products'

interface Material {
  id: number
  name: string
  unit: string
  price_per_unit: number
  stock_qty: number
  is_active: boolean
}
interface Product {
  id: number
  name: string
  price: number
  hpp: number
  image: string
  is_active: boolean
}
interface ProductMaterial {
  product_id: number
  material_id: number
  quantity: number
  yield: number
}

const materials = ref<Material[]>([])
const products = ref<Product[]>([])
const recipeRows = ref<ProductMaterial[]>([])
const loading = ref(false)
const savingId = ref<number | null>(null)
const toast = ref('')
const dirtyIds = ref<Set<number>>(new Set())
const draftStock = ref<Record<number, number>>({})

const showToast = (msg: string) => { toast.value = msg; setTimeout(() => (toast.value = ''), 2500) }

const matById = (id: number) => materials.value.find((m) => m.id === id)

// Status stok bahan: habis / rendah / tersedia
// "Rendah" = stok masih ada tapi kurang dari kebutuhan minimum 1x produksi (quantity/yield terkecil).
const materialStatus = (m: Material) => {
  if (m.stock_qty <= 0) return 'empty'
  const needs = recipeRows.value
    .filter((r) => r.material_id === m.id && r.quantity > 0)
    .map((r) => r.quantity / (r.yield && r.yield > 0 ? r.yield : 1))
  if (needs.length === 0) return 'ok'
  const minNeed = Math.min(...needs)
  return m.stock_qty < minNeed ? 'low' : 'ok'
}

const statusLabel = (m: Material) => {
  const s = materialStatus(m)
  return s === 'empty' ? 'Habis' : s === 'low' ? 'Rendah' : 'Tersedia'
}
const statusClass = (m: Material) => {
  const s = materialStatus(m)
  return s === 'empty' ? 'admin-badge--soldout' : s === 'low' ? 'admin-badge--preorder' : 'admin-badge--available'
}

const markDirty = (id: number) => dirtyIds.value.add(id)

const fetchAll = async () => {
  loading.value = true
  const [{ data: mats }, { data: prods }, { data: rows }] = await Promise.all([
    supabase.from('materials').select('*').order('name'),
    supabase.from('products').select('id, name, price, hpp, image, is_active').order('id'),
    supabase.from('product_materials').select('product_id, material_id, quantity, yield'),
  ])
  materials.value = (mats || []) as Material[]
  products.value = (prods || []) as Product[]
  recipeRows.value = (rows || []) as ProductMaterial[]

  // Sinkronkan draft stok dengan data terbaru, hanya untuk yang belum kotor.
  const nextDraft: Record<number, number> = {}
  materials.value.forEach((m) => {
    nextDraft[m.id] = dirtyIds.value.has(m.id) ? draftStock.value[m.id] : m.stock_qty
  })
  draftStock.value = nextDraft
  loading.value = false
}

const saveStock = async (id: number) => {
  const value = draftStock.value[id]
  if (value === undefined || value < 0) return
  savingId.value = id
  const { error } = await supabase.from('materials').update({ stock_qty: value }).eq('id', id)
  savingId.value = null
  if (error) return showToast('Gagal: ' + error.message)
  const local = materials.value.find((m) => m.id === id)
  if (local) local.stock_qty = value
  dirtyIds.value.delete(id)
  showToast('Stok tersimpan ✓')
}

// Kapasitas produksi per produk.
const capacityList = computed(() => {
  return products.value.map((p) => {
    const rows = recipeRows.value.filter((r) => r.product_id === p.id && r.quantity > 0)
    if (rows.length === 0) {
      return {
        product: p,
        max: 0,
        label: 'Belum ada resep',
        badgeClass: 'admin-badge--preorder',
        limiters: '-',
      }
    }

    const breakdown = rows
      .map((r) => {
        const m = matById(r.material_id)
        if (!m) return { max: 0, name: '?' }
        const yieldVal = r.yield && r.yield > 0 ? r.yield : 1
        return { max: (m.stock_qty * yieldVal) / r.quantity, name: m.name }
      })
      .sort((a, b) => a.max - b.max)

    const max = Math.floor(breakdown[0].max)
    const limiters = breakdown
      .filter((b) => Math.floor(b.max) === max)
      .map((b) => b.name)
      .join(', ')

    return {
      product: p,
      max,
      label: max > 0 ? `${max} pcs` : 'Tidak cukup stok',
      badgeClass: max > 0 ? 'admin-badge--available' : 'admin-badge--soldout',
      limiters: max > 0 ? limiters : breakdown.map((b) => b.name).join(', '),
    }
  })
})

onMounted(fetchAll)
</script>

<style scoped>
.stock__section-title {
  font-size: 1.05rem;
  font-weight: 800;
  margin-bottom: 0.75rem;
  color: var(--color-text);
}
.stock__qty-input {
  max-width: 120px;
  padding: 0.45rem 0.6rem;
}
.stock__product {
  display: flex;
  align-items: center;
  gap: 0.6rem;
  min-width: 200px;
}
</style>
