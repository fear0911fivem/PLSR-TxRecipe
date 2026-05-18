import React from "react";
import { createRoot } from "react-dom/client";
import { Provider } from "react-redux";

import App from "./containers/App";
import WindowListener from "containers/WindowListener";
import configureStore from "./configureStore";

import "./index.css";

const initialState = {};
const store = configureStore(initialState);

const mountNode = document.getElementById("app");

createRoot(mountNode).render(
  <React.StrictMode>
    <Provider store={store}>
      <WindowListener>
        <App />
      </WindowListener>
    </Provider>
  </React.StrictMode>
);
