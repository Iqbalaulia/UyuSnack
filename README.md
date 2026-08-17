# Uyu Snack — Landing Page

Landing page mobile-first untuk akun Instagram [@uyu_snack](https://www.instagram.com/uyu_snack/) dibangun dengan **Vue.js 3 (CDN)**, **HTML5**, dan **CSS3** murni. Tidak memerlukan build step, cocok untuk dihosting di Vercel, Netlify, atau GitHub Pages.

## Fitur

- ✅ Desain mobile-first, responsif ke desktop
- ✅ Navigasi sticky dengan smooth scroll
- ✅ Katalog produk dengan filter kategori
- ✅ Tombol pesan WhatsApp per produk + sticky WhatsApp button
- ✅ Testimoni & FAQ interaktif (accordion)
- ✅ Semua konten utama dikelola di satu file: `js/main.js`
- ✅ Font Google Fonts (Nunito & Playfair Display)
- ✅ Placeholder gambar sudah disediakan, siap diganti

## Struktur Folder

```
Uyusnack/
├── index.html              # Struktur halaman utama
├── css/
│   └── main.css            # Styling mobile-first
├── js/
│   └── main.js             # Vue app + data konten
├── assets/
│   └── images/
│       ├── hero-snack.png
│       ├── products/       # Foto produk
│       └── testimonials/   # Foto testimoni
├── generate-images.py      # Script generate placeholder gambar
└── README.md
```

## Cara Menjalankan Secara Lokal

Cukup buka `index.html` di browser, atau jalankan server lokal sederhana:

```bash
# Python 3
python -m http.server 8000

# Node.js (jika ada http-server)
npx http-server -p 8000
```

Buka http://localhost:8000 di browser.

## Cara Kustomisasi

### 1. Nomor WhatsApp & Pesan Default

Edit bagian `CONFIG` di `js/main.js`:

```js
const CONFIG = {
  phone: '6281234567890',      // Ganti dengan nomor bisnis (format 62xxxxxxxxxx)
  greeting: 'Halo Uyu Snack! Saya mau pesan:',
  instagram: 'https://www.instagram.com/uyu_snack/'
};
```

### 2. Menu Produk

Tambah/ubah data di `products` pada `js/main.js`:

```js
{
  id: 7,
  name: 'Nama Produk Baru',
  description: 'Deskripsi singkat produk.',
  price: 50000,
  category: 'Cookies',
  badge: 'Best Seller',       // Kosongkan '' jika tidak ada badge
  image: 'assets/images/products/nama-file.jpg'
}
```

### 3. Gambar

Ganti file di folder `assets/images/` dengan foto asli produk/testimoni. Usahakan:
- Rasio produk: **4:3** atau **1:1**
- Ukuran maksimal: **800px lebar**
- Format: **JPG** atau **PNG**
- Kompres gambar agar halaman tetap cepat.

### 4. Warna Brand

Edit variabel CSS di `css/main.css`:

```css
:root {
  --color-primary: #FF8C69;    /* Warna utama CTA */
  --color-secondary: #FFD6A5;  /* Warna aksen sekunder */
  --color-accent: #6B4F4B;     /* Warna teks judul */
  --color-bg: #FFFBF7;         /* Background */
}
```

## Deploy ke Hosting

### Vercel
1. Push project ke GitHub/GitLab.
2. Login ke [vercel.com](https://vercel.com) → Import repo.
3. Framework preset: **Other** (static).
4. Deploy.

### Netlify
1. Push project ke GitHub/GitLab.
2. Login ke [netlify.com](https://netlify.com) → Add new site → Import.
3. Build command: kosongkan. Publish directory: `/` (root).
4. Deploy.

### GitHub Pages
1. Push repo ke GitHub.
2. Aktifkan GitHub Pages di Settings → Pages → Branch `main`, folder `/ (root)`.
3. Akses URL yang diberikan.

## Catatan Penting

- Gambar saat ini masih **placeholder** yang dihasilkan oleh `generate-images.py`. Segera ganti dengan foto produk asli agar landing page terlihat profesional.
- Jika ingin menambahkan section baru, edit `index.html` untuk markup dan `js/main.js` untuk datanya.
- Untuk SEO lebih baik, pertimbangkan menambahkan meta tag Open Graph (OG) dan Schema.org di `<head>`.

## Teknologi

- [Vue.js 3](https://vuejs.org/) (via CDN)
- [Google Fonts](https://fonts.google.com/)
- HTML5 & CSS3 murni (tanpa framework CSS)

---

Dibuat untuk @uyu_snack 🍪
