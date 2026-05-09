import { useEffect, useState } from 'react'
import { Text, Box } from '@mantine/core'
import { Transition } from '@mantine/core'
import { rem } from '@mantine/core'
import { useAppStore } from '../../store/app'
import { useHudTheme } from '../../hooks/useHudTheme'
import { COLOR_DEATH } from '../../hudTheme'

function useCountdown(targetMs: number | false): number {
  const [remaining, setRemaining] = useState(0)
  useEffect(() => {
    if (targetMs === false) { setRemaining(0); return }
    const tick = () => setRemaining(Math.max(0, (targetMs as number) - Date.now()))
    tick()
    const id = setInterval(tick, 500)
    return () => clearInterval(id)
  }, [targetMs])
  return remaining
}

function fmt(ms: number): string {
  const s = Math.floor(ms / 1000)
  const m = Math.floor(s / 60)
  return m > 0 ? `${m}m ${s % 60}s` : `${s}s`
}

function KeyHint({ children, primary }: { children: string; primary: string }) {
  const parts = children.split(/(\[[^\]]+\])/g)
  return (
    <Text style={{ fontSize: rem(16), color: 'rgba(255,255,255,0.92)', lineHeight: 1 }}>
      {parts.map((p, i) =>
        /^\[.*\]$/.test(p)
          ? <Text key={i} span style={{ color: primary, fontWeight: 700 }}>{p}</Text>
          : p
      )}
    </Text>
  )
}

export default function DeathTexts() {
  const isDeathTexts = useAppStore((s) => s.isDeathTexts)
  const isReleasing  = useAppStore((s) => s.isReleasing)
  const deathTime    = useAppStore((s) => s.deathTime)
  const releaseTimer = useAppStore((s) => s.releaseTimer)
  const releaseType  = useAppStore((s) => s.releaseType)
  const releaseKey   = useAppStore((s) => s.releaseKey)
  const helpKey      = useAppStore((s) => s.helpKey)
  const medicalPrice = useAppStore((s) => s.medicalPrice)

  const { primary }      = useHudTheme()
  const deathRemaining   = useCountdown(deathTime as number | false)
  const releaseRemaining = useCountdown(releaseTimer as number | false)

  const getTitle = () => {
    switch (releaseType) {
      case 'knockout':    return 'Knocked Out'
      case 'death':       return 'You Are Dead'
      case 'hospital':    return 'Taken To Hospital'
      case 'hospital_rp': return 'Medical Attention Required'
      default:            return 'Incapacitated'
    }
  }

  return (
    <Transition mounted={isDeathTexts} transition="fade" duration={500}>
      {(styles) => (
        <Box style={{
          ...styles,
          position: 'absolute', inset: 0,
          display: 'flex', flexDirection: 'column',
          alignItems: 'center', justifyContent: 'center',
          pointerEvents: 'none',
        }}>
          <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(10) }}>

            {/* Title */}
            <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(6), marginBottom: rem(20) }}>
              <Text style={{
                fontSize: rem(26), fontWeight: 800,
                fontFamily: 'Orbitron, sans-serif',
                letterSpacing: '0.12em', textTransform: 'uppercase',
                color: COLOR_DEATH, lineHeight: 1,
              }}>
                {getTitle()}
              </Text>
              <Box style={{ width: rem(60), height: rem(3), background: COLOR_DEATH, opacity: 0.5 }} />
            </Box>

            {/* Timers */}
            {(deathTime !== false || (releaseTimer !== false && !isReleasing)) && (
              <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(10), marginTop: rem(4) }}>
                {deathTime !== false && (
                  <Box style={{ display: 'flex', alignItems: 'center', gap: rem(16) }}>
                    <Text style={{ fontSize: rem(13), color: '#ffffff', letterSpacing: '0.1em', textTransform: 'uppercase' }}>
                      Death In
                    </Text>
                    <Text style={{
                      fontSize: rem(19), fontFamily: 'Orbitron, sans-serif',
                      fontWeight: 700, color: COLOR_DEATH, lineHeight: 1,
                    }}>
                      {fmt(deathRemaining)}
                    </Text>
                  </Box>
                )}
                {releaseTimer !== false && !isReleasing && (
                  <Box style={{ display: 'flex', alignItems: 'center', gap: rem(16) }}>
                    <Text style={{ fontSize: rem(13), color: '#ffffff', letterSpacing: '0.1em', textTransform: 'uppercase' }}>
                      {releaseType === 'knockout' ? 'Wake Up In' : releaseType === 'death' ? 'Bleed Out In' : 'Release In'}
                    </Text>
                    <Text style={{
                      fontSize: rem(19), fontFamily: 'Orbitron, sans-serif',
                      fontWeight: 700, color: 'rgba(255,255,255,0.7)', lineHeight: 1,
                    }}>
                      {fmt(releaseRemaining)}
                    </Text>
                  </Box>
                )}
              </Box>
            )}

            {isReleasing && (
              <Text style={{
                fontSize: rem(12), color: primary,
                letterSpacing: '0.14em', textTransform: 'uppercase',
                animation: 'hud-flash 1.2s linear infinite',
              }}>
                Releasing...
              </Text>
            )}

            {/* Key hints */}
            <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: rem(14), marginTop: rem(14) }}>
              {medicalPrice !== false && medicalPrice !== null && (
                <Text style={{ fontSize: rem(14), color: '#ffffff' }}>
                  Medical bill:{' '}
                  <Text span style={{ color: '#ffffff', fontWeight: 700 }}>
                    ${String(medicalPrice)}
                  </Text>
                </Text>
              )}
              <Box style={{ display: 'flex', gap: rem(24) }}>
                {releaseTimer !== false && !isReleasing && Boolean(releaseKey) && (
                  <KeyHint primary={primary}>{`Press [${String(releaseKey as string)}] ${releaseType === 'knockout' ? 'to stand up' : releaseType === 'death' ? 'to respawn' : 'to leave bed'}`}</KeyHint>
                )}
                {Boolean(helpKey) && (
                  <KeyHint primary={primary}>{`Press [${String(helpKey as string)}] to call for help`}</KeyHint>
                )}
              </Box>
            </Box>

          </Box>
        </Box>
      )}
    </Transition>
  )
}
