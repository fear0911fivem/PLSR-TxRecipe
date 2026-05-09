import '@babel/polyfill';
import '@mantine/core/styles.css';
import '@mantine/dates/styles.css';
import React from 'react';
import { createRoot } from 'react-dom/client';
import { Provider } from 'react-redux';

import App from 'containers/App';
import WindowListener from 'containers/WindowListener';
import configureStore from './configureStore';

const initialState = {};
const store = configureStore(initialState);

const MOUNT_NODE = document.getElementById('app');
const root = createRoot(MOUNT_NODE);

const render = () => {
    root.render(
        <Provider store={store}>
            <WindowListener>
                <App />
            </WindowListener>
        </Provider>,
    );
};

render();
