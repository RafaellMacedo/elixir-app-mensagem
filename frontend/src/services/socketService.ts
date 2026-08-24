import { Socket } from 'phoenix'

const SOCKET_URL = 'ws://localhost:4000/socket'

let socket: Socket | null = null

let onReconnect: (() => void) | null = null

export function setOnReconnect(callback: () => void) {
  onReconnect = callback
}

export function connectSocket(): Socket {
  if (socket) {
    return socket
  }

  const token = localStorage.getItem('@mensagem:token')

  if (!token) {
    throw new Error('JWT token not found')
  }

  socket = new Socket(SOCKET_URL, {
    params: {
      token,
    },
  })

  socket.onOpen(() => {
    console.log('WebSocket connected')

    if (onReconnect) {
      onReconnect()
    }
  })

  socket.onError((error: unknown) => {
    console.error('WebSocket error:', error)
  })

  socket.onClose((event: unknown) => {
    console.log('WebSocket disconnected:', event)
  })

  socket.connect()

  return socket
}

export function disconnectSocket() {
  if (!socket) {
    return
  }

  socket.disconnect()
  socket = null
}

export function getSocket(): Socket | null {
  return socket
}
