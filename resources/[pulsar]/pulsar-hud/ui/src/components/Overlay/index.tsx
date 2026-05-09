import { Transition, Box } from '@mantine/core'
import { useOverlayStore } from '../../store/overlay'
import HuntingMapDark  from '../../assets/hunting-map-dark.webp'
import HuntingMapLight from '../../assets/hunting-map-light.webp'

interface OverlayItem { Name: string; MetaData?: { CustomItemImage?: string } }

export default function ImageOverlay() {
  const showing = useOverlayStore((s) => s.showing)
  const rawData = useOverlayStore((s) => s.data)
  const data    = (rawData as unknown as OverlayItem[]) ?? []

  const getImage = (): string | null => {
    const item = data?.[0]
    if (!item) return null
    if (item.Name === 'hunting_map_dark')  return HuntingMapDark
    if (item.Name === 'hunting_map_light') return HuntingMapLight
    if (item.Name.includes('vanityitem'))  return item.MetaData?.CustomItemImage ?? null
    return null
  }

  const img = getImage()

  return (
    <Transition mounted={showing && Boolean(img)} transition="slide-right" duration={500}>
      {(styles) => (
        <Box
          style={{ ...styles, position: 'absolute', top: '25vh', left: 0 }}
        >
          <Box
            style={{
              height: '50vh', width: '25vw', marginLeft: '2vw',
              backgroundImage: `url(${img ?? ''})`,
              backgroundSize: 'contain',
              backgroundRepeat: 'no-repeat',
            }}
          />
        </Box>
      )}
    </Transition>
  )
}
