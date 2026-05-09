<div align="center">

<img src="https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsarbanner.png" alt="Pulsar Framework" width="100%" />

<br/>

# PULSAR-ADMIN

### Staff administration panel and server management tools

<br/>

![Lua](https://img.shields.io/badge/Lua_5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-F40552?style=flat-square)
![React](https://img.shields.io/badge/React_17-61DAFB?style=flat-square&logo=react&logoColor=black)

<br/>

[Overview](#overview) · [UI Development](#ui-development) · [Dependencies](#dependencies)

</div>

---

## Overview

Staff administration panel for Pulsar Framework. Provides a full in-game dashboard for server management — player oversight, ban management, doorlock administration, noclip, nuke, damage testing, and a live server dashboard. Access is role-gated via pulsar-core.

---

## UI Development

The NUI is a React 17 + Webpack app.

```bash
cd ui
npm install --legacy-peer-deps
npm run start    # dev server with hot reload
npm run build    # production build → ui/dist/
```

---

## Dependencies

- `pulsar-core` — framework core, role access
- `ox_lib` — utility library
- `ox_inventory` — inventory access for admin actions
- `oxmysql` — ban storage, dashboard data
- `ox_doorlock` — doorlock administration

---

## License

This resource is proprietary software. All rights reserved by the Pulsar Framework team. Unauthorized distribution or resale is prohibited.

---

<div align="center">

![Pulsar Framework](https://img.shields.io/badge/Pulsar-Framework-7c3aed?style=flat-square)
![Built for FiveM](https://img.shields.io/badge/Built_for-FiveM-F40552?style=flat-square)

</div>
