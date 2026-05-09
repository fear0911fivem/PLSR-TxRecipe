// Seeds all Zustand stores with realistic mock data for dev preview.
// Imported only when import.meta.env.DEV is true.

import { useAppStore }          from '../store/app'
import { useHudStore }          from '../store/hud'
import { useLocationStore }     from '../store/location'
import { useStatusStore }       from '../store/status'
import { useVehicleStore }      from '../store/vehicle'
import { useNotificationsStore } from '../store/notifications'
import { useProgressStore }     from '../store/progress'
import { useActionStore }       from '../store/action'
import { useAction2Store }      from '../store/action'
import { useListStore }         from '../store/list'
import { useInfoOverlayStore }  from '../store/infoOverlay'
import { useMethStore }         from '../store/meth'
import { useGemTableStore }     from '../store/gemTable'
import { useArcadeStore }       from '../store/arcade'
import { useInteractionStore }  from '../store/interaction'

export function seedDevStores() {
  useHudStore.setState({
    showing: true,
    voip: 2,
    talking: 4,
    voipIcon: 'walkie-talkie',
    settings: false,
    config: {
      layout: 'minimap',
      statusType: 'icons',
      buffsAnchor: 'compass',
      buffsAnchor2: true,

      hideCrossStreet: false,
      hideCompassBg: false,
      largeBars: false,
      minimapAnchor: true,
      transparentBg: false,
      vehicle: 'default',
      maskRadio: false,
      condenseAlignment: 'left',
      circleNumbers: false,
      progressStyle: 'ticks',
    },
    position: { leftX: 0, bottomY: 0.97, rightX: 0.21, topY: 0, width: 0.21, height: 0.15 },
  })

  useLocationStore.setState({
    showing: true,
    shifted: false,
    location: { direction: 'NW', main: 'Vespucci Blvd', cross: 'Innocence Blvd', area: 'Vespucci' },
  })

  useStatusStore.setState({
    health: 72,
    maxHealth: 100,
    armor: 48,
    isDead: false,
    statuses: [
      { name: 'hunger', icon: 'utensils',    color: '#f59f00', value: 64, max: 100, flash: false, options: { order: 3 } },
      { name: 'thirst', icon: 'droplet',     color: '#339af0', value: 31, max: 100, flash: true,  options: { order: 4 } },
      { name: 'stress', icon: 'brain',       color: '#f03e3e', value: 15, max: 100, flash: false, options: { order: 5, hideZero: true } },
    ],
    buffDefs: {
      speed_boost:  { icon: 'bolt',          duration: 30000, type: 'timed',     color: '#ffd43b' },
      armor_boost:  { icon: 'shield-halved', duration: 0,     type: 'permanent', color: '#339af0' },
      health_regen: { icon: 'heart-pulse',   duration: 0,     type: 'value',     color: '#fa5252' },
    },
    buffs: [
      { buff: 'speed_boost',  val: 65 },
      { buff: 'armor_boost'            },
      { buff: 'health_regen', val: 40 },
    ],
  })

  useVehicleStore.setState({
    showing: true,
    ignition: true,
    speed: 87,
    rpm: 0.62,
    speedMeasure: 'MPH',
    seatbelt: false,
    seatbeltHide: false,
    cruise: false,
    checkEngine: 0,
    fuel: 43,
    fuelHide: false,
    nos: 0,
    leftSignal: true,
    rightSignal: false,
    battery: false,
    headlights: true,
    doorLock: true,
  })

  useNotificationsStore.setState({
    runningId: 3,
    notifications: [
      { _id: 1, created: Date.now() - 5000,  type: 'success', message: 'Vehicle stored successfully.',           duration: 8000, icon: undefined, hide: false, style: null },
      { _id: 2, created: Date.now() - 12000, type: 'warning', message: 'Low ammo — only <b>3 rounds</b> left.', duration: 0,    icon: undefined, hide: false, style: null },
      { _id: 3, created: Date.now() - 500,   type: 'error',   message: 'You don\'t have enough money.',          duration: 5000, icon: undefined, hide: false, style: null },
    ],
  })

  useProgressStore.setState({
    showing: true,
    label: 'Picking lock...',
    duration: 12000,
    cancelled: false,
    failed: false,
    finished: false,
    startTime: Date.now(),
  })

  useActionStore.setState({ showing: true, message: '[E] Open Door' })
  useAction2Store.setState({ actions: [
    { id: 'inspect', message: '[E] Inspect' },
    { id: 'grab',    message: '[G] Grab Item' },
  ] })

  useInfoOverlayStore.setState({
    showing: true,
    info: { label: 'Fleeca Bank', description: 'Open 09:00 – 21:00 · ATM available outside' },
  })

  useMethStore.setState({ showing: false, config: { ingredients: 4 as unknown as number[], maxCookTime: 90 } })

  // Off by default (full-screen) — toggle via DevPanel
  useGemTableStore.setState({ showing: false, info: { quality: 92 } })

  useArcadeStore.setState({
    showing: false,
    matchInfo: { matchEnd: Date.now() + 115000, matchLabel: 'Team Deathmatch' },
    team1: { current: 8,  max: 25 },
    team2: { current: 12, max: 25 },
  })

  useInteractionStore.setState({ showing: false, items: [], layer: 0 })

  useListStore.setState({
    showing: false,
    active: 'main',
    stack: [],
    menus: {
      main: {
        label: 'Dev Test Menu',
        items: [
          { label: 'Option 1', description: 'First option description', event: 'option1', data: {} },
          { label: 'Sub-menu', submenu: 'sub1' },
          { label: 'Disabled item', description: 'Cannot click this', disabled: true },
          { label: 'With actions', actions: [{ icon: 'trash', event: 'delete' }, { icon: 'pencil', event: 'edit' }] },
        ],
      },
      sub1: {
        label: 'Sub Menu',
        items: [
          { label: 'Back item', event: 'back_option' },
        ],
      },
    },
  })
}
