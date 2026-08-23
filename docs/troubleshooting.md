# Troubleshooting

## WindUI failed to load

- Check internet / HttpGet permissions in the executor.
- Confirm the Footagesus WindUI release URL is reachable.

## Window does not open

- Read the executor console for `[LoneWare]` errors.
- Ensure you are in Blade Ball (or a place where the script is allowed to run).

## Auto Parry never fires

- Enable **Debug Mode** and watch logs for ball detection.
- Confirm a ball exists under `Workspace.Balls` or `TrainingBalls`.
- Lower Minimum Ball Speed or raise Parry Distance for testing.

## ESP missing players

- Toggle ESP off/on after others spawn.
- Respawn once so character hooks settle.

## FFlag “Invalid JSON”

- Root must be `{ ... }`, not `[ ... ]`.
- Keys must be strings; values only string / number / boolean.

## Rejoin does nothing

- Teleport may be restricted by the experience or executor.
- Check notification for the error string.

## Script still running after close

- Closing the WindUI window should call Unload. If a custom executor keeps the thread, rejoin the game.
