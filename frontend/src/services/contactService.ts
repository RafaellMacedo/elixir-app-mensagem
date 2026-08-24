import type { User } from '../types/auth'
import api from './api'

interface ContactsResponse {
  contacts: User[]
}

interface AvailableUsersResponse {
  users: User[]
}

interface ContactResponse {
  message: string
}

export async function listContacts(): Promise<User[]> {
  const response = await api.get<ContactsResponse>('/contacts')

  return response.data.contacts
}

export async function listAvailableUsers(): Promise<User[]> {
  const response = await api.get<AvailableUsersResponse>('/users/available')

  return response.data.users
}

export async function addContact(contactId: number): Promise<ContactResponse> {
  const response = await api.post<ContactResponse>('/contacts', {
    contact_id: contactId,
  })

  return response.data
}

export async function removeContact(contactId: number): Promise<ContactResponse> {
  const response = await api.delete<ContactResponse>(`/contacts/${contactId}`)

  return response.data
}
