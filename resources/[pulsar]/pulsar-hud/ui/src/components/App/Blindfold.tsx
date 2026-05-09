import { Transition } from '@mantine/core'
import { useAppStore } from '../../store/app'
import blindfoldImg from '../../assets/blindfold.webp'

export default function Blindfold() {
  const blindfolded = useAppStore((s) => s.blindfolded)

  return (
    <Transition mounted={blindfolded} transition="fade" duration={300}>
      {(styles) => (
        <div
          style={{
            ...styles,
            position: 'absolute',
            inset: 0,
            background: '#000',
            display: 'flex',
            alignItems: 'center',
            justifyContent: 'center',
          }}
        >
          <img
            src={blindfoldImg}
            alt=""
            style={{ width: '100%', height: '100%', objectFit: 'cover' }}
          />
        </div>
      )}
    </Transition>
  )
}
