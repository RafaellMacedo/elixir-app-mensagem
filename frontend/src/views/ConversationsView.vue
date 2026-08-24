<script setup lang="ts">
import { nextTick, onBeforeUnmount, onMounted, ref } from 'vue'
import { useRouter } from 'vue-router'

import { disconnectSocket } from '../services/socketService'

import { useAuthStore } from '../stores/auth'
import { listConversations } from '../services/conversationService'
import { listMessages } from '../services/messageService'

import { joinConversation, leaveConversation, sendMessage } from '../services/channelService'

import type { RealtimeMessage } from '../services/channelService'

import type { Conversation } from '../types/conversation'
import type { Message } from '../types/message'

const authStore = useAuthStore()
const newMessage = ref('')

const router = useRouter()

const conversations = ref<Conversation[]>([])
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
    conversations.value = await listConversations()
  } catch (err) {
    console.error(err)

    error.value = 'Não foi possível carregar as conversas.'
  } finally {
    loadingConversations.value = false
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

  sendMessage(content)

  newMessage.value = ''
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
    <header class="header">
      <h1>Mensagem</h1>

      <div class="user-info">
        <span v-if="authStore.user">
          {{ authStore.user.name }}
        </span>

        <button @click="logout">Sair</button>
      </div>
    </header>

    <div class="layout">
      <aside class="sidebar">
        <h2>Conversas</h2>

        <p v-if="loadingConversations">Carregando...</p>

        <p v-else-if="conversations.length === 0">Nenhuma conversa encontrada.</p>

        <ul v-else class="conversation-list">
          <li
            v-for="conversation in conversations"
            :key="conversation.id"
            class="conversation-item"
            :class="{
              active: selectedConversation?.id === conversation.id,
            }"
            @click="selectConversation(conversation)"
          >
            <strong>
              {{
                conversation.contact?.name || conversation.name || `Conversa #${conversation.id}`
              }}
            </strong>

            <span v-if="conversation.contact">
              {{ conversation.contact.email }}
            </span>
          </li>
        </ul>
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

    <p v-if="error" class="error">
      {{ error }}
    </p>
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

.empty-chat {
  margin: auto;
  text-align: center;
  color: #777;
}

.error {
  padding: 12px 24px;
  color: #d32f2f;
}
</style>
