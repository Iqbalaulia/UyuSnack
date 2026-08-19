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

      <!-- Grafik tren 12 bulan (independen dari filter) -->
      <div class="admin-card dash__chart-card">
        <h3>Tren Omzet & Laba Bersih (12 bulan terakhir)</h3>
        <div class="dash__chart">
          <Bar :data="trendData" :options="CHART_OPTS_MONEY" />
        </div>
      </div>

      <div class="dash__chart-grid">
        <div class="admin-card dash__chart-card">
          <h3>Pengeluaran per Kategori</h3>
          <div v-if="expensesByCategory.length" class="dash__chart">
            <Bar :data="expenseChartData" :options="CHART_OPTS_H" />
          </div>
          <p v-else class="admin-muted">Belum ada pengeluaran pada periode ini.</p>
        </div>

        <div class="admin-card dash__chart-card">
          <h3>Kontribusi Omzet per Produk</h3>
          <div v-if="byProduct.length" class="dash__chart">
            <Doughnut :data="productChartData" :options="CHART_OPTS" />
          </div>
          <p v-else class="admin-muted">Belum ada penjualan pada periode ini.</p>
        </div>
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
import { Bar, Doughnut } from 'vue-chartjs'
import {
  Chart, BarElement, ArcElement, CategoryScale, LinearScale, Tooltip, Legend,
} from 'chart.js'

Chart.register(BarElement, ArcElement, CategoryScale, LinearScale, Tooltip, Legend)

interface OrderItem { id: number; name: string; price: number; qty: number }
interface Order { id: number; status: string; total_price: number; items: OrderItem[]; created_at: string }
interface ExpenseRow { amount: number; expense_date: string; category: string }

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
const expenseRows = ref<ExpenseRow[]>([])
const totalExpenses = computed(() => expenseRows.value.reduce((s, e) => s + (e.amount || 0), 0))

// Tren 12 bulan terakhir (independen dari filter periode)
const trend = ref<{ label: string; revenue: number; net: number }[]>([])

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

const expensesByCategory = computed(() => {
  const map = new Map<string, number>()
  expenseRows.value.forEach((e) => map.set(e.category, (map.get(e.category) || 0) + e.amount))
  return [...map.entries()].map(([category, amount]) => ({ category, amount })).sort((a, b) => b.amount - a.amount)
})

// ---------- Data grafik ----------
const CHART_OPTS = {
  responsive: true,
  maintainAspectRatio: false,
  plugins: { legend: { position: 'bottom' as const } },
}
const CHART_OPTS_MONEY = {
  ...CHART_OPTS,
  scales: { y: { ticks: { callback: (v: any) => 'Rp ' + (Number(v) / 1000).toLocaleString('id-ID') + 'rb' } } },
}
const CHART_OPTS_H = {
  ...CHART_OPTS,
  indexAxis: 'y' as const,
  plugins: { legend: { display: false } },
}

const trendData = computed(() => ({
  labels: trend.value.map((t) => t.label),
  datasets: [
    { label: 'Omzet', data: trend.value.map((t) => t.revenue), backgroundColor: '#6366f1', borderRadius: 4 },
    { label: 'Laba Bersih', data: trend.value.map((t) => t.net), backgroundColor: '#10b981', borderRadius: 4 },
  ],
}))

const expenseChartData = computed(() => ({
  labels: expensesByCategory.value.map((e) => e.category),
  datasets: [{ label: 'Pengeluaran', data: expensesByCategory.value.map((e) => e.amount), backgroundColor: '#f59e0b', borderRadius: 4 }],
}))

const PRODUCT_COLORS = ['#6366f1', '#10b981', '#f59e0b', '#ef4444', '#8b5cf6', '#ec4899', '#14b8a6', '#f97316']
const productChartData = computed(() => ({
  labels: byProduct.value.map((p) => p.name),
  datasets: [{ data: byProduct.value.map((p) => p.revenue), backgroundColor: PRODUCT_COLORS }],
}))

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

  let eq = supabase.from('expenses').select('amount, expense_date, category')
  if (from.value) eq = eq.gte('expense_date', from.value)
  if (to.value) eq = eq.lte('expense_date', to.value)
  const { data: ed } = await eq
  expenseRows.value = (ed || []) as ExpenseRow[]

  await loadTrend()
  loading.value = false
}

// Tren 12 bulan terakhir — dihitung sekali, tak ikut filter periode.
const loadTrend = async () => {
  const now = new Date()
  const start = new Date(now.getFullYear(), now.getMonth() - 11, 1)
  const startIso = iso(start)

  const { data: od } = await supabase
    .from('orders')
    .select('status, total_price, items, created_at')
    .gte('created_at', startIso)
  const { data: ed } = await supabase
    .from('expenses')
    .select('amount, expense_date')
    .gte('expense_date', startIso)

  // Kerangka 12 bulan
  const buckets: Record<string, { label: string; revenue: number; cogs: number; expense: number }> = {}
  const order: string[] = []
  for (let i = 0; i < 12; i++) {
    const d = new Date(now.getFullYear(), now.getMonth() - 11 + i, 1)
    const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`
    order.push(key)
    buckets[key] = { label: d.toLocaleDateString('id-ID', { month: 'short', year: '2-digit' }), revenue: 0, cogs: 0, expense: 0 }
  }

  ;(od || []).forEach((o: any) => {
    if (o.status === 'cancelled') return
    const key = String(o.created_at).slice(0, 7)
    const b = buckets[key]
    if (!b) return
    b.revenue += o.total_price
    ;(o.items || []).forEach((it: any) => (b.cogs += (hppMap.value[it.id] || 0) * it.qty))
  })
  ;(ed || []).forEach((e: any) => {
    const key = String(e.expense_date).slice(0, 7)
    if (buckets[key]) buckets[key].expense += e.amount || 0
  })

  trend.value = order.map((k) => ({
    label: buckets[k].label,
    revenue: buckets[k].revenue,
    net: buckets[k].revenue - buckets[k].cogs - buckets[k].expense,
  }))
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
.dash__chart-card {
  margin-bottom: 1.25rem;
}
.dash__chart-card h3 {
  margin-bottom: 0.75rem;
}
.dash__chart {
  height: 280px;
  position: relative;
}
.dash__chart-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.25rem;
  margin-bottom: 1.25rem;
}
</style>
