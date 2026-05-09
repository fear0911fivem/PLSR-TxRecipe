import React, { useState } from 'react';
import { useDispatch } from 'react-redux';
import { Box, Flex, Stack, Text, TextInput, Textarea, Select, Button } from '@mantine/core';
import { DatePickerInput } from '@mantine/dates';
import { getCodeList } from 'country-list';
import dayjs from 'dayjs';
import { FontAwesomeIcon } from '@fortawesome/react-fontawesome';

import Nui from '../../util/Nui';
import { STATE_CHARACTERS } from '../../util/States';
import { CreateCharacter } from '../../util/NuiEvents';
import { ACCENT, ACCENT_DIM, BG_BASE, BG_INPUT, TEXT_PRIMARY, TEXT_SECONDARY, TEXT_DIM, BORDER_SUBTLE, BORDER_DIM, CREATE_PANEL_WIDTH } from '../../theme';

const countryCodes = getCodeList();
const countryOptions = Object.entries(countryCodes).map(([code, name]) => ({
    value: code,
    label: name,
}));

const genderOptions = [
    { value: '0', label: 'Male' },
    { value: '1', label: 'Female' },
];

const TEXTAREA_STYLES = {
    input: {
        background: BG_INPUT,
        border: `1px solid ${BORDER_DIM}`,
        borderRadius: 2,
        color: TEXT_PRIMARY,
        padding: '12px 14px',
        fontSize: 15,
    },
    label: {
        color: TEXT_DIM,
        fontSize: 10,
        fontWeight: 700,
        letterSpacing: '2.5px',
        textTransform: 'uppercase',
        marginBottom: 8,
    },
};

const INPUT_STYLES = {
    input: {
        background: BG_INPUT,
        border: `1px solid ${BORDER_DIM}`,
        borderRadius: 2,
        color: TEXT_PRIMARY,
        padding: '12px 14px',
        fontSize: 15,
        height: 48,
        minHeight: 48,
    },
    label: {
        color: TEXT_DIM,
        fontSize: 10,
        fontWeight: 700,
        letterSpacing: '2.5px',
        textTransform: 'uppercase',
        marginBottom: 8,
    },
    dropdown: {
        background: BG_INPUT,
        border: `1px solid ${BORDER_SUBTLE}`,
        borderRadius: 2,
        padding: 4,
    },
    option: {
        color: TEXT_SECONDARY,
        borderRadius: 2,
        fontSize: 15,
        '&[dataSelected]': {
            background: ACCENT,
            color: '#fff',
        },
        '&[dataHovered]': {
            background: ACCENT_DIM,
            color: TEXT_PRIMARY,
        },
    },
};

const Corner = ({ top, left, right, bottom }) => (
    <Box
        style={{
            position: 'absolute',
            top, left, right, bottom,
            width: 18,
            height: 18,
            borderTop: top !== undefined ? `2px solid ${ACCENT}` : undefined,
            borderBottom: bottom !== undefined ? `2px solid ${ACCENT}` : undefined,
            borderLeft: left !== undefined ? `2px solid ${ACCENT}` : undefined,
            borderRight: right !== undefined ? `2px solid ${ACCENT}` : undefined,
            opacity: 0.7,
        }}
    />
);

