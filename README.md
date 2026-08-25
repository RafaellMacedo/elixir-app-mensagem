# Mensagem

Aplicação de mensagens em tempo real desenvolvida como parte de uma avaliação técnica.

O projeto foi construído com foco na implementação de uma aplicação completa, utilizando **Elixir e Phoenix no backend** e **Vue 3 + TypeScript no frontend**.

A aplicação permite que usuários se cadastrem, realizem login, adicionem contatos, iniciem conversas privadas, criem grupos e troquem mensagens em tempo real utilizando **Phoenix Channels e WebSockets**.

---

# Como executar

O projeto está estruturado como um monorepo contendo o backend Phoenix, o frontend Vue e a configuração do PostgreSQL através do Docker Compose.

## Pré-requisitos

Para executar o projeto é necessário ter instalado:

- Docker
- Docker Compose

Verifique a instalação:

```bash
docker --version
```

```bash
docker compose version
```

## Subindo os containers

Na raiz do projeto, execute:

```bash
docker compose up --build
```

Esse comando irá criar e iniciar os containers da aplicação:

- Backend Phoenix
- Frontend Vue 3
- PostgreSQL

Após a inicialização, os serviços estarão disponíveis em:

| Serviço     | Endereço                             |
| ----------- | ------------------------------------ |
| Frontend    | http://localhost:5173                |
| Backend API | http://localhost:4000                |
| PostgreSQL  | localhost:5432                       |
| WebSocket   | ws://localhost:4000/socket/websocket |

## Executando em segundo plano

Caso queira iniciar os containers em modo detached:

```bash
docker compose up -d --build
```

Para acompanhar os logs:

```bash
docker compose logs -f
```

## Parando os containers

Para parar os containers:

```bash
docker compose down
```

Caso seja necessário remover também os volumes:

```bash
docker compose down -v
```

> Atenção: o comando acima remove os dados persistidos do PostgreSQL.

## Executando migrations

Caso seja necessário executar as migrations manualmente:

```bash
docker compose exec backend mix ecto.migrate
```

## Acessando o container do backend

```bash
docker compose exec backend bash
```

Dentro do container, alguns comandos úteis são:

```bash
mix compile
```

```bash
mix ecto.migrate
```

```bash
mix phx.server
```

---

# Sobre o projeto

O **Mensagem** é uma aplicação de chat em tempo real que possui backend REST API, comunicação via WebSocket e interface web.

O projeto foi desenvolvido utilizando:

- Elixir
- Phoenix
- Ecto
- PostgreSQL
- Phoenix Channels
- WebSockets
- JWT
- Vue 3
- TypeScript
- Pinia
- Vue Router
- Docker

A arquitetura separa claramente o frontend e o backend, utilizando HTTP para operações REST e WebSockets para comunicação em tempo real.

---

# Funcionalidades

## Autenticação

- Cadastro de usuários
- Login
- Autenticação baseada em JWT
- Identificação do usuário autenticado
- Proteção das rotas da API
- Persistência do usuário autenticado no frontend
- Logout
- Proteção de rotas no Vue Router

---

## Contatos

O usuário pode gerenciar sua própria lista de contatos.

Funcionalidades implementadas:

- Listagem de contatos
- Listagem de usuários disponíveis
- Adição de contatos
- Remoção de contatos
- Validação para impedir operações indevidas sobre contatos de outros usuários

---

## Conversas privadas

O usuário pode iniciar uma conversa com um contato.

Funcionalidades:

- Criação de conversas privadas
- Busca de conversa existente entre dois usuários
- Reutilização da conversa caso ela já exista
- Associação dos participantes
- Listagem das conversas do usuário
- Consulta de conversa específica
- Histórico de mensagens
- Validação de participação na conversa

Quando um contato é selecionado no frontend, uma conversa privada pode ser criada automaticamente caso ainda não exista.

---

## Grupos

A aplicação permite a criação de grupos de conversa.

Funcionalidades:

- Criação de grupos
- Definição do nome do grupo
- Identificação do criador
- Adição de contatos como membros
- Validação dos participantes
- Listagem dos grupos do usuário
- Criação de uma conversa associada ao grupo
- Envio de mensagens para os participantes do grupo

