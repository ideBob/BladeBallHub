# Features

## Main

| Feature | Behavior |
|---------|----------|
| Infinite Jump | `JumpRequest` → `ChangeState(Jumping)` while alive; rebinds on `CharacterAdded` |
| No Fog | Raises fog end, clears atmosphere density; restores on disable |
| Full Bright | Brightness / clock / ambient override; restores on disable |
| Remove Jitter | RenderStepped lerp only on large short camera jumps |
| ESP | Highlight + billboard per other player; distance & HP; cleaned on leave/disable |
| Debug Mode | Sets logger to DEBUG with throttle |
| RakNet Desync | Experimental; enables only if network-related executor APIs exist |

## Parry

| Feature | Behavior |
|---------|----------|
| Auto Parry | Predicts impact from ball velocity; fires remote or async mouse fallback |
| Auto Dash | Impulse away from ball within distance/ETA; optional ability remote |
| Ball Tracker | Screen overlay: speed, distance, approach, ETA (~12.5 Hz) |

Sliders: Parry Distance, Reaction Time, Prediction Strength, Min Ball Speed, Max Ball Distance, Auto Dash Distance.

## Themes

Lavender, Purple, Violet, White, Black (default). Applied with `WindUI:SetTheme` without resetting features.

## FFlag

Configuration UI only:

- Multiline JSON editor
- Validation (syntax, types, flat key/value object)
- Apply stores validated table in memory (no `setfflag`)
- Rejoin via `TeleportService`
- Clear / Reset / presets / clipboard import-export

Failures in this tab do not unload the rest of LoneWare.
