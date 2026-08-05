# Trading

Use Request for the server decision and an event for status updates.

```lua
-- Server
Network:Register("TradeStatus", {}, function() end)

Network:RegisterRequest("ProposeTrade", "Trade could not be created", {
	Middlewares = {
		Network.Middleware:Cooldown(1),
		Network.Middleware:Types({ "number" }),
	},
}, function(_context, player, targetUserId)
	local trade = CreateTrade(player, targetUserId)
	if not trade then
		return nil -- client receives nil, so use a successful table for accepted requests
	end
	Network:FireClient(player, "TradeStatus", "Waiting for response")
	return { tradeId = trade.Id }
end)
```

```lua
-- Client
local reply = Network:Request("ProposeTrade", 5, targetUserId)
if reply then
	OpenTradeWaitingScreen(reply.tradeId)
end
```
