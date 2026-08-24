<script setup lang="ts">
import { useAuthStore } from '../stores/auth'

const authStore = useAuthStore()
</script>

<template>
  <main class="conversations">
    <header>
      <h1>Conversas</h1>

      <div v-if="authStore.user">
        <span>{{ authStore.user.name }}</span>

        <button @click="authStore.logout">Sair</button>
      </div>
    </header>

    <section>
      <p>Selecione uma conversa.</p>
    </section>
  </main>
</template>

<style scoped>
.conversations {
  min-height: 100vh;
  padding: 24px;
  background: #f5f7fb;
}

header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  padding-bottom: 24px;
  border-bottom: 1px solid #ddd;
}

header div {
  display: flex;
  align-items: center;
  gap: 16px;
}

button {
  padding: 8px 16px;
  border: 0;
  border-radius: 6px;
  cursor: pointer;
}

section {
  padding-top: 24px;
}
</style>
