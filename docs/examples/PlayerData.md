# Player Data

Resolve player data once and return a deliberately shaped view to the client.

```lua
-- Server
Network:RegisterRequest("PlayerData", "Player data is unavailable", {
	Middlewares = {
		Network.Middleware:Resolve(function(_context, player)
			return Profiles[player]
		end, "Profile"),
	},
}, function(context)
	local profile = context.Data.Profile
	return {
		level = profile.Level,
		coins = profile.Coins,
	}
end)
```

```lua
-- Client
local data = Network:Request("PlayerData")
if data then
	UpdateHud(data.level, data.coins)
end
```

> [!WARNING]
> Return only data the client is allowed to see. Do not return an entire server profile by default.
