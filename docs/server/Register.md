# Register

Registers a named client-to-server `RemoteEvent` endpoint.

## Syntax

```lua
Network:Register(name, middlewares, callback)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Name of the new `RemoteEvent` under `Remotes.Events`. |
| `middlewares` | `table` | Yes | Middleware array or configuration object. Use `{}` for none. |
| `callback` | `function(context, player, ...)` | Yes | Called after allowed middleware when a client fires the event. |

## Returns

Returns nothing. If Networker has not started or this name is already registered, no endpoint is added.

## Example

```lua
Network:Register("SendChat", {
	Middlewares = {
		Network.Middleware:RateLimit(3),
		Network.Middleware:Types({ "string" }),
	},
}, function(_context, player, message)
	BroadcastChat(player, message)
end)
```

## Notes

Creates a `RemoteEvent`, parents it to `ReplicatedStorage.Remotes.Events`, and attaches `OnServerEvent`. The callback's return values are ignored.

## Best Practices

Use this for one-way client actions. Validate every client argument with middleware and server logic.
