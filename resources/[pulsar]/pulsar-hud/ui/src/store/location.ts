import { create } from 'zustand'

export interface Location {
  main: string
  cross: string
  area: string
  direction: string
}

interface LocationState {
  showing: boolean
  location: Location
  shifted: boolean
}

export const useLocationStore = create<LocationState>()(() => ({
  showing: true,
  location: { main: '', cross: '', area: '', direction: 'N' },
  shifted: false,
}))

export const locationHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  TOGGLE_LOC: (p) => useLocationStore.setState({ showing: p.state as boolean }),
  UPDATE_LOCATION: (p) => useLocationStore.setState({ location: p.location as Location }),
  SHIFT_LOCATION: (p) => useLocationStore.setState({ shifted: p.shift as boolean }),
}
