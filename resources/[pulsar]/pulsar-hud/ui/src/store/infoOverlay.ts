import { create } from 'zustand'

interface InfoOverlayState {
  showing: boolean
  info: Record<string, unknown>
}

export const useInfoOverlayStore = create<InfoOverlayState>()(() => ({
  showing: false,
  info: {},
}))

export const infoOverlayHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_INFO_OVERLAY: (p) => useInfoOverlayStore.setState({
    showing: true,
    info: p.info as Record<string, unknown>,
  }),
  CLOSE_INFO_OVERLAY: () => useInfoOverlayStore.setState({ showing: false }),
}
