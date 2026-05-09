import { useEffect, useRef, useState } from 'react'
import { Transition, Box, Text } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import parse from 'html-react-parser'
import DOMPurify from 'dompurify'
import { rem } from '@mantine/core'
import { useNotificationsStore, HudNotification } from '../../store/notifications'
import { NOTIF_COLOR, NOTIF_TICK_MS } from '../../hudTheme'

function typeIcon(type?: string): IconProp {
  switch (type) {
    case 'success': return ['fas', 'circle-check']
    case 'warning': return ['fas', 'triangle-exclamation']
    case 'error':   return ['fas', 'circle-xmark']
    default:        return ['fas', 'circle-info']
  }
}

function sanitize(html: string) {
  return parse(DOMPurify.sanitize(html))
}

export default function NotificationCinematic({ notification }: { notification: HudNotification }) {
  const [visible, setVisible] = useState(false)
  const [timer, setTimer]     = useState(0)
  const intervalRef = useRef<ReturnType<typeof setInterval> | null>(null)

  useEffect(() => { setVisible(true) }, [])

  useEffect(() => {
    if (notification.hide) setVisible(false)
  }, [notification.hide])

  useEffect(() => {
    if (notification.duration <= 0) return
    intervalRef.current = setInterval(() => {
      setTimer((t) => t + NOTIF_TICK_MS)
    }, NOTIF_TICK_MS)
    return () => { if (intervalRef.current) clearInterval(intervalRef.current) }
  }, [notification.duration])

  useEffect(() => {
    if (notification.duration > 0 && timer >= notification.duration) {
      if (intervalRef.current) clearInterval(intervalRef.current)
      setTimeout(() => setVisible(false), 250)
    }
  }, [timer, notification.duration])

  const onHide = () => {
    useNotificationsStore.setState((s) => ({
      notifications: s.notifications.filter((n) => n._id !== notification._id),
    }))
  }

  const accentColor = NOTIF_COLOR[notification.type ?? 'info'] ?? NOTIF_COLOR.info
  const progressPct = notification.duration > 0
    ? 100 - (timer / notification.duration) * 100
    : 100

  const iconProp: IconProp = notification.icon
    ? notification.icon as unknown as IconProp
    : typeIcon(notification.type)

  return (
    <Transition mounted={visible} transition="slide-left" duration={300} onExited={onHide}>
      {(styles) => (
        <Box
          style={{
            ...styles,
            marginBottom: 6,
            overflow: 'hidden',
            background: 'rgba(14,14,18,0.95)',
          }}
        >
          <Box style={{ display: 'flex' }}>
            <Box
              style={{
                width: rem(40),
                flexShrink: 0,
                background: `${accentColor}22`,
                borderLeft: `3px solid ${accentColor}`,
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
              }}
            >
              <FontAwesomeIcon icon={iconProp} style={{ color: accentColor, fontSize: rem(16) }} />
            </Box>

            <Box style={{ flex: 1, padding: `${rem(8)} ${rem(12)}`, minWidth: 0 }}>
              <Text size="sm" style={{ lineHeight: 1.4, wordBreak: 'break-word' }}>
                {sanitize(notification.message)}
              </Text>
              <Box style={{ display: 'flex', alignItems: 'center', gap: rem(6), marginTop: rem(2) }}>
                {notification.duration <= 0 && (
                  <FontAwesomeIcon icon="thumbtack" style={{ color: 'rgba(255,255,255,0.3)', fontSize: rem(9) }} />
                )}
                <Text style={{ fontSize: rem(10), color: 'rgba(255,255,255,0.3)', letterSpacing: '0.04em' }}>
                  {new Date(notification.created).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                </Text>
              </Box>
            </Box>
          </Box>

          {notification.duration > 0 && (
            <Box style={{ height: rem(2), background: 'rgba(255,255,255,0.06)' }}>
              <Box
                style={{
                  height: '100%',
                  width: `${progressPct}%`,
                  background: accentColor,
                  transition: `width ${NOTIF_TICK_MS}ms linear`,
                }}
              />
            </Box>
          )}
        </Box>
      )}
    </Transition>
  )
}
