import React from 'react';
import { useDispatch, useSelector } from 'react-redux';
import { Box, Flex, Stack, Text, ScrollArea, Button } from '@mantine/core';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../util/Nui';
import { Motd } from '../../components';
import SpawnButton from './components/SpawnButton';
import { STATE_CHARACTERS } from '../../util/States';
import { PlayCharacter } from '../../util/NuiEvents';
import { ACCENT, ACCENT_HOVER, BG_BASE, TEXT_PRIMARY, TEXT_FAINT, BORDER_SUBTLE, SPAWN_PANEL_WIDTH } from '../../theme';

export default () => {
    const dispatch = useDispatch();

    const motd     = useSelector((state) => state.characters.motd);
    const spawns   = useSelector((state) => state.spawn.spawns);
    const selected = useSelector((state) => state.spawn.selected);
    const char     = useSelector((state) => state.characters.selected);

    const onSpawn = () => {
        if (!selected) return;
        Nui.send(PlayCharacter, { spawn: selected, character: char });
        dispatch({ type: 'LOADING_SHOW', payload: { message: 'Spawning' } });
        dispatch({ type: 'UPDATE_PLAYED' });
        dispatch({ type: 'DESELECT_CHARACTER' });
        dispatch({ type: 'DESELECT_SPAWN' });
    };

    const goBack = () => {
        dispatch({ type: 'DESELECT_CHARACTER' });
        dispatch({ type: 'DESELECT_SPAWN' });
        dispatch({ type: 'SET_STATE', payload: { state: STATE_CHARACTERS } });
    };

    return (
        <Box style={{ height: '100vh', width: '100vw', display: 'flex', position: 'relative' }}>
            {Boolean(motd) && <Motd message={motd} />}

            {/* Left spawn panel */}
            <Stack
                gap={0}
                style={{
                    width: SPAWN_PANEL_WIDTH,
                    height: '100%',
                    background: BG_BASE,
                    borderRight: `1px solid ${BORDER_SUBTLE}`,
                    animation: 'slideInLeft 0.4s ease',
                    animationFillMode: 'both',
                    flexShrink: 0,
                }}
            >
                {/* Header */}
                <Box style={{ padding: '22px 20px 18px', borderBottom: `1px solid ${BORDER_SUBTLE}`, flexShrink: 0 }}>
                    <Text
                        fz={9}
                        fw={700}
                        tt="uppercase"
                        c={ACCENT}
                        style={{ letterSpacing: '3.5px', marginBottom: 6 }}
                    >
                        Choose Location
                    </Text>
                    <Box style={{ height: 1, background: BORDER_SUBTLE }} />
                </Box>

                {/* Spawn list */}
                <ScrollArea style={{ flex: 1 }}>
                    {spawns.map((spawn, i) => (
                        <SpawnButton key={`spawn-${i}`} spawn={spawn} onPlay={onSpawn} index={i} />
                    ))}
                </ScrollArea>

                {/* Back */}
                <Box style={{ padding: '14px 20px', borderTop: `1px solid ${BORDER_SUBTLE}`, flexShrink: 0 }}>
                    <Button
                        variant="subtle"
                        onClick={goBack}
                        leftSection={<FontAwesomeIcon icon="arrow-left" />}
                        style={{
                            color: TEXT_FAINT,
                            fontSize: 10,
                            letterSpacing: '2px',
                            textTransform: 'uppercase',
                            fontWeight: 700,
                            padding: 0,
                            height: 'auto',
                            background: 'none',
                        }}
                        styles={{
                            root: {
                                '&:hover': { color: ACCENT, background: 'none' },
                            },
                        }}
                    >
                        Back to Characters
                    </Button>
                </Box>
            </Stack>

            {/* Bottom confirmation bar */}
            <Flex
                align="center"
                gap={32}
                style={{
                    position: 'absolute',
                    bottom: 0,
                    left: SPAWN_PANEL_WIDTH,
                    right: 0,
                    background: BG_BASE,
                    borderTop: `1px solid ${selected ? ACCENT : BORDER_SUBTLE}`,
                    padding: '18px 36px',
                    transition: 'border-color 0.3s ease',
                    animation: 'fadeInUp 0.4s ease',
                    animationFillMode: 'both',
                    animationDelay: '0.1s',
                }}
            >
                {/* Spawning as */}
                <Box style={{ flex: 1 }}>
                    <Text
                        fz={9}
                        tt="uppercase"
                        c={TEXT_FAINT}
                        style={{ letterSpacing: '2.5px', marginBottom: 4 }}
                    >
                        Spawning As
                    </Text>
                    <Text fw={700} c={TEXT_PRIMARY} style={{ fontSize: 18, letterSpacing: '-0.2px' }}>
                        {char?.First} {char?.Last}
                    </Text>
                </Box>

                <Box style={{ width: 1, height: 32, background: BORDER_SUBTLE, flexShrink: 0 }} />

                {/* Location */}
                <Box style={{ flex: 1 }}>
                    <Text
                        fz={9}
                        tt="uppercase"
                        c={TEXT_FAINT}
                        style={{ letterSpacing: '2.5px', marginBottom: 4 }}
                    >
                        Location
                    </Text>
                    <Text
                        fw={600}
                        style={{ fontSize: 15, color: selected ? ACCENT : TEXT_FAINT, transition: 'color 0.2s ease' }}
                    >
                        {selected ? selected.label : '— Select a spawn point —'}
                    </Text>
                </Box>

                {/* Play button */}
                <Button
                    onClick={onSpawn}
                    disabled={!selected}
                    color="brand"
                    radius={2}
                    style={{ height: 40, paddingLeft: 32, paddingRight: 32, letterSpacing: '3px', fontSize: 10 }}
                >
                    Play
                </Button>
            </Flex>
        </Box>
    );
};
