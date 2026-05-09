import { Box } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import { rem } from '@mantine/core'

// 270° arc — 90° gap sits at the bottom of the circle
const ARC_FRAC = 0.75

export interface ArcGaugeProps {
  icon: string
  value: number
  max: number
  color: string
  flash?: boolean
  size?: number
}

export default function ArcGauge({ icon, value, max, color, flash, size = 44 }: ArcGaugeProps) {
  const stroke = size >= 40 ? 3 : 2.5
  const r      = (size - stroke * 2) / 2
  const cx     = size / 2
  const cy     = size / 2
  const circ   = 2 * Math.PI * r
  const arcLen = circ * ARC_FRAC
  const pct    = Math.min(1, Math.max(0, value / (max || 100)))
  const offset = arcLen * (1 - pct)
  const isLow  = pct <= 0.25
  const iconPx = Math.round(size * 0.30)

  return (
    <Box style={{ position: 'relative', width: size, height: size, flexShrink: 0 }}>
      <svg width={size} height={size} style={{ position: 'absolute', inset: 0, overflow: 'visible' }}>
        {/* Ghost — dim full arc */}
        <circle
          cx={cx} cy={cy} r={r}
          fill="none"
          stroke={`${color}dd`}
          strokeWidth={stroke}
          strokeDasharray={`${arcLen} ${circ}`}
          strokeLinecap="round"
          transform={`rotate(135 ${cx} ${cy})`}
        />
        {/* Fill arc */}
        <circle
          cx={cx} cy={cy} r={r}
          fill="none"
          stroke={color}
          strokeWidth={stroke}
          strokeDasharray={`${arcLen} ${circ}`}
          strokeDashoffset={offset}
          strokeLinecap="round"
          transform={`rotate(135 ${cx} ${cy})`}
          style={{
            transition: 'stroke-dashoffset 0.35s cubic-bezier(0.4,0,0.2,1)',
            filter: isLow ? `drop-shadow(0 0 5px ${color}99)` : 'none',
          }}
        />
      </svg>

      <Box style={{
        position: 'absolute', inset: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <FontAwesomeIcon
          icon={icon as unknown as IconProp}
          fixedWidth
          style={{
            fontSize: rem(iconPx),
            color: isLow ? color : `${color}dd`,
            transition: 'color 0.3s',
            animation: isLow && flash ? 'hud-flash 1.4s ease-in-out infinite' : 'none',
            transform: 'translateY(-1px)',
          }}
        />
      </Box>
    </Box>
  )
}
