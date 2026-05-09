import { Box } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import { rem } from '@mantine/core'

interface Props {
  icon: string
  value: number
  max: number
  color: string
  flash?: boolean
  size?: number
}

export default function StatIcon({ icon, value, max, color, flash, size = 22 }: Props) {
  const pct   = Math.min(100, Math.max(0, (value / (max || 100)) * 100))
  const isLow = pct <= 25
  const fa    = icon as unknown as IconProp

  return (
    <Box style={{ position: 'relative', flexShrink: 0 }}>
      {/* Ghost — dim outline showing max */}
      <FontAwesomeIcon
        icon={fa}
        fixedWidth
        style={{
          fontSize: rem(size),
          color: `${color}90`,
          display: 'block',
        }}
      />
      {/* Fill — same icon, clipped from top so only bottom pct% is visible */}
      <FontAwesomeIcon
        icon={fa}
        fixedWidth
        style={{
          fontSize: rem(size),
          color,
          position: 'absolute',
          top: 0,
          left: 0,
          right: 0,
          bottom: 0,
          clipPath: `inset(${100 - pct}% 0 0 0)`,
          filter: isLow ? `drop-shadow(0 0 7px ${color})` : 'none',
          animation: isLow && flash ? 'hud-flash 1.4s ease-in-out infinite' : 'none',
          transition: 'clip-path 0.35s cubic-bezier(0.4, 0, 0.2, 1), filter 0.3s',
        }}
      />
    </Box>
  )
}
