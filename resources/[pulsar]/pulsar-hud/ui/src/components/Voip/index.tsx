import { Box, Text } from '@mantine/core'
import { rem } from '@mantine/core'
import { useHudStore } from '../../store/hud'
import {
  VOIP_COLOR_OFF,
  VOIP_COLOR_WHISPER,
  VOIP_COLOR_TALK,
  VOIP_COLOR_SHOUT,
  VOIP_COLOR_RADIO_IDLE,
  VOIP_COLOR_RADIO_TALKING,
  COLOR_DIVIDER_MID,
} from '../../hudTheme'
import StatIcon from '../Status/StatIcon'
import ArcGauge from '../Status/ArcGauge'

function resolveColor(voip: number, talking: number): string {
  if (voip === 0 && talking === 0) return VOIP_COLOR_OFF
  if (talking > 0 && voip > 0)    return VOIP_COLOR_RADIO_TALKING
  if (talking > 0)                 return VOIP_COLOR_RADIO_IDLE
  if (voip === 3)                  return VOIP_COLOR_SHOUT
  if (voip === 2)                  return VOIP_COLOR_TALK
  return VOIP_COLOR_WHISPER
}

function resolveIcon(voip: number, talking: number, voipIcon: string): string {
  if (voip === 0 && talking === 0) return 'microphone-slash'
  return voipIcon
}

interface ChipProps {
  color: string
  icon: string
  channel: string | null
}

function VoipIcons({ color, icon, channel }: ChipProps) {
  return (
    <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(3) }}>
      <StatIcon icon={icon} value={100} max={100} color={color} size={22} />
      {channel && (
        <Text style={{
          fontSize: rem(8), color: `${color}cc`,
          letterSpacing: '0.08em', lineHeight: 1,
          fontFamily: 'Rajdhani, sans-serif', fontWeight: 600,
        }}>
          {channel}
        </Text>
      )}
    </Box>
  )
}

function VoipRadial({ color, icon, channel }: ChipProps) {
  return (
    <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(3) }}>
      <ArcGauge icon={icon} value={100} max={100} color={color} size={36} />
      {channel && (
        <Text style={{
          fontSize: rem(8), color: `${color}cc`,
          letterSpacing: '0.08em', lineHeight: 1,
          fontFamily: 'Rajdhani, sans-serif', fontWeight: 600,
        }}>
          {channel}
        </Text>
      )}
    </Box>
  )
}

export default function VoipIndicator() {
  const voip       = useHudStore((s) => s.voip)
  const talking    = useHudStore((s) => s.talking)
  const voipIcon   = useHudStore((s) => s.voipIcon)
  const statusType = useHudStore((s) => s.config.statusType)

  const color = resolveColor(voip, talking)
  const icon  = resolveIcon(voip, talking, voipIcon)
  const Chip  = statusType === 'radial' ? VoipRadial : VoipIcons

  return (
    <Box style={{ display: 'flex', alignItems: 'center', gap: rem(10) }}>
      <Box style={{ width: rem(1), height: rem(22), background: COLOR_DIVIDER_MID, flexShrink: 0 }} />
      <Box style={{ filter: 'drop-shadow(0 1px 4px rgba(0,0,0,0.85))' }}>
        <Chip color={color} icon={icon} channel={null} />
      </Box>
    </Box>
  )
}
