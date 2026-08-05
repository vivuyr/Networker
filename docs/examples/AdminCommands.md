# Admin Commands

Put permission validation in custom middleware so every command callback receives only authorized players.

```lua
Network.Settings.PcallMiddlewares = false
```

```lua
local adminOnly = Network.Middleware:Custom(function(_context, player)
	return AdminUserIds[player.UserId] == true, "AdminOnly"
end)

Network:Register("AdminCommand", {
	Middlewares = {
		Network.Middleware:RateLimit(2),
		Network.Middleware:Types({ "string", "string" }),
		adminOnly,
	},
}, function(_context, player, command, targetName)
	RunAdminCommand(player, command, targetName)
end)
```

```lua
Network:FireServer("AdminCommand", "kick", "ExamplePlayer")
```

> [!CAUTION]
> Middleware should reject unauthorized callers, but command-specific target and argument validation is still required in the callback.
