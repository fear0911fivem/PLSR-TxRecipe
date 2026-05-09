<div align="center">

<img src="https://r2.fivemanage.com/GPYOH8Hq4GPyAY7czrgLe/pulsarbanner.png" alt="Pulsar Framework" width="100%" />

<br/>

# PULSAR-CORE

### Core foundation of the Pulsar Framework

<br/>

![Lua](https://img.shields.io/badge/Lua_5.4-2C2D72?style=flat-square&logo=lua&logoColor=white)
![FiveM](https://img.shields.io/badge/FiveM-F40552?style=flat-square)
![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat-square&logo=mariadb&logoColor=white)

<br/>

[Overview](#overview) · [Configuration](#configuration) · [Dependencies](#dependencies)

</div>

---

## Overview

The core of the Pulsar Framework. Every other resource in the stack depends on this. It handles player lifecycle, the middleware pipeline, bidirectional callbacks, routing buckets, task scheduling, logging, punishment, and network sync. Nothing runs without it.

---

## Configuration

Add to `server.cfg`:

```
set sv_environment     "PROD"
set sv_access_role      0
set log_level           0
set plsfw_version       "1.0.0"
```

| Convar | Default | Description |
|--------|---------|-------------|
| `sv_environment` | `DEV` | `DEV` or `PROD` — controls environment-gated behaviour |
| `sv_access_role` | `0` | Minimum access role level |
| `log_level` | `0` | Logging verbosity — `0` off, higher = more verbose |
| `plsfw_version` | `UNKNOWN` | Framework version string surfaced to other resources |

**Optional Discord webhooks:**

| Convar | Purpose |
|--------|---------|
| `discord_connection_webhook` | Player connect / disconnect logs |
| `discord_error_webhook` | Error logs |
| `discord_log_webhook` | General logs |
| `discord_pwnzor_webhook` | Anti-cheat logs |
| `discord_app` | Discord app ID (client rich presence) |

---

## Dependencies

- `oxmysql` — database layer
- `pulsar-pwnzor` — anti-cheat module

---

## License

This resource is proprietary software. All rights reserved by the Pulsar Framework team. Unauthorized distribution or resale is prohibited.

---

<div align="center">

![Pulsar Framework](https://img.shields.io/badge/Pulsar-Framework-7c3aed?style=flat-square)
![Built for FiveM](https://img.shields.io/badge/Built_for-FiveM-F40552?style=flat-square)

</div>
