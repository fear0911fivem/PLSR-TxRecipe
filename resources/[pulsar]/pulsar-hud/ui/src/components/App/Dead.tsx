import { Transition } from '@mantine/core'
import { useStatusStore } from '../../store/status'
import { useAppStore } from '../../store/app'
import { OPACITY_DEAD_OVERLAY } from '../../hudTheme'

export default function Dead() {
  const isDead = useStatusStore((s) => s.isDead)
  const blindfolded = useAppStore((s) => s.blindfolded)

  return (
    <Transition mounted={isDead && !blindfolded} transition="fade" duration={400}>
      {(styles) => (
        <div
          style={{
            ...styles,
            position: 'absolute',
            inset: 0,
            background: `rgba(26,14,14,${OPACITY_DEAD_OVERLAY})`,
            pointerEvents: 'none',
          }}
        />
      )}
    </Transition>
  )
}
