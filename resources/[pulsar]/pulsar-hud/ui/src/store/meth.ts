import { create } from 'zustand'

interface MethConfig {
  ingredients: number[]
  maxCookTime: number
}

interface MethState {
  showing: boolean
  config: MethConfig
}

const initialState: MethState = {
  showing: false,
  config: { ingredients: [], maxCookTime: 1 },
}

export const useMethStore = create<MethState>()(() => ({ ...initialState }))

const reset = () => useMethStore.setState({ ...initialState })

export const methHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  OPEN_METH: (p) => useMethStore.setState({ ...(p as Partial<MethState>), showing: true }),
  CLOSE_METH: reset,
  CLOSE_UI: reset,
  RESET_UI: reset,
}
