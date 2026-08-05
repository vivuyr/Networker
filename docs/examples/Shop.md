# Shop

Use an event for a purchase submission: the server performs the authoritative validation and can notify the player separately.

```lua
-- Server startup: make middleware `false` returns reject calls.
Network.Settings.PcallMiddlewares = false
```

```lua
-- Server
Network:Register("BuyItem", {
	Middlewares = {
		Network.Middleware:RateLimit(5),
		Network.Middleware:Cooldown(0.2),
		Network.Middleware:Types({ "number" }),
		Network.Middleware:Range(1, 500),
	},
}, function(_context, player, itemId)
	local item = ShopItems[itemId]
	if not item or not CanAfford(player, item.Price) then
		Network:FireClient(player, "Notification", "Purchase unavailable")
		return
	end
	Charge(player, item.Price)
	GrantItem(player, itemId)
	Network:FireClient(player, "Notification", "Purchased " .. item.Name)
end)
```

```lua
-- Client
Network:FireServer("BuyItem", selectedItemId)
```

> [!IMPORTANT]
> The client only requests a purchase. Never grant an item based on client-provided price or ownership.
