import { Box, Text } from '@mantine/core'
import { rem } from '@mantine/core'
import { useLocationStore } from '../../store/location'
import { useHudStore } from '../../store/hud'
import { useAppStore } from '../../store/app'
import { useHudTheme } from '../../hooks/useHudTheme'
import { DROP_SHADOW_STRONG } from '../../hudTheme'

export default function Location() {
  const { primary } = useHudTheme()
  const config      = useHudStore((s) => s.config)
  const isShowing   = useLocationStore((s) => s.showing)
  const location    = useLocationStore((s) => s.location)
  const blindfolded = useAppStore((s) => s.blindfolded)

  if (!isShowing || blindfolded) return null

  return (
    <Box
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: rem(3),
        filter: DROP_SHADOW_STRONG,
      }}
    >
      {/* Direction */}
      <Text
        style={{
          fontSize: rem(30),
          fontWeight: 800,
          color: primary,
          lineHeight: 1,
          letterSpacing: '0.08em',
        }}
      >
        {location.direction}
      </Text>

      {/* Street name */}
      <Text
        style={{
          fontSize: rem(17),
          fontWeight: 600,
          color: 'rgba(255,255,255,0.9)',
          lineHeight: 1,
          whiteSpace: 'nowrap',
        }}
      >
        {location.main || '—'}
        {location.cross && !config.hideCrossStreet && (
          <Text span style={{ color: 'rgba(255,255,255,0.35)', fontWeight: 400 }}>
            {' '}×{' '}{location.cross}
          </Text>
        )}
      </Text>

      {/* Area */}
      <Text
        style={{
          fontSize: rem(13),
          fontWeight: 500,
          color: 'rgba(255,255,255,0.55)',
          lineHeight: 1,
          letterSpacing: '0.08em',
          textTransform: 'uppercase',
        }}
      >
        {location.area || '—'}
      </Text>
    </Box>
  )
}
