import React from 'react'
import { createRoot } from 'react-dom/client'
import { library } from '@fortawesome/fontawesome-svg-core'
import { fas } from '@fortawesome/free-solid-svg-icons'
import { far } from '@fortawesome/free-regular-svg-icons'
import { fab } from '@fortawesome/free-brands-svg-icons'
import '@mantine/core/styles.css'
import '@mantine/notifications/styles.css'
import './global.css'
import App from './App'

library.add(fab, fas, far)

const root = createRoot(document.getElementById('app')!)
root.render(<App />)
