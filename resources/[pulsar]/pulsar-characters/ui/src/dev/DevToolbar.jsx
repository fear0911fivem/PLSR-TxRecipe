import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Box, Flex, Text, Button, Group } from '@mantine/core';
import { STATE_CHARACTERS, STATE_CREATE, STATE_SPAWN } from '../util/States';
import { ACCENT, BG_BASE } from '../theme';

const STATES = [
    { key: STATE_CHARACTERS, label: 'Characters' },
    { key: STATE_CREATE,     label: 'Create' },
    { key: STATE_SPAWN,      label: 'Spawn' },
];

export default () => {
    const dispatch = useDispatch();
    const appState = useSelector((s) => s.app.state);
    const characters = useSelector((s) => s.characters.characters);

    const go = (state) => {
        dispatch({ type: 'LOADING_HIDE' });
        if (state === STATE_SPAWN) {
            dispatch({ type: 'SELECT_CHARACTER', payload: { character: characters[0] } });
        }
        dispatch({ type: 'SET_STATE', payload: { state } });
    };

    return (
        <Flex
            align="center"
            gap={8}
            style={{
                position: 'fixed',
                top: 10,
                left: 10,
                zIndex: 9999,
                background: BG_BASE,
                border: `1px solid ${ACCENT}`,
                borderRadius: 3,
                padding: '6px 10px',
            }}
        >
            <Text fz={9} fw={700} tt="uppercase" c={ACCENT} style={{ letterSpacing: '2px' }}>
                DEV
            </Text>
            <Group gap={4}>
                {STATES.map(({ key, label }) => (
                    <Button
                        key={key}
                        size="xs"
                        variant={appState === key ? 'filled' : 'outline'}
                        color="brand"
                        onClick={() => go(key)}
                        style={{ minWidth: 80 }}
                    >
                        {label}
                    </Button>
                ))}
            </Group>
        </Flex>
    );
};
