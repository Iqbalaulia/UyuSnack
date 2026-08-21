<template>
  <!-- Login -->
  <div v-if="!session" class="admin-login">
    <form class="admin-card admin-login__card" @submit.prevent="login">
      <h1 class="admin-login__title">Admin Uyu Snack</h1>
      <input v-model="email" type="email" placeholder="Email" required class="admin-input" />
      <input v-model="password" type="password" placeholder="Password" required class="admin-input" />
      <p v-if="loginError" class="admin-error">{{ loginError }}</p>
      <button class="btn btn-primary" :disabled="loading">{{ loading ? '...' : 'Masuk' }}</button>
      <a href="#" class="admin-muted" @click.prevent="goHome">← Kembali ke landing page</a>
    </form>
  </div>

  <!-- Dashboard -->
  <div v-else class="admin-layout">
    <aside class="admin-sidebar">
      <div class="admin-sidebar__brand">Uyu Snack</div>
      <nav class="admin-sidebar__nav">
        <button
          v-for="m in menus"
          :key="m.id"
          class="admin-menu"
          :class="{ 'admin-menu--active': tab === m.id }"
          @click="tab = m.id"
        >
          <span class="admin-menu__icon">{{ m.icon }}</span>
          <span class="admin-menu__label">{{ m.label }}</span>
        </button>
      </nav>
      <div class="admin-sidebar__footer">
        <button class="admin-menu" @click="goHome">
          <span class="admin-menu__icon">🏠</span>
          <span class="admin-menu__label">Landing Page</span>
        </button>
        <button class="admin-menu" @click="logout">
          <span class="admin-menu__icon">🚪</span>
          <span class="admin-menu__label">Keluar</span>
        </button>
      </div>
    </aside>

    <main class="admin-main">
      <component :is="panels[tab]" />
    </main>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { supabase } from '../lib/supabase'
import AdminDashboard from '../components/admin/AdminDashboard.vue'
import AdminOrders from '../components/admin/AdminOrders.vue'
import AdminProducts from '../components/admin/AdminProducts.vue'
import AdminBatches from '../components/admin/AdminBatches.vue'
import AdminMaterials from '../components/admin/AdminMaterials.vue'
import AdminExpenses from '../components/admin/AdminExpenses.vue'
import AdminBlog from '../components/admin/AdminBlog.vue'
import AdminTestimonials from '../components/admin/AdminTestimonials.vue'
import AdminFunnel from '../components/admin/AdminFunnel.vue'
import AdminStock from '../components/admin/AdminStock.vue'

const session = ref<any>(null)
const email = ref('')
const password = ref('')
const loginError = ref('')
const loading = ref(false)
const tab = ref<string>('dashboard')

const menus = [
  { id: 'dashboard', label: 'Dashboard Laba', icon: '📊' },
  { id: 'funnel', label: 'Funnel Pengunjung', icon: '📉' },
  { id: 'orders', label: 'Orders', icon: '🧾' },
  { id: 'po', label: 'Open PO & Produk', icon: '📦' },
  { id: 'batches', label: 'Batch PO', icon: '🗓️' },
  { id: 'materials', label: 'Bahan Baku', icon: '🧪' },
  { id: 'stock', label: 'Stok Bahan', icon: '📦' },
  { id: 'expenses', label: 'Pengeluaran', icon: '💸' },
  { id: 'blog', label: 'Blog', icon: '📝' },
  { id: 'testimonials', label: 'Testimoni', icon: '💬' },
] as const

const panels: Record<string, any> = {
  dashboard: AdminDashboard,
  funnel: AdminFunnel,
  orders: AdminOrders,
  po: AdminProducts,
  batches: AdminBatches,
  materials: AdminMaterials,
  stock: AdminStock,
  expenses: AdminExpenses,
  blog: AdminBlog,
  testimonials: AdminTestimonials,
}

const login = async () => {
  loading.value = true
  loginError.value = ''
  const { error } = await supabase.auth.signInWithPassword({ email: email.value, password: password.value })
  if (error) loginError.value = error.message
  loading.value = false
}

const logout = () => supabase.auth.signOut()
const goHome = () => (window.location.hash = '')

