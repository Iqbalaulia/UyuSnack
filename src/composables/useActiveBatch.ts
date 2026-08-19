import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'

export interface ActiveBatch {
  id: number
  name: string
  start_date: string
  end_date: string
  notes: string | null
}

// Ambil 1 batch PO yang sedang berlangsung hari ini (aktif & tanggal hari ini di rentangnya).
export function useActiveBatch() {
  const batch = ref<ActiveBatch | null>(null)
  const daysLeft = ref<number | null>(null)

  onMounted(async () => {
    const today = new Date().toISOString().slice(0, 10)
    const { data } = await supabase
      .from('po_batches')
      .select('id, name, start_date, end_date, notes')
      .eq('is_active', true)
      .lte('start_date', today)
      .gte('end_date', today)
      .order('end_date', { ascending: true })
      .limit(1)

    if (data && data.length) {
      batch.value = data[0] as ActiveBatch
      const end = new Date(batch.value.end_date + 'T23:59:59')
      daysLeft.value = Math.max(0, Math.ceil((end.getTime() - Date.now()) / 86400000))
    }
  })

  return { batch, daysLeft }
}
