import React, { useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Box, Flex, Text } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import { SelectSpawn } from '../../../util/NuiEvents';
import Nui from '../../../util/Nui';
import { ACCENT, BG_ACTIVE, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_FAINT, BORDER_SUBTLE } from '../../../theme';

export default ({ spawn, onPlay, index }) => {
    const dispatch = useDispatch();
    const selected = useSelector((state) => state.spawn.selected);
    const [hovered, setHovered] = useState(false);

    const isActive = selected?.id === spawn?.id;

    const onClick = () => {
        Nui.send(SelectSpawn, { spawn });
        dispatch({ type: 'SELECT_SPAWN', payload: spawn });
    };

    return (
        <Flex
            align="center"
            onClick={onClick}
            onDoubleClick={onPlay}
            onMouseEnter={() => setHovered(true)}
            onMouseLeave={() => setHovered(false)}
            style={{
                height: 54,
                position: 'relative',
                background: isActive ? BG_ACTIVE : hovered ? 'rgba(255,255,255,0.03)' : 'transparent',
                borderBottom: `1px solid ${BORDER_SUBTLE}`,
                cursor: 'pointer',
                userSelect: 'none',
                transition: 'background 0.15s ease',
                animation: 'slideInLeft 0.3s ease',
                animationFillMode: 'both',
                animationDelay: `${index * 0.05}s`,
            }}
        >
            {/* Active left bar */}
            <Box
                style={{
                    position: 'absolute',
                    left: 0, top: 0, bottom: 0,
                    width: 2,
                    background: ACCENT,
                    opacity: isActive ? 1 : 0,
                    transition: 'opacity 0.15s ease',
                }}
            />

            {/* Icon */}
            <Flex
                align="center"
                justify="center"
                style={{
                    width: 54,
                    fontSize: 12,
                    color: isActive ? ACCENT : hovered ? TEXT_SECONDARY : TEXT_FAINT,
                    flexShrink: 0,
                    transition: 'color 0.15s ease',
                }}
            >
                <FontAwesomeIcon icon={spawn.icon || 'location-dot'} />
            </Flex>

            {/* Label */}
            <Box style={{ flex: 1, paddingRight: 16 }}>
                <Text
                    fz={13}
                    fw={isActive ? 600 : 400}
                    c={isActive ? TEXT_PRIMARY : hovered ? TEXT_SECONDARY : TEXT_FAINT}
                    style={{ transition: 'color 0.15s ease' }}
                >
                    {spawn.label}
                </Text>
                {isActive && (
                    <Text
                        fz={9}
                        c={TEXT_FAINT}
                        tt="uppercase"
                        style={{ letterSpacing: '1.5px', marginTop: 2 }}
                    >
                        Double click to play
                    </Text>
                )}
            </Box>
        </Flex>
    );
};
