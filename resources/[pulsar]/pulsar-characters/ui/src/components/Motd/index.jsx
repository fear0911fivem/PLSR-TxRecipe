import React from 'react';
import { Flex, Text } from '@mantine/core';
import { ACCENT, ACCENT_DIM, BG_BASE, TEXT_PRIMARY } from '../../theme';

export default ({ message }) => (
    <Flex
        align="stretch"
        style={{
            position: 'absolute',
            top: 24,
            left: 24,
            height: 36,
            width: 'fit-content',
            maxWidth: 520,
            pointerEvents: 'none',
            zIndex: 10,
            background: BG_BASE,
            borderLeft: `2px solid ${ACCENT}`,
            animation: 'slideInLeft 0.4s ease',
            animationFillMode: 'both',
        }}
    >
        <Text
            fz={9}
            fw={700}
            tt="uppercase"
            c={ACCENT}
            style={{
                display: 'flex',
                alignItems: 'center',
                padding: '0 10px',
                borderRight: `1px solid ${ACCENT_DIM}`,
                flexShrink: 0,
                letterSpacing: '2.5px',
            }}
        >
            MOTD
        </Text>
        <Text
            fz={13}
            c={TEXT_PRIMARY}
            style={{
                display: 'flex',
                alignItems: 'center',
                padding: '0 14px',
                letterSpacing: '0.3px',
                whiteSpace: 'nowrap',
                overflow: 'hidden',
                textOverflow: 'ellipsis',
            }}
        >
            {message}
        </Text>
    </Flex>
);
