import api from './api'

import type { Conversation, ConversationsResponse } from '../types/conversation'

export async function listConversations(): Promise<Conversation[]> {
  const response = await api.get<ConversationsResponse>('/conversations')

  return response.data.conversations
}
