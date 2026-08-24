import { defineStore } from 'pinia'
import { computed, ref } from 'vue'

import { getMe, login as loginRequest } from '../services/authService'

import type { LoginRequest, User } from '../types/auth'

export const useAuthStore = defineStore('auth', () => {
  const token = ref<string | null>(localStorage.getItem('@mensagem:token'))

  const user = ref<User | null>(null)

  const isAuthenticated = computed(() => !!token.value)

  async function login(credentials: LoginRequest) {
    const response = await loginRequest(credentials)

    token.value = response.token
    user.value = response.user

    localStorage.setItem('@mensagem:token', response.token)
  }

  async function loadUser() {
    if (!token.value) {
      return
    }

    try {
      user.value = await getMe()
    } catch (error) {
      console.error('Unable to restore session', error)

      logout()
    }
  }

  function logout() {
    token.value = null
    user.value = null

    localStorage.removeItem('@mensagem:token')
  }

  return {
    token,
    user,
    isAuthenticated,
    login,
    loadUser,
    logout,
  }
})
