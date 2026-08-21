# elixir-app-mensagem

Elixir 1.20 + Phoenix

chat-app/
│
├── backend/
│ ├── Phoenix API
│ ├── PostgreSQL
│ ├── JWT Authentication
│ ├── Phoenix Channels
│ │
│ ├── Users
│ ├── Contacts
│ ├── Conversations
│ ├── Groups
│ └── Messages
│
├── frontend/
│ ├── Vue 3
│ ├── TypeScript
│ ├── Pinia
│ ├── Vue Router
│ └── WebSocket
│
├── docker-compose.yml
└── README.md

Vue
│
│ WebSocket
▼
Phoenix Channel
│
├── Salva mensagem no PostgreSQL
│
└── Broadcast para participantes
│
▼
Vue atualiza a tela

Modelo do Banco

users
├── id
├── name
├── email
├── password_hash
├── inserted_at
└── updated_at

contacts
├── id
├── user_id
└── contact_id

conversations
├── id
├── type → private | group
├── name
├── creator_id
├── inserted_at
└── updated_at

conversation_members
├── id
├── conversation_id
└── user_id

messages
├── id
├── conversation_id
├── user_id
├── content
└── inserted_at

Rotas da API

Autenticação

POST /api/auth/register
POST /api/auth/login
GET /api/auth/me

Contatos

GET /api/contacts
POST /api/contacts
DELETE /api/contacts/:id

Conversas

GET /api/contacts
POST /api/contacts
DELETE /api/contacts/:id

Mensagems

Buscar os históricos

GET /api/conversations/:id/messages

Enviar/Receber mensagens pelo Phoenix Channel

conversation:{conversation_id}

# Dia 1 — Estrutura e autenticação

Instalar/configurar Elixir e Phoenix
Criar o monorepo
Criar backend
Configurar PostgreSQL
Criar User
Registro
Login
JWT
Usuário autenticado

# Dia 2 — Contatos e conversas

CRUD de contatos
Criar conversa privada
Criar grupos
Adicionar participantes
Listar conversas
Persistência de mensagens

# Dia 3 — Tempo real

Phoenix Channels
Entrar em uma conversa
Enviar mensagens
Broadcast
Atualização em tempo real

# Dia 4 — Frontend Vue

Setup Vue + TypeScript
Login
Layout baseado nas telas
Lista de conversas
Tela de chat
Integração REST

# Dia 5 — WebSocket e finalização

Conectar Vue ao Phoenix Channel
Atualização em tempo real
Testar fluxo completo
Docker
README
Revisão final
