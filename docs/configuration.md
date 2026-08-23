# Configuration

## In-UI sliders (Parry tab)

| Key | Default | Min | Max |
|-----|---------|-----|-----|
| ParryDistance | 12 | 4 | 30 |
| ReactionTime | 0.05 | 0.01 | 0.25 |
| PredictionStrength | 0.75 | 0.1 | 1.5 |
| MinimumBallSpeed | 10 | 0 | 80 |
| MaximumBallDistance | 120 | 30 | 250 |
| AutoDashDistance | 15 | 5 | 40 |

Values are clamped by LoneWare’s config layer. Invalid numbers fall back to defaults.

## Reference defaults

See [`config/Config.lua`](../config/Config.lua) for documented defaults (not loaded at runtime by the single-file hub; runtime uses internal defaults + sliders).

## FFlag JSON

Root must be a JSON **object** (not an array). Values may be string, number, or boolean only — no nested objects.

Example:

```json
{
  "ExampleFlag": false,
  "SomeNumber": 1
}
```

Apply validates and stores the table in memory for the session. It does not write engine FFlags.
