import { createTheme } from '@mantine/core'

// change this to rebrand the whole hud
export const COLOR_PRIMARY = '#7c3aed'

// backgrounds
export const COLOR_BG_DARK         = '#131315f8'
export const COLOR_PANEL_BG        = 'rgba(8,8,12,0.95)'
export const COLOR_MODAL_OVERLAY   = 'rgba(0,0,0,0.55)'
export const COLOR_INFO_OVERLAY_BG = 'rgba(8,8,12,0.72)'

// borders / dividers
export const COLOR_PANEL_BORDER = 'rgba(255,255,255,0.07)'
export const COLOR_DIVIDER      = 'rgba(255,255,255,0.06)'
export const COLOR_DIVIDER_MID  = 'rgba(255,255,255,0.12)'

// inputs
export const COLOR_INPUT_BG     = 'rgba(255,255,255,0.04)'
export const COLOR_INPUT_BORDER = 'rgba(255,255,255,0.10)'
export const COLOR_DROPDOWN_BG  = '#0e0e14'

// state colors
export const COLOR_DEATH   = '#c0392b'
export const COLOR_SIGNAL  = '#40c057'
export const COLOR_SUCCESS = '#40c057'
export const COLOR_FAIL    = '#fa5252'

export const DROP_SHADOW        = 'drop-shadow(0 1px 4px rgba(0,0,0,0.85))'
export const DROP_SHADOW_STRONG = 'drop-shadow(0 1px 6px rgba(0,0,0,0.9))'

export const COLOR_BAR_BG   = 'rgba(255,255,255,0.08)'
export const COLOR_NOTIF_BG = 'rgba(14,14,18,0.95)'

export const NOTIF_COLOR: Record<string, string> = {
  success: '#40c057',
  warning: '#fd7e14',
  error:   '#fa5252',
  info:    '#339af0',
}

export const STATUS_COLORS: Record<string, string> = {
  health: '#fa5252',
  armor:  '#339af0',
}

// voip states: off, whisper, talk, shout, radio idle, radio talking
export const VOIP_COLOR_OFF           = 'rgba(255,255,255,0.18)'
export const VOIP_COLOR_WHISPER       = '#74c0fc'
export const VOIP_COLOR_TALK          = '#ffffff'
export const VOIP_COLOR_SHOUT         = '#fd7e14'
export const VOIP_COLOR_RADIO_IDLE    = 'rgba(255,255,255,0.35)'
export const VOIP_COLOR_RADIO_TALKING = '#339af0'

// vehicle
export const VEHICLE_FUEL_LOW_COLOR  = '#fa5252'
export const VEHICLE_FUEL_MID_COLOR  = '#fd7e14'
export const VEHICLE_FUEL_HIGH_COLOR = '#fd7e14'
export const VEHICLE_NOS_COLOR       = '#0078ec'
export const VEHICLE_CRUISE_COLOR    = '#7c3aed'

export const BUFF_BAR_COLOR   = '#7c3aed'
export const BUFF_CHIP_SIZE   = 30
export const BUFF_RING_STROKE = 2

export const OPACITY_DEAD_OVERLAY = 0.32

export const PROGRESS_TICK_COUNT   = 24
export const ARCADE_SCORE_FONT_SIZE = 24

export const INTERACTION_RADIUS    = 165
export const INTERACTION_ITEM_SIZE = 80
export const INTERACTION_DEAD_ZONE = 44

export const NOTIF_BORDER_WIDTH = 3
export const NOTIF_TICK_MS      = 100
export const NOTIF_RIGHT        = 0
export const NOTIF_TOP          = 0
export const NOTIF_WIDTH        = 400

export const PROGRESS_TICK_MS = 10

export const LIST_TOP   = 200
export const LIST_RIGHT = '15%'

export const PROGRESS_BOTTOM = 210

export const VEHICLE_CLUSTER_BOTTOM         = 6
export const VEHICLE_CLUSTER_BOTTOM_SHIFTED = 31

// brand[5] must match COLOR_PRIMARY
export const theme = createTheme({
  fontFamily: 'Rajdhani, sans-serif',
  headings: { fontFamily: 'Orbitron, sans-serif' },
  primaryColor: 'brand',
  defaultRadius: 0,
  colors: {
    brand: [
      '#f5f0ff', '#ede5ff', '#ddd0ff', '#c4a8ff',
      '#a78bfa', '#7c3aed', '#6d28d9', '#5b21b6',
      '#4c1d95', '#3b0764',
    ],
    dark: [
      '#C1C2C5', '#A6A7AB', '#909296', '#5c5f66',
      '#373A40', '#2C2E33', '#25262b', '#1A1B1E',
      '#141517', '#101113',
    ],
  },
})