As conversas privadas e as conversas em grupo são apresentadas juntas na lista principal de conversas.

---

## Mensagens

As mensagens são persistidas no PostgreSQL.

Funcionalidades:

- Envio de mensagens
- Persistência no banco de dados
- Histórico de mensagens
- Ordenação cronológica
- Identificação do remetente
- Validação do conteúdo
- Limite de tamanho da mensagem
- Associação da mensagem à conversa
- Associação da mensagem ao usuário remetente

O `sender_id` não é informado diretamente pelo cliente.

O backend identifica o usuário através do JWT.

Fluxo:

```text
JWT
 │
 ▼
Usuário autenticado
 │
 ▼
current_user_id
 │
 ▼
sender_id
```

Isso evita que um cliente envie mensagens em nome de outro usuário.

---

# Mensagens em tempo real

A comunicação em tempo real é implementada utilizando **Phoenix Channels e WebSockets**.

Cada conversa possui um tópico próprio.

Exemplo:

```text
conversation:1
conversation:2
conversation:3
```

Quando um usuário entra em uma conversa, o frontend realiza o join no channel correspondente.

```text
Frontend
   │
   │ join
   ▼
conversation:ID
   │
   ▼
ConversationChannel
```

O backend verifica se o usuário possui permissão para participar da conversa.

Caso não participe:

```json
{
  "reason": "unauthorized"
}
```

---

## Fluxo de envio de mensagens

Quando o usuário envia uma mensagem:

```text
Vue Frontend
      │
      │ WebSocket
      ▼
ConversationChannel
      │
      ▼
Conversations.send_message
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

A mensagem é persistida antes do broadcast.

Dessa forma, os usuários recebem a mensagem em tempo real e o histórico permanece disponível caso a página seja recarregada.

---

# Segurança e validações

Algumas regras foram implementadas no backend para garantir que os usuários só possam acessar recursos permitidos.

## JWT

As rotas protegidas exigem um token JWT válido.

Exemplo:

```http
Authorization: Bearer JWT
```

---

## WebSocket autenticado

A conexão WebSocket também utiliza autenticação JWT.

O token é enviado durante a conexão:

```text
ws://localhost:4000/socket/websocket?token=JWT&vsn=2.0.0
```

O `UserSocket` valida o token e identifica o usuário.

```text
WebSocket
    │
    ▼
UserSocket.connect/3
    │
    ▼
Validação JWT
    │
    ├── inválido → conexão recusada
    │
    └── válido
          │
          ▼
    current_user_id
```

---

## Participação em conversas

Um usuário não pode entrar em qualquer conversa.

Antes do join no Phoenix Channel, o backend verifica:

```text
conversation_id + user_id
```

Somente participantes da conversa podem entrar no channel.

---

## Conversas privadas

Para criar uma conversa privada, o usuário deve possuir o outro participante em sua lista de contatos.

Também foi implementada uma validação para impedir que mensagens sejam enviadas em uma conversa privada quando o vínculo de contato não existir mais.

---

# Arquitetura

A aplicação possui três componentes principais:

```text
                    ┌───────────────────┐
                    │   Vue 3 Frontend  │
                    │   TypeScript      │
                    └─────────┬─────────┘
                              │
                ┌─────────────┴─────────────┐
                │                           │
             HTTP REST                  WebSocket
                │                           │
                ▼                           ▼
        ┌───────────────────────────────────────┐
        │            Phoenix Backend            │
        │                                       │
        │  Controllers       Phoenix Channels   │
        │  Contexts          UserSocket         │
        │  Authentication    ConversationChannel│
        └───────────────────┬───────────────────┘
                            │
                            ▼
                     ┌─────────────┐
                     │ PostgreSQL  │
                     └─────────────┘
```

---

# Backend

O backend foi desenvolvido utilizando Phoenix.

A estrutura utiliza contexts para organizar as regras de negócio.

Principais módulos:

```text
Mensagem
│
├── Accounts
├── Auth
├── Contacts
├── Conversations
└── Groups
```

O contexto `Conversations` concentra regras relacionadas a:

- Criação de conversas privadas
- Busca de conversas existentes
- Validação de participantes
- Histórico de mensagens
- Envio de mensagens
- Validação de contatos em conversas privadas

---

# Frontend

O frontend foi desenvolvido utilizando:

- Vue 3
- TypeScript
- Vite
- Pinia
- Vue Router
- Axios
- Phoenix JavaScript Client

As principais telas implementadas são:

- Login
- Cadastro
- Conversas
- Contatos
- Grupos

---

## Fluxo de autenticação

```text
Login
  │
  ▼
