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
    'preorder',
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
    'preorder',
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

-- Policy: admin (authenticated) bisa update & hapus orders
DROP POLICY IF EXISTS "Authenticated users can manage orders" ON orders;
CREATE POLICY "Authenticated users can manage orders"
  ON orders
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE TRIGGER update_orders_updated_at
  BEFORE UPDATE ON orders
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

-- Tabel blog_posts (Tips & Resep)
CREATE TABLE IF NOT EXISTS blog_posts (
  id SERIAL PRIMARY KEY,
  title_id TEXT NOT NULL,
  title_en TEXT NOT NULL,
  excerpt_id TEXT NOT NULL,
  excerpt_en TEXT NOT NULL,
  image TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE blog_posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read active blog posts"
  ON blog_posts
  FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can manage blog posts"
  ON blog_posts
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE TRIGGER update_blog_posts_updated_at
  BEFORE UPDATE ON blog_posts
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

INSERT INTO blog_posts (title_id, title_en, excerpt_id, excerpt_en, image, is_active, sort_order)
VALUES
  (
    'Cara Menyimpan Burnt Cheesecake Agar Tetap Lembut',
    'How to Store Burnt Cheesecake to Keep It Soft',
    'Simpan dalam kulkas dan biarkan suhu ruang 10-15 menit sebelum disantap untuk tekstur terbaik.',
    'Store in the refrigerator and let it reach room temperature for 10-15 minutes before serving for the best texture.',
    '/assets/burnt-cheesecake-original.jpg',
    true,
    1
  ),
  (
    'Ide Hampers Simpel untuk Orang Tersayang',
    'Simple Hampers Ideas for Loved Ones',
    'Kombinasi burnt cheesecake dengan kartu ucapan kecil bisa jadi hadiah yang berkesan.',
    'A combination of burnt cheesecake with a small greeting card can be a memorable gift.',
    '/assets/burnt-cheesecake-chocobery.jpg',
    true,
    2
  ),
  (
    'Paduan Terbaik Burnt Cheesecake dengan Minuman',
    'Best Drinks to Pair with Burnt Cheesecake',
    'Cobain dinikmati bersama kopi hitam atau teh tarik untuk pengalaman rasa yang lebih nikmat.',
    'Try enjoying it with black coffee or tarik tea for a more delightful taste experience.',
    '/assets/burnt-cheesecake-chocoregal.jpg',
    true,
    3
  );

-- Tabel testimonials (Apa Kata Pelanggan?)
CREATE TABLE IF NOT EXISTS testimonials (
  id SERIAL PRIMARY KEY,
  name TEXT NOT NULL,
  role_id TEXT NOT NULL,
  role_en TEXT NOT NULL,
  text_id TEXT NOT NULL,
  text_en TEXT NOT NULL,
  avatar TEXT NOT NULL,
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

ALTER TABLE testimonials ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read active testimonials"
  ON testimonials
  FOR SELECT
  USING (is_active = true);

CREATE POLICY "Authenticated users can manage testimonials"
  ON testimonials
  FOR ALL
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE TRIGGER update_testimonials_updated_at
  BEFORE UPDATE ON testimonials
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();

INSERT INTO testimonials (name, role_id, role_en, text_id, text_en, avatar, is_active, sort_order)
VALUES
  (
    'Dinda A.',
    'Pelanggan Setia',
    'Loyal Customer',
    'Burnt Cheesecake Original-nya enak banget, lembut dan nggak eneg. Sudah repeat order 3 kali!',
    'The Burnt Cheesecake Original is so good, soft and not overwhelming. Already reordered 3 times!',
    '/assets/burnt-cheesecake-original.jpg',
    true,
    1
  ),
  (
    'Rizky M.',
    'Pembeli Pertama',
    'First-time Buyer',
    'Chocobery-nya manisnya pas, topping stroberi dan cokelatnya melimpah. Favorit keluarga!',
    'The Chocobery sweetness is just right, strawberry and chocolate toppings are abundant. Family favorite!',
    '/assets/burnt-cheesecake-chocobery.jpg',
    true,
    2
  ),
  (
    'Siti N.',
    'Pembeli Hampers',
    'Hampers Buyer',
    'Pesan Chocolate Regal untuk hadiah teman, dikirim tepat waktu dan penerima senang banget.',
    'Ordered Chocolate Regal as a gift for a friend, delivered on time and the recipient was very happy.',
    '/assets/burnt-cheesecake-chocoregal.jpg',
    true,
    3
  );
