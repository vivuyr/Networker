# Matchmaking

Use a Request to confirm whether a player was queued.

```lua
Network.Settings.PcallMiddlewares = false
```

```lua
-- Server
Network:RegisterRequest("JoinMatchmaking", "Queue is unavailable", {
	Middlewares = {
		Network.Middleware:RateLimit(1),
		Network.Middleware:Types({ "string" }),
	},
}, function(_context, player, playlist)
	local queuePosition = QueuePlayer(player, playlist)
	return { position = queuePosition, playlist = playlist }
end)
```

```lua
-- Client
local queued = Network:Request("JoinMatchmaking", 5, "Ranked")
if queued then
	QueueLabel.Text = "Queued: #" .. queued.position
end
```