onMounted(async () => {
  const { data } = await supabase.auth.getSession()
  session.value = data.session
  supabase.auth.onAuthStateChange((_e, s) => (session.value = s))
})
</script>

<style scoped>
.admin-login {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  background: var(--color-bg);
  padding: 1.5rem;
}
.admin-login__card {
  width: 100%;
  max-width: 360px;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.admin-login__title {
  font-size: 1.25rem;
  font-weight: 800;
}

.admin-layout {
  display: flex;
  min-height: 100vh;
  background: var(--color-bg);
}
.admin-sidebar {
  width: 230px;
  flex-shrink: 0;
  background: var(--color-white);
  border-right: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  position: sticky;
  top: 0;
  height: 100vh;
}
.admin-sidebar__brand {
  padding: 1.25rem;
  font-size: 1.15rem;
  font-weight: 800;
  color: var(--color-primary-dark);
  border-bottom: 1px solid var(--color-border);
}
.admin-sidebar__nav {
  flex: 1;
  padding: 0.75rem;
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}
.admin-sidebar__footer {
  padding: 0.75rem;
  border-top: 1px solid var(--color-border);
  display: flex;
  flex-direction: column;
  gap: 0.25rem;
}
.admin-menu {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  width: 100%;
  padding: 0.7rem 0.9rem;
  border-radius: 10px;
  font: inherit;
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--color-text-light);
  background: none;
  border: none;
  cursor: pointer;
  text-align: left;
}
.admin-menu:hover {
  background: var(--color-secondary);
  color: var(--color-text);
}
.admin-menu--active {
  background: var(--color-primary);
  color: var(--color-white);
}
.admin-main {
  flex: 1;
  padding: 1.5rem;
  min-width: 0;
}

@media (max-width: 768px) {
  .admin-layout {
    flex-direction: column;
  }
  .admin-sidebar {
    width: 100%;
    height: auto;
    position: static;
    flex-direction: row;
    align-items: center;
    overflow-x: auto;
  }
  .admin-sidebar__brand {
    border-bottom: none;
    padding: 0.75rem 1rem;
    white-space: nowrap;
  }
  .admin-sidebar__nav {
    flex-direction: row;
    padding: 0.5rem;
  }
  .admin-sidebar__footer {
    flex-direction: row;
    border-top: none;
    padding: 0.5rem;
  }
  .admin-menu {
    width: auto;
    white-space: nowrap;
  }
  .admin-menu__label {
    display: none;
  }
  .admin-menu__icon {
    font-size: 1.2rem;
  }
  .admin-main {
    padding: 1rem;
  }
}
</style>

