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
  slug TEXT NOT NULL UNIQUE,
  title_id TEXT NOT NULL,
  title_en TEXT NOT NULL,
  excerpt_id TEXT NOT NULL,
  excerpt_en TEXT NOT NULL,
  content_id TEXT NOT NULL DEFAULT '',
  content_en TEXT NOT NULL DEFAULT '',
  image TEXT NOT NULL,
  published_at DATE NOT NULL DEFAULT CURRENT_DATE,
  read_time_minutes INTEGER NOT NULL DEFAULT 1,
  is_active BOOLEAN NOT NULL DEFAULT true,
  sort_order INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW()),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc', NOW())
);

-- Bila tabel sudah dibuat sebelumnya tanpa kolom baru:
ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS slug TEXT UNIQUE;
ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS content_id TEXT NOT NULL DEFAULT '';
ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS content_en TEXT NOT NULL DEFAULT '';
ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS published_at DATE NOT NULL DEFAULT CURRENT_DATE;
ALTER TABLE blog_posts ADD COLUMN IF NOT EXISTS read_time_minutes INTEGER NOT NULL DEFAULT 1;

-- Isi slug kosong bila data lama belum punya slug
UPDATE blog_posts SET slug = LOWER(REGEXP_REPLACE(REGEXP_REPLACE(title_id, '[^a-zA-Z0-9]+', '-', 'g'), '^-|-$', '', 'g')) WHERE slug IS NULL OR slug = '';

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

INSERT INTO blog_posts (slug, title_id, title_en, excerpt_id, excerpt_en, content_id, content_en, image, published_at, read_time_minutes, is_active, sort_order)
VALUES
  (
    'cara-menyimpan-burnt-cheesecake',
    'Cara Menyimpan Burnt Cheesecake Agar Tetap Lembut',
    'How to Store Burnt Cheesecake to Keep It Soft',
    'Simpan dalam kulkas dan biarkan suhu ruang 10-15 menit sebelum disantap untuk tekstur terbaik.',
    'Store in the refrigerator and let it reach room temperature for 10-15 minutes before serving for the best texture.',
    '<p>Burnt cheesecake terbaik dinikmati dalam suhu ruang. Simpan dalam kulkas maksimal 3 hari dalam wadah kedap udara.</p><p>Keluarkan dari kulkas 10-15 menit sebelum disantap agar tekstur kembali lembut dan creamy. Hindari memasukkan ke freezer karena dapat mengubah tekstur.</p>',
    '<p>Burnt cheesecake is best enjoyed at room temperature. Store in the refrigerator for up to 3 days in an airtight container.</p><p>Remove from the fridge 10-15 minutes before serving so the texture becomes soft and creamy again. Avoid freezing as it changes the texture.</p>',
    '/assets/burnt-cheesecake-original.jpg',
    CURRENT_DATE,
    2,
    true,
    1
  ),
  (
    'ide-hampers-simpel-untuk-orang-tersayang',
    'Ide Hampers Simpel untuk Orang Tersayang',
    'Simple Hampers Ideas for Loved Ones',
    'Kombinasi burnt cheesecake dengan kartu ucapan kecil bisa jadi hadiah yang berkesan.',
    'A combination of burnt cheesecake with a small greeting card can be a memorable gift.',
    '<p>Hampers tidak perlu mahal untuk terasa berkesan. Pilih 2-3 varian burnt cheesecake, tambahkan kartu ucapan tulisan tangan, dan kemas dalam box minimalis.</p><p>Cocok untuk ulang tahun, anniversary, atau hadiah rutin. Pesan satu hari sebelumnya agar pengiriman tepat waktu.</p>',
    '<p>Hampers do not have to be expensive to feel meaningful. Choose 2-3 burnt cheesecake variants, add a handwritten greeting card, and pack them in a minimalist box.</p><p>Perfect for birthdays, anniversaries, or casual gifts. Order one day in advance for on-time delivery.</p>',
    '/assets/burnt-cheesecake-chocobery.jpg',
    CURRENT_DATE,
    2,
    true,
    2
  ),
  (
    'paduan-terbaik-burnt-cheesecake-dengan-minuman',
    'Paduan Terbaik Burnt Cheesecake dengan Minuman',
    'Best Drinks to Pair with Burnt Cheesecake',
    'Cobain dinikmati bersama kopi hitam atau teh tarik untuk pengalaman rasa yang lebih nikmat.',
    'Try enjoying it with black coffee or tarik tea for a more delightful taste experience.',
    '<p>Burnt cheesecake yang creamy dan sedikit pahit cocok dipadukan dengan minuman yang menyegarkan.</p><p>Kopi hitam tanpa gula menyeimbangkan rasa manis, teh tarik memberikan sentuhan klasik, sedangkan susu dingin cocok untuk yang tidak suka kafein.</p>',
    '<p>The creamy and slightly bitter burnt cheesecake pairs well with refreshing drinks.</p><p>Black coffee without sugar balances the sweetness, tarik tea gives a classic touch, while cold milk is perfect for those who avoid caffeine.</p>',
    '/assets/burnt-cheesecake-chocoregal.jpg',
    CURRENT_DATE,
    2,
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
