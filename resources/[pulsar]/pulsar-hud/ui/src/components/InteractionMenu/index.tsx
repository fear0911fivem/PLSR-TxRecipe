import { useRef, useState, useCallback } from 'react'
import { Box, Text } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import { rem } from '@mantine/core'
import { useInteractionStore } from '../../store/interaction'
import { nui } from '../../nui'
import {
  COLOR_PRIMARY, COLOR_BG_DARK, COLOR_BAR_BG,
  INTERACTION_RADIUS, INTERACTION_DEAD_ZONE,
} from '../../hudTheme'

const RADIUS    = INTERACTION_RADIUS
const ITEM_SIZE = 66
const DEAD_ZONE = INTERACTION_DEAD_ZONE

export default function InteractionMenu() {
  const { showing, items, layer } = useInteractionStore()
  const [hoveredIdx, setHoveredIdx] = useState(-1)
  const containerRef = useRef<HTMLDivElement>(null)

  const handleMouseMove = useCallback((e: React.MouseEvent) => {
    const el = containerRef.current
    if (!el || items.length === 0) return
    const rect = el.getBoundingClientRect()
    const dx = e.clientX - (rect.left + rect.width  / 2)
    const dy = e.clientY - (rect.top  + rect.height / 2)
    if (Math.sqrt(dx * dx + dy * dy) < DEAD_ZONE) { setHoveredIdx(-1); return }
    const mouseAngle = Math.atan2(dy, dx)
    let closest = 0, minDiff = Infinity
    items.forEach((_, i) => {
      const itemAngle = (i / items.length) * 2 * Math.PI - Math.PI / 2
      let diff = Math.abs(mouseAngle - itemAngle)
      if (diff > Math.PI) diff = 2 * Math.PI - diff
      if (diff < minDiff) { minDiff = diff; closest = i }
    })
    setHoveredIdx(closest)
  }, [items])

  const handleClick = () => {
    if (hoveredIdx < 0 || !items[hoveredIdx]) return
    nui.send('Interaction:Trigger', { id: items[hoveredIdx].id })
  }

  const handleBack = (e: React.MouseEvent) => {
    e.stopPropagation()
    nui.send('Interaction:Back', {})
  }

  const handleHide = (e: React.MouseEvent) => {
    if (e.target === e.currentTarget) nui.send('Interaction:Hide', {})
  }

  const handleClose = (e: React.MouseEvent) => {
    e.stopPropagation()
    nui.send('Interaction:Hide', {})
  }

  if (!showing) return null

  return (
    <Box
      ref={containerRef}
      onClick={handleHide}
      onMouseMove={handleMouseMove}
      style={{
        position: 'absolute',
        inset: 0,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        zIndex: 500,
      }}
    >
      {/* Items */}
      {items.map((item, i) => {
        const angle  = (i / items.length) * 2 * Math.PI - Math.PI / 2
        const x      = Math.cos(angle) * RADIUS
        const y      = Math.sin(angle) * RADIUS
        const active = hoveredIdx === i

        return (
          <Box
            key={item.id}
            onClick={handleClick}
            style={{
              position: 'absolute',
              width:  rem(ITEM_SIZE),
              height: rem(ITEM_SIZE),
              left:  `calc(50% + ${rem(x)} - ${rem(ITEM_SIZE / 2)})`,
              top:   `calc(50% + ${rem(y)} - ${rem(ITEM_SIZE / 2)})`,
              display: 'flex',
              flexDirection: 'column',
              alignItems: 'center',
              justifyContent: 'center',
              gap: rem(5),
              background: COLOR_BG_DARK,
              border: `${active ? '2px' : '1px'} solid ${active ? COLOR_PRIMARY : COLOR_BAR_BG}`,
              cursor: 'pointer',
              transform: active ? 'scale(1.08)' : 'scale(1)',
              transition: 'transform 0.1s ease, border-color 0.1s ease, border-width 0.1s ease',
              userSelect: 'none',
            }}
          >
            {item.icon && (
              <FontAwesomeIcon
                icon={['fas', item.icon] as IconProp}
                style={{ color: active ? COLOR_PRIMARY : 'rgba(255,255,255,0.7)', fontSize: rem(24) }}
              />
            )}
            <Text
              style={{
                fontSize: rem(12),
                fontWeight: 600,
                color: active ? '#fff' : 'rgba(255,255,255,0.55)',
                letterSpacing: '0.04em',
                textAlign: 'center',
                lineHeight: 1.2,
                maxWidth: rem(ITEM_SIZE - 8),
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
              }}
            >
              {item.label}
            </Text>
          </Box>
        )
      })}

      {/* Center hub */}
      <Box
        onClick={layer > 0 ? handleBack : handleClose}
        style={{
          position: 'absolute',
          width:  rem(44),
          height: rem(44),
          borderRadius: '50%',
          background: COLOR_BG_DARK,
          border: `1px solid ${COLOR_BAR_BG}`,
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          cursor: 'pointer',
          zIndex: 100,
        }}
      >
        <FontAwesomeIcon
          icon={layer > 0 ? ['fas', 'arrow-left'] : ['fas', 'xmark']}
          style={{ color: 'rgba(255,255,255,0.4)', fontSize: rem(14) }}
        />
      </Box>
    </Box>
  )
}
