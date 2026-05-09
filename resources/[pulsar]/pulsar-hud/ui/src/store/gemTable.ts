import { create } from 'zustand'

interface GemTableState {
  showing: boolean
  info: Record<string, unknown>
}

export const useGemTableStore = create<GemTableState>()(() => ({
  showing: false,
  info: {},
}))

export const gemTableHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_GEM_TABLE: (p) => useGemTableStore.setState({
    showing: true,
    info: p.info as Record<string, unknown>,
  }),
  CLOSE_GEM_TABLE: () => useGemTableStore.setState({ showing: false }),
}
