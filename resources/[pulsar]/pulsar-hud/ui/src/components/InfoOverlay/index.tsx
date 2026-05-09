import { Transition, Box, Text } from '@mantine/core'
import { rem } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import parse from 'html-react-parser'
import DOMPurify from 'dompurify'
import { useInfoOverlayStore } from '../../store/infoOverlay'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_INFO_OVERLAY_BG } from '../../hudTheme'

export default function InfoOverlay() {
  const showing = useInfoOverlayStore((s) => s.showing)
  const info    = useInfoOverlayStore((s) => s.info)

  const { primary } = useHudTheme()
  const label       = String(info.label ?? '')
  const description = info.description != null ? String(info.description) : null
  const icon        = info.icon != null ? String(info.icon) : 'location-dot'

  return (
    <Transition mounted={showing} transition="slide-down" duration={500}>
      {(styles) => (
        <Box style={{
          ...styles,
          position: 'absolute',
          top: rem(10), left: 0, right: 0,
          display: 'flex',
          justifyContent: 'center',
        }}>
          <Box style={{
            display: 'flex',
            alignItems: 'stretch',
            background: COLOR_INFO_OVERLAY_BG,
            border: `1px solid ${primary}40`,
            overflow: 'hidden',
            minWidth: rem(300),
            maxWidth: rem(520),
          }}>
            {/* Icon column */}
            <Box style={{
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              padding: `0 ${rem(18)}`,
              borderRight: `1px solid ${primary}30`,
              color: primary,
              flexShrink: 0,
            }}>
              <FontAwesomeIcon icon={['fas', icon as never]} style={{ fontSize: rem(22) }} />
            </Box>

            {/* Text column */}
            <Box style={{ padding: `${rem(12)} ${rem(18)}` }}>
              <Text style={{ fontSize: rem(17), fontWeight: 700, color: '#fff', lineHeight: 1 }}>
                {label}
              </Text>
              {description && (
                <Text style={{ fontSize: rem(14), color: 'rgba(255,255,255,0.5)', marginTop: rem(5), lineHeight: 1.4 }}>
                  {parse(DOMPurify.sanitize(description))}
                </Text>
              )}
            </Box>
          </Box>
        </Box>
      )}
    </Transition>
  )
}
