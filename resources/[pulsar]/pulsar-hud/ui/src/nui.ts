const IS_DEV = import.meta.env.DEV

export const nui = {
  async send<T = unknown>(event: string, data: T = {} as T): Promise<void> {
    if (IS_DEV) {
      await new Promise<void>((resolve) => setTimeout(resolve, 100))
      return
    }
    await fetch(`https://pulsar-hud/${event}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json; charset=UTF-8' },
      body: JSON.stringify(data),
    })
  },

  emulate(type: string, data: unknown = null): void {
    window.dispatchEvent(new MessageEvent('message', { data: { type, data } }))
  },
}
