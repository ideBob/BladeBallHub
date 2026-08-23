# Changelog

All notable changes to BladeBallHub are documented in this file.

## [1.1.0] — 2026

### Added
- **UI Theme / Color Changer** tab
- Five runtime themes: Lavender, Purple, Violet, White, Black (default)
- Themes applied via `WindUI:AddTheme` / `WindUI:SetTheme` without resetting features

### Fixed
- Fog restore on disable
- ESP connection leaks and cleanup
- Ball tracker overlay cleanup
- Non-yielding parry fire path
- Debounce reset behavior

## [1.0.0] — Initial public release

### Added
- Main utilities: Infinite Jump, No Fog, Full Bright, Remove Jitter, ESP, Debug Mode
- Parry systems: Auto Parry (velocity prediction), Auto Dash, Ball Tracker
- Centralized state, connection manager, and BallController
- Capability detection and feature isolation via `pcall`
- WindUI window with Main and Parry tabs
- Official GitHub Pages site
