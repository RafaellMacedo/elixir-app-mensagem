# Mensagem

Backend de uma aplicação de mensagens em tempo real desenvolvido com **Elixir, Phoenix, Ecto e PostgreSQL**.

O projeto possui autenticação baseada em JWT, gerenciamento de contatos, conversas privadas, persistência de mensagens e comunicação em tempo real utilizando **Phoenix Channels e WebSockets**.

O frontend será desenvolvido posteriormente utilizando **Vue 3 + TypeScript**.

---

## Stack

- Elixir
- Phoenix
- Phoenix Channels
- Ecto
- PostgreSQL
- JWT
- Joken
- WebSockets
- Docker
- Vue 3 + TypeScript — frontend planejado

---

## Arquitetura

A aplicação possui duas formas principais de comunicação:

### REST API

```text
Cliente
   │
   │ HTTP + JSON
   ▼
Phoenix API
   │
   ├── Auth
   ├── Contacts
   ├── Conversations
   └── Messages
          │
          ▼
      PostgreSQL
```

### Comunicação em tempo real

```text
                    Phoenix
                       │
                  UserSocket
                       │
                   JWT Auth
                       │
              ConversationChannel
                       │
                 conversation:ID
                       │
          ┌────────────┴────────────┐
          │                         │
       Usuário A                Usuário B
       WebSocket                WebSocket
          │                         │
          └─────── broadcast ───────┘
```

---

## Funcionalidades implementadas

### Usuários

- Cadastro de usuários
- Login
- Identificação do usuário autenticado
- Autenticação baseada em JWT

### Contatos

- Listagem de contatos
- Adição de contatos
- Remoção de contatos

### Conversas privadas

- Criação de conversas privadas
- Validação de contato
- Associação de participantes
- Listagem das conversas do usuário
- Consulta de conversa específica
- Validação de participação na conversa

### Mensagens

- Criação de mensagens
- Persistência no PostgreSQL
- Associação da mensagem à conversa
- Associação da mensagem ao usuário remetente
- Histórico de mensagens
- Ordenação cronológica
- Validação do conteúdo da mensagem

### WebSocket

- `UserSocket` configurado
- Endpoint `/socket` registrado
- Autenticação JWT no WebSocket
- Identificação do usuário através do JWT
- `ConversationChannel` configurado
- Join de conversas
- Validação de participante no `join`
- Envio de mensagens em tempo real
- Persistência das mensagens recebidas via WebSocket
- Broadcast das mensagens para os participantes da conversa

---

# Autenticação

A autenticação utiliza **JWT** através da biblioteca Joken.

O token contém informações do usuário, incluindo:

```json
{
  "user_id": 1,
  "email": "rafael@email.com"
}
```

O mesmo mecanismo de autenticação é utilizado tanto pela API REST quanto pelo WebSocket.

---

# API REST

## Auth

### Registrar usuário

```http
POST /api/auth/register
Content-Type: application/json
```

Exemplo:

```json
{
  "name": "Rafael",
  "email": "rafael@email.com",
  "password": "123456"
}
```

### Login

```http
POST /api/auth/login
Content-Type: application/json
```

Exemplo:

```json
{
  "email": "rafael@email.com",
  "password": "123456"
}
```

Resposta:

```json
{
  "user": {
    "id": 1,
    "name": "Rafael",
    "email": "rafael@email.com"
  },
  "token": "JWT"
}
```

---

## Usuário autenticado

```http
GET /api/me
Authorization: Bearer JWT
```

---

## Contatos

### Listar contatos

```http
GET /api/contacts
Authorization: Bearer JWT
```

### Adicionar contato

```http
POST /api/contacts
Authorization: Bearer JWT
Content-Type: application/json
```

### Remover contato

```http
DELETE /api/contacts/:id
Authorization: Bearer JWT
```

---

## Conversas

### Listar conversas

```http
GET /api/conversations
Authorization: Bearer JWT
```

### Criar conversa privada

```http
POST /api/conversations
Authorization: Bearer JWT
Content-Type: application/json
```

Exemplo:

```json
{
  "contact_id": 2
}
```

### Consultar conversa

```http
GET /api/conversations/:id
Authorization: Bearer JWT
```

---

## Mensagens

### Histórico de mensagens

```http
GET /api/conversations/:conversation_id/messages
Authorization: Bearer JWT
```

As mensagens são retornadas em ordem cronológica.

### Enviar mensagem

```http
POST /api/conversations/:conversation_id/messages
Authorization: Bearer JWT
Content-Type: application/json
```

Exemplo:

```json
{
  "content": "Olá!"
}
```

O `sender_id` não é enviado pelo cliente.

Ele é obtido através do usuário autenticado:

```text
JWT
 ↓
current_user_id
 ↓
sender_id
```

Isso impede que um usuário tente enviar uma mensagem em nome de outro usuário.

---

# WebSocket

A comunicação em tempo real utiliza **Phoenix Channels**.

O socket está disponível através do endpoint:

```text
ws://localhost:4000/socket/websocket
```

O JWT é enviado como parâmetro:

```text
ws://localhost:4000/socket/websocket?token=JWT&vsn=2.0.0
```

---

## Autenticação do WebSocket

