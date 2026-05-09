import React from 'react';
import { useSelector } from 'react-redux';
import { Box, Center, Stack, Flex, Text, Image } from '@mantine/core';

import { ACCENT, TEXT_DIM, LOGO } from '../../theme';

export default () => {
    const loading = useSelector((state) => state.loader.loading);
    const message = useSelector((state) => state.loader.message);

    if (!loading) return null;

    return (
        <Center
            style={{
                position: 'absolute',
                inset: 0,
                zIndex: 900,
                pointerEvents: 'none',
            }}
        >
            <Stack
                align="center"
                gap={0}
                style={{
                    animation: 'fadeInUp 0.5s ease',
                    animationFillMode: 'both',
                }}
            >
                <Image
                    src={LOGO}
                    alt="Pulsar"
                    style={{
                        width: 460,
                        maxWidth: '65vw',
                        display: 'block',
                        marginBottom: 36,
                        transform: 'translateX(-10%)',
                    }}
                />

                <Flex
                    gap={3}
                    style={{
                        width: 460,
                        maxWidth: '65vw',
                        marginBottom: 18,
                    }}
                >
                    {Array.from({ length: 16 }).map((_, i) => (
                        <Box
                            key={`seg-${i}`}
                            style={{
                                flex: 1,
                                height: 2,
                                background: ACCENT,
                                opacity: 0.15,
                                animation: 'segmentPulse 1.6s ease-in-out infinite',
                                animationDelay: `${i * 0.1}s`,
                            }}
                        />
                    ))}
                </Flex>

                <Text
                    fz={13}
                    fw={600}
                    tt="uppercase"
                    c={TEXT_DIM}
                    style={{ letterSpacing: '5px' }}
                >
                    {message}
                </Text>
            </Stack>

            <style>{`
                @keyframes segmentPulse {
                    0%, 100% { opacity: 0.1; }
                    50% { opacity: 0.7; }
                }
            `}</style>
        </Center>
    );
};
