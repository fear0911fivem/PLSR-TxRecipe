import { useEffect } from 'react'
import { Box, Text, Slider } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { rem } from '@mantine/core'
import { useMethStore } from '../../store/meth'
import { nui } from '../../nui'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_BG_DARK, COLOR_MODAL_OVERLAY, COLOR_PANEL_BORDER, COLOR_DIVIDER } from '../../hudTheme'

const INGREDIENT_LABELS = [
  'Acetone', 'Battery Acid', 'Iodine Crystals', 'Sulfuric Acid',
  'Phosphorous', 'Gasoline', 'Lithium', 'Anhydrous Ammonia',
]

export default function MethDialog() {
  const showing  = useMethStore((s) => s.showing)
  const config   = useMethStore((s) => s.config)

  const ingredientCount = Number((config as unknown as Record<string, unknown>).ingredients ?? 0)
  const maxCookTime     = config.maxCookTime ?? 60

  const { primary } = useHudTheme()

  useEffect(() => {
    const handler = (e: KeyboardEvent) => {
      if (e.key === 'Escape' && showing) nui.send('Meth:Cancel')
    }
    window.addEventListener('keydown', handler)
    return () => window.removeEventListener('keydown', handler)
  }, [showing])

  if (!showing) return null

  const sliderStyles = {
    bar:   { background: primary },
    thumb: { borderColor: primary, background: '#111116' },
    label: { background: 'rgba(0,0,0,0.85)', color: '#fff', fontSize: rem(11) },
  }

  const onSubmit = (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const fd = new FormData(e.currentTarget)
    nui.send('Meth:Start', {
      cookTime:    Number(fd.get('cooktime')),
      ingredients: Array.from({ length: ingredientCount }, (_, i) => Number(fd.get(`ingredient${i}`) ?? 0)),
    })
  }

  return (
    <Box style={{
      position: 'fixed', inset: 0,
      background: COLOR_MODAL_OVERLAY,
      display: 'flex', alignItems: 'center', justifyContent: 'center',
      zIndex: 1000,
    }}>
      <Box style={{
        width: rem(420),
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
                Ingredient Mixture
              </Text>
              <Box style={{ width: rem(28), height: rem(2), background: primary, marginTop: rem(6) }} />
            </Box>
            <Box
              onClick={() => nui.send('Meth:Cancel')}
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
          <Box style={{ padding: `${rem(14)} ${rem(16)}`, display: 'flex', flexDirection: 'column', gap: rem(14) }}>

            {Array.from({ length: ingredientCount }, (_, i) => (
              <Box key={i}>
                <Text style={{
                  fontSize: rem(10), fontWeight: 600,
                  letterSpacing: '0.1em', textTransform: 'uppercase',
                  color: 'rgba(255,255,255,0.4)', marginBottom: rem(8),
                }}>
                  {INGREDIENT_LABELS[i] ?? `Ingredient ${i + 1}`}
                </Text>
                <Slider
                  name={`ingredient${i}`}
                  min={0} max={100} step={1} defaultValue={0}
                  label={(v) => `${v}`}
                  styles={sliderStyles}
                />
              </Box>
            ))}

            <Box>
              <Text style={{
                fontSize: rem(10), fontWeight: 600,
                letterSpacing: '0.1em', textTransform: 'uppercase',
                color: 'rgba(255,255,255,0.4)', marginBottom: rem(8),
              }}>
                Cook Time (Minutes)
              </Text>
              <Slider
                name="cooktime"
                min={1} max={maxCookTime} step={1} defaultValue={1}
                label={(v) => `${v}m`}
                styles={sliderStyles}
              />
            </Box>

          </Box>

          {/* Divider */}
          <Box style={{ height: rem(1), background: COLOR_DIVIDER }} />

          {/* Footer */}
          <Box style={{
            padding: `${rem(10)} ${rem(16)}`,
            display: 'flex', justifyContent: 'flex-end', gap: rem(8),
          }}>
            <Box
              onClick={() => nui.send('Meth:Cancel')}
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
              Start Cook
            </button>
          </Box>
        </form>

      </Box>
    </Box>
  )
}
