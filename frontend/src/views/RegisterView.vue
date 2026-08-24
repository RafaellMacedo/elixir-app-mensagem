```vue
<script setup lang="ts">
import { ref } from 'vue'
import { useRouter } from 'vue-router'

import { register } from '../services/authService'

const router = useRouter()

const name = ref('')
const email = ref('')
const password = ref('')
const passwordConfirmation = ref('')

const error = ref('')
const loading = ref(false)

async function handleRegister() {
  error.value = ''

  if (password.value !== passwordConfirmation.value) {
    error.value = 'As senhas não coincidem.'
    return
  }

  loading.value = true

  try {
    await register({
      name: name.value,
      email: email.value,
      password: password.value,
    })

    await router.push('/login')
  } catch (err) {
    console.error(err)

    error.value = 'Não foi possível criar a conta.'
  } finally {
    loading.value = false
  }
}
</script>

<template>
  <main class="register">
    <div class="register-card">
      <h1>Mensagem</h1>

      <p class="subtitle">Crie sua conta</p>

      <form @submit.prevent="handleRegister">
        <div class="field">
          <label for="name">Nome</label>

          <input id="name" v-model="name" type="text" autocomplete="name" required />
        </div>

        <div class="field">
          <label for="email">E-mail</label>

          <input id="email" v-model="email" type="email" autocomplete="email" required />
        </div>

        <div class="field">
          <label for="password">Senha</label>

          <input
            id="password"
            v-model="password"
            type="password"
            autocomplete="new-password"
            required
          />
        </div>

        <div class="field">
          <label for="password-confirmation">Confirmar senha</label>

          <input
            id="password-confirmation"
            v-model="passwordConfirmation"
            type="password"
            autocomplete="new-password"
            required
          />
        </div>

        <p v-if="error" class="error">
          {{ error }}
        </p>

        <button type="submit" :disabled="loading">
          {{ loading ? 'Criando conta...' : 'Criar conta' }}
        </button>
      </form>

      <button class="back-button" type="button" @click="router.push('/login')">
        Já tenho uma conta
      </button>
    </div>
  </main>
</template>

<style scoped>
.register {
  min-height: 100vh;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 24px;
  background: #f5f7fb;
}

.register-card {
  width: 100%;
  max-width: 400px;
  padding: 32px;
  background: white;
  border-radius: 12px;
  box-shadow: 0 8px 30px rgba(0, 0, 0, 0.08);
}

h1 {
  margin: 0;
  text-align: center;
}

.subtitle {
  margin: 8px 0 24px;
  text-align: center;
  color: #666;
}

.field {
  margin-bottom: 16px;
}

label {
  display: block;
  margin-bottom: 6px;
  font-weight: 600;
}

input {
  box-sizing: border-box;
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d5d9e0;
  border-radius: 8px;
  font-size: 16px;
}

button {
  width: 100%;
  padding: 11px;
  border: 0;
  border-radius: 8px;
  background: #42b883;
  color: white;
  font-size: 16px;
  cursor: pointer;
}

button:disabled {
  opacity: 0.6;
  cursor: not-allowed;
}

.error {
  margin-bottom: 16px;
  color: #d32f2f;
}

.back-button {
  margin-top: 12px;
  background: transparent;
  color: #42b883;
  border: 1px solid #42b883;
}
</style>
```
