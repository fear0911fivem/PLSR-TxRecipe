import { useState } from 'react'
import { Box, Text } from '@mantine/core'
import { rem } from '@mantine/core'
import { useHudTheme }        from '../hooks/useHudTheme'
import { COLOR_BG_DARK, COLOR_PANEL_BORDER, COLOR_DIVIDER, COLOR_INPUT_BORDER } from '../hudTheme'
import { useHudStore }         from '../store/hud'
import { useListStore }        from '../store/list'
import { useGemTableStore }    from '../store/gemTable'
import { useArcadeStore }      from '../store/arcade'
import { useStatusStore }      from '../store/status'
import { useInputStore }       from '../store/input'
import { useConfirmStore }     from '../store/confirm'
import { useMethStore }        from '../store/meth'
import { useAppStore }         from '../store/app'
import { useProgressStore }    from '../store/progress'
import { useVehicleStore }     from '../store/vehicle'
import { useInteractionStore } from '../store/interaction'
import { useInfoOverlayStore } from '../store/infoOverlay'
import { useOverlayStore }     from '../store/overlay'

function Section({ label, primary }: { label: string; primary: string }) {
  return (
    <Box style={{ marginTop: rem(12), marginBottom: rem(7) }}>
      <Text style={{
        fontSize: rem(10), fontWeight: 700,
        letterSpacing: '0.1em', textTransform: 'uppercase',
        color: 'rgba(255,255,255,0.35)', lineHeight: 1,
      }}>
        {label}
      </Text>
      <Box style={{ width: rem(14), height: rem(1), background: primary, marginTop: rem(4), opacity: 0.55 }} />
    </Box>
  )
}

function Btn({ label, onClick, primary }: { label: string; onClick: () => void; primary: string }) {
  return (
    <Box
      onClick={onClick}
      style={{
        cursor: 'pointer',
        padding: `${rem(5)} ${rem(10)}`,
        border: `1px solid ${COLOR_INPUT_BORDER}`,
        color: 'rgba(255,255,255,0.5)',
        fontSize: rem(11),
        letterSpacing: '0.05em',
        userSelect: 'none' as const,
        background: 'transparent',
      }}
      onMouseEnter={(e) => {
        const el = e.currentTarget as HTMLElement
        el.style.color = '#fff'
        el.style.borderColor = `${primary}70`
        el.style.background = `${primary}12`
      }}
      onMouseLeave={(e) => {
        const el = e.currentTarget as HTMLElement
        el.style.color = 'rgba(255,255,255,0.5)'
        el.style.borderColor = COLOR_INPUT_BORDER
        el.style.background = 'transparent'
      }}
    >
      {label}
    </Box>
  )
}

