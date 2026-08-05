# RegisterRequest

Registers a client-to-server Request endpoint on Networker's shared Request event.

## Syntax

```lua
Network:RegisterRequest(name, errorInfo, middlewares, callback)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Request route sent by `Client:Request`. |
| `errorInfo` | `string?` | Yes | Optional replacement response sent when `callback` errors. Use `nil` for an empty string. |
| `middlewares` | `table` | Yes | Middleware array or configuration object. |
| `callback` | `function(context, player, ...)` | Yes | Called after middleware; its results are sent in the response. |

## Returns

Returns nothing. A duplicate name or a call before `Start()` leaves the registry unchanged.

## Example

```lua
Network:RegisterRequest("Inventory", "Inventory is unavailable", {
	Middlewares = {
		Network.Middleware:Resolve(GetProfile, "Profile"),
	},
}, function(context)
	return context.Data.Profile.Inventory
end)
```

## Notes

No new Roblox instance is created. Registered Requests share `Remotes.Requests.RequestEvent`. Only the callback's first return value is sent. A callback failure produces an unsuccessful response; client `Request` returns `nil` for it. Middleware `false` returns reject only when `PcallMiddlewares` is disabled; see [Middleware](../middleware.md).

## Best Practices

Use for client-to-server operations that need a result and can safely handle timeout. See [Request System](../requests.md).
