import { Box, Text } from '@mantine/core'
import { rem } from '@mantine/core'
import { COLOR_PRIMARY, PROGRESS_TICK_MS, COLOR_SUCCESS, COLOR_FAIL } from '../../hudTheme'

interface Props {
  pct: number
  curr: number
  dur: number
  displayLabel: string
  cancelled: boolean
  finished: boolean
  failed: boolean
}

export default function ProgressMinimal({ pct, curr, dur, displayLabel, cancelled, finished, failed }: Props) {
  const secsLeft  = Math.max(0, Math.ceil((dur - curr) / 1000))
  const fillColor = cancelled || failed ? COLOR_FAIL : finished ? COLOR_SUCCESS : COLOR_PRIMARY

  return (
    <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(6) }}>
      <Text
        style={{
          fontSize: rem(16),
          fontWeight: 600,
          color: 'rgba(255,255,255,1)',
          letterSpacing: '0.06em',
          textTransform: 'uppercase',
          lineHeight: 1,
          whiteSpace: 'nowrap',
        }}
      >
        {displayLabel}
      </Text>

      <Box style={{ width: rem(300), height: rem(3), borderRadius: rem(2), background: 'rgba(255,255,255,0.06)', overflow: 'hidden' }}>
        <Box
          style={{
            height: '100%',
            width: `${pct}%`,
            background: fillColor,
            borderRadius: rem(2),
            boxShadow: `0 0 8px ${fillColor}99`,
            transition: `width ${PROGRESS_TICK_MS}ms linear, background 0.3s ease`,
          }}
        />
      </Box>

      {!cancelled && !finished && !failed && dur > 0 && (
        <Text style={{ fontSize: rem(14), color: 'rgba(255,255,255,0.8)', letterSpacing: '0.04em', lineHeight: 1 }}>
          {secsLeft}s
        </Text>
      )}
    </Box>
  )
}
