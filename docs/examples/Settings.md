# Settings

Use an event for a setting change that does not need an immediate response.

```lua
Network.Settings.PcallMiddlewares = false
```

```lua
-- Server
Network:Register("UpdateSetting", {
	Middlewares = {
		Network.Middleware:Resolve(function(_context, player)
			return Profiles[player]
		end, "Profile"),
		Network.Middleware:Types({ "string", "boolean" }),
	},
}, function(context, _player, key, enabled)
	if key ~= "MusicEnabled" and key ~= "ShowDamage" then
		return
	end
	context.Data.Profile.Settings[key] = enabled
end)
```

```lua
-- Client
Network:FireServer("UpdateSetting", "MusicEnabled", musicToggle.Value)
```
