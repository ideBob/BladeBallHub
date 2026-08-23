# Installation

## Steps

1. Get the source from this repository:
   - [Download ZIP](https://github.com/ideBob/BladeBallHub/archive/refs/heads/main.zip)
   - or clone: `git clone https://github.com/ideBob/BladeBallHub.git`
2. Open [`src/LoneWare.lua`](../src/LoneWare.lua).
3. Join **Blade Ball** on Roblox.
4. Inject your preferred Luau executor.
5. Execute the full contents of `LoneWare.lua`.

## Remote load

When `src/LoneWare.lua` is present on `main`:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/ideBob/BladeBallHub/main/src/LoneWare.lua"))()
```

## Requirements

- Network access (WindUI is downloaded at runtime)
- Executor supporting `loadstring` and `HttpGet`

## After load

The LoneWare window opens with **Main**, **Parry**, **UI THEME / COLOR CHANGER**, and **FFlag** tabs. Closing the window runs full unload.
