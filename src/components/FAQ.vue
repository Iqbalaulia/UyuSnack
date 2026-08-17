<template>
  <section id="faq" class="faq section">
    <div class="container">
      <SectionReveal>
        <h2 class="section-title">Pertanyaan yang Sering Diajukan</h2>
        <p class="section-subtitle">Temukan jawaban seputar pemesanan dan produk Uyu Snack.</p>
      </SectionReveal>

      <div class="faq__list">
        <SectionReveal
          v-for="(item, index) in faqs"
          :key="index"
          :style="{ transitionDelay: `${index * 80}ms` }"
        >
          <div
            class="faq__item"
            :class="{ 'faq__item--open': openIndex === index }"
          >
          <button
            class="faq__question"
            @click="toggle(index)"
            :aria-expanded="openIndex === index"
          >
            <span>{{ item.question }}</span>
            <span class="faq__icon" :class="{ 'faq__icon--open': openIndex === index }">
              <ChevronIcon :size="20" />
            </span>
          </button>
          <transition name="faq">
            <div v-show="openIndex === index" class="faq__answer">
              <p>{{ item.answer }}</p>
            </div>
          </transition>
        </div>
        </SectionReveal>
      </div>
    </div>
  </section>
</template>

<script setup>
import { ref } from 'vue'
import ChevronIcon from './icons/ChevronIcon.vue'
import SectionReveal from './SectionReveal.vue'

const openIndex = ref(0)

const toggle = (index) => {
  openIndex.value = openIndex.value === index ? -1 : index
}

const faqs = [
  {
    question: 'Apakah produk Uyu Snack halal dan tanpa pengawet?',
    answer: 'Ya, semua produk kami dibuat dengan bahan halal dan tanpa bahan pengawet. Kami prioritaskan kesehatan dan keamanan konsumen.',
  },
  {
    question: 'Berapa lama produk bisa bertahan?',
    answer: 'Masa simpan bervariasi 3-5 hari tergantung jenis camilan. Setiap kemasan kami cantumkan tanggal produksi dan saran penyimpanan.',
  },
  {
    question: 'Bisa kirim ke luar kota?',
    answer: 'Belum bisa. Saat ini kami hanya mengakomodir wilayah jakarta saja.',
  },
  {
    question: 'Bisa pesan custom hampers?',
    answer: 'Belum bisa. Saat ini kami belum bisa custom hampers.',
  },
  {
    question: 'Bagaimana cara pembayarannya?',
    answer: 'Kami menerima transfer bank, e-wallet, QRIS dan COD untuk area tertentu. Detail rekening akan dikirim setelah pesanan dikonfirmasi.',
  },
]
</script>

<style scoped>
.faq {
  background: var(--color-white);
}

.faq__list {
  max-width: 720px;
  margin: 0 auto;
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
}

.faq__item {
  background: var(--color-bg);
  border-radius: var(--radius-md);
  overflow: hidden;
  border: 1px solid var(--color-border);
}

.faq__question {
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
  padding: 1rem 1.25rem;
  text-align: left;
  font-weight: 700;
  font-size: 0.95rem;
  color: var(--color-text);
}

.faq__icon {
  display: inline-flex;
  color: var(--color-primary);
  transition: transform 0.3s ease;
  flex-shrink: 0;
}

.faq__icon--open {
  transform: rotate(180deg);
}

.faq__answer {
  padding: 0 1.25rem 1.25rem;
  color: var(--color-text-light);
  font-size: 0.9rem;
  line-height: 1.6;
}

.faq-enter-active,
.faq-leave-active {
  transition: opacity 0.25s ease, max-height 0.25s ease;
}

.faq-enter-from,
.faq-leave-to {
  opacity: 0;
}
</style>
