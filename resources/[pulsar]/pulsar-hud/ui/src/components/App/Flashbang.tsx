import { useEffect } from 'react'
import { Transition } from '@mantine/core'
import { useAppStore } from '../../store/app'
import { nui } from '../../nui'

interface FlashbangPayload {
  strength?: number
  duration?: number
}

export default function Flashbang() {
  const flashbanged = useAppStore((s) => s.flashbanged) as FlashbangPayload | false

  useEffect(() => {
    if (!flashbanged || !flashbanged.duration) return
    const t = setTimeout(() => {
      useAppStore.setState({ flashbanged: false })
    }, flashbanged.duration)
    return () => clearTimeout(t)
  }, [flashbanged])

  const opacity = flashbanged ? (flashbanged.strength ?? 1) : 0

  return (
    <Transition mounted={Boolean(flashbanged)} transition="fade" duration={100}>
      {(styles) => (
        <div
          style={{
            ...styles,
            position: 'absolute',
            inset: 0,
            background: '#fff',
            opacity,
            pointerEvents: 'none',
          }}
        />
      )}
    </Transition>
  )
}
