import { useEffect } from 'react'
import { Box, Text } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { rem } from '@mantine/core'
import parse from 'html-react-parser'
import DOMPurify from 'dompurify'
import { useConfirmStore } from '../../store/confirm'
import { nui } from '../../nui'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_BG_DARK, COLOR_MODAL_OVERLAY, COLOR_PANEL_BORDER, COLOR_DIVIDER } from '../../hudTheme'

export default function ConfirmDialog() {
  const confirm = useConfirmStore()

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && confirm.showing) onClose()
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [confirm.showing])

  const onAccept = () => nui.send('Confirm:Yes', { event: confirm.yes, data: confirm.data })
  const onClose  = () => nui.send('Confirm:No',  { event: confirm.no,  data: confirm.data })

  const { primary } = useHudTheme()

  if (!confirm.showing) return null
  return (
    <Box style={{
      position: 'fixed', inset: 0,
      background: COLOR_MODAL_OVERLAY,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 1000,
    }}>
      <Box style={{
        width: rem(360),
        background: COLOR_BG_DARK,
        border: `1px solid ${COLOR_PANEL_BORDER}`,
        overflow: 'hidden',
      }}>

        {/* Header */}
        <Box style={{ padding: `${rem(14)} ${rem(16)} ${rem(12)}` }}>
          <Box style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
            <Box>
              <Text style={{
                fontSize: rem(13), fontWeight: 700,
                letterSpacing: '0.1em', textTransform: 'uppercase',
                color: 'rgba(255,255,255,0.9)', lineHeight: 1,
              }}>
                {confirm.title}
              </Text>
              <Box style={{ width: rem(28), height: rem(2), background: primary, marginTop: rem(6) }} />
            </Box>
            <Box
              onClick={onClose}
              style={{ cursor: 'pointer', color: 'rgba(255,255,255,0.3)', fontSize: rem(11), paddingTop: rem(2) }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = '#fff' }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = 'rgba(255,255,255,0.3)' }}
            >
              <FontAwesomeIcon icon={['fas', 'xmark']} />
            </Box>
          </Box>
        </Box>

        {/* Divider */}
        <Box style={{ height: rem(1), background: COLOR_DIVIDER }} />

        {/* Body */}
        <Box style={{ padding: `${rem(14)} ${rem(16)} ${rem(16)}` }}>
          {Boolean(confirm.description) && (
            <Text style={{
              fontSize: rem(13), color: 'rgba(255,255,255,0.55)',
              lineHeight: 1.6, marginBottom: rem(18),
            }}>
              {parse(DOMPurify.sanitize(String(confirm.description)))}
            </Text>
          )}

          <Box style={{ display: 'flex', justifyContent: 'flex-end', gap: rem(8) }}>
            <Box
              onClick={onClose}
              style={{
                cursor: 'pointer',
                padding: `${rem(6)} ${rem(16)}`,
                border: '1px solid rgba(255,255,255,0.10)',
                color: 'rgba(255,255,255,0.4)',
                fontSize: rem(12), letterSpacing: '0.06em',
                userSelect: 'none',
              }}
              onMouseEnter={(e) => {
                const el = e.currentTarget as HTMLElement
                el.style.color = '#fff'
                el.style.borderColor = 'rgba(255,255,255,0.25)'
              }}
              onMouseLeave={(e) => {
                const el = e.currentTarget as HTMLElement
                el.style.color = 'rgba(255,255,255,0.4)'
                el.style.borderColor = 'rgba(255,255,255,0.10)'
              }}
            >
              {confirm.denyLabel ?? 'No'}
            </Box>
            <Box
              onClick={onAccept}
              style={{
                cursor: 'pointer',
                padding: `${rem(6)} ${rem(16)}`,
                background: `${primary}22`,
                border: `1px solid ${primary}70`,
                color: '#fff',
                fontSize: rem(12), letterSpacing: '0.06em',
                userSelect: 'none',
              }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.background = `${primary}44` }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.background = `${primary}22` }}
            >
              {confirm.acceptLabel ?? 'Yes'}
            </Box>
          </Box>
        </Box>
      </Box>
    </Box>
  )
}