export default function DevPanel() {
  const [open, setOpen] = useState(false)
  const { primary } = useHudTheme()

  if (!open) {
    return (
      <Box
        onClick={() => setOpen(true)}
        style={{
          position: 'fixed', bottom: rem(10), left: rem(10), zIndex: 9999,
          background: COLOR_BG_DARK,
          border: `1px solid ${primary}50`,
          padding: `${rem(5)} ${rem(12)}`,
          cursor: 'pointer',
        }}
      >
        <Text style={{
          fontSize: rem(11), fontWeight: 700,
          letterSpacing: '0.12em', textTransform: 'uppercase',
          color: primary, lineHeight: 1,
        }}>
          DEV ▲
        </Text>
      </Box>
    )
  }

  const toggle = (key: string) => {
    switch (key) {
      case 'settings':
        useHudStore.setState((s) => ({ settings: !s.settings })); break
      case 'list':
        useListStore.setState((s) => ({ showing: !s.showing })); break
      case 'gemtable':
        useGemTableStore.setState((s) => ({ showing: !s.showing })); break
      case 'arcade':
        useArcadeStore.setState((s) => ({ showing: !s.showing })); break
      case 'dead':
        useStatusStore.setState((s) => ({ isDead: !s.isDead })); break
      case 'blindfold':
        useAppStore.setState((s) => ({ blindfolded: !s.blindfolded })); break
      case 'flashbang':
        useAppStore.setState({ flashbanged: { strength: 0.9, duration: 3000 } }); break
      case 'deathtexts':
        useAppStore.setState((s) => ({
          isDeathTexts: !s.isDeathTexts,
          deathTime: Date.now() + 300000,
          releaseTimer: Date.now() + 30000,
          releaseType: 'knockout',
          releaseKey: 'X',
          helpKey: 'F1',
          medicalPrice: 1500,
        })); break
      case 'input':
        useInputStore.setState({
          showing: true, title: 'Transfer Funds', event: 'transfer', data: null,
          label: null, type: null, options: {},
          inputs: [
            { id: 'amount', type: 'number', options: { label: 'Amount ($)', min: 1 } },
            { id: 'reason', type: 'text',   options: { label: 'Reason' } },
          ],
        } as Parameters<typeof useInputStore.setState>[0]); break
      case 'confirm':
        useConfirmStore.setState({
          showing: true, title: 'Delete Vehicle?',
          description: 'This action <b>cannot be undone</b>.',
          yes: 'confirm_delete', no: 'cancel_delete',
          acceptLabel: 'Delete', denyLabel: 'Cancel', data: null,
        }); break
      case 'meth':
        useMethStore.setState({ showing: true, config: { ingredients: 4, cookTimeMax: 60, tableId: 'table_01' } as unknown as never }); break
      case 'vehicle':
        useVehicleStore.setState((s) => ({ showing: !s.showing })); break
      case 'doorlock':
        useVehicleStore.setState((s) => ({ doorLock: !s.doorLock })); break
      case 'progress':
        useProgressStore.setState((s) => ({
          showing: !s.showing,
          label: 'Lockpicking...',
          duration: 12000,
          cancelled: false, failed: false, finished: false,
          startTime: Date.now(),
        })); break
      case 'infooverlay':
        useInfoOverlayStore.setState((s) => ({ showing: !s.showing })); break
      case 'imageoverlay':
        useOverlayStore.setState((s) => s.showing
          ? { showing: false, data: {} }
          : { showing: true, data: [{ Name: 'hunting_map_dark' }] as unknown as Record<string, unknown> }
        ); break
      case 'interaction':
        useInteractionStore.setState((s) => ({
          showing: !s.showing,
          layer: 0,
          items: s.showing ? [] : [
            { id: 'inventory',  label: 'Inventory',  icon: 'backpack'       },
            { id: 'phone',      label: 'Phone',      icon: 'mobile-screen'  },
            { id: 'job',        label: 'Job Menu',   icon: 'briefcase'      },
            { id: 'emotes',     label: 'Emotes',     icon: 'person-walking' },
            { id: 'settings',   label: 'Settings',   icon: 'gear'           },
            { id: 'vehicle',    label: 'Vehicle',    icon: 'car'            },
          ],
        })); break
      case 'voip-off':
        useHudStore.setState({ voip: 0, talking: 0, voipIcon: 'microphone' }); break
      case 'voip-whisper':
        useHudStore.setState({ voip: 1, talking: 0, voipIcon: 'microphone' }); break
      case 'voip-talk':
        useHudStore.setState({ voip: 2, talking: 0, voipIcon: 'microphone' }); break
      case 'voip-shout':
        useHudStore.setState({ voip: 3, talking: 0, voipIcon: 'microphone' }); break
      case 'voip-radio':
        useHudStore.setState({ voip: 0, talking: 4, voipIcon: 'walkie-talkie' }); break
      case 'voip-radio-talking':
        useHudStore.setState({ voip: 2, talking: 4, voipIcon: 'walkie-talkie' }); break
    }
  }

  const btn = (label: string, key: string) => (
    <Btn key={key} label={label} onClick={() => toggle(key)} primary={primary} />
  )

  return (
    <Box style={{
      position: 'fixed', bottom: rem(10), left: rem(10), zIndex: 9999,
      background: COLOR_BG_DARK,
      border: `1px solid ${COLOR_PANEL_BORDER}`,
      overflow: 'hidden',
      width: rem(178),
    }}>
      {/* Header */}
      <Box style={{
        padding: `${rem(9)} ${rem(12)}`,
        display: 'flex', justifyContent: 'space-between', alignItems: 'center',
        borderBottom: `1px solid ${COLOR_DIVIDER}`,
      }}>
        <Text style={{
          fontSize: rem(11), fontWeight: 700,
          letterSpacing: '0.12em', textTransform: 'uppercase',
          color: primary, lineHeight: 1,
        }}>
          Dev Panel
        </Text>
        <Box
          onClick={() => setOpen(false)}
          style={{ cursor: 'pointer', color: 'rgba(255,255,255,0.25)', fontSize: rem(11), lineHeight: 1 }}
          onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = '#fff' }}
          onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = 'rgba(255,255,255,0.25)' }}
        >
          ▼
        </Box>
      </Box>

      {/* Sections */}
      <Box style={{ padding: `${rem(2)} ${rem(12)} ${rem(12)}` }}>
        <Section label="Dialogs" primary={primary} />
        <Box style={{ display: 'flex', flexDirection: 'column', gap: rem(4) }}>
          {btn('Input Dialog',   'input')}
          {btn('Confirm Dialog', 'confirm')}
          {btn('Meth Dialog',    'meth')}
          {btn('Settings',       'settings')}
        </Box>

        <Section label="Menus" primary={primary} />
        <Box style={{ display: 'flex', flexDirection: 'column', gap: rem(4) }}>
          {btn('List Menu', 'list')}
          {btn('GemTable',  'gemtable')}
          {btn('Arcade',    'arcade')}
        </Box>

        <Section label="App States" primary={primary} />
        <Box style={{ display: 'flex', flexDirection: 'column', gap: rem(4) }}>
          {btn('Toggle Dead',      'dead')}
          {btn('Toggle Blindfold', 'blindfold')}
          {btn('Flashbang',        'flashbang')}
          {btn('Death Texts',      'deathtexts')}
        </Box>

        <Section label="HUD Parts" primary={primary} />
        <Box style={{ display: 'flex', flexDirection: 'column', gap: rem(4) }}>
          {btn('Toggle Vehicle',  'vehicle')}
          {btn('Toggle Door Lock','doorlock')}
          {btn('Toggle Progress', 'progress')}
          {btn('Interaction',     'interaction')}
          {btn('Info Overlay',    'infooverlay')}
          {btn('Image Overlay',   'imageoverlay')}
        </Box>

        <Section label="Voip" primary={primary} />
        <Box style={{ display: 'flex', flexDirection: 'column', gap: rem(4) }}>
          {btn('Off',           'voip-off')}
          {btn('Whisper',       'voip-whisper')}
          {btn('Talk',          'voip-talk')}
          {btn('Shout',         'voip-shout')}
          {btn('Radio Idle',    'voip-radio')}
          {btn('Radio Talking', 'voip-radio-talking')}
        </Box>
      </Box>
    </Box>
  )
}
