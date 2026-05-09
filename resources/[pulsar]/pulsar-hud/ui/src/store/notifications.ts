import { create } from 'zustand'

interface NotificationStyle {
  alert?: Record<string, string>
  progressBg?: Record<string, string>
  progress?: Record<string, string>
}

export interface HudNotification {
  _id: number | string
  created: number
  icon?: string
  message: string
  duration: number
  type?: 'success' | 'error' | 'info' | 'warning' | 'custom'
  style?: NotificationStyle | null
  hide?: boolean
}

interface NotificationsState {
  runningId: number
  notifications: HudNotification[]
}

export const useNotificationsStore = create<NotificationsState>()(() => ({
  runningId: 0,
  notifications: [],
}))

export const notificationHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  CLEAR_ALERTS: () => useNotificationsStore.setState({ runningId: 0, notifications: [] }),
  ADD_ALERT: (p) => {
    const notif = p.notification as Partial<HudNotification>
    useNotificationsStore.setState((s) => {
      const hasId = Boolean(notif._id)
      const exists = hasId && s.notifications.some((n) => n._id === notif._id)
      return {
        notifications: exists
          ? s.notifications.map((n) => (n._id === notif._id ? { ...n, ...notif } : n))
          : [
              ...s.notifications,
              { _id: s.runningId + 1, created: Date.now(), ...notif } as HudNotification,
            ],
        runningId: s.runningId + 1,
      }
    })
  },
  REMOVE_ALERT: (p) => useNotificationsStore.setState((s) => ({
    notifications: s.notifications.filter((n) => n._id !== (p.id as number | string)),
  })),
  HIDE_ALERT: (p) => useNotificationsStore.setState((s) => ({
    notifications: s.notifications.map((n) =>
      n._id === (p.id as number | string) ? { ...n, hide: true } : n,
    ),
  })),
}
