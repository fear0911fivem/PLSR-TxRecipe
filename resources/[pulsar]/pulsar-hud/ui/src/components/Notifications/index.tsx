import { useMemo } from 'react'
import { Box, rem } from '@mantine/core'
import { useNotificationsStore } from '../../store/notifications'
import Notification from './Notification'
import { NOTIF_RIGHT, NOTIF_TOP, NOTIF_WIDTH } from '../../hudTheme'

export default function HudNotifications() {
  const notifications = useNotificationsStore((s) => s.notifications)

  const pers  = useMemo(() => notifications.filter((n) => n.duration <= 0), [notifications])
  const timed = useMemo(() => notifications.filter((n) => n.duration > 0),  [notifications])

  return (
    <Box
      style={{
        position: 'absolute',
        top: rem(NOTIF_TOP),
        right: rem(NOTIF_RIGHT),
        width: rem(NOTIF_WIDTH),
        padding: rem(10),
        pointerEvents: 'none',
        zIndex: 100,
      }}
    >
      {[...pers, ...timed]
        .sort((a, b) => b.created - a.created)
        .map((n) => <Notification key={n._id} notification={n} />)}
    </Box>
  )
}
