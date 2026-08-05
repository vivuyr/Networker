# Custom

Wraps your own middleware callback in Networker's middleware format.

## Syntax

```lua
local middleware = Network.Middleware:Custom(callback, additionalData)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `callback` | `function(context, player, additionalData, ...)` | Yes | Returns whether the pipeline may continue. |
| `additionalData` | `table?` | No | Static table passed as the callback's third argument. |

## Returns

Returns a middleware callback.

## Example

```lua
local requiresRole = Network.Middleware:Custom(function(_context, player, data)
	return player:GetAttribute("Role") == data.Role, "RequiresRole"
end, { Role = "Admin" })

Network:Register("AdminCommand", { Middlewares = { requiresRole } }, RunAdminCommand)
```

## Notes

`additionalData` is passed as supplied (including `nil`) and is not copied. Your callback's return values are passed through unchanged.

## Warnings

> [!WARNING]
> If your callback returns `false`, that return is enforced only when `Network.Settings.PcallMiddlewares = false`.

## Best Practices

Return a descriptive second value for useful diagnostics, and keep the check short.
