<div align="center">

<img src="https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsarbanner.png" alt="Pulsar Framework" width="100%" />

<br/>

# PULSAR-CHARACTERS

### Character creation, selection, and lifecycle management

<br/>

![Lua](https://img.shields.io/badge/Lua_5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-F40552?style=flat-square)
![React](https://img.shields.io/badge/React_18-61DAFB?style=flat-square&logo=react&logoColor=black)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)

<br/>

[Overview](#overview) · [UI Development](#ui-development) · [Dependencies](#dependencies)

</div>

---

## Overview

Handles the full character lifecycle — creation, selection, spawning, and data persistence. Provides the character data layer that every other resource in the stack reads from, including name, SID, job, cash, reputation, and custom metadata.

---

## UI Development

The NUI is a React 18 + Webpack app.

```bash
cd ui
npm install
npm run start    # dev server with hot reload
npm run build    # production build → ui/dist/
```

---

## Dependencies

- `pulsar-core` — framework core
- `ox_lib` — utility library
- `oxmysql` — character persistence
- `pulsar-ped` — appearance on character creation

---

## License

This resource is proprietary software. All rights reserved by the Pulsar Framework team. Unauthorized distribution or resale is prohibited.

---

<div align="center">

![Pulsar Framework](https://img.shields.io/badge/Pulsar-Framework-7c3aed?style=flat-square)
![Built for FiveM](https://img.shields.io/badge/Built_for-FiveM-F40552?style=flat-square)

</div>
