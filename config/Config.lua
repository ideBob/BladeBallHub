--[[
    BladeBallHub — Default Configuration
    Shared defaults used by src/BladeBallHub.lua
    Edit values here for reference; runtime sliders override in-session.
]]

return {
    -- Auto Parry
    ParryDistance       = 12,
    ReactionTime        = 0.05,
    PredictionStrength  = 0.75,
    MinimumBallSpeed    = 10,
    MaximumBallDistance = 120,

    -- Auto Dash
    AutoDashDistance    = 15,
    AutoDashCooldown     = 0.65,

    -- Debug
    DebugThrottle       = 0.35,

    -- Feature defaults (all off for safety)
    Defaults = {
        InfiniteJump  = false,
        NoFog         = false,
        FullBright    = false,
        RemoveJitter  = false,
        RakNetDesync  = false,
        ESP           = false,
        AutoParry     = false,
        AutoDash      = false,
        BallTracker   = false,
        DebugMode     = false,
    },
}
