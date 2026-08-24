import type { LoginRequest, LoginResponse, MeResponse, User } from '../types/auth'
import api from './api'

export async function login(credentials: LoginRequest): Promise<LoginResponse> {
  const response = await api.post<LoginResponse>('/auth/login', credentials)

  return response.data
}

export async function getMe(): Promise<User> {
  const response = await api.get<MeResponse>('/me')

  return response.data.user
}
