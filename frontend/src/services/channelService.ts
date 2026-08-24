import type { Channel } from 'phoenix'

import { connectSocket, getSocket, setOnReconnect } from './socketService'

export interface RealtimeMessage {
  id: number
  conversation_id: number
  sender_id: number
  content: string
  inserted_at: string
}

let channel: Channel | null = null

let currentConversationId: number | null = null

let currentOnMessage: ((message: RealtimeMessage) => void) | null = null

let hasConnectedBefore = false

setOnReconnect(() => {
  if (!hasConnectedBefore) {
    hasConnectedBefore = true
    return
  }

  reconnectConversation()
})

function createConversationChannel(
  conversationId: number,
  onMessage: (message: RealtimeMessage) => void,
) {
  const socket = getSocket()

  if (!socket) {
    throw new Error('WebSocket is not connected')
  }

  if (channel) {
    channel.leave()
    channel = null
  }

  channel = socket.channel(`conversation:${conversationId}`, {})

  channel.on('message', (message) => {
    console.log('Message received:', message)

    onMessage(message as RealtimeMessage)
  })

  channel
    .join()
    .receive('ok', (response) => {
      console.log(`Joined conversation:${conversationId}`, response)
    })
    .receive('error', (response) => {
      console.error(`Failed to join conversation:${conversationId}`, response)
    })
    .receive('timeout', () => {
      console.error(`Timeout joining conversation:${conversationId}`)
    })

  return channel
}

export function joinConversation(
  conversationId: number,
  onMessage: (message: RealtimeMessage) => void,
): Channel {
  connectSocket()

  currentConversationId = conversationId
  currentOnMessage = onMessage

  return createConversationChannel(conversationId, onMessage)
}

export function reconnectConversation() {
  if (!currentConversationId || !currentOnMessage) {
    return
  }

  console.log(`Rejoining conversation:${currentConversationId}`)

  createConversationChannel(currentConversationId, currentOnMessage)
}

export function sendMessage(content: string) {
  if (!channel) {
    throw new Error('Conversation channel is not connected')
  }

  channel.push('message', {
    content,
  })
}

export function leaveConversation() {
  if (!channel) {
    return
  }

  channel.leave()
  channel = null

  currentConversationId = null
  currentOnMessage = null
}

export function getConversationChannel(): Channel | null {
  return channel
}
