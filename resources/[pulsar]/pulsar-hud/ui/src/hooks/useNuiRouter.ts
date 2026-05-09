import { useEffect } from 'react'
import { dispatch } from '../store/router'

export function useNuiRouter(): void {
  useEffect(() => {
    const handler = (event: MessageEvent<{ type?: string; data?: Record<string, unknown> }>) => {
      const { type, data } = event.data
      if (type != null) {
        dispatch(type, { ...(data ?? {}) })
      }
    }
    window.addEventListener('message', handler)
    return () => window.removeEventListener('message', handler)
  }, [])
}
