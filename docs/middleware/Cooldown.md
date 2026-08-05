# Cooldown

Creates middleware that blocks repeated accepted calls from a player for a duration.

## Syntax

```lua
local middleware = Network.Middleware:Cooldown(seconds)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `seconds` | `number` | Yes | Cooldown duration. Must be greater than zero. |

## Returns

Returns a middleware callback when `seconds > 0`; otherwise warns and returns `nil`.

## Example

```lua
Network:Register("ClaimDailyReward", {
	Middlewares = { Network.Middleware:Cooldown(1) },
}, ClaimDailyReward)
```

## Notes

The cooldown begins when the middleware accepts a call, before the endpoint callback executes. State is separate per factory call and cleared on player removal. During the cooldown it returns `false, "Cooldown"`.

## Warnings

> [!WARNING]
> The `false` return only blocks the endpoint when `Network.Settings.PcallMiddlewares = false`. With its default `true` value, Networker logs the cooldown (if middleware logging is enabled) but still continues the pipeline.

## Best Practices

Use a longer gameplay cooldown in your own data when persistence across server sessions is required.
