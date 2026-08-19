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

// Catat setiap step sekali saja per sesi (hindari baris duplikat).
const seen = new Set<StepName>()

export const track = (step: StepName): void => {
  if (seen.has(step)) return
  seen.add(step)
  supabase
    .from('funnel_events')
    .insert({ session_id: sessionId, step: STEPS[step], step_name: step })
    .then(({ error }) => error && console.warn('track gagal:', error.message))
}
