# Notifications

Register an event once, then use it for server-pushed messages.

```lua
-- Server registration (the inbound callback may be empty for an outbound-only event)
Network:Register("Notification", {}, function() end)

-- Later on the server
Network:FireClient(player, "Notification", "Your trade was accepted")
Network:FireAllClients("Notification", "Double XP has started")
```

```lua
-- Client
Network:On("Notification", function(message)
	ShowNotification(message)
end)
```

> [!NOTE]
> `FireClient` and `FireAllClients` require an event that is already registered or already exists in the Events folder.
