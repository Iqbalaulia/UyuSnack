<template>
  <section>
    <div class="admin-page-head">
      <h2 class="admin-page-title">Funnel Pengunjung</h2>
      <button class="admin-btn" @click="load">↻ Refresh</button>
    </div>

    <div class="admin-toolbar">
      <button v-for="p in PRESETS" :key="p.id" class="admin-chip" :class="{ 'admin-chip--active': preset === p.id }" @click="applyPreset(p.id)">
        {{ p.label }}
      </button>
      <label class="fn__date">Dari <input v-model="from" type="date" class="admin-input" @change="preset = 'custom'; load()" /></label>
      <label class="fn__date">Sampai <input v-model="to" type="date" class="admin-input" @change="preset = 'custom'; load()" /></label>
    </div>

    <p v-if="loading" class="admin-muted">Menghitung...</p>
    <template v-else>
      <p v-if="!totalSessions" class="admin-empty">Belum ada data pengunjung pada periode ini.</p>

      <template v-else>
        <div class="admin-stats" style="margin-bottom:1.25rem">
          <div class="admin-stat">
            <div class="admin-stat__value">{{ totalSessions }}</div>
            <div class="admin-stat__label">Total pengunjung (sesi)</div>
          </div>
          <div class="admin-stat">
            <div class="admin-stat__value">{{ conversion.toFixed(1) }}%</div>
            <div class="admin-stat__label">
              Konversi (order/sesi)
              <span v-if="from && to" :class="conversionDelta >= 0 ? 'fn__up' : 'fn__down'">
                {{ conversionDelta >= 0 ? '▲' : '▼' }} {{ Math.abs(conversionDelta).toFixed(1) }} vs periode lalu
              </span>
            </div>
          </div>
          <div class="admin-stat">
            <div class="admin-stat__value">{{ fmt(abandonedCart.total) }}</div>
            <div class="admin-stat__label">Nilai keranjang ditinggal ({{ abandonedCart.sessions }} sesi berhenti di checkout)</div>
          </div>
        </div>

        <div class="fn">
          <div v-for="s in funnel" :key="s.step" class="fn__row">
            <div class="fn__head">
              <span class="fn__name">{{ s.label }}</span>
              <span class="fn__count">{{ s.count }} <small>({{ pct(s.count) }}%)</small></span>
            </div>
            <div class="fn__bar"><div class="fn__fill" :style="{ width: pct(s.count) + '%' }"></div></div>
            <div v-if="s.drop > 0" class="fn__drop">↓ berhenti di sini: <strong>{{ s.drop }}</strong> orang ({{ pct(s.drop) }}%)</div>
          </div>
        </div>

        <div class="admin-card" style="margin-top:1.25rem">
          <h3 style="margin-bottom:.5rem">Kesimpulan</h3>
          <p class="admin-muted" style="margin:0">
            Paling banyak pengunjung berhenti di step
            <strong style="color:var(--color-text)">"{{ topDrop.label }}"</strong>
            — {{ topDrop.drop }} orang ({{ pct(topDrop.drop) }}%) tidak lanjut dari titik ini.
          </p>
        </div>

        <div class="fn__grid">
          <div class="admin-card">
            <h3 style="margin-bottom:.75rem">Perangkat</h3>
            <table class="admin-table">
              <thead><tr><th>Device</th><th>Sesi</th><th>%</th></tr></thead>
              <tbody>
                <tr v-for="d in byDevice" :key="d.label">
                  <td style="text-transform:capitalize">{{ d.label }}</td>
                  <td>{{ d.count }}</td>
                  <td>{{ pct(d.count) }}%</td>
                </tr>
              </tbody>
            </table>
          </div>

          <div class="admin-card">
            <h3 style="margin-bottom:.75rem">Lokasi (perkiraan)</h3>
            <table class="admin-table">
              <thead><tr><th>Daerah</th><th>Sesi</th><th>%</th></tr></thead>
              <tbody>
                <tr v-for="l in byLocation" :key="l.label">
                  <td>{{ l.label }}</td>
                  <td>{{ l.count }}</td>
                  <td>{{ pct(l.count) }}%</td>
                </tr>
              </tbody>
            </table>
            <p class="admin-muted" style="margin:.75rem 0 0;font-size:.78rem">
              Perkiraan dari IP (level kota) — bisa meleset di jaringan seluler/VPN.
            </p>
          </div>

          <!-- #1 Produk masuk keranjang tapi gagal checkout -->
          <div class="admin-card">
            <h3 style="margin-bottom:.75rem">Produk Ditinggal di Keranjang</h3>
            <table class="admin-table">
              <thead><tr><th>Produk</th><th>Sesi</th></tr></thead>
              <tbody>
                <tr v-for="p in abandonedProducts" :key="p.label">
                  <td>{{ p.label }}</td>
                  <td>{{ p.count }}</td>
                </tr>
                <tr v-if="!abandonedProducts.length"><td colspan="2" class="admin-muted">Tidak ada.</td></tr>
              </tbody>
            </table>
            <p class="admin-muted" style="margin:.75rem 0 0;font-size:.78rem">
              Produk yang masuk keranjang tapi sesi tidak lanjut ke checkout.
            </p>
          </div>

          <!-- #2 Sumber trafik -->
          <div class="admin-card">
            <h3 style="margin-bottom:.75rem">Sumber Trafik</h3>
            <table class="admin-table">
              <thead><tr><th>Sumber</th><th>Sesi</th><th>%</th></tr></thead>
              <tbody>
                <tr v-for="s in bySource" :key="s.label">
                  <td>{{ s.label }}</td>
                  <td>{{ s.count }}</td>
                  <td>{{ pct(s.count) }}%</td>
                </tr>
              </tbody>
            </table>
            <p class="admin-muted" style="margin:.75rem 0 0;font-size:.78rem">
              Dari <code>?utm_source</code> atau domain asal. Tandai link IG/WA dengan <code>?utm_source=instagram</code>.
            </p>
          </div>
        </div>

        <!-- #3 Trafik per jam & per hari -->
        <div class="fn__grid">
          <div class="admin-card">
            <h3 style="margin-bottom:.75rem">Event per Jam</h3>
            <div class="fn__hours">
              <div v-for="(v, h) in byHour" :key="h" class="fn__hbar" :title="`${h}:00 — ${v} event`">
                <div class="fn__hfill" :style="{ height: (v / maxHour * 100) + '%' }"></div>
                <span v-if="h % 3 === 0" class="fn__hlabel">{{ h }}</span>
              </div>
            </div>
          </div>

          <div class="admin-card">
            <h3 style="margin-bottom:.75rem">Event per Hari</h3>
            <div v-for="(v, d) in byDow" :key="d" class="fn__row" style="padding:.5rem .75rem;margin-bottom:.4rem">
              <div class="fn__head" style="margin-bottom:.35rem">
                <span class="fn__name">{{ DOW[d] }}</span><span class="fn__count">{{ v }}</span>
              </div>
              <div class="fn__bar"><div class="fn__fill" :style="{ width: (v / maxDow * 100) + '%' }"></div></div>
            </div>
          </div>
        </div>
      </template>
    </template>
  </section>
