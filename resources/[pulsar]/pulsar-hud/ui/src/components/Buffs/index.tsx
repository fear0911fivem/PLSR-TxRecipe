import { useState, useEffect } from 'react'
import { Box } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import { Transition } from '@mantine/core'
import { rem } from '@mantine/core'
import { useStatusStore, Buff, BuffDef } from '../../store/status'
import { useHudStore } from '../../store/hud'
import { BUFF_BAR_COLOR, BUFF_CHIP_SIZE, BUFF_RING_STROKE, DROP_SHADOW, COLOR_BAR_BG } from '../../hudTheme'

interface ChipProps { buff: Buff; def: BuffDef }

// ── Icon-fill style (default) ─────────────────────────────────────────────────

function BuffChipIcons({ buff, def }: ChipProps) {
  const icon  = (buff.override || def.icon) as string
  const color = def.color ?? BUFF_BAR_COLOR

  const calcPct = () => {
    if (def.type === 'permanent') return 100
    if (def.type === 'timed' && buff.val && buff.startTime) {
      const elapsed = Date.now() / 1000 - buff.startTime
      return Math.max(0, (1 - elapsed / buff.val) * 100)
    }
    return buff.val ?? 100
  }

  const [barPct, setBarPct] = useState(calcPct)

  useEffect(() => {
    if (def.type !== 'timed' || !buff.val || !buff.startTime) {
      setBarPct(buff.val ?? 100)
      return
    }
    const id = setInterval(() => setBarPct(calcPct()), 500)
    return () => clearInterval(id)
  }, [buff.val, buff.startTime, def.type])

  return (
    <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(3), width: rem(26) }}>
      <FontAwesomeIcon
        icon={['fas', icon] as IconProp}
        style={{ fontSize: rem(22), color, width: rem(26), textAlign: 'center' }}
      />
      <Box style={{
        width: rem(26), height: rem(3), borderRadius: rem(1),
        background: COLOR_BAR_BG, overflow: 'hidden', flexShrink: 0,
      }}>
        <Box style={{
          height: '100%', width: `${barPct}%`,
          background: color, borderRadius: rem(1),
          transition: 'width 0.5s linear',
        }} />
      </Box>
    </Box>
  )
}

// ── Radial style — full 360° ring so buffs read differently from stat arcs ───

const RING_SIZE   = BUFF_CHIP_SIZE
const RING_STROKE = BUFF_RING_STROKE

function BuffRing({ buff, def }: ChipProps) {
  const icon    = (buff.override || def.icon) as string
  const barPct  = def.type === 'permanent' ? 100 : (buff.val ?? 100)
  const color   = def.color ?? BUFF_BAR_COLOR
  const r       = (RING_SIZE - RING_STROKE * 2) / 2
  const cx      = RING_SIZE / 2
  const cy      = RING_SIZE / 2
  const circ    = 2 * Math.PI * r
  const offset  = circ * (1 - barPct / 100)
  const iconPx  = Math.round(RING_SIZE * 0.32)

  return (
    <Box style={{ position: 'relative', width: RING_SIZE, height: RING_SIZE, flexShrink: 0 }}>
      <svg width={RING_SIZE} height={RING_SIZE} style={{ position: 'absolute', inset: 0 }}>
        {/* Ghost ring */}
        <circle
          cx={cx} cy={cy} r={r}
          fill="none"
          stroke={`${color}18`}
          strokeWidth={RING_STROKE}
        />
        {/* Fill ring — drains clockwise from top */}
        <circle
          cx={cx} cy={cy} r={r}
          fill="none"
          stroke={color}
          strokeWidth={RING_STROKE}
          strokeDasharray={circ}
          strokeDashoffset={offset}
          strokeLinecap="round"
          transform={`rotate(-90 ${cx} ${cy})`}
          style={{ transition: 'stroke-dashoffset 0.4s ease' }}
        />
      </svg>

      <Box style={{
        position: 'absolute', inset: 0,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
      }}>
        <FontAwesomeIcon
          icon={['fas', icon] as IconProp}
          fixedWidth
          style={{
            fontSize: rem(iconPx),
            color: `${color}cc`,
          }}
        />
      </Box>
    </Box>
  )
}

// ── Buffs container ───────────────────────────────────────────────────────────

export default function Buffs() {
  const buffDefs   = useStatusStore((s) => s.buffDefs)
  const buffs      = useStatusStore((s) => s.buffs)
  const statusType = useHudStore((s) => s.config.statusType)
  const valid      = buffs.filter((b) => b && buffDefs[b.buff])

  const Chip = statusType === 'radial' ? BuffRing : BuffChipIcons

  return (
    <Box style={{
      display: 'flex',
      alignItems: 'center',
      gap: rem(6),
      filter: DROP_SHADOW,
    }}>
      {valid.map((buff, i) => (
        <Transition key={i} mounted transition="fade" duration={400}>
          {(styles) => (
            <Box style={styles}>
              <Chip buff={buff} def={buffDefs[buff.buff]} />
            </Box>
          )}
        </Transition>
      ))}
    </Box>
  )
}
