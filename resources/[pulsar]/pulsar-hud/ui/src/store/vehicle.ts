import { create } from 'zustand'

interface VehicleState {
  showing: boolean
  ignition: boolean
  nos: number
  speed: number
  rpm: number
  speedMeasure: 'MPH' | 'KPH'
  seatbelt: boolean
  seatbeltHide: boolean
  cruise: boolean
  checkEngine: number
  fuel: number
  fuelHide: boolean
  leftSignal: boolean
  rightSignal: boolean
  battery: boolean
  headlights: boolean
  doorLock: boolean
  mileage: number | null
}

export const useVehicleStore = create<VehicleState>()(() => ({
  showing: false,
  ignition: false,
  nos: 0,
  speed: 0,
  rpm: 0,
  speedMeasure: 'MPH',
  seatbelt: false,
  seatbeltHide: false,
  cruise: false,
  checkEngine: 0,
  fuel: 0,
  fuelHide: false,
  leftSignal: false,
  rightSignal: false,
  battery: false,
  headlights: false,
  doorLock: false,
  mileage: null,
}))

export const vehicleHandlers: Record<string, (payload: Record<string, unknown>) => void> = {
  SHOW_VEHICLE: () => useVehicleStore.setState({ showing: true }),
  HIDE_VEHICLE: () => useVehicleStore.setState({ showing: false }),
  UPDATE_IGNITION: (p) => useVehicleStore.setState({ ignition: p.ignition as boolean }),
  UPDATE_RPM: (p) => useVehicleStore.setState({ rpm: p.rpm as number }),
  UPDATE_SPEED: (p) => useVehicleStore.setState({ speed: p.speed as number }),
  UPDATE_SPEED_MEASURE: (p) => useVehicleStore.setState({ speedMeasure: p.measurement as 'MPH' | 'KPH' }),
  UPDATE_SEATBELT: (p) => useVehicleStore.setState({ seatbelt: p.seatbelt as boolean }),
  SHOW_SEATBELT: () => useVehicleStore.setState({ seatbeltHide: false }),
  HIDE_SEATBELT: () => useVehicleStore.setState({ seatbeltHide: true }),
  UPDATE_CRUISE: (p) => useVehicleStore.setState({ cruise: p.cruise as boolean }),
  UPDATE_ENGINELIGHT: (p) => useVehicleStore.setState({ checkEngine: p.checkEngine as number }),
  SHOW_HUD: (p) => useVehicleStore.setState((s) => ({
    fuel: p.fuel ? (p.fuel as number) : s.fuel,
    fuelHide: typeof p.fuelHide === 'boolean' ? p.fuelHide : s.fuelHide,
  })),
  UPDATE_FUEL: (p) => useVehicleStore.setState((s) => ({
    fuel: p.fuel ? (p.fuel as number) : s.fuel,
    fuelHide: typeof p.fuelHide === 'boolean' ? p.fuelHide : s.fuelHide,
  })),
  SHOW_FUEL: () => useVehicleStore.setState({ fuelHide: false }),
  HIDE_FUEL: () => useVehicleStore.setState({ fuelHide: true }),
  UPDATE_NOS: (p) => useVehicleStore.setState({ nos: p.nos as number }),
  UPDATE_LEFT_SIGNAL:  (p) => useVehicleStore.setState({ leftSignal:  p.state as boolean }),
  UPDATE_RIGHT_SIGNAL: (p) => useVehicleStore.setState({ rightSignal: p.state as boolean }),
  UPDATE_BATTERY:      (p) => useVehicleStore.setState({ battery:     p.state as boolean }),
  UPDATE_HEADLIGHTS:   (p) => useVehicleStore.setState({ headlights:  p.state as boolean }),
  UPDATE_DOORLOCK:     (p) => useVehicleStore.setState({ doorLock:    p.state as boolean }),
  UPDATE_MILEAGE:      (p) => useVehicleStore.setState({ mileage:     p.mileage as number }),
}
