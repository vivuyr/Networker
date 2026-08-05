# Context

Every server callback and every server middleware receives a fresh context as its first argument.

## Shape

```lua
type Context = {
	Data = { [string]: any },
	StartTime = number,
}
```

| Field | Type | Description |
|---|---|---|
| `Data` | table | Initially empty table for values shared by middleware and the endpoint callback. |
| `StartTime` | number | `os.clock()` value captured immediately before middleware runs. |

## Example

```lua
Network:Register("Equip", {
	Middlewares = {
		Network.Middleware:Resolve(function(_context, player)
			return Profiles[player]
		end, "Profile"),
	},
}, function(context, player, itemId)
	local profile = context.Data.Profile
	profile.Equipped = itemId
	print("Handled in", os.clock() - context.StartTime, "seconds")
end)
```

## Notes

- A context exists only for one incoming server call; it is not persistent player state.
- `Resolve` stores its value in `context.Data[container]`.
- Client callbacks passed to `On` and `OnServerInvoke` do not receive a Networker context.

> [!TIP]
> Use `Data` for request-scoped values such as a loaded profile or permission result. Keep durable player data in your own data system.