</template>

<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { supabase } from '../../lib/supabase'

// Definisi step funnel (urut). Order = step terakhir (5), dari tabel orders.
const STEPS = [
  { step: 1, label: 'Lihat Menu' },
  { step: 2, label: 'Tambah ke Keranjang' },
  { step: 3, label: 'Buka Keranjang' },
  { step: 4, label: 'Mulai Checkout' },
  { step: 5, label: 'Order Terkirim' },
]

const PRESETS = [
  { id: 'last30', label: '30 Hari' },
  { id: 'month', label: 'Bulan Ini' },
  { id: 'all', label: 'Semua' },
]

const loading = ref(false)
const preset = ref('last30')
const from = ref('')
const to = ref('')

// Jumlah sesi unik yang MENCAPAI tiap step (step lebih dalam ⊆ step sebelumnya).
const reached = ref<Record<number, number>>({})
const totalSessions = computed(() => reached.value[1] || 0)

// Breakdown per sesi unik: device & lokasi.
const byDevice = ref<{ label: string; count: number }[]>([])
const byLocation = ref<{ label: string; count: number }[]>([])

// #1 Produk yang masuk keranjang tapi tidak jadi checkout.
const abandonedProducts = ref<{ label: string; count: number }[]>([])
// #2 Sumber trafik.
const bySource = ref<{ label: string; count: number }[]>([])
// #3 Trafik per jam & per hari.
const byHour = ref<number[]>(Array(24).fill(0))
const byDow = ref<number[]>(Array(7).fill(0))
const DOW = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab']
// #4 Nilai keranjang yang ditinggal di checkout.
const abandonedCart = ref({ sessions: 0, total: 0 })
// #5 Konversi periode ini vs periode sebelumnya.
const conversion = ref(0)
const prevConversion = ref(0)
const conversionDelta = computed(() => conversion.value - prevConversion.value)

