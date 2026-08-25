import type { User } from './auth'

export interface Conversation {
  id: number
  name: string | null
  type: 'private' | 'group'
  inserted_at: string
  updated_at: string
  contact: User | null
}

export interface Contact {
  id: number
  name: string
  email: string
}

export interface ConversationsResponse {
  conversations: Conversation[]
}
