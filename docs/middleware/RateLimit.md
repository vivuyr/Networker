# RateLimit

Creates middleware that limits each player to accepted calls at a maximum rate.

## Syntax

```lua
local middleware = Network.Middleware:RateLimit(limit)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `limit` | `number` | Yes | Maximum accepted calls per second per player. Must be greater than zero. |

## Returns

Returns a middleware callback when `limit > 0`; otherwise warns and returns `nil`.

## Example

```lua
Network:Register("SendChat", {
	Middlewares = { Network.Middleware:RateLimit(2) },
}, SendChat)
```

## Notes

After an accepted call, the same player must wait `1 / limit` seconds. State is isolated per RateLimit factory call and is cleared when the player leaves. When over the limit, the callback returns `false, "RateLimit"`.

## Warnings

> [!WARNING]
> The `false` return only blocks the endpoint when `Network.Settings.PcallMiddlewares = false`. With its default `true` value, Networker logs the rate limit (if middleware logging is enabled) but still continues the pipeline.

## Best Practices

Use it before expensive middleware and combine it with `Cooldown` for state-changing actions.
