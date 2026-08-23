# Contributing to LoneWare

Thanks for your interest in improving LoneWare.

## How to contribute

1. Open an [issue](https://github.com/ideBob/BladeBallHub/issues) for bugs or feature ideas before large changes.
2. Fork the repository and create a branch.
3. Keep changes focused; preserve existing feature intent unless fixing a bug.
4. Test enable/disable, respawn, and unload when touching features.
5. Open a pull request with a clear description.

## Code guidelines

- Prefer isolated feature modules with Enable / Disable / Cleanup.
- Use `SafeCall` / `pcall` for fallible game API work.
- Track connections through `ConnectionManager`; never leave permanent listeners after disable.
- Do not add anti-cheat bypasses, detection evasion, or executor `setfflag` manipulation.
- Match existing naming and log through the LoneWare logger.

## Reporting bugs

Include:

- Executor (if relevant)
- What you did
- Expected vs actual behavior
- Whether the issue survives respawn / rejoin

Use the bug report issue template when available.

## Feature requests

Describe the goal and how it fits Blade Ball usage of the hub. Unrelated games or stealth tooling are out of scope.
