# Daily Rewards

Use Request when the UI must know whether the server granted the reward.

```lua
-- Server
Network:RegisterRequest("ClaimDailyReward", "Reward could not be claimed", {
	Middlewares = {
		Network.Middleware:Cooldown(1),
		Network.Middleware:Resolve(function(_context, player)
			return Profiles[player]
		end, "Profile"),
	},
}, function(context)
	local profile = context.Data.Profile
	if not IsDailyRewardAvailable(profile) then
		return { claimed = false }
	end
	GrantCoins(profile, 100)
	MarkDailyRewardClaimed(profile)
	return { claimed = true, coins = 100 }
end)
```

```lua
-- Client
local result = Network:Request("ClaimDailyReward", 5)
if result and result.claimed then
	ShowReward(result.coins)
end
```
