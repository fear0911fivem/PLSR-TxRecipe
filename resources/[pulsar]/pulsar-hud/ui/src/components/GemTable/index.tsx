import { Transition, Box, Text, rem } from '@mantine/core'
import { useGemTableStore } from '../../store/gemTable'

export default function GemTable() {
  const showing = useGemTableStore((s) => s.showing)
  const info    = useGemTableStore((s) => s.info)

  return (
    <Transition mounted={showing} transition="fade" duration={500}>
      {(styles) => (
        <Box
          style={{
            ...styles,
            position: 'absolute',
            inset: 0,
          }}
        >
          <Box
            style={{
              position: 'absolute',
              top: 0,
              left: 0, right: 0,
              height: rem(150),
              background: '#000',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Text size="xl" fw={700}>SAGMA Gem Table</Text>
          </Box>
          <Box
            style={{
              position: 'absolute',
              bottom: 0,
              left: 0, right: 0,
              height: rem(150),
              background: '#000',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
            }}
          >
            <Text size="lg">Appraised Gem Quality: {String(info)}%</Text>
          </Box>
        </Box>
      )}
    </Transition>
  )
}
