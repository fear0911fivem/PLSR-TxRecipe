import { create } from 'zustand'

interface ConfirmState {
  showing: boolean
  yes: string | null
  no: string | null
  data: unknown
  title: string | null
  description: string | null
  denyLabel: string | null
  acceptLabel: string | null
}

const initialState: ConfirmState = {
  showing: false,
  yes: null,
  no: null,
  data: null,
  title: null,
  description: null,
  denyLabel: null,
  acceptLabel: null,
}

export const useConfirmStore = create<ConfirmState>()(() => ({ ...initialState }))

const reset = () => useConfirmStore.setState({ ...initialState })

export const confirmHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_CONFIRM: (p) => useConfirmStore.setState({ ...(p as Partial<ConfirmState>), showing: true }),
  CLOSE_CONFIRM: reset,
  CLOSE_UI: reset,
  RESET_UI: reset,
}
