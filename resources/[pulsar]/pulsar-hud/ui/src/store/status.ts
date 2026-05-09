import { create } from 'zustand'

export interface Status {
  name: string
  max: number
  value: number | string
  icon: string
  color: string
  flash: boolean
  options: {
    hideZero?: boolean
    order?: number
    force?: string
  }
}

export interface BuffDef {
  icon: string
  duration: number
  type: 'permanent' | 'timed' | 'value'
  color?: string
  effect?: string
}

export interface Buff {
  buff: string
  override?: string
  val?: number
  startTime?: number
}

interface StatusState {
  health: number
  maxHealth: number
  armor: number
  isDead: boolean
  buffDefs: Record<string, BuffDef>
  buffs: Buff[]
  statuses: Status[]
}

const initialState: StatusState = {
  health: 100,
  maxHealth: 100,
  armor: 100,
  isDead: false,
  buffDefs: {},
  buffs: [],
  statuses: [],
}

export const useStatusStore = create<StatusState>()(() => ({ ...initialState }))

export const statusHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SET_DEAD: (p) => useStatusStore.setState({ isDead: p.state as boolean }),
  SHOW_HUD: (p) => useStatusStore.setState({
    health: p.hp as number,
    maxHealth: p.maxHp as number,
    armor: p.armor as number,
  }),
  UPDATE_HP: (p) => useStatusStore.setState({
    health: p.hp as number,
    maxHealth: p.maxHp as number,
    armor: p.armor as number,
  }),
  REGISTER_STATUS: (p) => useStatusStore.setState((s) => ({
    statuses: [...s.statuses, p.status as Status],
  })),
  RESET_STATUSES: () => useStatusStore.setState({ statuses: [] }),
  UPDATE_STATUS: (p) => useStatusStore.setState((s) => ({
    statuses: s.statuses.map((st) =>
      st.name === (p.status as Status).name ? { ...st, ...(p.status as Status) } : st,
    ),
  })),
  UPDATE_STATUS_VALUE: (p) => useStatusStore.setState((s) => ({
    statuses: s.statuses.map((st) =>
      st.name === (p.name as string) ? { ...st, value: p.value as number | string } : st,
    ),
  })),
  UPDATE_STATUSES: (p) => useStatusStore.setState({ statuses: p.statuses as Status[] }),
  REGISTER_BUFF: (p) => useStatusStore.setState((s) => ({
    buffDefs: { ...s.buffDefs, [p.id as string]: p.data as BuffDef },
  })),
  BUFF_APPLIED: (p) => useStatusStore.setState((s) => ({
    buffs: [...s.buffs, p.instance as Buff],
  })),
  BUFF_APPLIED_UNIQUE: (p) => {
    const instance = p.instance as Buff
    useStatusStore.setState((s) => {
      const exists = s.buffs.some((b) => b?.buff === instance?.buff)
      return {
        buffs: exists
          ? s.buffs.map((b) => (b?.buff === instance?.buff ? { ...instance } : b))
          : [...s.buffs, instance],
      }
    })
  },
  BUFF_UPDATED: (p) => useStatusStore.setState((s) => ({
    buffs: s.buffs.map((b) =>
      b?.buff === (p.buff as string)
        ? { ...b, val: p.val !== undefined ? (p.val as number) : b.val, override: (p.override as string) ?? b.override }
        : b,
    ),
  })),
  UPDATE_BUFF_ICON: () => {},
  REMOVE_BUFF_BY_TYPE: (p) => useStatusStore.setState((s) => ({
    buffs: s.buffs.filter((b) => b?.buff !== (p.type as string)),
  })),
  UI_RESET: () => useStatusStore.setState((s) => ({
    ...initialState,
    buffDefs: { ...s.buffDefs },
    buffs: [...s.buffs],
  })),
}
