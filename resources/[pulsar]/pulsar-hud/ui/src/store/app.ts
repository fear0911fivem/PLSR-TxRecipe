import { create } from 'zustand'

interface AppState {
  hidden: boolean
  blindfolded: boolean
  persistent: Record<string, unknown>
  flashbanged: unknown
  sniper: boolean
  armed: boolean
  isDeathTexts: boolean
  isReleasing: boolean
  deathTime: number | false
  releaseTimer: number | false
  releaseType: unknown
  releaseKey: unknown
  helpKey: unknown
  medicalPrice: unknown
  settings: boolean
}

export const useAppStore = create<AppState>()(() => ({
  hidden: false,
  blindfolded: false,
  persistent: {},
  flashbanged: false,
  sniper: false,
  armed: false,
  isDeathTexts: false,
  isReleasing: false,
  deathTime: false,
  releaseTimer: false,
  releaseType: false,
  releaseKey: false,
  helpKey: false,
  medicalPrice: false,
  settings: false,
}))

export const appHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  APP_SHOW: () => useAppStore.setState({ hidden: false }),
  APP_HIDE: () => useAppStore.setState({ hidden: true }),
  DO_DEATH_TEXT: (p) => {
    const deathRaw  = p.deathTime as number | false
    const timerRaw  = p.timer    as number | false
    const nowMs     = Date.now()
    // Only treat as a live countdown if the target is meaningfully in the future (>2s)
    const deathMs   = (typeof deathRaw  === 'number' && deathRaw  * 1000 > nowMs + 2000) ? deathRaw  * 1000 : false
    const timerMs   = (typeof timerRaw  === 'number' && timerRaw  * 1000 > nowMs + 2000) ? timerRaw  * 1000 : false
    useAppStore.setState({
      isDeathTexts: true,
      isReleasing: false,
      deathTime: deathMs,
      releaseTimer: timerMs,
      releaseType: p.type,
      releaseKey: p.key,
      helpKey: p.f1Key,
      medicalPrice: p.medicalPrice,
    })
  },
  DO_DEATH_RELEASING: () => useAppStore.setState({ isReleasing: true }),
  HIDE_DEATH_TEXT: () => useAppStore.setState({
    isDeathTexts: false,
    isReleasing: false,
    deathTime: false,
    releaseTimer: false,
    releaseType: false,
    releaseKey: false,
    helpKey: false,
    medicalPrice: false,
  }),
  SHOW_SCOPE: () => useAppStore.setState({ sniper: true }),
  HIDE_SCOPE: () => useAppStore.setState({ sniper: false }),
  SET_BLINDFOLD: (p) => useAppStore.setState({ blindfolded: p.state as boolean }),
  SET_FLASHBANGED: (p) => useAppStore.setState({ flashbanged: p }),
  CLEAR_FLASHBANGED: () => useAppStore.setState({ flashbanged: false }),
  RESET_UI: () => useAppStore.setState({ settings: false }),
  ARMED: (p) => useAppStore.setState({ armed: p.state as boolean }),
}
