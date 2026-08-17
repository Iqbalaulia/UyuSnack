<template>
  <section class="cta section">
    <div class="container">
      <div class="cta__box">
        <h2 class="cta__title">Yuk, Jajan Uyu Snack Sekarang!</h2>
        <p class="cta__desc">
          Jangan sampai kehabisan. Chat kami di Instagram atau WhatsApp untuk pemesanan cepat.
        </p>
        <div class="cta__actions">
          <a
            href="https://wa.me/6281216593329?text=Halo%20Uyu%20Snack,%20saya%20mau%20pesan"
            target="_blank"
            rel="noopener noreferrer"
            class="btn cta__btn cta__btn--whatsapp"
          >
            💬 Pesan via WhatsApp
          </a>
          <a
            href="https://www.instagram.com/uyu_snack/"
            target="_blank"
            rel="noopener noreferrer"
            class="btn cta__btn cta__btn--instagram"
          >
            📸 Lihat di Instagram
          </a>
        </div>
      </div>
    </div>
  </section>
</template>

<style scoped>
.cta {
  background: var(--color-white);
  padding-bottom: 2rem;
}

.cta__box {
  background: linear-gradient(135deg, var(--color-primary) 0%, var(--color-primary-dark) 100%);
  color: var(--color-white);
  padding: 2.5rem 1.5rem;
  border-radius: var(--radius-lg);
  text-align: center;
  box-shadow: var(--shadow-lg);
}

.cta__title {
  font-size: 1.75rem;
  font-weight: 900;
  margin-bottom: 0.75rem;
}

.cta__desc {
  font-size: 1rem;
  opacity: 0.95;
  margin-bottom: 1.5rem;
  max-width: 480px;
  margin-left: auto;
  margin-right: auto;
}

.cta__actions {
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  align-items: center;
}

.cta__btn {
  width: 100%;
  max-width: 280px;
}

.cta__btn--whatsapp {
  background: var(--color-white);
  color: var(--color-primary-dark);
}

.cta__btn--whatsapp:hover {
  background: var(--color-secondary);
}

.cta__btn--instagram {
  background: transparent;
  color: var(--color-white);
  border: 2px solid var(--color-white);
}

.cta__btn--instagram:hover {
  background: rgba(255, 255, 255, 0.15);
}

@media (min-width: 640px) {
  .cta__actions {
    flex-direction: row;
    justify-content: center;
  }

  .cta__btn {
    width: auto;
  }
}
</style>
