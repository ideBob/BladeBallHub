# BladeBallHub

Blade Ball Luau Script Hub built with **WindUI**.

A modular, production-oriented script hub for Roblox *Blade Ball* featuring Auto Parry, Auto Dash, Ball Tracker, ESP, theme switching, and common quality-of-life utilities.

## Features

### Main
- **Infinite Jump** — event-driven jump requests with character respawn support
- **No Fog** — removes fog/atmosphere while preserving restore values
- **Full Bright** — forced bright lighting with safe restore
- **Remove Jitter** — lightweight camera spike dampening
- **RakNet Desync** — experimental, capability-gated (fails safely if unsupported)
- **ESP** — player highlights, distance, and health
- **Debug Mode** — throttled console diagnostics

### Parry
- **Auto Parry** — velocity-based prediction, configurable distance/reaction/prediction
- **Auto Dash** — evasive dash with cooldown when the ball is a threat
- **Ball Tracker** — live overlay (speed, distance, approaching, ETA)
- Configurable: Parry Distance, Reaction Time, Prediction Strength, Min Ball Speed, Max Distance, Dash Distance

### UI THEME / COLOR CHANGER
- **Select Theme** dropdown: Lavender, Purple, Violet, White, **Black** (default)
- Runtime `WindUI:SetTheme` — no UI rebuild, does not reset features

## Architecture

- Centralized **State** and **Config** tables
- **Connection manager** — track/disconnect all event connections on feature disable or UI destroy
- **BallController** — single source of truth for the active ball
- Custom themes via `WindUI:AddTheme` / `WindUI:SetTheme`
- Feature isolation via `pcall` so one failure does not crash the hub
- Capability detection for executor-specific APIs
- Full cleanup on `Window:OnDestroy`

## Dependencies

| Dependency | Source |
|------------|--------|
| **WindUI** | Loaded at runtime via `loadstring` from the official Footagesus/WindUI releases |

WindUI is **not** vendored in this repository. The hub loads the latest release:

```lua
local WindUI = loadstring(game:HttpGet(
  "https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"
))()
```

See [WindUI](https://github.com/Footagesus/WindUI) for library documentation.

## Usage

1. Open Roblox and join **Blade Ball**.
2. Inject your preferred executor.
3. Execute the contents of [`src/BladeBallHub.lua`](src/BladeBallHub.lua).

The UI window opens with **Main**, **Parry**, and **UI THEME / COLOR CHANGER** tabs.

## Website

Official landing page lives in [`website/`](website/) and deploys automatically to GitHub Pages:

**https://idebob.github.io/BladeBallHub/**

## Repository Layout

```text
BladeBallHub/
├── README.md
├── .gitignore
├── src/
│   └── BladeBallHub.lua      # Complete executable hub
├── website/
│   ├── index.html
│   ├── css/style.css
│   ├── js/script.js
│   └── assets/
├── .github/workflows/pages.yml
├── config/
│   └── Config.lua            # Shared default configuration
└── docs/
    └── Features.md            # Feature reference
```

## Disclaimer

This project is for educational and personal use. Using scripts in Roblox may violate the Roblox Terms of Service and can result in account moderation. Use at your own risk on accounts you can afford to lose.

## License

Provided as-is for learning and private use. WindUI remains under its own license (MIT — Footagesus/WindUI).
