import { Box, Text, Transition } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { rem } from '@mantine/core'
import { useVehicleStore } from '../../store/vehicle'
import { useHudStore } from '../../store/hud'
import { useHudTheme } from '../../hooks/useHudTheme'
import {
  VEHICLE_FUEL_LOW_COLOR, VEHICLE_FUEL_MID_COLOR, VEHICLE_FUEL_HIGH_COLOR,
  VEHICLE_NOS_COLOR, VEHICLE_CRUISE_COLOR, COLOR_SIGNAL,
  VEHICLE_CLUSTER_BOTTOM, VEHICLE_CLUSTER_BOTTOM_SHIFTED,
} from '../../hudTheme'

function fuelColor(v: number) {
  if (v >= 50) return VEHICLE_FUEL_HIGH_COLOR
  if (v >= 10) return VEHICLE_FUEL_MID_COLOR
  return VEHICLE_FUEL_LOW_COLOR
}

function rpmColor(v: number, primary: string) {
  if (v >= 0.85) return '#fa5252'
  if (v >= 0.65) return '#fd7e14'
  return primary
}

function isShiftedUp(layout: string, buffsAnchor2: boolean): boolean {
  return layout === 'center' || (layout === 'minimap' && buffsAnchor2)
}

export default function VehicleMinimal() {
  const { primary }  = useHudTheme()
  const config       = useHudStore((s) => s.config)
  const showing      = useVehicleStore((s) => s.showing)
  const ignition     = useVehicleStore((s) => s.ignition)
  const speed        = useVehicleStore((s) => s.speed)
  const speedMeasure = useVehicleStore((s) => s.speedMeasure)
  const seatbelt     = useVehicleStore((s) => s.seatbelt)
  const seatbeltHide = useVehicleStore((s) => s.seatbeltHide)
  const checkEngine  = useVehicleStore((s) => s.checkEngine)
  const cruise       = useVehicleStore((s) => s.cruise)
  const fuelVal      = useVehicleStore((s) => s.fuel)
  const fuelHide     = useVehicleStore((s) => s.fuelHide)
  const rpmVal       = useVehicleStore((s) => s.rpm)
  const nosVal       = useVehicleStore((s) => s.nos)
  const leftSignal   = useVehicleStore((s) => s.leftSignal)
  const rightSignal  = useVehicleStore((s) => s.rightSignal)
  const battery      = useVehicleStore((s) => s.battery)
  const doorLock     = useVehicleStore((s) => s.doorLock)

  const shifted  = isShiftedUp(config.layout, config.buffsAnchor2)
  const bottom   = shifted ? VEHICLE_CLUSTER_BOTTOM_SHIFTED : VEHICLE_CLUSTER_BOTTOM

  const rpmNorm  = Math.min(1, Math.max(0, rpmVal))
  const fuelNorm = Math.min(1, Math.max(0, fuelVal / 100))
  const nosNorm  = Math.min(1, Math.max(0, nosVal / 100))
  const fuelCol  = fuelColor(fuelVal)
  const speedCol = ignition ? rpmColor(rpmNorm, '#ffffff') : 'rgba(255,255,255,0.15)'

  const hasWarning = (!seatbeltHide && !seatbelt) || battery || checkEngine

  return (
    <Transition mounted={showing} transition="fade" duration={300}>
      {(styles) => (
        <Box style={{
          ...styles,
          position: 'absolute', right: rem(20), bottom: rem(bottom),
          display: 'flex', flexDirection: 'column', alignItems: 'center',
          filter: 'drop-shadow(0 1px 12px rgba(0,0,0,0.95))',
        }}>

          {/* Cruise */}
          {cruise && (
            <FontAwesomeIcon icon={['fas', 'gauge']} style={{
              fontSize: rem(10), color: VEHICLE_CRUISE_COLOR,
              letterSpacing: '0.1em', marginBottom: rem(5),
            }} />
          )}

          {/* Turn signals — invisible when off */}
          <Box style={{ display: 'flex', alignItems: 'center', gap: rem(16), marginBottom: rem(1), height: rem(12) }}>
            <FontAwesomeIcon icon={['fas', 'arrow-left']} style={{
              fontSize: rem(14),
              color: leftSignal ? COLOR_SIGNAL : 'transparent',
              animation: leftSignal ? 'hud-flash 0.6s linear infinite' : 'none',
            }} />
            <FontAwesomeIcon icon={['fas', 'arrow-right']} style={{
              fontSize: rem(14),
              color: rightSignal ? COLOR_SIGNAL : 'transparent',
              animation: rightSignal ? 'hud-flash 0.6s linear infinite' : 'none',
            }} />
          </Box>

          {/* Speed */}
          <Text style={{
            fontSize: rem(62), fontWeight: 800, lineHeight: 1,
            fontFamily: 'Rajdhani, sans-serif',
            letterSpacing: '-0.03em',
            color: speedCol,
            transition: 'color 0.2s ease',
          }}>
            {ignition ? speed : '—'}
          </Text>

          {/* Unit */}
          <Text style={{
            fontSize: rem(9), color: 'rgba(255,255,255,0.18)',
            letterSpacing: '0.22em', textTransform: 'uppercase',
            marginTop: rem(1), fontFamily: 'Rajdhani, sans-serif',
          }}>
            {speedMeasure}
          </Text>

          {/* Fuel line */}
          {!fuelHide && (
            <Box style={{
              width: rem(80), height: rem(3),
              background: 'rgba(255,255,255,0.07)',
              marginTop: rem(7), overflow: 'hidden',
            }}>
              <Box style={{
                height: '100%', width: `${fuelNorm * 100}%`,
                background: fuelCol,
                transition: 'width 0.5s ease, background 0.3s ease',
                boxShadow: fuelVal <= 10 ? `0 0 6px ${fuelCol}` : 'none',
                animation: fuelVal <= 10 ? 'hud-flash 0.5s linear infinite' : 'none',
              }} />
            </Box>
          )}

          {/* NOS line — only when active */}
          {nosVal > 0 && (
            <Box style={{
              width: rem(80), height: rem(3),
              background: 'rgba(255,255,255,0.05)',
              marginTop: rem(3), overflow: 'hidden',
            }}>
              <Box style={{
                height: '100%', width: `${nosNorm * 100}%`,
                background: VEHICLE_NOS_COLOR,
                boxShadow: `0 0 8px ${VEHICLE_NOS_COLOR}`,
                transition: 'width 0.1s linear',
              }} />
            </Box>
          )}

          {/* Warnings — only appear when something is wrong */}
          {hasWarning && (
            <Box style={{ display: 'flex', gap: rem(10), marginTop: rem(8) }}>
              {!seatbeltHide && !seatbelt && (
                <FontAwesomeIcon icon={['fas', 'user-shield']} style={{
                  fontSize: rem(14), color: '#fd7e14',
                  animation: 'hud-flash 3s linear infinite',
                }} />
              )}
              {battery && (
                <FontAwesomeIcon icon={['fas', 'car-battery']} style={{
                  fontSize: rem(14), color: '#fa5252',
                  animation: 'hud-flash 1s linear infinite',
                }} />
              )}
              {checkEngine && (
                <FontAwesomeIcon icon={['fas', 'oil-can']} style={{
                  fontSize: rem(14), color: '#fa5252',
                  animation: 'hud-flash 1s linear infinite',
                }} />
              )}
              {doorLock && (
                <FontAwesomeIcon icon={['fas', 'lock']} style={{
                  fontSize: rem(14), color: `${primary}cc`,
                }} />
              )}
            </Box>
          )}

        </Box>
      )}
    </Transition>
  )
}
