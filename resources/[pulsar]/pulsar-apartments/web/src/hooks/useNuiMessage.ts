import { useEffect } from 'react';

export function useNuiMessage<T extends { action: string }>(
  action: string,
  handler: (data: T) => void
): void {
  useEffect(() => {
    const listener = (event: MessageEvent) => {
      if (event.data?.action === action) {
        handler(event.data as T);
      }
    };
    window.addEventListener('message', listener);
    return () => window.removeEventListener('message', listener);
  }, [action, handler]);
}
