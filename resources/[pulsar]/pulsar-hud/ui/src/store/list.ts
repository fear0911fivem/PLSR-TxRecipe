import { create } from 'zustand'

export interface ListItemAction {
  icon: string
  event: string
}

export interface ListItem {
  label: string
  description?: string
  event?: string
  submenu?: string
  data?: unknown
  disabled?: boolean
  actions?: ListItemAction[]
}

export interface MenuHeaderAction {
  event: string
  icon: string
  data?: unknown
}

export interface Menu {
  label: string
  items: ListItem[]
  headerAction?: MenuHeaderAction
}

interface ListState {
  showing: boolean
  active: string
  menus: Record<string, Menu>
  stack: string[]
}

export const useListStore = create<ListState>()(() => ({
  showing: false,
  active: 'main',
  menus: {},
  stack: [],
}))

export const listHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SET_LIST_MENU: (p) => useListStore.setState({
    showing: true,
    active: 'main',
    menus: p.menus as Record<string, Menu>,
    stack: [],
  }),
  CHANGE_MENU: (p) => {
    const next = p.menu as string
    useListStore.setState((s) => {
      if (!s.menus[next] || next === s.active) return s
      return { active: next, stack: [...s.stack, s.active] }
    })
  },
  LIST_GO_BACK: () => useListStore.setState((s) => ({
    active: s.stack.length > 0 ? s.stack[s.stack.length - 1] : 'main',
    stack: s.stack.slice(0, -1),
  })),
  CLOSE_LIST_MENU: () => useListStore.setState({
    showing: false,
    active: 'main',
    menus: {},
    stack: [],
  }),
}
