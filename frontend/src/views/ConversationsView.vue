<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import { disconnectSocket } from '../services/socketService'

import { useAuthStore } from '../stores/auth'
import { createConversation, listConversations } from '../services/conversationService'
import { listContacts } from '../services/contactService'
import { listMessages } from '../services/messageService'

import type { User } from '../types/auth'

import { joinConversation, leaveConversation, sendMessage } from '../services/channelService'

import type { RealtimeMessage } from '../services/channelService'

import type { Conversation } from '../types/conversation'
import type { Message } from '../types/message'

const authStore = useAuthStore()
const newMessage = ref('')

const router = useRouter()

const conversations = ref<Conversation[]>([])
const contacts = ref<User[]>([])

const selectedConversation = ref<Conversation | null>(null)
const messages = ref<Message[]>([])

const loadingConversations = ref(true)
const loadingMessages = ref(false)

const messagesContainer = ref<HTMLElement | null>(null)

const error = ref('')

async function loadConversations() {
  loadingConversations.value = true
  error.value = ''

  try {
    const [conversationsData, contactsData] = await Promise.all([
      listConversations(),
      listContacts(),
    ])

    conversations.value = conversationsData
    contacts.value = contactsData
  } catch (err) {
    console.error(err)

    error.value = 'Não foi possível carregar as conversas.'
  } finally {
    loadingConversations.value = false
  }
}

function getExistingConversation(contactId: number) {
  return conversations.value.find(
    (conversation) => conversation.type === 'private' && conversation.contact?.id === contactId,
  )
}

async function startConversation(contact: User) {
  error.value = ''

  try {
    const existingConversation = getExistingConversation(contact.id)

    if (existingConversation) {
      await selectConversation(existingConversation)
      return
    }

    const conversation = await createConversation(contact.id)

    conversations.value.unshift(conversation)

    await selectConversation(conversation)
  } catch (err) {
    console.error(err)

    error.value = 'Não foi possível iniciar a conversa.'
  }
}

async function selectConversation(conversation: Conversation) {
  selectedConversation.value = conversation

  messages.value = await listMessages(conversation.id)

  await nextTick()

  scrollToBottom()

  joinConversation(conversation.id, handleRealtimeMessage)
}

async function handleRealtimeMessage(message: RealtimeMessage) {
  messages.value.push(message)

  await nextTick()

  scrollToBottom()
}

function scrollToBottom() {
  if (!messagesContainer.value) {
    return
  }

  messagesContainer.value.scrollTop = messagesContainer.value.scrollHeight
}

async function logout() {
  authStore.logout()
  await router.push('/login')
}

function handleSendMessage() {
  const content = newMessage.value.trim()

  if (!content) {
    return
  }

  try {
    const push = sendMessage(content)

    push
      .receive('ok', () => {
        newMessage.value = ''
      })
      .receive('error', (response) => {
        console.error('Erro ao enviar mensagem:', response)

        if (response?.reason === 'not_a_contact') {
          error.value = 'Você não possui mais este contato.'
        } else {
          error.value = 'Não foi possível enviar a mensagem.'
        }
      })
      .receive('timeout', () => {
        error.value = 'Não foi possível enviar a mensagem.'
      })
  } catch (err) {
    console.error(err)
    error.value = 'Não foi possível enviar a mensagem.'
  }
}

onMounted(() => {
  loadConversations()
})

onBeforeUnmount(() => {
  leaveConversation()
  disconnectSocket()
})
</script>

<template>
  <main class="messenger">
    <div v-if="error" class="error-popup">
      <span>{{ error }}</span>

      <button class="error-close" @click="error = ''">×</button>
    </div>

    <header class="header">
      <h1>Mensagem</h1>

      <div class="user-info">
        <span v-if="authStore.user">
          {{ authStore.user.name }}
        </span>

        <button @click="router.push('/contacts')">Contatos</button>

        <button @click="router.push('/groups')">Grupos</button>

        <button @click="logout">Sair</button>
      </div>
    </header>

    <div class="layout">
      <aside class="sidebar">
        <h2>Conversas</h2>

        <p v-if="loadingConversations">Carregando...</p>

        <template v-else>
          <p v-if="conversations.length === 0 && contacts.length === 0">
            Nenhuma conversa encontrada.
          </p>

          <ul class="conversation-list">
            <li
              v-for="conversation in conversations"
              :key="`conversation-${conversation.id}`"
              class="conversation-item"
              :class="{
                active: selectedConversation?.id === conversation.id,
              }"
              @click="selectConversation(conversation)"
            >
              <div class="conversation-info">
                <span class="conversation-type">
                  {{ conversation.type === 'group' ? '👥 Grupo' : '👤 Conversa' }}
                </span>

                <strong>
                  {{
                    conversation.type === 'group' ? conversation.name : conversation.contact?.name
                  }}
                </strong>

                <span v-if="conversation.type === 'private' && conversation.contact">
                  {{ conversation.contact.email }}
                </span>
              </div>
            </li>

            <li
              v-for="contact in contacts.filter((contact) => !getExistingConversation(contact.id))"
              :key="`contact-${contact.id}`"
              class="conversation-item new-conversation"
              @click="startConversation(contact)"
            >
              <div class="conversation-info">
                <span class="conversation-type"> 👤 Novo contato </span>

                <strong>
                  {{ contact.name }}
                </strong>

                <span>
                  {{ contact.email }}
                </span>
              </div>
            </li>
          </ul>
        </template>
      </aside>

      <section class="chat">
        <template v-if="selectedConversation">
          <div class="chat-header">
            <h2>
              {{
                selectedConversation.contact?.name ||
                selectedConversation.name ||
                `Conversa #${selectedConversation.id}`
              }}
            </h2>
          </div>

          <div ref="messagesContainer" class="messages">
            <p v-if="loadingMessages">Carregando mensagens...</p>

            <p v-else-if="messages.length === 0">Nenhuma mensagem.</p>

            <div
              v-else
              v-for="message in messages"
              :key="message.id"
              class="message-wrapper"
              :class="{
                mine: message.sender_id === authStore.user?.id,
              }"
            >
              <div class="message">
                <strong
                  v-if="
                    selectedConversation.type === 'group' &&
                    message.sender_id !== authStore.user?.id
                  "
                  class="sender-name"
                >
                  {{ message.sender.name }}
                </strong>

                <p>{{ message.content }}</p>

                <small>
                  {{ new Date(message.inserted_at).toLocaleString() }}
                </small>
              </div>
            </div>
          </div>

          <div class="message-input">
            <input
              v-model="newMessage"
              type="text"
              placeholder="Digite uma mensagem..."
              @keyup.enter="handleSendMessage"
            />

            <button :disabled="!newMessage.trim()" @click="handleSendMessage">Enviar</button>
          </div>
        </template>

        <div v-else class="empty-chat">
          <h2>Selecione uma conversa</h2>

          <p>Escolha uma conversa para visualizar as mensagens.</p>
        </div>
      </section>
    </div>
  </main>
