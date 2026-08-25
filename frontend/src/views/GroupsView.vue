<script setup lang="ts">
import { onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import type { User } from '../types/auth'
import type { Group } from '../types/group'

import { listContacts } from '../services/contactService'
import { createGroup, listGroups } from '../services/groupService'

const router = useRouter()

const groups = ref<Group[]>([])
const contacts = ref<User[]>([])

const groupName = ref('')
const selectedMemberIds = ref<number[]>([])

const loading = ref(true)
const creating = ref(false)
const error = ref('')

async function loadData() {
  loading.value = true
  error.value = ''

  try {
    const [groupsData, contactsData] = await Promise.all([listGroups(), listContacts()])

    groups.value = groupsData
    contacts.value = contactsData
  } catch (err) {
    console.error(err)

    error.value = 'Não foi possível carregar os grupos e contatos.'
  } finally {
    loading.value = false
  }
}

function toggleMember(userId: number) {
  if (selectedMemberIds.value.includes(userId)) {
    selectedMemberIds.value = selectedMemberIds.value.filter((id) => id !== userId)
  } else {
    selectedMemberIds.value.push(userId)
  }
}

async function handleCreateGroup() {
  error.value = ''

  const name = groupName.value.trim()

  if (!name) {
    error.value = 'Informe o nome do grupo.'
    return
  }

  if (selectedMemberIds.value.length === 0) {
    error.value = 'Selecione pelo menos um contato.'
    return
  }

  creating.value = true

  try {
    await createGroup({
      name,
      member_ids: selectedMemberIds.value,
    })

    groupName.value = ''
    selectedMemberIds.value = []

    await loadData()
  } catch (err) {
    console.error(err)

    error.value = 'Não foi possível criar o grupo.'
  } finally {
    creating.value = false
  }
}

function getMemberNames(group: Group) {
  return group.members.map((member) => member.name).join(' • ')
}

onMounted(() => {
  loadData()
})
</script>

<template>
  <main class="groups">
    <div class="groups-container">
      <header class="header">
        <div class="header-title">
          <button class="back-button" @click="router.push('/conversations')">← Conversas</button>

          <h1>Grupos</h1>
        </div>

        <button class="refresh-button" :disabled="loading" @click="loadData">
          {{ loading ? 'Carregando...' : 'Atualizar' }}
        </button>
      </header>

      <p v-if="error" class="error">
        {{ error }}
      </p>

      <section class="section">
        <h2>Meus grupos</h2>

        <p v-if="!loading && groups.length === 0" class="empty">
          Você ainda não participa de nenhum grupo.
        </p>

        <div v-else class="group-list">
          <div v-for="group in groups" :key="group.id" class="group-item">
            <div class="group-info">
              <strong>{{ group.name }}</strong>

              <span>
                {{ group.members.length }}
                {{ group.members.length === 1 ? 'membro' : 'membros' }}
              </span>

              <small>
                {{ getMemberNames(group) }}
              </small>
            </div>
          </div>
        </div>
      </section>

      <section class="section">
        <h2>Criar grupo</h2>

        <form @submit.prevent="handleCreateGroup">
          <div class="field">
            <label for="group-name">Nome do grupo</label>

            <input
              id="group-name"
              v-model="groupName"
              type="text"
              maxlength="100"
              placeholder="Digite o nome do grupo"
              :disabled="creating"
            />
          </div>

          <div class="field">
            <label>Contatos</label>

            <p v-if="contacts.length === 0" class="empty">Você ainda não possui contatos.</p>

            <div v-else class="contact-list">
              <label v-for="contact in contacts" :key="contact.id" class="contact-item">
                <input
                  type="checkbox"
                  :checked="selectedMemberIds.includes(contact.id)"
                  :disabled="creating"
                  @change="toggleMember(contact.id)"
                />

                <div class="contact-info">
                  <strong>{{ contact.name }}</strong>
                  <span>{{ contact.email }}</span>
                </div>
              </label>
            </div>
          </div>

          <button type="submit" class="create-button" :disabled="creating || contacts.length === 0">
            {{ creating ? 'Criando...' : 'Criar grupo' }}
          </button>
        </form>
      </section>
    </div>
  </main>
</template>

<style scoped>
.groups {
  min-height: 100vh;
  padding: 32px;
  box-sizing: border-box;
  background: #f5f7fb;
}

.groups-container {
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

.header h1 {
  margin: 0;
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

.back-button {
  background: #607d8b;
}

.refresh-button {
  background: #607d8b;
}

.section {
  margin-bottom: 32px;
  padding: 24px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.06);
}

.section h2 {
  margin: 0 0 20px;
  font-size: 20px;
}

.group-list {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.group-item {
  padding: 16px;
  border: 1px solid #e1e5eb;
  border-radius: 8px;
}

.group-info {
  display: flex;
  flex-direction: column;
  gap: 5px;
}

.group-info span {
  color: #666;
  font-size: 14px;
}

.group-info small {
  color: #777;
  font-size: 13px;
}

.field {
  margin-bottom: 20px;
}

.field > label {
  display: block;
  margin-bottom: 8px;
  font-weight: 600;
}

.field input[type='text'] {
  box-sizing: border-box;
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d5d9e0;
  border-radius: 8px;
  font-size: 16px;
}

.contact-list {
  display: flex;
  flex-direction: column;
  gap: 10px;
}

.contact-item {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px;
  border: 1px solid #e1e5eb;
  border-radius: 8px;
  cursor: pointer;
}

.contact-item:hover {
  background: #f8fafc;
}

.contact-item input[type='checkbox'] {
  width: 18px;
  height: 18px;
}

.contact-info {
  display: flex;
  flex-direction: column;
  gap: 3px;
}

.contact-info span {
  color: #666;
  font-size: 13px;
}

.create-button {
  width: 100%;
  background: #42b883;
  font-size: 16px;
  padding: 11px;
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
