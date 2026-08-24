export interface Contact {
  id: number
  name: string
  email: string
}

export interface Conversation {
  id: number
  name: string | null
  type: 'private' | 'group'
  inserted_at: string
  updated_at: string
  contact: Contact | null
}

export interface ConversationsResponse {
  conversations: Conversation[]
}
