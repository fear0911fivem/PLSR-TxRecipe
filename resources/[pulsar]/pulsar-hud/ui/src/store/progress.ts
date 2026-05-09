import { create } from 'zustand'
import { nui } from '../nui'

interface ProgressState {
  showing: boolean
  label: string | null
  duration: number | null
  cancelled: boolean
  failed: boolean
  finished: boolean
  startTime: number | null
}

const initialState: ProgressState = {
  showing: false,
  label: null,
  duration: null,
  cancelled: false,
  failed: false,
  finished: false,
  startTime: null,
}

export const useProgressStore = create<ProgressState>()(() => ({ ...initialState }))

export const progressHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  START_PROGRESS: (p) => useProgressStore.setState({
    ...(p as Partial<ProgressState>),
    cancelled: false,
    failed: false,
    finished: false,
    showing: true,
    startTime: Date.now(),
  }),
  CANCEL_PROGRESS: () => useProgressStore.setState({ failed: false, finished: false, cancelled: true }),
  FAILED_PROGRESS: () => useProgressStore.setState({ cancelled: false, finished: false, failed: true }),
  FINISH_PROGRESS: () => {
    nui.send('Progress:Finish')
    useProgressStore.setState({ failed: false, finished: true })
  },
  HIDE_PROGRESS: () => useProgressStore.setState({ ...initialState, showing: false }),
}
