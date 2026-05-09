import { useState } from 'react'
import { Box, Text } from '@mantine/core'
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome'
import type { IconProp } from '@fortawesome/fontawesome-svg-core'
import parse from 'html-react-parser'
import DOMPurify from 'dompurify'
import { rem } from '@mantine/core'
import { useListStore, ListItem } from '../../store/list'
import { nui } from '../../nui'
import { COLOR_PRIMARY } from '../../hudTheme'

interface Props { index: number; item: ListItem }

export default function ListItemRow({ index, item }: Props) {
  const [hovered, setHovered] = useState(false)
  const isClickable = !item.actions && !item.disabled && (Boolean(item.event) || Boolean(item.submenu))
  const active = hovered && !item.disabled

  const onClick = () => {
    if (item.disabled) return
    if (item.submenu) {
      nui.send('ListMenu:SubMenu', { submenu: item.submenu })
      useListStore.setState((s) => ({
        active: item.submenu as string,
        stack: [...s.stack, s.active],
      }))
    } else if (item.event) {
      nui.send('ListMenu:Clicked', { event: item.event, data: item.data })
    }
  }

  const onAction = (event: string) =>
    nui.send('ListMenu:Clicked', { event, data: item.data })

  return (
    <Box
      onClick={isClickable ? onClick : undefined}
      onMouseEnter={() => setHovered(true)}
      onMouseLeave={() => setHovered(false)}
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: rem(12),
        padding: `${rem(11)} ${rem(16)}`,
        cursor: isClickable ? 'pointer' : 'default',
        opacity: item.disabled ? 0.3 : 1,
        background: active ? `${COLOR_PRIMARY}0d` : 'transparent',
        transition: 'background 0.12s ease',
      }}
    >
      {/* Dot indicator */}
      <Box
        style={{
          width: rem(5),
          height: rem(5),
          borderRadius: '50%',
          background: active ? COLOR_PRIMARY : 'rgba(255,255,255,0.15)',
          flexShrink: 0,
          transition: 'background 0.12s ease',
        }}
      />

      {/* Text */}
      <Box style={{ flex: 1, minWidth: 0 }}>
        <Text
          style={{
            fontSize: rem(14),
            fontWeight: active ? 600 : 400,
            color: active ? '#fff' : 'rgba(255,255,255,0.72)',
            lineHeight: 1,
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
            transition: 'color 0.12s ease',
          }}
        >
          {item.label}
        </Text>
        {item.description && (
          <Text
            style={{
              fontSize: rem(12),
              color: 'rgba(255,255,255,0.28)',
              marginTop: rem(3),
              lineHeight: 1.3,
            }}
          >
            {parse(DOMPurify.sanitize(item.description))}
          </Text>
        )}
      </Box>

      {/* Submenu chevron */}
      {item.submenu && (
        <FontAwesomeIcon
          icon={['fas', 'chevron-right']}
          style={{
            color: active ? COLOR_PRIMARY : 'rgba(255,255,255,0.18)',
            fontSize: rem(9),
            flexShrink: 0,
            transition: 'color 0.12s ease',
          }}
        />
      )}

      {/* Row actions */}
      {item.actions && (
        <Box style={{ display: 'flex', gap: rem(10), flexShrink: 0 }}>
          {item.actions.map((action, k) => (
            <Box
              key={`${index}-${k}`}
              onClick={(e) => { e.stopPropagation(); onAction(action.event) }}
              style={{ cursor: 'pointer', color: 'rgba(255,255,255,0.3)', fontSize: rem(11), transition: 'color 0.1s ease' }}
              onMouseEnter={(e) => { (e.currentTarget as HTMLElement).style.color = COLOR_PRIMARY }}
              onMouseLeave={(e) => { (e.currentTarget as HTMLElement).style.color = 'rgba(255,255,255,0.3)' }}
            >
              <FontAwesomeIcon icon={['fas', action.icon] as unknown as IconProp} />
            </Box>
          ))}
        </Box>
      )}
    </Box>
  )
}
