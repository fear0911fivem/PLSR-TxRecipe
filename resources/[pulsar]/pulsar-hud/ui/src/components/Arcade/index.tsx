import { useEffect, useState } from 'react'
import { Transition, Box, Grid, Text, rem } from '@mantine/core'
import { useArcadeStore } from '../../store/arcade'
import { COLOR_BG_DARK, ARCADE_SCORE_FONT_SIZE } from '../../hudTheme'

function useCountdown(endMs: number) {
  const [remaining, setRemaining] = useState('')

  useEffect(() => {
    if (!endMs) return
    const tick = () => {
      const diff = Math.max(0, endMs - Date.now())
      const m = Math.floor(diff / 60000)
      const s = Math.floor((diff % 60000) / 1000).toString().padStart(2, '0')
      setRemaining(`${m}:${s}`)
    }
    tick()
    const id = setInterval(tick, 500)
    return () => clearInterval(id)
  }, [endMs])

  return remaining
}

export default function Arcade() {
  const showing   = useArcadeStore((s) => s.showing)
  const matchInfo = useArcadeStore((s) => s.matchInfo)
  const team1     = useArcadeStore((s) => s.team1)
  const team2     = useArcadeStore((s) => s.team2)
  const timer     = useCountdown(matchInfo.matchEnd)

  return (
    <Transition mounted={showing} transition="fade" duration={500}>
      {(styles) => (
        <Box style={{ ...styles, position: 'absolute', top: 0, left: 0, right: 0, margin: 'auto', width: rem(340) }}>
          <Grid style={{ background: COLOR_BG_DARK, padding: rem(15), textAlign: 'center' }}>
            <Grid.Col span={3}>
              <Text size="sm">Team 1</Text>
              <Text style={{ fontSize: rem(ARCADE_SCORE_FONT_SIZE) }}>{team1.current} / {team1.max}</Text>
            </Grid.Col>
            <Grid.Col span={6}>
              <Text size="xs" c="dimmed">{matchInfo.matchLabel}</Text>
              <Text style={{ fontSize: rem(ARCADE_SCORE_FONT_SIZE) }}>{timer}</Text>
            </Grid.Col>
            <Grid.Col span={3}>
              <Text size="sm">Team 2</Text>
              <Text style={{ fontSize: rem(ARCADE_SCORE_FONT_SIZE) }}>{team2.current} / {team2.max}</Text>
            </Grid.Col>
          </Grid>
        </Box>
      )}
    </Transition>
  )
}
