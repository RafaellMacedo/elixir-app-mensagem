import api from './api'

import type { Message, MessagesResponse } from '../types/message'

export async function listMessages(conversationId: number): Promise<Message[]> {
  const response = await api.get<MessagesResponse>(`/conversations/${conversationId}/messages`)

  return response.data.messages
}
