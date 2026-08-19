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
        <div class="admin-stat" style="margin-bottom:1.25rem">
          <div class="admin-stat__value">{{ totalSessions }}</div>
          <div class="admin-stat__label">Total pengunjung (sesi)</div>
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

const load = async () => {
  loading.value = true

  // Step furthest per sesi dari funnel_events.
  let eq = supabase.from('funnel_events').select('session_id, step, device, city, region, created_at')
  if (from.value) eq = eq.gte('created_at', from.value)
  if (to.value) eq = eq.lte('created_at', to.value + 'T23:59:59')
  const { data: events } = await eq

  // Sesi yang berhasil order (step 5) = sesi yang punya event checkout_start & order tersimpan.
  // orders tidak menyimpan session_id, jadi step 5 diambil dari jumlah order pada periode.
  let oq = supabase.from('orders').select('id, created_at').neq('status', 'cancelled')
  if (from.value) oq = oq.gte('created_at', from.value)
  if (to.value) oq = oq.lte('created_at', to.value + 'T23:59:59')
  const { data: orders } = await oq

  // Untuk tiap sesi, catat step tertinggi + device/lokasi (ambil nilai pertama non-null).
  const maxStep = new Map<string, number>()
  const devOf = new Map<string, string>()
  const locOf = new Map<string, string>()
  ;(events || []).forEach((e: any) => {
    const cur = maxStep.get(e.session_id) || 0
    if (e.step > cur) maxStep.set(e.session_id, e.step)
    if (e.device && !devOf.has(e.session_id)) devOf.set(e.session_id, e.device)
    const loc = e.city || e.region
    if (loc && !locOf.has(e.session_id)) locOf.set(e.session_id, e.region ? `${e.city || '?'}, ${e.region}` : loc)
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

  // reached[k] = jumlah sesi dengan maxStep >= k (funnel kumulatif).
  const r: Record<number, number> = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 }
  maxStep.forEach((step) => {
    for (let k = 1; k <= step; k++) r[k]++
  })
  // Step 5 dari jumlah order (tidak bisa dikaitkan ke sesi tanpa session_id di orders).
  r[5] = (orders || []).length

  reached.value = r
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
</style>
