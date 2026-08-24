export interface Conversation {
  id: number
  name: string | null
  type: 'private' | 'group'
  inserted_at: string
  updated_at: string
}

export interface ConversationsResponse {
  conversations: Conversation[]
}
