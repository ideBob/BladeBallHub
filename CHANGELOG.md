# Changelog

All notable changes to **LoneWare** are documented in this file.

## [1.0.0] — 2026-08

### Added
- **LoneWare** product branding and single-file hub (`src/LoneWare.lua`)
- Modular feature lifecycle: Enable / Disable / Cleanup
- Core: SafeCall, Logger, ConnectionManager, validated Config, References, Unload
- Main: Infinite Jump, No Fog, Full Bright, Remove Jitter, ESP, Debug Mode, RakNet Desync (gated)
- Parry: Auto Parry, Auto Dash, Ball Tracker + configuration sliders
- Themes: Lavender, Purple, Violet, White, Black
- **FFlag** tab: JSON editor, validation, Apply (store only), Rejoin, Clear/Reset, presets, clipboard import/export
- Repository docs, LICENSE, CONTRIBUTING, issue templates

### Improved
- Non-yielding parry primary path; mouse fallback async
- Time-based Auto Parry debounce (no leaked delayed tasks after disable)
- ESP label throttle and prefix-based connection cleanup
- BallController event-driven refresh with light staleness check

### Notes
- FFlag Apply does **not** invoke executor `setfflag` or anti-cheat bypasses
- WindUI loaded at runtime from Footagesus releases
