import React from 'react';
import { useSelector } from 'react-redux';
import { MantineProvider, createTheme } from '@mantine/core';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import { fab } from '@fortawesome/free-brands-svg-icons';

import Loader from '../Loader';
import Splash from '../Splash';
import Characters from '../Characters';
import Create from '../Create';
import Spawn from '../Spawn';

const DevToolbar = process.env.NODE_ENV !== 'production'
    ? require('../../dev/DevToolbar').default
    : null;

import { STATE_CHARACTERS, STATE_CREATE, STATE_SPAWN } from '../../util/States';
import { ACCENT, BG_BASE, BRAND_COLORS, TEXT_PRIMARY } from '../../theme';

library.add(fab, fas);

const theme = createTheme({
    fontFamily: 'Source Sans Pro, sans-serif',
    primaryColor: 'brand',
    colors: {
        brand: BRAND_COLORS,
    },
    components: {
        Modal: {
            styles: {
                content: { background: BG_BASE, borderLeft: `2px solid ${ACCENT}` },
                header: { background: BG_BASE },
                overlay: { background: 'rgba(0,0,0,0.82)' },
            },
        },
    },
});

const GLOBAL_STYLES = `
    :root { color-scheme: normal !important; }
    * { box-sizing: border-box; }

    @keyframes slideInLeft {
        from { opacity: 0; transform: translateX(-20px); }
        to   { opacity: 1; transform: translateX(0); }
    }
    @keyframes fadeInUp {
        from { opacity: 0; transform: translateY(16px); }
        to   { opacity: 1; transform: translateY(0); }
    }
    @keyframes blinker {
        0%, 70% { opacity: 1; }
        85%, 100% { opacity: 0.15; }
    }
    @keyframes cornerPulse {
        0%, 100% { opacity: 0.3; }
        50% { opacity: 0.9; }
    }
    @keyframes slideInRight {
        from { opacity: 0; transform: translateX(24px); }
        to   { opacity: 1; transform: translateX(0); }
    }
    @keyframes scanLine {
        0%   { transform: translateY(0); opacity: 0.04; }
        50%  { opacity: 0.1; }
        100% { transform: translateY(100vh); opacity: 0.04; }
    }
`;

export default () => {
    const hidden = useSelector((state) => state.app.hidden);
    const appState = useSelector((state) => state.app.state);
    const loading = useSelector((state) => state.loader.loading);

    let display;
    switch (appState) {
        case STATE_CHARACTERS: display = <Characters />; break;
        case STATE_CREATE:     display = <Create />;     break;
        case STATE_SPAWN:      display = <Spawn />;      break;
        default:               display = null;           break;
    }

    return (
        <MantineProvider theme={theme} forceColorScheme="dark">
            <style>{GLOBAL_STYLES}</style>
            {DevToolbar && <DevToolbar />}
            {!hidden && (
                <div style={{
                    height: '100vh',
                    width: '100vw',
                    background: 'transparent',
                    color: TEXT_PRIMARY,
                    fontFamily: 'Source Sans Pro, sans-serif',
                    position: 'relative',
                    overflow: 'hidden',
                }}>
                    {process.env.NODE_ENV === 'production' && <Splash />}
                    {loading ? <Loader /> : display}
                </div>
            )}
        </MantineProvider>
    );
};
