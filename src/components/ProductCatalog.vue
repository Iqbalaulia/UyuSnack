<template>
  <section id="menu" class="menu section">
    <div class="container">
      <h2 class="section-title">Menu Favorit Kami</h2>
      <p class="section-subtitle">Pilih camilan favoritmu dan pesan langsung dengan mudah.</p>

      <div class="menu__filters">
        <button
          v-for="category in categories"
          :key="category.id"
          class="menu__filter"
          :class="{ 'menu__filter--active': activeCategory === category.id }"
          @click="activeCategory = category.id"
        >
          {{ category.name }}
        </button>
      </div>

      <div class="menu__grid">
        <div v-for="product in filteredProducts" :key="product.id" class="product-card">
          <div class="product-card__image">
            <img :src="product.image" :alt="product.name" loading="lazy" />
            <span v-if="product.badge" class="product-card__badge">{{ product.badge }}</span>
          </div>
          <div class="product-card__body">
            <h3 class="product-card__name">{{ product.name }}</h3>
            <p class="product-card__desc">{{ product.description }}</p>
            <div class="product-card__footer">
              <span class="product-card__price">{{ formatPrice(product.price) }}</span>
              <a
                :href="getOrderLink(product)"
                target="_blank"
                rel="noopener noreferrer"
                class="product-card__btn"
              >
                Pesan
              </a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref, computed } from 'vue'
import { categories, products, formatPrice } from '../data/products.js'

const activeCategory = ref('all')

const filteredProducts = computed(() => {
  if (activeCategory.value === 'all') return products
  return products.filter((p) => p.category === activeCategory.value)
})

const getOrderLink = (product) => {
  const message = `Halo Uyu Snack, saya mau pesan ${product.name}. Apakah tersedia?`
  return `https://wa.me/6281234567890?text=${encodeURIComponent(message)}`
}
</script>

<style scoped>
.menu {
  background: var(--color-bg);
}

.menu__filters {
  display: flex;
  gap: 0.75rem;
  overflow-x: auto;
  padding-bottom: 1rem;
  margin-bottom: 1.5rem;
  scrollbar-width: none;
}

.menu__filters::-webkit-scrollbar {
  display: none;
}

.menu__filter {
  flex-shrink: 0;
  padding: 0.5rem 1.25rem;
  border-radius: 9999px;
  font-weight: 600;
  font-size: 0.9rem;
  background: var(--color-white);
  color: var(--color-text);
  border: 1px solid var(--color-border);
  transition: var(--transition);
}

.menu__filter--active {
  background: var(--color-primary);
  color: var(--color-white);
  border-color: var(--color-primary);
}

.menu__grid {
  display: grid;
  grid-template-columns: 1fr;
  gap: 1.25rem;
}

.product-card {
  background: var(--color-white);
  border-radius: var(--radius-md);
  overflow: hidden;
  box-shadow: var(--shadow);
  transition: var(--transition);
}

.product-card:hover {
  transform: translateY(-4px);
  box-shadow: var(--shadow-lg);
}

.product-card__image {
  position: relative;
  aspect-ratio: 4 / 3;
  overflow: hidden;
}

.product-card__image img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  transition: transform 0.5s ease;
}

.product-card:hover .product-card__image img {
  transform: scale(1.05);
}

.product-card__badge {
  position: absolute;
  top: 0.75rem;
  left: 0.75rem;
  background: var(--color-accent);
  color: var(--color-text);
  padding: 0.25rem 0.75rem;
  border-radius: 9999px;
  font-size: 0.75rem;
  font-weight: 800;
}

.product-card__body {
  padding: 1.25rem;
}

.product-card__name {
  font-size: 1.1rem;
  font-weight: 800;
  margin-bottom: 0.25rem;
}

.product-card__desc {
  font-size: 0.85rem;
  color: var(--color-text-light);
  margin-bottom: 1rem;
  line-height: 1.5;
}

.product-card__footer {
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.product-card__price {
  font-weight: 800;
  color: var(--color-primary-dark);
  font-size: 1rem;
}

.product-card__btn {
  background: var(--color-primary);
  color: var(--color-white);
  padding: 0.5rem 1rem;
  border-radius: 9999px;
  font-weight: 700;
  font-size: 0.85rem;
  transition: var(--transition);
}

.product-card__btn:hover {
  background: var(--color-primary-dark);
}

@media (min-width: 640px) {
  .menu__grid {
    grid-template-columns: repeat(2, 1fr);
  }
}

@media (min-width: 1024px) {
  .menu__grid {
    grid-template-columns: repeat(3, 1fr);
  }
}
</style>
