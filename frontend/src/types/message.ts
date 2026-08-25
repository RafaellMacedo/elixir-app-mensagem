import type { User } from './auth'

export interface Message {
  id: number
  inserted_at: string
  content: string
  conversation_id: number
  sender_id: number
  sender: User
}

export interface MessagesResponse {
  messages: Message[]
}
