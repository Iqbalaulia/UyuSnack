<template>
  <div class="rich-editor">
    <div ref="editorRef" class="rich-editor__box"></div>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onBeforeUnmount, watch } from 'vue'
import Quill from 'quill'
import 'quill/dist/quill.snow.css'
import { supabase } from '../../lib/supabase'

const props = defineProps<{ modelValue: string; placeholder?: string }>()
const emit = defineEmits<{ (e: 'update:modelValue', value: string): void }>()

const editorRef = ref<HTMLDivElement | null>(null)
let quill: Quill | null = null

const uploadImage = async (file: File): Promise<string | null> => {
  const ext = file.name.split('.').pop() || 'png'
  const path = `uploads/${Date.now()}-${Math.random().toString(36).slice(2)}.${ext}`
  const { error } = await supabase.storage.from('blog-images').upload(path, file)
  if (error) {
    alert('Gagal upload gambar: ' + error.message)
    return null
  }
  const { data } = supabase.storage.from('blog-images').getPublicUrl(path)
  return data.publicUrl
}

const imageHandler = () => {
  const input = document.createElement('input')
  input.setAttribute('type', 'file')
  input.setAttribute('accept', 'image/*')
  input.click()
  input.onchange = async () => {
    const file = input.files?.[0]
    if (!file) return
    const url = await uploadImage(file)
    if (url && quill) {
      const range = quill.getSelection(true)
      quill.insertEmbed(range.index, 'image', url)
      quill.setSelection(range.index + 1)
    }
  }
}

onMounted(() => {
  if (!editorRef.value) return

  quill = new Quill(editorRef.value, {
    theme: 'snow',
    placeholder: props.placeholder || 'Tulis konten artikel di sini...',
    modules: {
      toolbar: {
        container: [
          [{ header: [1, 2, 3, false] }],
          ['bold', 'italic', 'underline', 'strike'],
          [{ list: 'ordered' }, { list: 'bullet' }],
          ['link', 'image'],
          ['clean'],
        ],
        handlers: { image: imageHandler },
      },
    },
  })

  if (props.modelValue) {
    quill.root.innerHTML = props.modelValue
  }

  quill.on('text-change', () => {
    emit('update:modelValue', quill!.root.innerHTML)
  })
})

onBeforeUnmount(() => {
  quill = null
})

watch(
  () => props.modelValue,
  (value) => {
    if (quill && value !== quill.root.innerHTML) {
      quill.root.innerHTML = value
    }
  }
)
</script>

<style scoped>
.rich-editor {
  border-radius: 8px;
  overflow: hidden;
  border: 1px solid var(--color-border);
  background: var(--color-white);
}
.rich-editor__box :deep(.ql-toolbar) {
  border: none;
  border-bottom: 1px solid var(--color-border);
}
.rich-editor__box :deep(.ql-container) {
  border: none;
  min-height: 200px;
  font-size: 0.95rem;
}
.rich-editor__box :deep(.ql-editor) {
  min-height: 200px;
  line-height: 1.7;
}
.rich-editor__box :deep(.ql-editor img) {
  max-width: 100%;
  border-radius: 8px;
  margin: 0.5rem 0;
}
</style>
