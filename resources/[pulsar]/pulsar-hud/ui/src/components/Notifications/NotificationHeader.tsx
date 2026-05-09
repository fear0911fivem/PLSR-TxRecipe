import { useEffect, useRef, useState } from 'react'
import { Transition, Box, Text } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import parse from 'html-react-parser'
import DOMPurify from 'dompurify'
import { rem } from '@mantine/core'
import { useNotificationsStore, HudNotification } from '../../store/notifications'
import { NOTIF_COLOR, NOTIF_TICK_MS } from '../../hudTheme'

function typeLabel(type?: string) {
  switch (type) {
    case 'success': return 'SUCCESS'
    case 'warning': return 'WARNING'
    case 'error':   return 'ERROR'
    default:        return 'INFO'
  }
}

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

export default function Notification({ notification }: { notification: HudNotification }) {
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
            borderLeft: `3px solid ${accentColor}`,
            padding: `${rem(8)} ${rem(12)} ${rem(9)}`,
          }}
        >
          {/* Header row: icon + type label + timestamp */}
          <Box style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: rem(4) }}>
            <Box style={{ display: 'flex', alignItems: 'center', gap: rem(6) }}>
              <FontAwesomeIcon icon={iconProp} style={{ color: accentColor, fontSize: rem(11) }} />
              <Text
                style={{
                  fontSize: rem(11),
                  fontWeight: 700,
                  color: accentColor,
                  letterSpacing: '0.08em',
                  textTransform: 'uppercase',
                  lineHeight: 1,
                }}
              >
                {typeLabel(notification.type)}
              </Text>
              {notification.duration <= 0 && (
                <FontAwesomeIcon icon="thumbtack" style={{ color: 'rgba(255,255,255,0.25)', fontSize: rem(9) }} />
              )}
            </Box>
            <Text style={{ fontSize: rem(10), color: 'rgba(255,255,255,0.28)', letterSpacing: '0.03em' }}>
              {new Date(notification.created).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
            </Text>
          </Box>

          {/* Message */}
          <Text size="sm" style={{ lineHeight: 1.4, color: 'rgba(255,255,255,0.78)', wordBreak: 'break-word' }}>
            {sanitize(notification.message)}
          </Text>

          {/* Drain bar */}
          {notification.duration > 0 && (
            <Box style={{ height: rem(2), background: 'rgba(255,255,255,0.06)', marginTop: rem(8) }}>
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
