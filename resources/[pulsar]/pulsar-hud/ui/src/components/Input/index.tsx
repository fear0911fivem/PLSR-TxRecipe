import { useEffect } from 'react'
import { Box, Text, TextInput, Textarea, Select, NumberInput } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { rem } from '@mantine/core'
import { useInputStore } from '../../store/input'
import { nui } from '../../nui'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_BG_DARK, COLOR_MODAL_OVERLAY, COLOR_PANEL_BORDER, COLOR_DIVIDER, COLOR_INPUT_BG, COLOR_INPUT_BORDER } from '../../hudTheme'

interface InputDef {
  id: string
  type: 'text' | 'number' | 'multiline' | 'select'
  options?: Record<string, unknown>
  select?: { value: string; label: string }[]
}

export default function InputDialog() {
  const input = useInputStore() as unknown as Record<string, unknown> & {
    showing: boolean; event: string | null; title: string | null
    data: unknown; inputs: InputDef[]
  }
  const { primary } = useHudTheme()

  const fieldStyles = {
    input: {
      background: COLOR_INPUT_BG,
      border: `1px solid ${COLOR_INPUT_BORDER}`,
      borderRadius: 0,
      color: '#fff',
      fontSize: rem(13),
      '&:focus': { borderColor: primary },
      '&::placeholder': { color: 'rgba(255,255,255,0.18)' },
    },
    label: {
      color: 'rgba(255,255,255,0.45)',
      fontSize: rem(10),
      letterSpacing: '0.1em',
      textTransform: 'uppercase' as const,
      marginBottom: rem(4),
    },
  }

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && input.showing) onClose()
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [input.showing])

  const onClose = () => nui.send('Input:Close', { event: input.event, values: false, data: input.data })

  const onSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const res: Record<string, unknown> = {}
    const fd = new FormData(e.currentTarget)
    ;(input.inputs ?? []).forEach((inp) => { res[inp.id] = fd.get(inp.id) })
    nui.send('Input:Submit', { event: input.event, values: res, data: input.data })
  }

  const renderField = (inp: InputDef) => {
    const opts = inp.options ?? {}
    const label = String(opts.label ?? inp.id)
    switch (inp.type) {
      case 'number':
        return <NumberInput key={inp.id} name={inp.id} label={label} mb="sm" styles={fieldStyles} />
      case 'multiline':
        return <Textarea key={inp.id} name={inp.id} label={label} minRows={3} mb="sm" autoFocus styles={fieldStyles} />
      case 'select':
        return (
          <Select
            key={inp.id}
            name={inp.id}
            label={label}
            data={(inp.select ?? []).map((o) => ({ value: o.value, label: o.label }))}
            mb="sm"
            styles={fieldStyles}
          />
        )
      default:
        return <TextInput key={inp.id} name={inp.id} label={label} mb="sm" autoFocus styles={fieldStyles} />
    }
  }

  if (!input.showing) return null
  return (
    <Box style={{
      position: 'fixed', inset: 0,
      background: COLOR_MODAL_OVERLAY,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 1000,
    }}>
      <Box style={{
        width: rem(380),
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
                {input.title ?? ''}
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

        {/* Form */}
        <form onSubmit={onSubmit}>
          <Box style={{ padding: `${rem(14)} ${rem(16)}` }}>
            {(input.inputs ?? []).map(renderField)}
          </Box>

          {/* Divider */}
          <Box style={{ height: rem(1), background: COLOR_DIVIDER }} />

          {/* Footer */}
          <Box style={{
            padding: `${rem(10)} ${rem(16)}`,
            display: 'flex', justifyContent: 'flex-end', gap: rem(8),
          }}>
            <Box
              onClick={onClose}
              style={{
                cursor: 'pointer',
                padding: `${rem(6)} ${rem(16)}`,
                border: `1px solid ${COLOR_INPUT_BORDER}`,
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
              Cancel
            </Box>
            <button
              type="submit"
              style={{
                cursor: 'pointer',
                padding: `${rem(6)} ${rem(16)}`,
                background: `${primary}22`,
                border: `1px solid ${primary}70`,
                color: '#fff',
                fontSize: rem(12), letterSpacing: '0.06em',
                userSelect: 'none',
                fontFamily: 'inherit',
              }}
              onMouseEnter={(e) => { e.currentTarget.style.background = `${primary}44` }}
              onMouseLeave={(e) => { e.currentTarget.style.background = `${primary}22` }}
            >
              Submit
            </button>
          </Box>
        </form>
      </Box>
    </Box>
  )
}
