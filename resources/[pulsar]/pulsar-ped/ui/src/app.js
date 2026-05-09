import '@babel/polyfill';

import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';
import CssBaseline from '@mui/material/CssBaseline';
import {
	ThemeProvider,
	createTheme,
	StyledEngineProvider,
} from '@mui/material';

import App from 'containers/App';
import WindowListener from 'containers/WindowListener';
import configureStore from './configureStore';
import KeyListener from './containers/KeyListener';

const initialState = {};
const store = configureStore(initialState);
const MOUNT_NODE = document.getElementById('app');

const render = () => {
	const muiTheme = createTheme({
		typography: {
			fontFamily: ["'Oswald'", 'sans-serif'],
		},
		palette: {
			primary: {
				main: '#b14cff',
				light: '#c97dff',
				dark: '#7a22c9',
				contrastText: '#ffffff',
			},
			secondary: {
				main: '#000000',
				light: '#111111',
				dark: '#000000',
				contrastText: '#ffffff',
			},
			error: {
				main: '#6e1616',
				light: '#a13434',
				dark: '#430b0b',
			},
			success: {
				main: '#52984a',
				light: '#60eb50',
				dark: '#244a20',
			},
			warning: {
				main: '#f09348',
				light: '#f2b583',
				dark: '#b05d1a',
			},
			info: {
				main: '#247ba5',
				light: '#247ba5',
				dark: '#175878',
			},
			text: {
				main: '#ffffff',
				alt: '#cecece',
				info: '#919191',
				light: '#ffffff',
				dark: '#000000',
			},
			rarities: {
				rare1: '#ffffff',
				rare2: '#52984a',
				rare3: '#247ba5',
				rare4: '#8e3bb8',
				rare5: '#f2d411',
			},
			border: {
				main: '#e0e0e008',
				light: '#ffffff',
				dark: '#26292d',
				input: 'rgba(255, 255, 255, 0.23)',
				divider: 'rgba(255, 255, 255, 0.12)',
			},
			mode: 'dark',
		},
		components: {
			MuiCssBaseline: {
				styleOverrides: {
					html: {
						background:
							process.env.NODE_ENV != 'production'
								? '#000000'
								: 'transparent',
					},
					'*': {
						'&::-webkit-scrollbar': { width: 4 },
						'&::-webkit-scrollbar-thumb': {
							background: 'rgba(177,76,255,0.3)',
							borderRadius: 2,
							transition: 'background ease-in 0.15s',
						},
						'&::-webkit-scrollbar-thumb:hover': {
							background: 'rgba(177,76,255,0.55)',
						},
						'&::-webkit-scrollbar-track': {
							background: 'transparent',
						},
					},
				},
			},
			MuiTooltip: {
				styleOverrides: {
					tooltip: {
						fontSize: 12,
						fontFamily: "'Oswald', sans-serif",
						fontWeight: 600,
						backgroundColor: 'rgba(0,0,0,0.82)',
						border: '1px solid rgba(177,76,255,0.25)',
						boxShadow: '0 4px 16px rgba(0,0,0,0.6)',
						color: '#ffffff',
					},
				},
			},
			MuiAppBar: {
				styleOverrides: {
					root: {
						backgroundImage: 'none',
					},
					colorTransparent: {
						backgroundColor: 'transparent',
						border: '1px solid rgba(177,76,255,0.2)',
						boxShadow: 'none',
					},
				},
			},
			MuiTab: {
				styleOverrides: {
					root: {
						fontFamily: "'Oswald', sans-serif",
						fontWeight: 700,
						fontSize: 12,
						letterSpacing: '0.1em',
						color: 'rgba(255,255,255,0.6)',
						transition: 'color 0.2s ease',
						'&.Mui-selected': {
							color: '#b14cff',
						},
					},
				},
			},
			MuiTabs: {
				styleOverrides: {
					indicator: {
						backgroundColor: '#b14cff',
					},
				},
			},
		},
	});

	ReactDOM.render(
		<Provider store={store}>
			<KeyListener>
				<WindowListener>
					<StyledEngineProvider injectFirst>
						<ThemeProvider theme={muiTheme}>
							<CssBaseline />
							<App />
						</ThemeProvider>
					</StyledEngineProvider>
				</WindowListener>
			</KeyListener>
		</Provider>,
		MOUNT_NODE,
	);
};

if (module.hot) {
	module.hot.accept(['containers/App'], () => {
		ReactDOM.unmountComponentAtNode(MOUNT_NODE);
		render();
	});
}

render();
