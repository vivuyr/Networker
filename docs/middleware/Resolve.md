# Resolve

Creates middleware that resolves data and stores it in the current context.

## Syntax

```lua
local middleware = Network.Middleware:Resolve(callback, container)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `callback` | `function(context, player, ...)` | Yes | Produces the value to store. |
| `container` | `string` | Yes | Key used for `context.Data[container]`. |

## Returns

Returns a middleware callback.

## Example

```lua
local function getProfile(_context, player)
	return Profiles[player]
end

Network:Register("ChangeSetting", {
	Middlewares = { Network.Middleware:Resolve(getProfile, "Profile") },
}, function(context, _player, key, value)
	context.Data.Profile.Settings[key] = value
end)
```

## Notes

If the callback returns a falsy value, `Resolve` returns `false, "Resolve"`. Otherwise it stores the value and returns `true, "Resolve"`.

## Warnings

> [!WARNING]
> A false middleware return stops the endpoint only when `Network.Settings.PcallMiddlewares = false`; it is not enforced with the default setting.

## Best Practices

Use it to avoid repeated lookup code in callbacks. Place it after cheap throttling checks.
