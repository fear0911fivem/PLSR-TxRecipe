import React from 'react';
import ReactDOM from 'react-dom';
import { Provider } from 'react-redux';

import App from 'containers/App';
import WindowListener from 'containers/WindowListener';
import configureStore from './configureStore';

const initialState = {};
const store = configureStore(initialState);

ReactDOM.render(
  <React.StrictMode>
    <Provider store={store}>
      <WindowListener>
        <App />
      </WindowListener>
    </Provider>
  </React.StrictMode>,
  document.getElementById('app')
);
