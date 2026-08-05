# RegisterFunction

Registers a named client-to-server `RemoteFunction` endpoint.

## Syntax

```lua
Network:RegisterFunction(name, middlewares, callback)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Name of the new `RemoteFunction` under `Remotes.Functions`. |
| `middlewares` | `table` | Yes | Middleware array or configuration object. |
| `callback` | `function(context, player, ...)` | Yes | Returns the function result after middleware succeeds. |

## Returns

Returns nothing. Duplicate names and calls made before `Start()` are ignored.

## Example

```lua
Network:RegisterFunction("GetCoins", {}, function(_context, player)
	return GetCoins(player)
end)
```

## Notes

The client receives two values: a success Boolean followed by the callback's first return value. If middleware rejects or the callback errors, it receives `false` and `nil`.

## Warnings

> [!CAUTION]
> `RemoteFunction:InvokeServer()` yields the client until a server response. Prefer [Request](../requests.md) for client-to-server gameplay interactions that need a timeout.
