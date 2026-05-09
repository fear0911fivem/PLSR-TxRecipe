import { create } from 'zustand'

export interface InteractionItem {
  id: string
  label: string
  icon?: string
  data?: unknown
}

interface InteractionState {
  showing: boolean
  items: InteractionItem[]
  layer: number
}

export const useInteractionStore = create<InteractionState>()(() => ({
  showing: false,
  items: [],
  layer: 0,
}))

export const interactionHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_INTERACTION_MENU: (p) => {
    const d = p.toggle as boolean
    useInteractionStore.setState({ showing: d })
    if (!d) useInteractionStore.setState({ items: [], layer: 0 })
  },
  SET_INTERACTION_MENU_ITEMS: (p) =>
    useInteractionStore.setState({ items: (p.items as InteractionItem[]) ?? [] }),
  SET_INTERACTION_LAYER: (p) =>
    useInteractionStore.setState({ layer: (p.layer as number) ?? 0 }),
}
