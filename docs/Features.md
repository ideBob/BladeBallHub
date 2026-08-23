# BladeBallHub — Feature Reference

## Main Tab

### Infinite Jump
Allows repeated jumps while airborne using `UserInputService.JumpRequest`.
- Rebinds on `CharacterAdded`
- Disconnects cleanly when disabled
- Does not poll every frame

### No Fog
Sets `Lighting.FogEnd` high and clears Atmosphere density.
- Captures original values on enable
- Restores on disable
- Monitors property changes so the game cannot force fog back while active

### Full Bright
Raises brightness, sets midday clock time, and lifts ambient colors.
- Original lighting values stored and restored on disable

### Remove Jitter
Lightweight RenderStepped blend that only softens large, short camera position spikes.
- Does not force Camera.CFrame every frame
- Avoids aggressive overrides of legitimate movement

### RakNet Desync
Experimental client-side networking feature.
- Gated behind capability detection
- Fails with a notification if the executor does not expose required APIs
- Isolated from the rest of the hub

### ESP
Highlight + BillboardGui per other player:
- Name, distance (studs), health
- Created/destroyed on join, leave, and character respawn
- Full cleanup when ESP is toggled off or the hub is destroyed

### Debug Mode
Throttled `warn` output for ball detection, speeds, ETA, and parry triggers.

---

## Parry Tab

### Auto Parry
Pipeline:
1. Resolve active ball via `BallController` (`realBall` attribute preferred)
2. Read ball velocity (`zoomies` LinearVelocity / BodyVelocity or `AssemblyLinearVelocity`)
3. Compute relative motion and time-to-impact
4. Require approaching trajectory
5. Optional target attribute check
6. Fire parry within configured threshold

Parry methods (tried in order):
1. `ReplicatedStorage.Remotes.ParryButtonPress` / `ParryAttempt`
2. `VirtualInputManager` mouse click fallback

### Auto Dash
When the ball is approaching, within dash distance, and ETA is low:
- Applies an impulse away from the ball
- Optional ability remote fire
- Cooldown prevents spam

### Ball Tracker
CoreGui overlay showing:
- Speed
- Distance
- Approaching (YES/NO)
- Estimated time to impact

UI updates are throttled (~12.5 Hz) to reduce overhead.

### Configuration Sliders
| Setting | Default | Range |
|---------|---------|-------|
| Parry Distance | 12 | 4–30 |
| Reaction Time | 0.05 | 0.01–0.25 |
| Prediction Strength | 0.75 | 0.1–1.5 |
| Minimum Ball Speed | 10 | 0–80 |
| Max Ball Distance | 120 | 30–250 |
| Auto Dash Distance | 15 | 5–40 |

---

## UI THEME / COLOR CHANGER Tab

### Select Theme
Dropdown with exactly five options:

| Theme | Style |
|-------|--------|
| **Lavender** | Soft lavender accents on deep purple-gray |
| **Purple** | Rich purple / magenta accents |
| **Violet** | Deep violet dark theme |
| **White** | Light background, dark text |
| **Black** | Near-black UI (default) |

Behavior:
- Themes are registered with `WindUI:AddTheme` before the window is created
- Selection calls `WindUI:SetTheme(name)` at runtime (no UI rebuild)
- Does **not** reset or interfere with Main / Parry feature state
- Failures are caught with `pcall` and notified; active theme is left unchanged
- Default on load: **Black**

---

## Ball Detection

`BallController` watches `Workspace.Balls` (and `TrainingBalls` if present):
- ChildAdded / ChildRemoved
- Heartbeat fallback if the current ball is destroyed
- Attribute `realBall == true` preferred

All systems read `BallController.CurrentBall` instead of scanning Workspace independently.

---

## Cleanup

On `Window:OnDestroy`:
- All feature states set to false
- Every tracked connection disconnected
- ESP objects destroyed
- Lighting restored
- Ball tracker ScreenGui removed
- BallController stopped