O `UserSocket` recebe o JWT e valida o token utilizando o mesmo mecanismo da API REST.

Fluxo:

```text
WebSocket
    │
    ▼
UserSocket.connect/3
    │
    ▼
Token.verify_and_validate/2
    │
    ├── inválido → conexão recusada
    │
    └── válido
          │
          ▼
    current_user_id
```

---

## Entrando em uma conversa

Cada conversa possui seu próprio tópico:

```text
conversation:1
conversation:2
conversation:3
```

Para entrar em uma conversa:

```json
["1", "1", "conversation:1", "phx_join", {}]
```

O servidor verifica se o usuário autenticado participa daquela conversa.

Se não participar:

```json
{
  "reason": "unauthorized"
}
```

Se participar, o usuário entra no channel.

---

## Enviando mensagens em tempo real

Depois de entrar no channel, o cliente pode enviar:

```json
[
  "1",
  "2",
  "conversation:1",
  "message",
  {
    "content": "Olá!"
  }
]
```

O servidor:

1. identifica o usuário através do JWT;
2. identifica a conversa através do channel;
3. valida a participação;
4. persiste a mensagem;
5. realiza o broadcast para os participantes.

Fluxo:

```text
Cliente
   │
   │ message
   ▼
ConversationChannel
   │
   ▼
Conversations.send_message/3
   │
   ▼
PostgreSQL
   │
   ▼
broadcast!
   │
   ├──────────────► Usuário A
   │
   └──────────────► Usuário B
```

---

# Segurança

Algumas decisões importantes da implementação:

### JWT

Todas as rotas protegidas exigem autenticação.

### WebSocket

O WebSocket também exige um JWT válido.

### Participação na conversa

Um usuário autenticado não pode entrar em qualquer conversa.

O `ConversationChannel` verifica:

```text
conversation_id + user_id
```

antes de permitir o `join`.

### Remetente da mensagem

O cliente não informa o `sender_id`.

O servidor utiliza:

```elixir
socket.assigns.current_user_id
```

Isso evita falsificação do remetente.

---

# Testes realizados

O backend foi validado manualmente utilizando a API REST e WebSocket.

Foram testados:

- Login com JWT
- Consulta de usuário autenticado
- Listagem de conversas
- Conexão WebSocket autenticada
- Join de conversa
- Validação de participante
- Envio de mensagem via WebSocket
- Persistência da mensagem
- Broadcast para outro usuário
- Comunicação bidirecional entre dois usuários

Exemplo validado:

```text
Rafael
   │
   │ "Olá João!"
   ▼
Phoenix
   │
   ├── PostgreSQL
   │
   └── broadcast
          │
          ▼
        João
```

João recebeu a mensagem em tempo real através do WebSocket.

---

# Como executar

O backend pode ser executado utilizando Docker ou diretamente no ambiente Elixir.

Para iniciar o servidor Phoenix:

```bash
mix phx.server
```

O servidor ficará disponível em:

```text
http://localhost:4000
```

WebSocket:

```text
ws://localhost:4000/socket/websocket
```

---

# Estrutura principal

```text
lib/
├── mensagem/
│   ├── auth/
│   │   └── token.ex
│   ├── accounts.ex
│   ├── contacts.ex
│   ├── contact.ex
│   ├── conversations.ex
│   ├── conversation.ex
│   ├── conversation_participant.ex
│   ├── message.ex
│   ├── user.ex
│   └── repo.ex
│
└── mensagem_web/
    ├── channels/
    │   ├── conversation_channel.ex
    │   └── user_socket.ex
    ├── controllers/
    │   ├── auth_controller.ex
    │   ├── contact_controller.ex
    │   ├── conversation_controller.ex
    │   └── message_controller.ex
    ├── plugs/
    │   └── auth_plug.ex
    ├── endpoint.ex
    └── router.ex
```

---

# Próximos passos

O backend principal está funcional.

As próximas etapas planejadas são:

- [ ] Criar frontend com Vue 3
- [ ] Configurar TypeScript
- [ ] Criar tela de login
- [ ] Integrar autenticação JWT
- [ ] Criar lista de conversas
- [ ] Criar tela de chat
- [ ] Integrar histórico de mensagens
- [ ] Integrar WebSocket
- [ ] Implementar envio de mensagens
- [ ] Implementar recebimento em tempo real
- [ ] Implementar logout
- [ ] Melhorar UX e tratamento de erros

---

# Status

**Backend:** concluído para a primeira versão do chat em tempo real.

**Frontend:** próximo passo — Vue 3 + TypeScript.

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

# 1. Usuários e contatos ← próxima etapa

Listar usuários disponíveis
Adicionar usuário aos contatos
Remover contato
Listar meus contatos
Garantir que um usuário só altere os próprios contatos

# 2. Conversas privadas

Criar/iniciar conversa com um contato
Persistir conversa
Persistir mensagens
Listar minhas conversas
Buscar histórico cronológico

# 3. Grupos

Criar grupo
Definir nome e criador
Adicionar contatos como membros
Listar grupos
Enviar mensagens no grupo
Histórico persistido

# 4. Tempo real

Aqui entra uma das partes mais interessantes do Phoenix:

Phoenix Channels / WebSockets
