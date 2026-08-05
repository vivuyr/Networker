# Inventory

Use a Request when the UI needs a server snapshot.

```lua
-- Server
Network:RegisterRequest("Inventory", "Inventory is unavailable", {
	Middlewares = {
		Network.Middleware:Resolve(function(_context, player)
			return Profiles[player]
		end, "Profile"),
	},
}, function(context)
	return context.Data.Profile.Inventory
end)
```

```lua
-- Client
local inventory = Network:Request("Inventory", 5)
if inventory then
	RenderInventory(inventory)
end
```
