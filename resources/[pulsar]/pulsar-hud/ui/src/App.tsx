import React, { useEffect } from 'react'
import { MantineProvider } from '@mantine/core'
import { Notifications } from '@mantine/notifications'
import { theme } from './hudTheme'
import { useNuiRouter } from './hooks/useNuiRouter'
import { nui } from './nui'

// App overlays
import Dead       from './components/App/Dead'
import Blindfold  from './components/App/Blindfold'
import Flashbang  from './components/App/Flashbang'
import DeathTexts from './components/App/DeathTexts'

// Notifications (custom HUD notifications — distinct from Mantine Notifications)
import HudNotifications from './components/Notifications'

// HUD layouts
import HudDefault from './components/Hud/Default'

// Dialogs
import InputDialog   from './components/Input'
import ConfirmDialog from './components/Confirm'
import MethDialog    from './components/Meth'
import Settings      from './components/Settings'

// Menus
import ListMenu         from './components/List'
import InfoOverlay      from './components/InfoOverlay'
import InteractionMenu  from './components/InteractionMenu'

// Persistent overlays
import ImageOverlay from './components/Overlay'
import GemTable     from './components/GemTable'
import Arcade       from './components/Arcade'

// Action banners
import { ActionBanner, Action2List } from './components/Action'

// Progress
import ProgressBar from './components/Progress'

// Dev-only helpers
if (import.meta.env.DEV) {
  ;(window as unknown as Record<string, unknown>).nui = (type: string, data?: unknown) =>
    nui.emulate(type, data)
}

// Lazy-loaded dev modules (tree-shaken from production build)
const DevPanel = import.meta.env.DEV
  ? React.lazy(() => import('./dev/DevPanel'))
  : null
const seedDevStores = import.meta.env.DEV
  ? () => import('./dev/seed').then((m) => m.seedDevStores())
  : null

export default function App() {
  useNuiRouter()

  useEffect(() => {
    if (seedDevStores) seedDevStores()
  }, [])

  return (
    <MantineProvider theme={theme} defaultColorScheme="dark">
      <Notifications position="top-right" />

      {/* Full-screen overlays (order matters — layered top-to-bottom) */}
      <Dead />
      <Flashbang />
      <Blindfold />
      <DeathTexts />

      {/* Main HUD */}
      <HudDefault />

      {/* Custom notification stack */}
      <HudNotifications />

      {/* Progress bar */}
      <ProgressBar />

      {/* Action banners */}
      <ActionBanner />
      <Action2List />

      {/* Info panels */}
      <InfoOverlay />
      <ImageOverlay />
      <GemTable />
      <Arcade />

      {/* Menus */}
      <ListMenu />
      <InteractionMenu />

      {/* Dialogs */}
      <InputDialog />
      <ConfirmDialog />
      <MethDialog />
      <Settings />

      {/* Dev panel — tree-shaken in production */}
      {import.meta.env.DEV && DevPanel && (
        <React.Suspense fallback={null}>
          <DevPanel />
        </React.Suspense>
      )}
    </MantineProvider>
  )
}
