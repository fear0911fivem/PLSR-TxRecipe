import { create } from 'zustand'

interface ActionState {
  showing: boolean
  message: string | null
  buttons?: unknown[]
}

export const useActionStore = create<ActionState>()(() => ({
  showing: false,
  message: null,
}))

export interface ActionItem {
  id: string
  message: string
}

interface Action2State {
  actions: ActionItem[]
}

export const useAction2Store = create<Action2State>()(() => ({
  actions: [],
}))

export const actionHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_ACTION: (p) => useActionStore.setState({
    showing: true,
    message: p.message as string,
    buttons: p.buttons as unknown[],
  }),
  HIDE_ACTION: () => useActionStore.setState({ showing: false }),
  ADD_ACTION: (p) => useAction2Store.setState((s) => ({
    actions: [...s.actions, p as unknown as ActionItem],
  })),
  REMOVE_ACTION: (p) => useAction2Store.setState((s) => ({
    actions: s.actions.filter((a) => a.id !== (p.id as string)),
  })),
  REMOVE_ALL_ACTIONS: () => useAction2Store.setState({ actions: [] }),
}
