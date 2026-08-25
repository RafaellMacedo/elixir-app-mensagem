import api from './api'

import type { Conversation, ConversationsResponse } from '../types/conversation'

interface CreateConversationResponse {
  conversation: Conversation
}

export async function listConversations(): Promise<Conversation[]> {
  const response = await api.get<ConversationsResponse>('/conversations')

  return response.data.conversations
}

export async function createConversation(contactId: number): Promise<Conversation> {
  const response = await api.post<CreateConversationResponse>('/conversations', {
    contact_id: contactId,
  })

  return response.data.conversation
}