<!-- Style global untuk komponen admin (di-share ke semua panel) -->
<style>
.admin-card {
  background: var(--color-white);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 1.25rem;
}
.admin-input {
  width: 100%;
  padding: 0.6rem 0.75rem;
  border: 1px solid var(--color-border);
  border-radius: 8px;
  font: inherit;
  background: var(--color-white);
}
.admin-input:focus {
  outline: 2px solid var(--color-primary);
  outline-offset: -1px;
}
.admin-error {
  color: #dc2626;
  font-size: 0.85rem;
}
.admin-muted {
  color: var(--color-text-light);
  font-size: 0.85rem;
}
.admin-page-head {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: space-between;
  gap: 0.75rem;
  margin-bottom: 1.25rem;
}
.admin-page-title {
  font-size: 1.35rem;
  font-weight: 800;
}
.admin-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.4rem;
  padding: 0.55rem 1rem;
  border-radius: 9999px;
  border: 1px solid var(--color-border);
  background: var(--color-white);
  font: inherit;
  font-size: 0.88rem;
  font-weight: 600;
  cursor: pointer;
  color: var(--color-text);
}
.admin-btn:hover {
  background: var(--color-secondary);
}
.admin-btn--primary {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: var(--color-white);
}
.admin-btn--primary:hover {
  background: var(--color-primary-dark);
}
.admin-btn--danger {
  color: #dc2626;
  border-color: #fecaca;
}
.admin-btn--danger:hover {
  background: #fef2f2;
}
.admin-btn--sm {
  padding: 0.35rem 0.75rem;
  font-size: 0.8rem;
}
.admin-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}
.admin-chip {
  padding: 0.45rem 0.9rem;
  border-radius: 9999px;
  border: 1px solid var(--color-border);
  background: var(--color-white);
  font: inherit;
  font-size: 0.85rem;
  font-weight: 600;
  cursor: pointer;
  color: var(--color-text);
}
.admin-chip--active {
  background: var(--color-primary);
  border-color: var(--color-primary);
  color: var(--color-white);
}
.admin-stats {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
  gap: 0.75rem;
  margin-bottom: 1.25rem;
}
.admin-stat {
  background: var(--color-white);
  border: 1px solid var(--color-border);
  border-radius: 12px;
  padding: 1rem;
}
.admin-stat__value {
  font-size: 1.4rem;
  font-weight: 800;
  color: var(--color-primary-dark);
}
.admin-stat__label {
  font-size: 0.8rem;
  color: var(--color-text-light);
}
.admin-table {
  width: 100%;
  border-collapse: collapse;
}
.admin-table th {
  text-align: left;
  font-size: 0.78rem;
  text-transform: uppercase;
  letter-spacing: 0.03em;
  color: var(--color-text-light);
  padding: 0.6rem 0.5rem;
  border-bottom: 1px solid var(--color-border);
}
.admin-table td {
  padding: 0.6rem 0.5rem;
  border-bottom: 1px solid var(--color-border);
  vertical-align: middle;
  font-size: 0.92rem;
}
.admin-thumb {
  width: 2.5rem;
  height: 2.5rem;
  object-fit: cover;
  border-radius: 8px;
}
.admin-row-inactive td {
  opacity: 0.5;
}
.admin-badge {
  display: inline-block;
  padding: 0.15rem 0.6rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 700;
}
.admin-badge--available { background: #d1fae5; color: #047857; }
.admin-badge--preorder { background: #fef3c7; color: #b45309; }
.admin-badge--soldout { background: #fee2e2; color: #b91c1c; }
.admin-badge--pending { background: #fef3c7; color: #b45309; }
.admin-badge--confirmed { background: #dbeafe; color: #1d4ed8; }
.admin-badge--processing { background: #e0e7ff; color: #4338ca; }
.admin-badge--shipped { background: #cffafe; color: #0e7490; }
.admin-badge--completed { background: #d1fae5; color: #047857; }
.admin-badge--cancelled { background: #fee2e2; color: #b91c1c; }

/* Modal */
.admin-modal-overlay {
  position: fixed;
  inset: 0;
  background: rgba(0, 0, 0, 0.45);
  z-index: 1100;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 1rem;
}
.admin-modal {
  background: var(--color-white);
  border-radius: 14px;
  padding: 1.5rem;
  width: 100%;
  max-width: 520px;
  max-height: 90vh;
  overflow-y: auto;
}
.admin-modal__title {
  font-size: 1.1rem;
  font-weight: 800;
  margin-bottom: 1rem;
}
.admin-form {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}
.admin-form label {
  font-size: 0.82rem;
  font-weight: 700;
  color: var(--color-text-light);
  display: block;
  margin-bottom: 0.25rem;
}
.admin-form__row {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 0.75rem;
}
.admin-form__actions {
  display: flex;
  justify-content: flex-end;
  gap: 0.5rem;
  margin-top: 0.5rem;
}
.admin-check {
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 0.9rem;
  font-weight: 600;
}
.admin-check input {
  width: 1.1rem;
  height: 1.1rem;
}
.admin-toast {
  position: fixed;
  bottom: 1.25rem;
  left: 50%;
  transform: translateX(-50%);
  background: var(--color-text);
  color: var(--color-white);
  padding: 0.6rem 1.25rem;
  border-radius: 9999px;
  font-size: 0.88rem;
  font-weight: 600;
  z-index: 1200;
}
.admin-toolbar {
  display: flex;
  flex-wrap: wrap;
  gap: 0.5rem;
  margin-bottom: 1rem;
  align-items: center;
}
.admin-toolbar .admin-input {
  width: auto;
  flex: 1;
  min-width: 180px;
}
.admin-empty {
  text-align: center;
  padding: 2.5rem 1rem;
  color: var(--color-text-light);
}
</style>
