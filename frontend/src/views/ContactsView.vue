<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import type { User } from '../types/auth'
import {
  addContact,
  listAvailableUsers,
  listContacts,
  removeContact,
} from '../services/contactService'

const router = useRouter()

const contacts = ref<User[]>([])
const availableUsers = ref<User[]>([])

const loading = ref(true)
const error = ref('')
const addingContactId = ref<number | null>(null)
const removingContactId = ref<number | null>(null)

async function loadContacts() {
  loading.value = true
  error.value = ''

  try {
    const [contactsData, availableUsersData] = await Promise.all([
      listContacts(),
      listAvailableUsers(),
    ])

    contacts.value = contactsData
    availableUsers.value = availableUsersData
  } catch (err) {
    console.error(err)
    error.value = 'Não foi possível carregar os contatos.'
  } finally {
    loading.value = false
  }
}

async function handleAddContact(user: User) {
  addingContactId.value = user.id
  error.value = ''

  try {
    await addContact(user.id)

    contacts.value.push(user)

    availableUsers.value = availableUsers.value.filter(
      (availableUser) => availableUser.id !== user.id,
    )
  } catch (err) {
    console.error(err)
    error.value = 'Não foi possível adicionar o contato.'
  } finally {
    addingContactId.value = null
  }
}

async function handleRemoveContact(user: User) {
  removingContactId.value = user.id
  error.value = ''

  try {
    await removeContact(user.id)

    contacts.value = contacts.value.filter((contact) => contact.id !== user.id)

    availableUsers.value.push(user)
  } catch (err) {
    console.error(err)
    error.value = 'Não foi possível remover o contato.'
  } finally {
    removingContactId.value = null
  }
}

onMounted(() => {
  loadContacts()
})
</script>

<template>
  <main class="contacts">
    <div class="contacts-container">
      <header class="header">
        <div class="header-title">
          <button class="back-button" @click="router.push('/conversations')">← Conversas</button>

          <h1>Contatos</h1>
        </div>

        <button class="refresh-button" @click="loadContacts" :disabled="loading">
          {{ loading ? 'Carregando...' : 'Atualizar' }}
        </button>
      </header>

      <p v-if="error" class="error">
        {{ error }}
      </p>

      <section class="section">
        <h2>Meus contatos</h2>

        <p v-if="!loading && contacts.length === 0" class="empty">
          Você ainda não possui contatos.
        </p>

        <div v-else class="user-list">
          <div v-for="contact in contacts" :key="contact.id" class="user-item">
            <div class="user-info">
              <strong>{{ contact.name }}</strong>
              <span>{{ contact.email }}</span>
            </div>

            <button
              class="remove-button"
              :disabled="removingContactId === contact.id"
              @click="handleRemoveContact(contact)"
            >
              {{ removingContactId === contact.id ? 'Removendo...' : 'Remover' }}
            </button>
          </div>
        </div>
      </section>

      <section class="section">
        <h2>Adicionar contato</h2>

        <p v-if="!loading && availableUsers.length === 0" class="empty">
          Não existem usuários disponíveis para adicionar.
        </p>

        <div v-else class="user-list">
          <div v-for="user in availableUsers" :key="user.id" class="user-item">
            <div class="user-info">
              <strong>{{ user.name }}</strong>
              <span>{{ user.email }}</span>
            </div>

            <button
              class="add-button"
              :disabled="addingContactId === user.id"
              @click="handleAddContact(user)"
            >
              {{ addingContactId === user.id ? 'Adicionando...' : 'Adicionar' }}
            </button>
          </div>
        </div>
      </section>
    </div>
  </main>
</template>

<style scoped>
.contacts {
  min-height: 100vh;
  padding: 32px;
  box-sizing: border-box;
  background: #f5f7fb;
}

.contacts-container {
  max-width: 800px;
  margin: 0 auto;
}

.header {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-bottom: 24px;
}

.header-title {
  display: flex;
  align-items: center;
  gap: 16px;
}

.back-button {
  background: #607d8b;
  color: white;
}

h1 {
  margin: 0;
}

h2 {
  margin: 0 0 16px;
  font-size: 20px;
}

.section {
  margin-bottom: 32px;
  padding: 24px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.06);
}

.user-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.user-item {
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 16px;
  padding: 14px 16px;
  border: 1px solid #e1e5eb;
  border-radius: 8px;
}

.user-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.user-info span {
  color: #666;
  font-size: 14px;
}

button {
  border: 0;
  border-radius: 8px;
  padding: 9px 14px;
  color: white;
  cursor: pointer;
  font-size: 14px;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.add-button {
  background: #42b883;
}

.remove-button {
  background: #d32f2f;
}

.refresh-button {
  background: #607d8b;
}

.empty {
  margin: 0;
  color: #666;
}

.error {
  margin-bottom: 20px;
  color: #d32f2f;
}
</style>
