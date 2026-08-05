# Chat

Chat is a one-way client action with strict type and rate validation.

```lua
Network.Settings.PcallMiddlewares = false
```

```lua
-- Server
Network:Register("Chat", {
	Middlewares = {
		Network.Middleware:RateLimit(2),
		Network.Middleware:Types({ "string" }),
	},
}, function(_context, player, message)
	if #message > 150 then
		return
	end
	local filtered = FilterForBroadcast(player, message)
	Network:FireAllClients("ChatMessage", player.Name, filtered)
end)

Network:Register("ChatMessage", {}, function() end)
```

```lua
-- Client
Network:FireServer("Chat", textBox.Text)
Network:On("ChatMessage", function(author, message)
	AppendChat(author, message)
end)
```
