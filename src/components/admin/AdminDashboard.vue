<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Dashboard Laba</h2>
      <button class="admin-btn" @click="loadAll">↻ Refresh</button>
    </div>

    <div class="admin-toolbar">
      <button v-for="p in PRESETS" :key="p.id" class="admin-chip" :class="{ 'admin-chip--active': preset === p.id }" @click="applyPreset(p.id)">
        {{ p.label }}
      </button>
      <label class="dash__date">Dari <input v-model="from" type="date" class="admin-input" @change="preset = 'custom'" /></label>
      <label class="dash__date">Sampai <input v-model="to" type="date" class="admin-input" @change="preset = 'custom'" /></label>
    </div>

    <p v-if="loading" class="admin-muted">Menghitung...</p>
    <template v-else>
      <!-- Kartu utama laba -->
      <div class="dash__cards">
        <div class="dash__card dash__card--revenue">
          <div class="dash__label">Pendapatan (Omzet)</div>
          <div class="dash__value">{{ formatPrice(revenue) }}</div>
          <div class="dash__sub">{{ orderCount }} order · {{ itemCount }} item terjual</div>
        </div>
        <div class="dash__card dash__card--gross">
          <div class="dash__label">Laba Kotor</div>
          <div class="dash__value">{{ formatPrice(grossProfit) }}</div>
          <div class="dash__sub">Omzet − HPP ({{ marginPct(grossProfit) }}%)</div>
        </div>
        <div class="dash__card dash__card--net" :class="{ 'is-loss': netProfit < 0 }">
          <div class="dash__label">Laba Bersih</div>
          <div class="dash__value">{{ formatPrice(netProfit) }}</div>
          <div class="dash__sub">Laba Kotor − Pengeluaran ({{ marginPct(netProfit) }}%)</div>
        </div>
      </div>

      <!-- Rincian -->
      <div class="admin-card dash__breakdown">
        <h3>Rincian</h3>
        <ul>
          <li><span>Pendapatan</span><strong>{{ formatPrice(revenue) }}</strong></li>
          <li><span>HPP (biaya bahan baku terjual)</span><strong class="minus">− {{ formatPrice(cogs) }}</strong></li>
          <li class="sum"><span>Laba Kotor</span><strong>{{ formatPrice(grossProfit) }}</strong></li>
          <li><span>Pengeluaran operasional</span><strong class="minus">− {{ formatPrice(totalExpenses) }}</strong></li>
          <li class="sum total"><span>Laba Bersih</span><strong>{{ formatPrice(netProfit) }}</strong></li>
        </ul>
      </div>

      <!-- Laba per produk -->
      <div class="admin-card" style="overflow-x:auto">
        <h3 style="margin-bottom:.75rem">Kontribusi per Produk</h3>
        <table class="admin-table">
          <thead><tr><th>Produk</th><th>Qty</th><th>Omzet</th><th>HPP</th><th>Laba Kotor</th></tr></thead>
          <tbody>
            <tr v-for="r in byProduct" :key="r.name">
              <td>{{ r.name }}</td>
              <td>{{ r.qty }}</td>
              <td>{{ formatPrice(r.revenue) }}</td>
              <td>{{ formatPrice(r.cogs) }}</td>
              <td :style="{ color: r.revenue - r.cogs >= 0 ? '#047857' : '#b91c1c', fontWeight: 700 }">
                {{ formatPrice(r.revenue - r.cogs) }}
              </td>
            </tr>
            <tr v-if="byProduct.length === 0"><td colspan="5" class="admin-muted">Belum ada penjualan pada periode ini.</td></tr>
          </tbody>
        </table>
      </div>

      <p class="admin-muted" style="margin-top:1rem">
        HPP diambil dari resep produk saat ini. Order berstatus "Dibatalkan" tidak dihitung.
      </p>
    </template>
  </section>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'
import { formatPrice } from '../../data/products'

interface OrderItem { id: number; name: string; price: number; qty: number }
interface Order { id: number; status: string; total_price: number; items: OrderItem[]; created_at: string }

const PRESETS = [
  { id: 'month', label: 'Bulan Ini' },
  { id: 'last30', label: '30 Hari' },
  { id: 'year', label: 'Tahun Ini' },
  { id: 'all', label: 'Semua' },
]

const loading = ref(false)
const preset = ref('month')
const from = ref('')
const to = ref('')

const orders = ref<Order[]>([])
const hppMap = ref<Record<number, number>>({})
const totalExpenses = ref(0)

