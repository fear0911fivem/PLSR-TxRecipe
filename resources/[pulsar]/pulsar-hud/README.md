<div align="center">

<img src="https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsarbanner.png" alt="Pulsar Framework" width="100%" />

<br/>

# PULSAR-HUD

### HUD, notifications, progress bars, menus, and UI components

<br/>

![Lua](https://img.shields.io/badge/Lua_5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-F40552?style=flat-square)
![React](https://img.shields.io/badge/React_18-61DAFB?style=flat-square&logo=react&logoColor=black)
![Mantine](https://img.shields.io/badge/Mantine-339AF0?style=flat-square&logo=mantine&logoColor=white)
![Vite](https://img.shields.io/badge/Vite-646CFF?style=flat-square&logo=vite&logoColor=white)
![Zustand](https://img.shields.io/badge/Zustand-%888888?style=flat&logo=react&logoColor=white)

<br/>

[Overview](#overview) · [UI Development](#ui-development) · [Dependencies](#dependencies) · [Credits](#credits)

</div>

---

## Overview

The UI layer of the Pulsar Framework. Provides all shared UI components used across the stack — notifications, progress bars, input dialogs, confirm dialogs, action banners, list menus, interaction menus, info overlays, the HUD, vehicle HUD, buff system, and minimap. Every resource that displays UI goes through pulsar-hud.


---

## Preview

### Hud Components w/ buffs, action, compass and progress bar:
![Hud](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-status.png)
![action](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-action2.png)
![Compass](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-compass.png)
![ProgressBar](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-progress.png)
### Vehicle Hud w/ milage tracking
![vehhud](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-vehhud.png)
## Interaction Menu (radial Menu)
![RadialMenu](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-redial.png)
### Hud Menus (settings, input, confirm)
![SettingsMenu](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-settings.png)
### List Menu (context Menu)
![context](https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsar-hud-listmenu.png)
---

## UI Development

The NUI is built with React 18, Mantine, and Vite.

```bash
cd ui
bun install
bun run dev      # dev server with hot reload
bun run build    # production build → ui/dist/
```

### Themes

Pre-built themes are included in `ui/src/`. To switch themes, rename the theme file you want to use by removing the color suffix so it becomes `hudTheme.ts`, then rebuild.

```
hudTheme.ts         ← active theme (purple, default)
hudTheme.red.ts     ← rename to hudTheme.ts to use
hudTheme.teal.ts    ← rename to hudTheme.ts to use
```

---

## Dependencies

- `pulsar-core` — framework core
- `pulsar-characters` — player data for HUD display

---

## Credits

- Lead framework maintainer & Mantine UI redesign — [@Artmines](https://github.com/Artmines)
- SQL migration & component exports — [@AutLaaw](https://github.com/AutLaaw)

---

## License

This resource is released under a custom source-available license. Free to use on any FiveM server. Selling, paid redistribution, and monetization are strictly prohibited. See [LICENSE](./LICENSE) for full terms.

---

<div align="center">

![Pulsar Framework](https://img.shields.io/badge/Pulsar-Framework-7c3aed?style=flat-square)
![Built for FiveM](https://img.shields.io/badge/Built_for-FiveM-F40552?style=flat-square)

</div>