export default () => {
    const dispatch = useDispatch();

    const [state, setState] = useState({
        first: '',
        last: '',
        dob: dayjs().subtract(18, 'year').toDate(),
        gender: '0',
        bio: '',
        origin: null,
    });

    const set = (key) => (val) => setState((s) => ({ ...s, [key]: val }));
    const onChange = (key) => (e) => set(key)(e.target.value);

    const onSubmit = (e) => {
        e.preventDefault();
        Nui.send(CreateCharacter, {
            first: state.first,
            last: state.last,
            gender: state.gender,
            dob: dayjs(state.dob).format('YYYY-MM-DD'),
            origin: state.origin,
            bio: state.bio,
            lastPlayed: -1,
        });
        dispatch({ type: 'LOADING_SHOW', payload: { message: 'Creating Character' } });
    };

    const goBack = () => dispatch({ type: 'SET_STATE', payload: { state: STATE_CHARACTERS } });

    return (
        <Flex
            align="center"
            justify="flex-end"
            style={{ height: '100vh', width: '100vw', position: 'relative', paddingRight: '10%' }}
        >
            <Box
                style={{
                    width: CREATE_PANEL_WIDTH,
                    maxHeight: '88vh',
                    position: 'relative',
                    display: 'flex',
                    flexDirection: 'column',
                    background: BG_BASE,
                    animation: 'slideInRight 0.38s cubic-bezier(0.22,1,0.36,1)',
                    animationFillMode: 'both',
                }}
            >
                <Corner top={0} left={0} />
                <Corner top={0} right={0} />
                <Corner bottom={0} left={0} />
                <Corner bottom={0} right={0} />

                {/* Top accent line */}
                <Box style={{ height: 1, background: `linear-gradient(90deg, ${ACCENT}, transparent)`, opacity: 0.4 }} />

                {/* Header */}
                <Flex
                    align="flex-start"
                    justify="space-between"
                    style={{ padding: '22px 28px 20px', borderBottom: `1px solid ${BORDER_SUBTLE}`, flexShrink: 0 }}
                >
                    <Stack gap={8}>
                        <Text
                            fz={10}
                            fw={700}
                            tt="uppercase"
                            c={ACCENT}
                            style={{ letterSpacing: '4px', opacity: 0.8 }}
                        >
                            Pulsar Framework
                        </Text>
                        <Text fw={700} c={TEXT_PRIMARY} style={{ fontSize: 28, letterSpacing: '-0.3px', lineHeight: 1 }}>
                            New Character
                        </Text>
                    </Stack>

                    <Button
                        variant="subtle"
                        onClick={goBack}
                        style={{
                            border: `1px solid ${BORDER_DIM}`,
                            color: TEXT_DIM,
                            width: 30,
                            height: 30,
                            padding: 0,
                            minWidth: 0,
                            flexShrink: 0,
                            marginTop: 2,
                            background: 'none',
                            fontSize: 12,
                        }}
                        styles={{
                            root: {
                                '&:hover': { color: ACCENT, borderColor: ACCENT_DIM, background: 'none' },
                            },
                        }}
                    >
                        <FontAwesomeIcon icon="xmark" />
                    </Button>
                </Flex>

                {/* Form */}
                <Box style={{ flex: 1, overflowY: 'auto', padding: '26px 28px 10px' }}>
                    <form id="createForm" onSubmit={onSubmit} autoComplete="off">
                        <Stack gap={20}>
                            <Flex gap={16}>
                                <TextInput
                                    required
                                    label="First Name"
                                    value={state.first}
                                    onChange={(e) => set('first')(e.target.value.replace(/\s/g, ''))}
                                    styles={INPUT_STYLES}
                                    style={{ flex: 1 }}
                                />
                                <TextInput
                                    required
                                    label="Last Name"
                                    value={state.last}
                                    onChange={(e) => set('last')(e.target.value.replace(/\s/g, ''))}
                                    styles={INPUT_STYLES}
                                    style={{ flex: 1 }}
                                />
                            </Flex>

                            <Select
                                label="Country of Origin"
                                data={countryOptions}
                                value={state.origin}
                                onChange={set('origin')}
                                searchable
                                clearable
                                placeholder="Select country..."
                                styles={INPUT_STYLES}
                            />

                            <Flex gap={16}>
                                <Select
                                    required
                                    label="Gender"
                                    data={genderOptions}
                                    value={state.gender}
                                    onChange={set('gender')}
                                    allowDeselect={false}
                                    size="md"
                                    styles={INPUT_STYLES}
                                    style={{ flex: 1 }}
                                />
                                <DatePickerInput
                                    required
                                    label="Date of Birth"
                                    value={state.dob}
                                    onChange={set('dob')}
                                    maxDate={dayjs().subtract(18, 'year').toDate()}
                                    minDate={dayjs().subtract(100, 'year').toDate()}
                                    valueFormat="MM/DD/YYYY"
                                    size="md"
                                    styles={INPUT_STYLES}
                                    style={{ flex: 1 }}
                                />
                            </Flex>

                            <Textarea
                                required
                                label="Biography"
                                value={state.bio}
                                onChange={onChange('bio')}
                                rows={10}
                                styles={TEXTAREA_STYLES}
                            />
                        </Stack>
                    </form>
                </Box>

                {/* Footer */}
                <Flex
                    justify="flex-end"
                    gap={10}
                    style={{ padding: '16px 28px 22px', borderTop: `1px solid ${BORDER_SUBTLE}`, flexShrink: 0 }}
                >
                    <Button variant="subtle" color="gray" radius={2} size="sm" onClick={goBack}>
                        Cancel
                    </Button>
                    <Button
                        type="submit"
                        form="createForm"
                        color="brand"
                        radius={2}
                        size="sm"
                        style={{ paddingLeft: 28, paddingRight: 28 }}
                    >
                        Create
                    </Button>
                </Flex>

                {/* Bottom accent line */}
                <Box style={{ height: 1, background: `linear-gradient(90deg, transparent, ${ACCENT})`, opacity: 0.3 }} />
            </Box>
        </Flex>
    );
};
