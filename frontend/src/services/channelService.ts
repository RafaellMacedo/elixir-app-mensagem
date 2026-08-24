import type { Channel } from 'phoenix'

import { connectSocket } from './socketService'

export interface RealtimeMessage {
  id: number
  conversation_id: number
  sender_id: number
  content: string
  inserted_at: string
}

let channel: Channel | null = null

export function joinConversation(
  conversationId: number,
  onMessage: (message: RealtimeMessage) => void,
): Channel {
  const socket = connectSocket()

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
}

export function getConversationChannel(): Channel | null {
  return channel
}
