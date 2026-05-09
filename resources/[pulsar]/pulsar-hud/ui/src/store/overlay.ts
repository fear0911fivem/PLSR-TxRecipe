import { create } from 'zustand'

interface OverlayState {
  showing: boolean
  data: Record<string, unknown>
}

export const useOverlayStore = create<OverlayState>()(() => ({
  showing: false,
  data: {},
}))

const hide = () => useOverlayStore.setState({ showing: false })

export const overlayHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_OVERLAY: (p) => useOverlayStore.setState({ showing: true, data: p }),
  HIDE_OVERLAY: hide,
  CLOSE_UI: hide,
  RESET_UI: hide,
}