const maxHour = computed(() => Math.max(1, ...byHour.value))
const maxDow = computed(() => Math.max(1, ...byDow.value))
const fmt = (n: number) => 'Rp ' + Math.round(n).toLocaleString('id-ID')

const funnel = computed(() =>
  STEPS.map((s, i) => {
    const count = reached.value[s.step] || 0
    const next = STEPS[i + 1] ? reached.value[STEPS[i + 1].step] || 0 : 0
    return { ...s, count, drop: STEPS[i + 1] ? count - next : 0 }
  })
)

const topDrop = computed(() =>
  funnel.value.reduce((max, s) => (s.drop > max.drop ? s : max), funnel.value[0])
)

const pct = (n: number) => (totalSessions.value ? Math.round((n / totalSessions.value) * 100) : 0)

const iso = (d: Date) => d.toISOString().slice(0, 10)
const applyPreset = (id: string) => {
  preset.value = id
  const now = new Date()
  if (id === 'month') { from.value = iso(new Date(now.getFullYear(), now.getMonth(), 1)); to.value = iso(now) }
  else if (id === 'last30') { const d = new Date(now); d.setDate(d.getDate() - 29); from.value = iso(d); to.value = iso(now) }
  else { from.value = ''; to.value = '' }
  load()
}

// Ambil event + order pada rentang tanggal, lalu hitung metrik ringkas.
const fetchRange = async (fromDate: string, toDate: string) => {
  let eq = supabase
    .from('funnel_events')
    .select('session_id, step, device, city, region, product_name, cart_value, utm_source, referrer, created_at')
  if (fromDate) eq = eq.gte('created_at', fromDate)
  if (toDate) eq = eq.lte('created_at', toDate + 'T23:59:59')
  const { data: events } = await eq

  let oq = supabase.from('orders').select('id').neq('status', 'cancelled')
  if (fromDate) oq = oq.gte('created_at', fromDate)
  if (toDate) oq = oq.lte('created_at', toDate + 'T23:59:59')
  const { data: orders } = await oq

  const sessions = new Set((events || []).map((e: any) => e.session_id))
  const orderCount = (orders || []).length
  return { events: events || [], orderCount, sessionCount: sessions.size }
}

