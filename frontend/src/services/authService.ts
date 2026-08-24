import type { LoginRequest, LoginResponse, MeResponse, RegisterRequest, User } from '../types/auth'

import api from './api'

export async function login(credentials: LoginRequest): Promise<LoginResponse> {
  const response = await api.post<LoginResponse>('/auth/login', credentials)

  return response.data
}

export async function register(data: RegisterRequest) {
  const response = await api.post('/auth/register', data)

  return response.data
}

export async function getMe(): Promise<User> {
  const response = await api.get<MeResponse>('/me')

  return response.data.user
}
