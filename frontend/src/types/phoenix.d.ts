declare module 'phoenix' {
  export interface SocketOptions {
    params?: Record<string, string>
  }

  export class Socket {
    constructor(endPoint: string, opts?: SocketOptions)

    connect(): void

    disconnect(code?: number, reason?: string): void

    onOpen(callback: () => void): void

    onError(callback: (error: unknown) => void): void

    onClose(callback: (event: unknown) => void): void

    channel(topic: string, params: Record<string, unknown>): Channel
  }

  export class Channel {
    join(): Push

    leave(): void

    on(event: string, callback: (payload: unknown) => void): number

    off(event: string, ref?: number): void

    push(event: string, payload: Record<string, unknown>): Push
  }

  export class Push {
    receive(status: string, callback: (response: unknown) => void): Push
  }
}
