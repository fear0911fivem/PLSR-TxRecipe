import React from 'react';
import { useSelector } from 'react-redux';
import { Box, Flex, Text } from '@mantine/core';

import { Motd } from '../../components';
import CharacterButton from './components/CharacterButton';
import CreateCharacter from './components/CreateCharacter';
import { TEXT_DIM, TEXT_SECONDARY, TEXT_FAINT } from '../../theme';

export default () => {
    const characters = useSelector((state) => state.characters.characters);
    const characterLimit = useSelector((state) => state.characters.characterLimit);
    const motd = useSelector((state) => state.characters.motd);

    return (
        <Box
            style={{
                height: '100vh',
                width: '100vw',
                position: 'relative',
                display: 'flex',
                alignItems: 'flex-end',
                justifyContent: 'flex-start',
            }}
        >
            {Boolean(motd) && <Motd message={motd} />}

            <Flex align="flex-end" gap={10} pl={60} pb={72}>
                {characters.map((char, i) => (
                    <CharacterButton key={`char-${char.ID ?? i}`} character={char} index={i} />
                ))}
                {characters.length < characterLimit && (
                    <CreateCharacter index={characters.length} />
                )}
            </Flex>

            <Flex
                gap={18}
                style={{
                    position: 'absolute',
                    bottom: 22,
                    left: '50%',
                    transform: 'translateX(-50%)',
                    pointerEvents: 'none',
                }}
            >
                <Text fz={10} c={TEXT_DIM} style={{ letterSpacing: '0.8px' }}>
                    <Text component="span" c={TEXT_SECONDARY}>DOUBLE CLICK</Text> to play
                </Text>
                <Text fz={10} c={TEXT_FAINT} style={{ letterSpacing: '0.8px' }}>·</Text>
                <Text fz={10} c={TEXT_DIM} style={{ letterSpacing: '0.8px' }}>
                    <Text component="span" c={TEXT_SECONDARY}>RIGHT CLICK</Text> to delete
                </Text>
            </Flex>
        </Box>
    );
};