POST /api/auth/login
  │
  ▼
JWT
  │
  ▼
Auth Store
  │
  ▼
Rotas protegidas
```

O Vue Router utiliza guards para impedir o acesso às páginas protegidas quando o usuário não está autenticado.

---

## Conversas

A tela principal apresenta:

- Lista de conversas privadas
- Lista de conversas em grupo
- Identificação do tipo de conversa
- Histórico de mensagens
- Identificação visual das mensagens enviadas pelo usuário
- Atualização automática ao receber mensagens em tempo real
- Scroll automático para novas mensagens

---

## Contatos

Na tela de contatos, o usuário pode:

- Visualizar seus contatos
- Adicionar novos contatos
- Remover contatos
- Retornar para a tela de conversas

Os contatos também podem ser utilizados para iniciar novas conversas privadas.

---

## Grupos

A tela de grupos permite:

- Criar um grupo
- Informar o nome do grupo
- Selecionar contatos participantes
- Visualizar os grupos criados
- Retornar para a lista de conversas

Após a criação, o grupo também aparece na lista principal de conversas.

---

# API REST

## Autenticação

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

---

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

### Usuário autenticado

```http
GET /api/me
Authorization: Bearer JWT
```

---

# Contatos

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

Exemplo:

```json
{
  "contact_id": 2
}
```

### Remover contato

```http
DELETE /api/contacts/:id
Authorization: Bearer JWT
```

---

# Conversas

### Listar conversas

```http
GET /api/conversations
Authorization: Bearer JWT
```

A resposta pode conter conversas privadas e conversas em grupo.

Exemplo:

```json
{
  "conversations": [
    {
      "id": 1,
      "name": null,
      "type": "private",
      "contact": {
        "id": 2,
        "name": "João",
        "email": "joao@email.com"
      }
    },
    {
      "id": 2,
      "name": "Grupo Teste",
      "type": "group",
      "contact": null
    }
  ]
}
```

---

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

---

### Consultar conversa

```http
GET /api/conversations/:id
Authorization: Bearer JWT
```

---

# Grupos

### Listar grupos

```http
GET /api/groups
Authorization: Bearer JWT
```

### Criar grupo

```http
POST /api/groups
Authorization: Bearer JWT
Content-Type: application/json
```

Exemplo:

```json
{
  "name": "Grupo Teste",
  "member_ids": [2, 3]
}
```

Os membros informados devem pertencer à lista de contatos do usuário criador.

---

# Mensagens

### Histórico de mensagens

```http
GET /api/conversations/:conversation_id/messages
Authorization: Bearer JWT
```

As mensagens são retornadas em ordem cronológica.

Exemplo:

```json
{
  "messages": [
    {
      "id": 1,
      "content": "Olá!",
      "conversation_id": 1,
      "sender_id": 1,
      "sender": {
        "id": 1,
        "name": "Rafael",
        "email": "rafael@email.com"
      },
      "inserted_at": "2026-08-24T22:51:56Z"
    }
  ]
}
```

---

### Enviar mensagem via API

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

---

# WebSocket

A conexão WebSocket está disponível em:

```text
ws://localhost:4000/socket/websocket
```

Com autenticação:

```text
ws://localhost:4000/socket/websocket?token=JWT&vsn=2.0.0
```

Cada conversa possui seu próprio tópico:

```text
conversation:1
conversation:2
conversation:3
```

Após entrar no tópico da conversa, o cliente pode enviar:

```json
{
  "content": "Olá!"
}
```

O backend:

1. Identifica o usuário através do JWT.
2. Obtém a conversa através do socket.
3. Valida a participação do usuário.
4. Valida as regras de envio.
5. Persiste a mensagem no PostgreSQL.
6. Carrega os dados do remetente.
7. Realiza o broadcast para os participantes.

---

# Estrutura do projeto

```text
.
├── backend/
│   ├── lib/
│   │   ├── mensagem/
│   │   │   ├── auth/
│   │   │   ├── accounts.ex
│   │   │   ├── contact.ex
│   │   │   ├── contacts.ex
│   │   │   ├── conversation.ex
│   │   │   ├── conversation_participant.ex
│   │   │   ├── conversations.ex
│   │   │   ├── group.ex
│   │   │   ├── group_member.ex
│   │   │   ├── groups.ex
│   │   │   ├── message.ex
│   │   │   └── user.ex
│   │   │
│   │   └── mensagem_web/
│   │       ├── channels/
│   │       │   ├── conversation_channel.ex
│   │       │   └── user_socket.ex
│   │       │
│   │       ├── controllers/
│   │       │   ├── auth_controller.ex
│   │       │   ├── contact_controller.ex
│   │       │   ├── conversation_controller.ex
│   │       │   ├── group_controller.ex
│   │       │   └── message_controller.ex
│   │       │
│   │       ├── plugs/
│   │       │   └── auth_plug.ex
│   │       │
│   │       ├── endpoint.ex
│   │       └── router.ex
│   │
│   └── priv/
│       └── repo/
│           └── migrations/
│
├── frontend/
│   └── src/
│       ├── services/
│       ├── stores/
│       ├── types/
│       ├── views/
│       └── router/
│
└── docker-compose.yml
```

---

# Testes realizados

O projeto foi validado manualmente utilizando múltiplos usuários autenticados simultaneamente.

Foram realizados testes de:

- Cadastro de usuários
- Login com JWT
- Consulta do usuário autenticado
- Proteção de rotas
- Adição de contatos
- Remoção de contatos
- Criação de conversas privadas
- Reutilização de conversas existentes
- Criação de grupos
- Adição de participantes ao grupo
- Listagem de conversas privadas e grupos
- Histórico de mensagens
- Persistência no PostgreSQL
- Conexão WebSocket autenticada
- Join em conversas
- Validação de participação
- Envio de mensagens privadas
- Envio de mensagens em grupos
- Broadcast de mensagens
- Comunicação em tempo real entre dois usuários
- Atualização da interface após recebimento de mensagens
- Validação para impedir o envio em conversas privadas sem vínculo de contato

---

# Principais conceitos explorados

Durante o desenvolvimento deste projeto foram explorados conceitos importantes do ecossistema Elixir e Phoenix:

- Programação funcional
- Pattern Matching
- Imutabilidade
- Pipelines
- Tuples `{:ok, value}` e `{:error, reason}`
- Ecto Schemas
- Changesets
- Ecto Queries
- Transactions
- Phoenix Controllers
- Phoenix Contexts
- Plug
- JWT
- Phoenix Channels
- WebSockets
- Broadcast em tempo real
- Comunicação entre frontend e backend

No frontend:

- Composition API
- TypeScript
- Pinia
- Vue Router
- Navigation Guards
- Axios
- WebSockets
- Gerenciamento de estado
- Comunicação REST API

---

# Status do projeto

O projeto possui uma primeira versão funcional da aplicação de mensagens.

### Backend

- [x] Autenticação JWT
- [x] Usuários
- [x] Contatos
- [x] Conversas privadas
- [x] Grupos
- [x] Persistência de mensagens
- [x] Histórico de mensagens
- [x] Phoenix Channels
- [x] WebSocket autenticado
- [x] Mensagens em tempo real
- [x] Validações de acesso

### Frontend

- [x] Vue 3
- [x] TypeScript
- [x] Login
- [x] Cadastro
- [x] Autenticação
- [x] Proteção de rotas
- [x] Contatos
- [x] Grupos
- [x] Lista de conversas
- [x] Conversas privadas
- [x] Conversas em grupo
- [x] Histórico de mensagens
- [x] Envio de mensagens
- [x] Recebimento de mensagens em tempo real
- [x] Logout

---

# Autor

**Rafael Macedo**

Projeto desenvolvido como parte de uma avaliação técnica, com o objetivo de demonstrar conhecimentos em:

**Elixir • Phoenix • PostgreSQL • REST API • Phoenix Channels • WebSockets • Vue 3 • TypeScript • Docker**