const load = async () => {
  loading.value = true

  const { events, orderCount } = await fetchRange(from.value, to.value)

  // Per sesi: step tertinggi, device/lokasi, sumber, produk pertama, nilai keranjang.
  const maxStep = new Map<string, number>()
  const devOf = new Map<string, string>()
  const locOf = new Map<string, string>()
  const srcOf = new Map<string, string>()
  const prodOf = new Map<string, string>()
  const cartOf = new Map<string, number>()
  events.forEach((e: any) => {
    const cur = maxStep.get(e.session_id) || 0
    if (e.step > cur) maxStep.set(e.session_id, e.step)
    if (e.device && !devOf.has(e.session_id)) devOf.set(e.session_id, e.device)
    const loc = e.city || e.region
    if (loc && !locOf.has(e.session_id)) locOf.set(e.session_id, e.region ? `${e.city || '?'}, ${e.region}` : loc)
    const src = e.utm_source || e.referrer
    if (src && !srcOf.has(e.session_id)) srcOf.set(e.session_id, src)
    if (e.product_name && !prodOf.has(e.session_id)) prodOf.set(e.session_id, e.product_name)
    if (e.cart_value != null && !cartOf.has(e.session_id)) cartOf.set(e.session_id, e.cart_value)
  })

  const tally = (m: Map<string, string>, fallback: string) => {
    const c = new Map<string, number>()
    maxStep.forEach((_s, sid) => {
      const key = m.get(sid) || fallback
      c.set(key, (c.get(key) || 0) + 1)
    })
    return [...c.entries()].map(([label, count]) => ({ label, count })).sort((a, b) => b.count - a.count)
  }
  byDevice.value = tally(devOf, 'tidak diketahui')
  byLocation.value = tally(locOf, 'tidak diketahui')
  bySource.value = tally(srcOf, 'langsung / tidak diketahui') // #2

  // reached[k] = jumlah sesi dengan maxStep >= k (funnel kumulatif).
  const r: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
  maxStep.forEach((step) => {
    for (let k = 1; k <= step; k++) r[k]++
  })
  r[5] = orderCount
  reached.value = r

  // #1 Produk yang masuk keranjang tapi TIDAK sampai checkout (maxStep 2 atau 3).
  const prodCount = new Map<string, number>()
  maxStep.forEach((step, sid) => {
    if (step >= 2 && step <= 3) {
      const p = prodOf.get(sid)
      if (p) prodCount.set(p, (prodCount.get(p) || 0) + 1)
    }
  })
  abandonedProducts.value = [...prodCount.entries()]
    .map(([label, count]) => ({ label, count }))
    .sort((a, b) => b.count - a.count)

  // #3 Trafik per jam & hari (dari waktu lokal event).
  const hrs = Array(24).fill(0)
  const dow = Array(7).fill(0)
  events.forEach((e: any) => {
    const d = new Date(e.created_at)
    hrs[d.getHours()]++
    dow[d.getDay()]++
  })
  byHour.value = hrs
  byDow.value = dow

  // #4 Nilai keranjang ditinggal: sesi yang sampai checkout (maxStep 4) tapi tak ada order.
  // ponytail: order tak terikat session_id, jadi "ditinggal" = berhenti tepat di step 4.
  let aSessions = 0
  let aTotal = 0
  maxStep.forEach((step, sid) => {
    if (step === 4) {
      aSessions++
      aTotal += cartOf.get(sid) || 0
    }
  })
  abandonedCart.value = { sessions: aSessions, total: aTotal }

  // #5 Konversi (order / total sesi) periode ini vs periode sebelumnya (panjang sama).
  const totalNow = r[1] || 0
  conversion.value = totalNow ? (orderCount / totalNow) * 100 : 0
  if (from.value && to.value) {
    const fromD = new Date(from.value)
    const toD = new Date(to.value)
    const days = Math.round((+toD - +fromD) / 86400000) + 1
    const prevTo = new Date(fromD); prevTo.setDate(prevTo.getDate() - 1)
    const prevFrom = new Date(prevTo); prevFrom.setDate(prevFrom.getDate() - days + 1)
    const prev = await fetchRange(iso(prevFrom), iso(prevTo))
    prevConversion.value = prev.sessionCount ? (prev.orderCount / prev.sessionCount) * 100 : 0
  } else {
    prevConversion.value = 0
  }

  loading.value = false
}

onMounted(() => applyPreset('last30'))
</script>

<style scoped>
.fn__date {
  display: flex;
  align-items: center;
  gap: 0.4rem;
  font-size: 0.85rem;
  font-weight: 600;
  color: var(--color-text-light);
}
.fn__date .admin-input { width: auto; }
.fn { display: flex; flex-direction: column; gap: 1rem; }
.fn__row {
  background: var(--color-white);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 1rem;
}
.fn__head {
  display: flex;
  justify-content: space-between;
  align-items: baseline;
  margin-bottom: 0.5rem;
}
.fn__name { font-weight: 700; }
.fn__count { font-weight: 800; color: var(--color-primary-dark); }
.fn__count small { font-weight: 600; color: var(--color-text-light); }
.fn__bar {
  height: 12px;
  background: var(--color-bg);
  border-radius: 9999px;
  overflow: hidden;
}
.fn__fill {
  height: 100%;
  background: linear-gradient(90deg, #6366f1, #4f46e5);
  border-radius: 9999px;
  transition: width 0.4s ease;
}
.fn__drop {
  margin-top: 0.5rem;
  font-size: 0.82rem;
  color: #b45309;
}
.fn__grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 1.25rem;
  margin-top: 1.25rem;
}
.fn__up { color: #047857; font-weight: 700; }
.fn__down { color: #b91c1c; font-weight: 700; }
.fn__hours {
  display: flex;
  align-items: flex-end;
  gap: 3px;
  height: 140px;
  margin-bottom: 1.1rem;
}
.fn__hbar {
  flex: 1;
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: flex-end;
  align-items: center;
  position: relative;
}
.fn__hfill {
  width: 100%;
  min-height: 2px;
  background: linear-gradient(180deg, #6366f1, #4f46e5);
  border-radius: 3px 3px 0 0;
}
.fn__hlabel {
  position: absolute;
  bottom: -1.1rem;
  font-size: 0.65rem;
  color: var(--color-text-light);
}
</style>
