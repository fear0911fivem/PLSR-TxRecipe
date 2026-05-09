import { useCallback, useState } from 'react'
import { Box } from '@mantine/core'
import { Transition } from '@mantine/core'
import { rem } from '@mantine/core'
import { useHudStore } from '../../store/hud'
import { COLOR_DIVIDER_MID } from '../../hudTheme'
import { useLocationStore } from '../../store/location'
import { useVehicleStore } from '../../store/vehicle'
import { useStatusStore } from '../../store/status'
import StatusDefault from '../Status/Default'
import StatusRadial  from '../Status/Radial'
import Location from '../Location'
import VehicleDefault from '../Vehicle/Default'
import VehicleDigital from '../Vehicle/Digital'
import Buffs from '../Buffs'
import VoipIndicator from '../Voip'

export default function HudDefault() {
  const showing  = useHudStore((s) => s.showing)
  const config   = useHudStore((s) => s.config)
  const position = useHudStore((s) => s.position)
  const isShifted = useLocationStore((s) => s.shifted)
  const inVeh    = useVehicleStore((s) => s.showing)

  const buffs    = useStatusStore((s) => s.buffs)
  const buffDefs = useStatusStore((s) => s.buffDefs)
  const hasBuffs = buffs.some((b) => b && buffDefs[b.buff])

  const [height, setHeight] = useState(0)
  const measuredRef = useCallback((node: HTMLDivElement | null) => {
    if (node) setHeight(node.getBoundingClientRect().height)
  }, [])

  const shifted = isShifted || inVeh

  const getPanelStyle = () => {
    switch (config.layout) {
      case 'minimap':
        return {
          position: 'absolute' as const,
          left: `${((position.leftX ?? 0) + 0.0045) * 100}vw`,
          top: `calc(${(position.bottomY ?? 0) * 100}vh - ${height}px + 2.8rem)`,
          height: 'fit-content',
        }
      case 'center':
        return {
          position: 'absolute' as const,
          left: '50%',
          transform: 'translateX(-50%)',
          top: `calc(${(position.bottomY ?? 0) * 100}vh - ${height}px + 2.8rem)`,
          height: 'fit-content',
        }
      default:
        return {
          position: 'absolute' as const,
          left: `${((position.leftX ?? 0) + 0.0045) * 100}vw`,
          top: `calc(${(position.bottomY ?? 0) * 100}vh - ${height}px + 2.8rem)`,
          height: 'fit-content',
        }
    }
  }

  const panelStyle = getPanelStyle()

  const getStatus = () => {
    switch (config.statusType) {
      case 'radial': return <StatusRadial />
      default:       return <StatusDefault />
    }
  }

  const getVehicle = () => {
    switch (config.vehicle) {
      case 'digital': return <VehicleDigital />
      default:        return <VehicleDefault />
    }
  }

  return (
    <Transition mounted={showing} transition="fade" duration={300}>
      {(styles) => (
        <Box style={{ ...styles, position: 'relative', width: '100%', height: '100%' }}>
          <div ref={measuredRef} style={panelStyle}>
            <Box style={{ display: 'flex', alignItems: 'center', gap: rem(10) }}>
              {getStatus()}
              {hasBuffs && (
                <>
                  <Box style={{ width: rem(1), height: rem(22), background: COLOR_DIVIDER_MID, flexShrink: 0 }} />
                  <Buffs />
                </>
              )}
              <VoipIndicator />
            </Box>
          </div>

          {/* Location — top center, independent */}
          <Box
            style={{
              position: 'absolute',
              top: rem(14),
              left: '50%',
              transform: 'translateX(-50%)',
            }}
          >
            <Location />
          </Box>

          {getVehicle()}
        </Box>
      )}
    </Transition>
  )
}
