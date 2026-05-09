import { create } from 'zustand'

interface InputState {
  showing: boolean
  event: string | null
  title: string | null
  label: string | null
  type: string | null
  data: unknown
  options: Record<string, unknown>
}

const initialState: InputState = {
  showing: false,
  event: null,
  title: null,
  label: null,
  type: null,
  data: null,
  options: {},
}

export const useInputStore = create<InputState>()(() => ({ ...initialState }))

const reset = () => useInputStore.setState({ ...initialState })

export const inputHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_INPUT: (p) => useInputStore.setState({
    ...(p as Partial<InputState>),
    options: (p.options as Record<string, unknown>) ?? {},
    showing: true,
  }),
  CLOSE_INPUT: reset,
  CLOSE_UI: reset,
  RESET_UI: reset,
}
