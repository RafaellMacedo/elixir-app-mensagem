export interface Message {
  id: number
  inserted_at: string
  content: string
  conversation_id: number
  sender_id: number
}

export interface MessagesResponse {
  messages: Message[]
}
