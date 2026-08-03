local Players = game:GetService("Players")
local Middleware = {}

local Connections = {
	RateLimit = {},
	Cooldown = {},
}

local Ids = {
	RateLimit = 1,
	Cooldown = 1,
}

type Context = {
	Data: {},
	StartTime: number,
}

type Callback = (Context, Player, any) -> any

function Middleware.Start(): ()
	Players.PlayerRemoving:Connect(function(leavingPlayer)
		for _, data in pairs(Connections) do
			for _, connection in pairs(data) do
				for _, findedPlayer in pairs(connection) do
					if findedPlayer == leavingPlayer then
						findedPlayer = nil
					end
				end
			end
		end
	end)
end

function Middleware.RateLimit(limit: number): (Context, Player, any) -> (boolean, string?)
	local id = Ids.RateLimit
	Ids.RateLimit += 1
	Connections.RateLimit[id] = {}
	local RateConnection = Connections.RateLimit[id]

	return function(_context, player, ...)
		local plr = RateConnection[player]
		local now = os.clock()
		local minDelay = 1 / limit
		if plr == nil or plr <= now then
			RateConnection[player] = now + minDelay
			return true, "RateLimit"
		end
		warn(("%s is rate limited"):format(player.Name))
		return false, "RateLimit"
	end
end

function Middleware.Cooldown(cooldown: number): (Context, Player, any) -> (boolean, string?)
	local id = Ids.Cooldown
	Ids.RateLimit += 1
	local CooldownConnection = Connections.Cooldown[id]
	return function(_context: Context, player: Player, ...: any)
		local now = os.clock()
		if not CooldownConnection[player] or CooldownConnection[player] <= now then
			CooldownConnection[player] = now + cooldown
			return true, "Cooldown"
		end
		warn(("%s on cooldown"):format(player.Name))
		return false, "Cooldown"
	end
end

function Middleware.Resolve(callback: Callback, container: string): (Context, Player, any) -> (boolean, string?)
	return function(context, player, ...)
		local data = callback(context, player, ...)
		if not data then
			warn(("%s data not find"):format(player.Name))
			return false, "Resolve"
		end
		context.Data[container] = data
		return true, "Resolve"
	end
end

function Middleware.Types(argsTypes: {}): (Context, Player, any) -> (boolean, string?)
	return function(_context, _player, ...)
		local args = { ... }
		for i, arg in ipairs(args) do
			if type(args[i]) ~= argsTypes[i] then
				warn(("Type %s is wrong"):format(i))
				return false, "Types"
			end
		end
		return true, "Types"
	end
end

function Middleware.Range(min: number, max: number): (Context, Player, any) -> (boolean, string?)
	return function(_context, _player, ...: number)
		local number = math.clamp(..., min, max)
		if number == max or number == min then
			warn("Number is higher or lower than can be")
			return false, "Range"
		end
		return true, "Range"
	end
end

function Middleware.Context(data: any, container: string): (Context, Player, any) -> (boolean, string?)
	return function(context, _player, ...)
		context.Data[container] = data
		return true, "Context"
	end
end

function Middleware.Custom(callback, additionalData: {}?): ()
	return function(context: Context, player: Player, ...: any): boolean
		return callback(context, player, additionalData, ...)
	end
end

return Middleware