</template>

<style scoped>
.messenger {
  min-height: 100vh;
  background: #f5f7fb;
}

.header {
  height: 64px;
  padding: 0 24px;
  display: flex;
  align-items: center;
  justify-content: space-between;
  background: white;
  border-bottom: 1px solid #ddd;
  box-sizing: border-box;
}

.header h1 {
  margin: 0;
}

.user-info {
  display: flex;
  align-items: center;
  gap: 16px;
}

.user-info button {
  background: #42b883;
  color: white;
}

.user-info button:last-child {
  background: #d32f2f;
}

button {
  padding: 8px 16px;
  border: 0;
  border-radius: 6px;
  cursor: pointer;
}

.layout {
  height: calc(100vh - 64px);
  display: flex;
}

.sidebar {
  width: 300px;
  padding: 20px;
  background: white;
  border-right: 1px solid #ddd;
  box-sizing: border-box;
  overflow-y: auto;
}

.sidebar h2 {
  margin-top: 0;
}

.conversation-info {
  display: flex;
  flex-direction: column;
  gap: 4px;
}

.conversation-type {
  font-size: 12px;
  color: #888;
}

.conversation-list {
  list-style: none;
  padding: 0;
  margin: 0;
}

.conversation-item {
  display: flex;
  flex-direction: column;
  gap: 4px;
  padding: 14px;
  margin-bottom: 8px;
  border-radius: 8px;
  cursor: pointer;
}

.conversation-item:hover,
.conversation-item.active {
  background: #eef2f7;
}

.conversation-item span {
  font-size: 13px;
  color: #777;
}

.chat {
  flex: 1;
  display: flex;
  flex-direction: column;
}

.chat-header {
  padding: 20px;
  background: white;
  border-bottom: 1px solid #ddd;
}

.chat-header h2 {
  margin: 0;
}

.messages {
  flex: 1;
  padding: 24px;
  overflow-y: auto;
}

.message-wrapper {
  display: flex;
  margin-bottom: 12px;
}

.message-wrapper.mine {
  justify-content: flex-end;
}

.message {
  max-width: 65%;
  padding: 10px 14px;
  border-radius: 10px;
  background: white;
}

.message-wrapper.mine .message {
  background: #dcf8c6;
}

.message p {
  margin: 0 0 5px;
}

.sender-name {
  display: block;
  margin-bottom: 4px;
  font-size: 13px;
  color: #42b883;
}

.message small {
  font-size: 11px;
  color: #777;
}

.message-input {
  display: flex;
  gap: 10px;
  padding: 16px;
  background: white;
  border-top: 1px solid #ddd;
}

.message-input input {
  flex: 1;
  padding: 10px;
  border: 1px solid #ddd;
  border-radius: 6px;
}

.message-input button:disabled {
  opacity: 0.5;
  cursor: not-allowed;
}

.new-conversation {
  border: 1px dashed #42b883;
}

.new-conversation:hover {
  background: #f0faf6;
}

.empty-chat {
  margin: auto;
  text-align: center;
  color: #777;
}

.error-popup {
  position: fixed;
  top: 80px;
  right: 24px;
  z-index: 1000;

  display: flex;
  align-items: center;
  gap: 16px;

  max-width: 350px;
  padding: 14px 16px;

  background: #fff;
  color: #d32f2f;

  border-left: 4px solid #d32f2f;
  border-radius: 8px;

  box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
}

.error-close {
  padding: 0;
  background: transparent;
  color: #d32f2f;
  font-size: 20px;
  line-height: 1;
}

.error-close:hover {
  background: transparent;
}
</style>
