import { useState, useEffect, useRef } from 'react'
import { Box, Text } from '@mantine/core'
import { Transition } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import { rem } from '@mantine/core'
import { useVehicleStore } from '../../store/vehicle'
import { useHudStore } from '../../store/hud'
import { useHudTheme } from '../../hooks/useHudTheme'
import {
  VEHICLE_FUEL_LOW_COLOR, VEHICLE_FUEL_MID_COLOR, VEHICLE_FUEL_HIGH_COLOR,
  VEHICLE_NOS_COLOR, VEHICLE_CRUISE_COLOR, COLOR_SIGNAL,
  VEHICLE_CLUSTER_BOTTOM, VEHICLE_CLUSTER_BOTTOM_SHIFTED,
  DROP_SHADOW,
} from '../../hudTheme'

const SIZE        = 250
const CX          = SIZE / 2
const CY          = SIZE / 2
const R           = 100

const GAUGE_START = 155
const GAUGE_SWEEP = 240

const DASH        = 28
const DASH_GAP    = 6
const DASH_PERIOD = DASH + DASH_GAP

const ZONE1 = 0.6
const ZONE2 = 0.2
const ZONE3 = 0.2

// 3 equal dashes in the orange zone, 3 in the red zone
const ZONE_ARC_LEN = 2 * Math.PI * R * ((GAUGE_SWEEP * 0.2) / 360)
const ZONE_GAP     = 6
const ZONE_DASH    = (ZONE_ARC_LEN - 2 * ZONE_GAP) / 3

// Fuel arc — inner track, first 120° of gauge span (left side)
const R_FUEL       = R - 16   // closer inner track
const FUEL_MAX_DEG = GAUGE_SWEEP  // same span as RPM, inner track
// 4 equal fuel segments: compute dash length so exactly 4 fit with 3 gaps of 4px
const FUEL_ARC_LEN = 2 * Math.PI * R_FUEL * (FUEL_MAX_DEG / 360)
const FUEL_GAP     = 4
const FUEL_DASH    = (FUEL_ARC_LEN - 3 * FUEL_GAP) / 4

function toRad(deg: number) { return (deg * Math.PI) / 180 }

function arcPoint(cx: number, cy: number, r: number, deg: number) {
  return {
    x: cx + r * Math.cos(toRad(deg)),
    y: cy + r * Math.sin(toRad(deg)),
  }
}

function arcPath(cx: number, cy: number, r: number, startDeg: number, sweepDeg: number): string {
  if (sweepDeg <= 0) return ''
  const clampedSweep = Math.min(sweepDeg, 359.99)
  const endDeg = startDeg + clampedSweep
  const s = arcPoint(cx, cy, r, startDeg)
  const e = arcPoint(cx, cy, r, endDeg)
  const largeArc = clampedSweep > 180 ? 1 : 0
  return `M ${s.x.toFixed(3)} ${s.y.toFixed(3)} A ${r} ${r} 0 ${largeArc} 1 ${e.x.toFixed(3)} ${e.y.toFixed(3)}`
}

const TICKS = [
  { label: '0', deg: 155 },
  { label: '2', deg: 215 },
  { label: '4', deg: 275 },
  { label: '6', deg: 335 },
  { label: '8', deg: 35  },
]
const LABEL_R = R + 16

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

