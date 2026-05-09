import { Box } from '@mantine/core'
import { rem } from '@mantine/core'
import { useStatusStore, Status } from '../../store/status'
import { STATUS_COLORS, DROP_SHADOW, COLOR_DIVIDER_MID } from '../../hudTheme'
import StatIcon from './StatIcon'

export default function StatusDefault() {
  const statuses  = useStatusStore((s) => s.statuses)
  const health    = useStatusStore((s) => s.health)
  const maxHealth = useStatusStore((s) => s.maxHealth)
  const armor     = useStatusStore((s) => s.armor)
  const isDead    = useStatusStore((s) => s.isDead)

  const sorted = [...statuses].sort((a, b) => (a.options.order ?? 99) - (b.options.order ?? 99))

  const shouldShow = (s: Status): boolean => {
    const opts = s.options as Record<string, unknown>
    if (s.options.hideZero && Number(s.value) <= 0) return false
    if (isDead && !opts.visibleWhileDead) return false
    return true
  }

  const visibleStats = sorted.filter(shouldShow)

  return (
    <Box
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: rem(10),
        filter: DROP_SHADOW,
      }}
    >
      {/* Health */}
      <StatIcon
        icon={isDead ? 'skull' : 'heart'}
        value={isDead ? 0 : health}
        max={maxHealth || 100}
        color={STATUS_COLORS.health}
        flash
        size={26}
      />

      {/* Armor — only when non-zero */}
      {armor > 0 && (
        <StatIcon
          icon="shield"
          value={armor}
          max={100}
          color={STATUS_COLORS.armor}
          size={24}
        />
      )}

      {/* Dot separator between built-ins and custom stats */}
      {visibleStats.length > 0 && (
        <Box
          style={{
            width: rem(3),
            height: rem(3),
            borderRadius: '50%',
            background: COLOR_DIVIDER_MID,
            flexShrink: 0,
          }}
        />
      )}

      {/* Custom stats */}
      {visibleStats.map((s) => (
        <StatIcon
          key={s.name}
          icon={s.icon}
          value={Number(s.value)}
          max={(s.options as Record<string, unknown>).customMax as number || s.max || 100}
          color={s.color}
          flash={s.flash}
          size={20}
        />
      ))}
    </Box>
  )
}
