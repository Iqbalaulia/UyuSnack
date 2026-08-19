import { supabase } from './supabase'

// Funnel steps — makin besar, makin dalam prosesnya.
export const STEPS = {
  view_menu: 1,
  add_to_cart: 2,
  open_cart: 3,
  checkout_start: 4,
} as const
export type StepName = keyof typeof STEPS

const sessionId = (() => {
  const KEY = 'uyu_sid'
  let id = localStorage.getItem(KEY)
  if (!id) {
    id = crypto.randomUUID()
    localStorage.setItem(KEY, id)
  }
  return id
})()

const device: 'mobile' | 'desktop' = /Mobi|Android|iPhone|iPad|iPod/i.test(navigator.userAgent)
  ? 'mobile'
  : 'desktop'

// Lokasi (perkiraan kota via IP). Diambil sekali per sesi, disimpan di localStorage
// supaya tidak memanggil ipapi.co berulang (kuota gratis ~1000/hari).
// ponytail: akurasi level kota, sering meleset di jaringan seluler/VPN.
const geo = { city: null as string | null, region: null as string | null }
const loadGeo = async (): Promise<void> => {
  const KEY = 'uyu_geo'
  const cached = localStorage.getItem(KEY)
  if (cached) {
    Object.assign(geo, JSON.parse(cached))
    return
  }
  try {
    const res = await fetch('https://ipapi.co/json/')
    if (!res.ok) return
    const d = await res.json()
    geo.city = d.city || null
    geo.region = d.region || null
    localStorage.setItem(KEY, JSON.stringify(geo))
  } catch {
    /* offline / kuota habis — biarkan null */
  }
}
const geoReady = loadGeo()

// Catat setiap step sekali saja per sesi (hindari baris duplikat).
const seen = new Set<StepName>()

export const track = async (step: StepName): Promise<void> => {
  if (seen.has(step)) return
  seen.add(step)
  await geoReady
  const { error } = await supabase.from('funnel_events').insert({
    session_id: sessionId,
    step: STEPS[step],
    step_name: step,
    device,
    city: geo.city,
    region: geo.region,
  })
  if (error) console.warn('track gagal:', error.message)
}
