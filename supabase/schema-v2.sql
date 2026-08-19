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
  quantity NUMERIC NOT NULL DEFAULT 0          -- jumlah unit bahan per 1 produk
);

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
