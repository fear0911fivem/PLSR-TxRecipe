import { appHandlers } from './app'
import { hudHandlers } from './hud'
import { locationHandlers } from './location'
import { statusHandlers } from './status'
import { vehicleHandlers } from './vehicle'
import { notificationHandlers } from './notifications'
import { progressHandlers } from './progress'
import { actionHandlers } from './action'
import { listHandlers } from './list'
import { inputHandlers } from './input'
import { confirmHandlers } from './confirm'
import { infoOverlayHandlers } from './infoOverlay'
import { overlayHandlers } from './overlay'
import { gemTableHandlers } from './gemTable'
import { methHandlers } from './meth'
import { arcadeHandlers } from './arcade'
import { interactionHandlers } from './interaction'

type Handler = (payload: Record<string, unknown>) => void

// Multiple stores may handle the same action type (e.g. SHOW_HUD updates hud, status, and vehicle).
// The router fans out to all registered handlers for each type.
const routeMap = new Map<string, Handler[]>()

function register(handlers: Record<string, Handler>): void {
  for (const [type, fn] of Object.entries(handlers)) {
    const existing = routeMap.get(type) ?? []
    routeMap.set(type, [...existing, fn])
  }
}

register(appHandlers)
register(hudHandlers)
register(locationHandlers)
register(statusHandlers)
register(vehicleHandlers)
register(notificationHandlers)
register(progressHandlers)
register(actionHandlers)
register(listHandlers)
register(inputHandlers)
register(confirmHandlers)
register(infoOverlayHandlers)
register(overlayHandlers)
register(gemTableHandlers)
register(methHandlers)
register(arcadeHandlers)
register(interactionHandlers)

export function dispatch(type: string, payload: Record<string, unknown>): void {
  const handlers = routeMap.get(type)
  if (handlers) handlers.forEach((fn) => fn(payload))
}
