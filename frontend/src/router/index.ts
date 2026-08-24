import { createRouter, createWebHistory } from 'vue-router'

import { useAuthStore } from '../stores/auth'

import ContactsView from '../views/ContactsView.vue'
import ConversationsView from '../views/ConversationsView.vue'
import LoginView from '../views/LoginView.vue'
import RegisterView from '../views/RegisterView.vue'

const router = createRouter({
  history: createWebHistory(import.meta.env.BASE_URL),

  routes: [
    {
      path: '/login',
      name: 'login',
      component: LoginView,
    },

    {
      path: '/register',
      name: 'register',
      component: RegisterView,
    },

    {
      path: '/contacts',
      name: 'contacts',
      component: ContactsView,
      meta: {
        requiresAuth: true,
      },
    },

    {
      path: '/conversations',
      name: 'conversations',
      component: ConversationsView,
      meta: {
        requiresAuth: true,
      },
    },
  ],
})

router.beforeEach(async (to) => {
  const authStore = useAuthStore()

  if (authStore.token && !authStore.user) {
    await authStore.loadUser()
  }

  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    return {
      name: 'login',
    }
  }

  if (to.name === 'login' && authStore.isAuthenticated) {
    return {
      name: 'conversations',
    }
  }

  return true
})

export default router