const iso = (d: Date) => d.toISOString().slice(0, 10)
const applyPreset = (id: string) => {
  preset.value = id
  const now = new Date()
  if (id === 'month') { from.value = iso(new Date(now.getFullYear(), now.getMonth(), 1)); to.value = iso(now) }
  else if (id === 'last30') { const d = new Date(now); d.setDate(d.getDate() - 29); from.value = iso(d); to.value = iso(now) }
  else if (id === 'year') { from.value = iso(new Date(now.getFullYear(), 0, 1)); to.value = iso(now) }
  else { from.value = ''; to.value = '' }
  loadAll()
}

const validOrders = computed(() => orders.value.filter((o) => o.status !== 'cancelled'))
const revenue = computed(() => validOrders.value.reduce((s, o) => s + o.total_price, 0))
const orderCount = computed(() => validOrders.value.length)
const itemCount = computed(() => validOrders.value.reduce((s, o) => s + o.items.reduce((a, i) => a + i.qty, 0), 0))
const cogs = computed(() =>
  validOrders.value.reduce((s, o) => s + o.items.reduce((a, i) => a + (hppMap.value[i.id] || 0) * i.qty, 0), 0)
)
const grossProfit = computed(() => revenue.value - cogs.value)
const netProfit = computed(() => grossProfit.value - totalExpenses.value)
const marginPct = (v: number) => (revenue.value ? Math.round((v / revenue.value) * 100) : 0)

const byProduct = computed(() => {
  const map = new Map<string, { name: string; qty: number; revenue: number; cogs: number }>()
  validOrders.value.forEach((o) =>
    o.items.forEach((it) => {
      const r = map.get(it.name) || { name: it.name, qty: 0, revenue: 0, cogs: 0 }
      r.qty += it.qty
      r.revenue += it.price * it.qty
      r.cogs += (hppMap.value[it.id] || 0) * it.qty
      map.set(it.name, r)
    })
  )
  return [...map.values()].sort((a, b) => b.revenue - a.revenue)
})

const loadAll = async () => {
  loading.value = true

  let oq = supabase.from('orders').select('id, status, total_price, items, created_at')
  if (from.value) oq = oq.gte('created_at', from.value)
  if (to.value) oq = oq.lte('created_at', to.value + 'T23:59:59')
  const { data: od } = await oq
  orders.value = (od || []) as Order[]

  const { data: pd } = await supabase.from('products').select('id, hpp')
  const map: Record<number, number> = {}
  ;(pd || []).forEach((p: any) => (map[p.id] = p.hpp || 0))
  hppMap.value = map

  let eq = supabase.from('expenses').select('amount, expense_date')
  if (from.value) eq = eq.gte('expense_date', from.value)
  if (to.value) eq = eq.lte('expense_date', to.value)
  const { data: ed } = await eq
  totalExpenses.value = (ed || []).reduce((s: number, e: any) => s + (e.amount || 0), 0)

  loading.value = false
}

onMounted(() => applyPreset('month'))
</script>

<style scoped>
.dash__date {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-light);
}
.dash__date .admin-input {
  width: auto;
}
.dash__cards {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
  gap: 1rem;
  margin-bottom: 1.25rem;
}
.dash__card {
  border-radius: 14px;
  padding: 1.25rem;
  color: #fff;
}
.dash__card--revenue { background: linear-gradient(135deg, #6366f1, #4f46e5); }
.dash__card--gross { background: linear-gradient(135deg, #f59e0b, #d97706); }
.dash__card--net { background: linear-gradient(135deg, #10b981, #059669); }
.dash__card--net.is-loss { background: linear-gradient(135deg, #ef4444, #b91c1c); }
.dash__label { font-size: 0.85rem; opacity: 0.9; }
.dash__value { font-size: 1.75rem; font-weight: 800; margin: 0.25rem 0; }
.dash__sub { font-size: 0.78rem; opacity: 0.9; }
.dash__breakdown {
  margin-bottom: 1.25rem;
}
.dash__breakdown h3 { margin-bottom: 0.75rem; }
.dash__breakdown ul { list-style: none; padding: 0; margin: 0; }
.dash__breakdown li {
  display: flex;
  justify-content: space-between;
  padding: 0.55rem 0;
  border-bottom: 1px dashed var(--color-border);
  font-size: 0.95rem;
}
.dash__breakdown .minus { color: #b91c1c; }
.dash__breakdown .sum { font-weight: 800; border-bottom: 2px solid var(--color-border); }
.dash__breakdown .total strong { color: var(--color-primary-dark); font-size: 1.15rem; }
</style>
