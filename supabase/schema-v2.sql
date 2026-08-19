-- ============================================================
-- Uyu Snack — Migration v2
-- Fitur: Bahan Baku (HPP), Batch Open PO, Pengeluaran, Laba
-- Jalankan seluruh file ini di Supabase SQL Editor.
-- ============================================================

-- Kolom HPP pada products (harga pokok produksi per unit, rupiah)
ALTER TABLE products ADD COLUMN IF NOT EXISTS hpp INTEGER NOT NULL DEFAULT 0;

-- ---------- Bahan Baku ----------
CREATE TABLE IF NOT EXISTS materials (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  unit TEXT NOT NULL DEFAULT 'gram',          -- gram / ml / pcs / dst
  price_per_unit NUMERIC NOT NULL DEFAULT 0,  -- harga per 1 unit
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE materials ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated manage materials" ON materials;
CREATE POLICY "Authenticated manage materials"
  ON materials FOR ALL TO authenticated USING (true) WITH CHECK (true);

DROP TRIGGER IF EXISTS update_materials_updated_at ON materials;
CREATE TRIGGER update_materials_updated_at
  BEFORE UPDATE ON materials FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ---------- Resep produk (Bill of Materials) ----------
CREATE TABLE IF NOT EXISTS product_materials (
  id SERIAL PRIMARY KEY,
  product_id INTEGER NOT NULL REFERENCES products(id) ON DELETE CASCADE,
  material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
  quantity NUMERIC NOT NULL DEFAULT 0,         -- jumlah unit bahan yang dipakai
  yield NUMERIC NOT NULL DEFAULT 1             -- 1 pakaian bahan ini menghasilkan berapa produk
);

-- Bila tabel sudah pernah dibuat tanpa kolom yield:
ALTER TABLE product_materials ADD COLUMN IF NOT EXISTS yield NUMERIC NOT NULL DEFAULT 1;

ALTER TABLE product_materials ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated manage product_materials" ON product_materials;
CREATE POLICY "Authenticated manage product_materials"
  ON product_materials FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---------- Batch Open PO ----------
CREATE TABLE IF NOT EXISTS po_batches (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  start_date DATE NOT NULL,
  end_date DATE NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE po_batches ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated manage po_batches" ON po_batches;
CREATE POLICY "Authenticated manage po_batches"
  ON po_batches FOR ALL TO authenticated USING (true) WITH CHECK (true);
-- publik boleh baca batch aktif (untuk info di landing page bila perlu)
DROP POLICY IF EXISTS "Public read active po_batches" ON po_batches;
CREATE POLICY "Public read active po_batches"
  ON po_batches FOR SELECT USING (is_active = true);

DROP TRIGGER IF EXISTS update_po_batches_updated_at ON po_batches;
CREATE TRIGGER update_po_batches_updated_at
  BEFORE UPDATE ON po_batches FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- ---------- Pengeluaran (biaya operasional untuk laba bersih) ----------
CREATE TABLE IF NOT EXISTS expenses (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL DEFAULT 'operasional',  -- operasional / gaji / packaging / marketing / lainnya
  amount INTEGER NOT NULL DEFAULT 0,
  expense_date DATE NOT NULL DEFAULT CURRENT_DATE,
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE expenses ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated manage expenses" ON expenses;
CREATE POLICY "Authenticated manage expenses"
  ON expenses FOR ALL TO authenticated USING (true) WITH CHECK (true);

-- ---------- Funnel Tracking (sampai step apa user berhenti) ----------
-- step: 1=view_menu, 2=add_to_cart, 3=open_cart, 4=checkout_start, 5=order (order tersimpan di tabel orders)
CREATE TABLE IF NOT EXISTS funnel_events (
  id SERIAL PRIMARY KEY,
  session_id TEXT NOT NULL,       -- id acak per pengunjung (localStorage)
  step INTEGER NOT NULL,          -- nomor step, makin besar makin dalam funnel
  step_name TEXT NOT NULL,
  device TEXT,                    -- 'mobile' / 'desktop' (dari userAgent)
  city TEXT,                      -- perkiraan kota (dari IP via ipapi.co)
  region TEXT,                    -- perkiraan provinsi/wilayah
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Jika tabel sudah dibuat sebelumnya tanpa kolom ini:
ALTER TABLE funnel_events ADD COLUMN IF NOT EXISTS device TEXT;
ALTER TABLE funnel_events ADD COLUMN IF NOT EXISTS city TEXT;
ALTER TABLE funnel_events ADD COLUMN IF NOT EXISTS region TEXT;
CREATE INDEX IF NOT EXISTS funnel_events_created_idx ON funnel_events (created_at);

ALTER TABLE funnel_events ENABLE ROW LEVEL SECURITY;
-- Pengunjung anonim boleh mencatat event (insert saja), tidak boleh baca.
DROP POLICY IF EXISTS "Anyone insert funnel" ON funnel_events;
CREATE POLICY "Anyone insert funnel"
  ON funnel_events FOR INSERT TO anon, authenticated WITH CHECK (true);
-- Hanya admin (login) yang boleh membaca hasil tracking.
DROP POLICY IF EXISTS "Authenticated read funnel" ON funnel_events;
CREATE POLICY "Authenticated read funnel"
  ON funnel_events FOR SELECT TO authenticated USING (true);
