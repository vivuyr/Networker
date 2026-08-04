local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logger = require(ReplicatedStorage.Shared.Logger)
local Middleware = { Settings = { Logging = nil } }

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
						connection[leavingPlayer] = nil
					end
				end
			end
		end
	end)
end

function Middleware:RateLimit(limit: number): (Context, Player, any) -> (boolean, string?)
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
		Logger.Warn(("%s is rate limited"):format(player.Name), self.Settings.Logging)
		return false, "RateLimit"
	end
end

function Middleware:Cooldown(cooldown: number): (Context, Player, any) -> (boolean, string?)
	local id = Ids.Cooldown
	Ids.Cooldown += 1
	Connections.Cooldown[id] = {}
	local CooldownConnection = Connections.Cooldown[id]
	return function(_context: Context, player: Player, ...: any)
		local now = os.clock()
		if not CooldownConnection[player] or CooldownConnection[player] <= now then
			CooldownConnection[player] = now + cooldown
			return true, "Cooldown"
		end
		Logger.Warn(("%s on cooldown"):format(player.Name), self.Settings.Logging)
		return false, "Cooldown"
	end
end

function Middleware:Resolve(callback: Callback, container: string): (Context, Player, any) -> (boolean, string?)
	return function(context, player, ...)
		local data = callback(context, player, ...)
		if not data then
			Logger.Warn(("%s data not find"):format(player.Name), self.Settings.Logging)
			return false, "Resolve"
		end
		context.Data[container] = data
		return true, "Resolve"
	end
end

function Middleware:Types(argsTypes: {}): (Context, Player, any) -> (boolean, string?)
	return function(_context, player, ...)
		local args = { ... }
		for i, arg in ipairs(args) do
			if type(args[i]) ~= argsTypes[i] then
				Logger.Warn(("%s type %s is wrong"):format(player.Name, i), self.Settings.Logging)
				return false, "Types"
			end
		end
		return true, "Types"
	end
end

function Middleware:Range(min: number, max: number): (Context, Player, any) -> (boolean, string?)
	return function(_context, player, ...: number)
		local number = ...
		if number < min or number > max then
			Logger.Warn(("%s number is higher or lower than can be"):format(player.Name), self.Settings.Logging)
			return false, "Range"
		end
		return true, "Range"
	end
end

function Middleware:Custom(callback, additionalData: {}?): ()
	return function(context: Context, player: Player, ...: any): boolean
		return callback(context, player, additionalData, ...)
	end
end

return Middleware