export default function VehicleDefault() {
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
  const headlights   = useVehicleStore((s) => s.headlights)
  const doorLock     = useVehicleStore((s) => s.doorLock)
  const mileage      = useVehicleStore((s) => s.mileage)

  const shifted = isShiftedUp(config.layout, config.buffsAnchor2)
  const bottom  = shifted ? VEHICLE_CLUSTER_BOTTOM_SHIFTED : VEHICLE_CLUSTER_BOTTOM

  const rpmNorm  = Math.min(1, Math.max(0, rpmVal))
  const isIdle  = rpmNorm < 0.3
  const tRef    = useRef(0)
  const [jitter, setJitter] = useState(0)
  useEffect(() => {
    if (!isIdle) { setJitter(0); return }
    const id = setInterval(() => {
      tRef.current += 0.025
      const t = tRef.current
      setJitter(Math.sin(t * 1.1) * 0.018 + Math.sin(t * 0.5) * 0.012)
    }, 50)
    return () => clearInterval(id)
  }, [isIdle])
  const rpmFinal = Math.max(0, Math.min(1, rpmNorm + jitter))
  const fuelNorm = Math.min(1, Math.max(0, fuelVal / 100))
  const nosNorm  = Math.min(1, Math.max(0, nosVal / 100))

  const rpmSweep  = rpmFinal * GAUGE_SWEEP
  const fuelSweep = fuelNorm * FUEL_MAX_DEG
  const nosSweep  = nosNorm * GAUGE_SWEEP

  const fuelCol = fuelColor(fuelVal)

  const fuelPath = arcPath(CX, CY, R_FUEL, GAUGE_START, fuelSweep)
  const nosPath  = arcPath(CX, CY, R_FUEL, GAUGE_START, nosSweep)

  return (
    <Transition mounted={showing} transition="fade" duration={300}>
      {(styles) => (
        <Box style={{ ...styles, position: 'absolute', right: rem(20), bottom: rem(bottom), width: 'fit-content' }}>
          <Box style={{ position: 'relative', width: rem(SIZE), height: rem(SIZE) }}>
            <svg viewBox={`0 0 ${SIZE} ${SIZE}`} style={{ position: 'absolute', inset: 0, width: rem(SIZE), height: rem(SIZE), transform: 'rotate(25deg)', overflow: 'visible', filter: DROP_SHADOW }}>

              {/* Zone 1 bg: 0–6, solid */}
              <path d={arcPath(CX, CY, R, GAUGE_START, GAUGE_SWEEP * ZONE1)} fill="none"
                stroke="rgba(255,255,255,0.22)" strokeWidth={8} strokeLinecap="butt"
              />
              {/* Zone 2 bg: 6–8, 3 segments */}
              <path d={arcPath(CX, CY, R, GAUGE_START + GAUGE_SWEEP * ZONE1, GAUGE_SWEEP * ZONE2)} fill="none"
                stroke="rgba(253,126,20,0.50)" strokeWidth={8} strokeLinecap="butt"
                strokeDasharray={`${ZONE_DASH} ${ZONE_GAP}`}
              />
              {/* Zone 3 bg: 8–10, 3 segments */}
              <path d={arcPath(CX, CY, R, GAUGE_START + GAUGE_SWEEP * (ZONE1 + ZONE2), GAUGE_SWEEP * ZONE3)} fill="none"
                stroke="rgba(250,82,82,0.55)" strokeWidth={8} strokeLinecap="butt"
                strokeDasharray={`${ZONE_DASH} ${ZONE_GAP}`}
              />

              {/* RPM fill zone 1 — solid */}
              {rpmFinal > 0 && (
                <path d={arcPath(CX, CY, R, GAUGE_START, Math.min(rpmSweep, GAUGE_SWEEP * ZONE1))} fill="none"
                  stroke={ignition ? primary : 'rgba(255,255,255,0.06)'} strokeWidth={8} strokeLinecap="butt"
                  style={{ transition: 'stroke 0.2s ease' }}
                />
              )}
              {/* RPM fill zone 2 — segmented orange */}
              {rpmFinal > ZONE1 && (
                <path d={arcPath(CX, CY, R, GAUGE_START + GAUGE_SWEEP * ZONE1, Math.min((rpmFinal - ZONE1) / ZONE2, 1) * GAUGE_SWEEP * ZONE2)} fill="none"
                  stroke={ignition ? '#fd7e14' : 'rgba(255,255,255,0.06)'} strokeWidth={8} strokeLinecap="butt"
                  strokeDasharray={`${ZONE_DASH} ${ZONE_GAP}`}
                />
              )}
              {/* RPM fill zone 3 — segmented red */}
              {rpmFinal > ZONE1 + ZONE2 && (
                <path d={arcPath(CX, CY, R, GAUGE_START + GAUGE_SWEEP * (ZONE1 + ZONE2), Math.min((rpmFinal - ZONE1 - ZONE2) / ZONE3, 1) * GAUGE_SWEEP * ZONE3)} fill="none"
                  stroke={ignition ? '#fa5252' : 'rgba(255,255,255,0.06)'} strokeWidth={8} strokeLinecap="butt"
                  strokeDasharray={`${ZONE_DASH} ${ZONE_GAP}`}
                />
              )}

              {/* Fuel background — 4 dim segments */}
              {!fuelHide && (
                <path d={arcPath(CX, CY, R_FUEL, GAUGE_START, FUEL_MAX_DEG)} fill="none"
                  stroke="rgba(255,255,255,0.22)" strokeWidth={8} strokeLinecap="butt"
                  strokeDasharray={`${FUEL_DASH} ${FUEL_GAP}`}
                />
              )}

              {/* Fuel fill — same dash grid, lights up segments */}
              {!fuelHide && fuelSweep > 0 && (
                <path d={fuelPath} fill="none"
                  stroke={fuelCol} strokeWidth={8} strokeLinecap="butt"
                  strokeDasharray={`${FUEL_DASH} ${FUEL_GAP}`}
                  style={{ transition: 'stroke 0.3s ease' }}
                />
              )}

              {/* NOS fill */}
              {nosVal > 0 && nosSweep > 0 && (
                <path d={nosPath} fill="none"
                  stroke={VEHICLE_NOS_COLOR} strokeWidth={6} strokeLinecap="round"
                />
              )}

              {/* Tick labels */}
              {TICKS.map(({ label, deg }) => {
                const angleRad = toRad(deg)
                const x = CX + LABEL_R * Math.cos(angleRad)
                const y = CY + LABEL_R * Math.sin(angleRad)
                return (
                  <text key={label} x={x} y={y}
                    textAnchor="middle" dominantBaseline="middle"
                    fill="rgba(255,255,255,1)" fontSize={16} fontWeight="bold" fontFamily="Rajdhani, sans-serif"
                    transform={`rotate(-25, ${x}, ${y})`}
                  >
                    {label}
                  </text>
                )
              })}
            </svg>

            {/* Center content */}
            <Box style={{
              position: 'absolute', inset: 0,
              display: 'flex', flexDirection: 'column',
              alignItems: 'center', justifyContent: 'center', paddingBottom: rem(10), paddingLeft: rem(14),
            }}>
              {/* Turn signals */}
              {ignition && (
                <Box style={{ display: 'flex', alignItems: 'center', gap: rem(8), marginBottom: rem(6), marginTop: rem(-16), marginLeft: rem(-14) }}>
                  <FontAwesomeIcon icon={['fas', 'arrow-left']} style={{
                    fontSize: rem(19),
                    color: leftSignal ? COLOR_SIGNAL : 'rgba(255,255,255,0.65)',
                    animation: leftSignal ? 'hud-flash 0.6s linear infinite' : 'none',
                  }} />
                  <FontAwesomeIcon icon={['fas', 'arrow-right']} style={{
                    fontSize: rem(19),
                    color: rightSignal ? COLOR_SIGNAL : 'rgba(255,255,255,0.65)',
                    animation: rightSignal ? 'hud-flash 0.6s linear infinite' : 'none',
                  }} />
                </Box>
              )}

              {cruise && (
                <FontAwesomeIcon icon={['fas', 'gauge']}
                  style={{ color: VEHICLE_CRUISE_COLOR, fontSize: rem(24), marginBottom: rem(4) }}
                />
              )}

              {ignition ? (
                <Box style={{ display: 'flex', alignItems: 'center', gap: rem(8) }}>
                  <Text style={{
                    fontSize: rem(34), fontFamily: 'Orbitron, sans-serif',
                    fontWeight: 700, lineHeight: 1, color: '#fff', letterSpacing: '-0.02em',
                  }}>
                    {speed}
                  </Text>
                  <Box style={{
                    width: rem(1), height: rem(28),
                    background: 'rgba(255,255,255,0.2)', flexShrink: 0,
                  }} />
                  <Box style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 0 }}>
                    <Text style={{
                      fontSize: rem(19), fontFamily: 'Orbitron, sans-serif',
                      fontWeight: 700, lineHeight: 1, color: rpmColor(rpmNorm, primary),
                    }}>
                      {(rpmFinal * 8).toFixed(1)}
                    </Text>
                    <Text style={{
                      fontSize: rem(11), color: 'rgba(255,255,255,0.4)',
                      letterSpacing: '0.08em', lineHeight: 1, marginTop: rem(5),
                    }}>
                      ×1000
                    </Text>
                  </Box>
                </Box>
              ) : (
                <Text style={{ fontSize: rem(24), color: 'rgba(255,255,255,0.25)', letterSpacing: '0.14em' }}>
                  OFF
                </Text>
              )}

              <Text style={{
                fontSize: rem(12), color: 'rgba(255,255,255,0.65)',
                letterSpacing: '0.12em', textTransform: 'uppercase', marginTop: rem(3),
              }}>
                {speedMeasure}
              </Text>

            </Box>

            {/* Fuel icon — right of arc start */}
            {ignition && !fuelHide && (
              <FontAwesomeIcon icon={['fas', 'gas-pump']}
                style={{
                  position: 'absolute', left: rem(54), top: rem(108),
                  fontSize: rem(15), color: fuelCol,
                  animation: fuelVal <= 10 ? 'hud-flash 0.5s linear infinite' : 'none',
                  filter: DROP_SHADOW,
                }}
              />
            )}

            {/* Fuel % — below arc start */}
            {ignition && !fuelHide && (
              <Text style={{
                position: 'absolute', left: rem(33), top: rem(128),
                fontSize: rem(11), color: fuelCol, fontWeight: 600, lineHeight: 1,
                filter: DROP_SHADOW,
              }}>
                {fuelVal}%
              </Text>
            )}

            {/* Mileage — right of seatbelt icon */}
            {ignition && mileage != null && (
              <Box style={{
                position: 'absolute', bottom: rem(74), left: 0, right: 0,
                display: 'flex', justifyContent: 'center', paddingLeft: rem(60),
                filter: DROP_SHADOW,
              }}>
                <Text style={{
                  fontSize: rem(15),
                  fontFamily: 'Orbitron, sans-serif',
                  fontWeight: 700,
                  color: '#fd7e14',
                  letterSpacing: '0.06em',
                }}>
                  {Math.round(mileage).toLocaleString()} mi
                </Text>
              </Box>
            )}

            {/* Seatbelt — above status row */}
            {!seatbeltHide && (
              <Box style={{
                position: 'absolute', bottom: rem(74), left: 0, right: 0,
                display: 'flex', justifyContent: 'center', paddingRight: rem(124),
                filter: DROP_SHADOW,
              }}>
                <FontAwesomeIcon icon={['fas', 'user-shield']} style={{
                  fontSize: rem(24),
                  color: !seatbelt ? '#c92a2a' : '#40c057',
                  animation: !seatbelt ? 'hud-flash 1.5s linear infinite' : 'none',
                }} />
              </Box>
            )}

            {/* Status icons */}
            <Box style={{
              position: 'absolute', bottom: rem(32), left: 0, right: 0,
              display: 'flex', justifyContent: 'center', gap: rem(10), paddingRight: rem(56),
              filter: DROP_SHADOW,
            }}>
              <FontAwesomeIcon icon={['fas', 'car-battery']} style={{
                fontSize: rem(24),
                color: battery ? '#fa5252' : 'rgba(255,255,255,0.65)',
                animation: battery ? 'hud-flash 1s linear infinite' : 'none',
              }} />
              <FontAwesomeIcon icon={['fas', 'oil-can']} style={{
                fontSize: rem(24),
                color: checkEngine === 2 ? '#fa5252' : checkEngine === 1 ? '#fd7e14' : 'rgba(255,255,255,0.65)',
                animation: checkEngine === 2 ? 'hud-flash-mild 1s linear infinite' : 'none',
                filter: checkEngine === 2 ? 'drop-shadow(0 0 5px #fa5252)' : 'none',
              }} />
              <FontAwesomeIcon icon={['fas', 'lightbulb']} style={{
                fontSize: rem(24),
                color: headlights ? '#fff' : 'rgba(255,255,255,0.65)',
              }} />
              <FontAwesomeIcon icon={['fas', doorLock ? 'lock' : 'lock-open']} style={{
                fontSize: rem(24),
                color: doorLock ? '#c92a2a' : 'rgba(255,255,255,0.65)',
              }} />
            </Box>
          </Box>
        </Box>
      )}
    </Transition>
  )
}
