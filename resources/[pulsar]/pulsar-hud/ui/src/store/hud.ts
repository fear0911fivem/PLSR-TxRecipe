import { create } from 'zustand'

export interface HudConfig {
  layout: 'minimap' | 'center'
  statusType: 'icons' | 'radial' | 'circles'
  buffsAnchor: string
  buffsAnchor2: boolean

  hideCrossStreet: boolean
  hideCompassBg: boolean
  largeBars: boolean
  minimapAnchor: boolean
  transparentBg: boolean
  vehicle: 'default' | 'digital'
  maskRadio: boolean
  condenseAlignment: 'left' | 'right'
  circleNumbers: boolean
  progressStyle: 'ticks' | 'minimal'
}

export interface HudPosition {
  Y?: number
  width?: number
  topY?: number
  X?: number
  height?: number
  leftX?: number
  bottomY?: number
  rightX?: number
}

interface HudState {
  showing: boolean
  voip: number
  voipIcon: string
  talking: number
  settings: boolean
  config: HudConfig
  position: HudPosition
}

const defaultConfig: HudConfig = {
  layout: 'minimap',
  statusType: 'icons',
  buffsAnchor: 'compass',
  buffsAnchor2: true,

  hideCrossStreet: false,
  hideCompassBg: true,
  largeBars: false,
  minimapAnchor: true,
  transparentBg: false,
  vehicle: 'default',
  maskRadio: false,
  condenseAlignment: 'left',
  circleNumbers: false,
  progressStyle: 'ticks',
}

export const useHudStore = create<HudState>()(() => ({
  showing: false,
  voip: 0,
  voipIcon: 'microphone',
  talking: 0,
  settings: false,
  config: defaultConfig,
  position: {},
}))

export const hudHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_HUD: () => useHudStore.setState({ showing: true }),
  HIDE_HUD: () => useHudStore.setState({ showing: false }),
  TOGGLE_HUD: () => useHudStore.setState((s) => ({ showing: !s.showing })),
  SET_CONFIG: (p) => useHudStore.setState({ config: { ...defaultConfig, ...(p.config as HudConfig ?? {}) } }),
  UPDATE_MM_POS: (p) => useHudStore.setState({ position: p.position as HudPosition }),
  SHIFT_LOCATION: (p) => useHudStore.setState({ position: p.position as HudPosition }),
  SET_VOIP_LEVEL: (p) => useHudStore.setState({
    voip: p.level as number,
    talking: p.talking as number,
    voipIcon: p.icon as string,
  }),
  TOGGLE_SETTINGS: (p) => useHudStore.setState({ settings: p.state as boolean }),
}
