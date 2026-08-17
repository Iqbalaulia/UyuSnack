# TODO — Pengembangan Landing Page Uyu Snack

Daftar rencana pengembangan landing page Uyu Snack. Urutan berdasarkan prioritas dampak terhadap konversi dan usaha pengerjaan.

---

## Legenda Status

| Status | Keterangan |
|--------|------------|
| 🔴 To Do | Belum dikerjakan |
| 🟡 In Progress | Sedang dikerjakan |
| 🟢 Done | Sudah selesai |

## Legenda Prioritas

| Prioritas | Keterangan |
|-----------|------------|
| 🔥 High | Berdampak langsung pada konversi/pengalaman user |
| ⚡ Medium | Peningkatan fitur dan kenyamanan |
| 💡 Low | Nice to have / jangka panjang |

---

## Phase 1 — Quick Wins

| Status | Prioritas | Task | Keterangan | File Terkait |
|--------|-----------|------|------------|--------------|
| 🟢 Done | 🔥 High | Setup project Vue 3 + Vite | Struktur awal, routing, dan styling system | `package.json`, `vite.config.js`, `src/style.css` |
| 🟢 Done | 🔥 High | Landing page mobile-first | Hero, About, Features, Menu, Testimonials, How to Order, CTA, Footer | `src/components/*.vue` |
| 🟢 Done | 🔥 High | Ganti emoji dengan icon SVG custom | Semua icon menggunakan SVG line art konsisten | `src/components/icons/*.vue` |
| 🟢 Done | 🔥 High | Integrasi gambar & data asli Uyu Snack | Menggunakan foto produk, logo, harga, dan nomor WA asli dari menu Uyu Snack | `public/assets/`, `src/data/products.js`, `src/components/Hero.vue`, `src/components/About.vue` |
| 🟢 Done | 🔥 High | Floating WhatsApp button | Tombol WA mengambang di pojok kanan bawah, selalu terlihat saat scroll | `src/components/WhatsAppFloat.vue` |
| 🟢 Done | 🔥 High | Section FAQ | Pertanyaan umum seputar pemesanan, pengiriman, dan custom hampers | `src/components/FAQ.vue` |
| 🟢 Done | 🔥 High | Open Graph & meta tags lengkap | `og:image`, `og:title`, `og:description`, Twitter Card agar link menarik saat dishare | `index.html` |
| 🟢 Done | ⚡ Medium | Sticky bottom bar di mobile | Tombol CTA ke Menu/WhatsApp sticky di bawah layar mobile | `src/components/MobileStickyBar.vue` |

## Phase 2 — Peningkatan Konversi

| Status | Prioritas | Task | Keterangan | File Terkait |
|--------|-----------|------|------------|--------------|
| 🟢 Done | 🔥 High | Keranjang sederhana | User bisa pilih beberapa produk, total otomatis, kirim ke WA dalam satu pesan | `src/stores/cart.js`, `src/components/CartDrawer.vue` |
| 🟢 Done | 🔥 High | Testimoni dengan foto real | Avatar menggunakan foto produk asli Uyu Snack | `src/components/Testimonials.vue` |
| 🟢 Done | ⚡ Medium | Indikator stok / label pre-order | Status Tersedia/Pre-Order pada setiap produk | `src/data/products.js`, `src/components/ProductCatalog.vue` |
| 🟢 Done | ⚡ Medium | Animasi scroll & micro-interaction | Fade-in, hover effect, smooth reveal pakai CSS/Intersection Observer | `src/style.css`, `src/components/SectionReveal.vue`, `src/composables/useScrollReveal.js` |
| 🟢 Done | ⚡ Medium | Lazy load gambar produk | Lazy loading + shimmer placeholder via komponen `LazyImage` | `src/components/LazyImage.vue` |

## Phase 3 — Skalabilitas & Konten

| Status | Prioritas | Task | Keterangan | File Terkait |
|--------|-----------|------|------------|--------------|
| 🟢 Done | ⚡ Medium | Katalog dinamis dari Supabase | Data produk di-fetch dari Supabase, owner bisa update via dashboard Supabase | `src/lib/supabase.js`, `src/composables/useProducts.js`, `supabase/schema.sql` |
| 🟢 Done | ⚡ Medium | Galeri Instagram feed | Grid foto produk yang link ke Instagram @uyu_snack | `src/components/InstagramFeed.vue` |
| 🟢 Done | 💡 Low | Blog / tips / resep | Section blog dengan artikel tips & resep | `src/components/Blog.vue`, `src/locales/messages.js` |
| 🟢 Done | 💡 Low | Multi-bahasa (ID/EN) | Dukungan Bahasa Indonesia & Inggris dengan toggle | `src/locales/`, `vue-i18n`, `src/components/LanguageToggle.vue` |

## Phase 4 — Advanced & Analitik

| Status | Prioritas | Task | Keterangan | File Terkait |
|--------|-----------|------|------------|--------------|
| 🔴 To Do | 💡 Low | Progressive Web App (PWA) | Bisa di-install di homescreen, offline support dasar | `vite-plugin-pwa`, `manifest.json` |
| 🔴 To Do | 💡 Low | Integrasi payment gateway | Checkout langsung via Midtrans/Xendit | `src/components/Checkout.vue`, backend payment |
| 🔴 To Do | 💡 Low | Analytics & heatmap | Google Analytics 4 / Plausible / Microsoft Clarity untuk tracking perilaku user | `index.html`, third-party script |
| 🔴 To Do | 💡 Low | Newsletter / promo capture | Form email untuk blast promo menu baru | `src/components/Newsletter.vue` |

---

## Catatan

- Phase 1, 2, dan 3 sudah selesai.
- Untuk Supabase, pastikan environment variables `VITE_SUPABASE_URL` dan `VITE_SUPABASE_ANON_KEY` sudah diisi di file `.env` lokal dan di dashboard Vercel.
- Jalankan schema SQL di `supabase/schema.sql` untuk membuat tabel dan seed data.
