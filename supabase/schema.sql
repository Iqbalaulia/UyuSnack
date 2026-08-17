-- Supabase schema untuk Uyu Snack
-- Jalankan query ini di SQL Editor Supabase

-- Tabel products
CREATE TABLE IF NOT EXISTS products (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  price INTEGER NOT NULL,
  description TEXT NOT NULL,
  image TEXT NOT NULL,
  badge TEXT,
  stock TEXT NOT NULL DEFAULT 'available' CHECK (stock IN ('available', 'preorder', 'soldout')),
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Row Level Security (RLS)
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- Policy: semua orang bisa baca produk aktif
CREATE POLICY "Public read active products"
  ON products
  FOR SELECT
  USING (is_active = true);

-- Policy: hanya authenticated user (admin) yang bisa insert/update/delete
CREATE POLICY "Authenticated users can manage products"
  ON products
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

-- Fungsi update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = TIMEZONE('utc', NOW());
  RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_products_updated_at
  BEFORE UPDATE ON products
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Seed data: produk Uyu Snack
INSERT INTO products (name, category, price, description, image, badge, stock, is_active)
VALUES
  (
    'Burnt Cheesecake Original',
    'best-seller',
    21000,
    'Classic variant dengan tekstur lembut dan permukaan karamelisasi yang sempurna. Diameter 10cm, tinggi 3cm.',
    '/assets/burnt-cheesecake-original.jpg',
    'Best Seller',
    'available',
    true
  ),
  (
    'Burnt Cheesecake Chocobery',
    'new',
    23500,
    'Perpaduan lembut burnt cheesecake dengan topping selai stroberi manis dan lilitan cokelat premium.',
    '/assets/burnt-cheesecake-chocobery.jpg',
    'New Variant',
    'preorder',
    true
  ),
  (
    'Burnt Cheesecake Chocolate Regal',
    'new',
    23500,
    'Burnt cheesecake cokelat dengan topping cokelat lumer, biskuit Regal utuh, dan remahan biskuit renyah.',
    '/assets/burnt-cheesecake-chocoregal.jpg',
    'New Variant',
    'available',
    true
  );

-- Tabel orders (untuk menyimpan pesanan yang masuk)
CREATE TABLE IF NOT EXISTS orders (
  id SERIAL PRIMARY KEY,
  customer_name TEXT NOT NULL,
  customer_phone TEXT NOT NULL,
  customer_address TEXT,
  items JSONB NOT NULL,
  total_price INTEGER NOT NULL,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'processing', 'shipped', 'completed', 'cancelled')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- Policy: hanya authenticated user yang bisa baca orders
CREATE POLICY "Authenticated users can read orders"
  ON orders
  FOR SELECT
  TO authenticated
  USING (true);

-- Policy: public bisa insert order (tanpa login)
CREATE POLICY "Public can insert orders"
  ON orders
  FOR INSERT
  TO anon
  WITH CHECK (true);

CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
