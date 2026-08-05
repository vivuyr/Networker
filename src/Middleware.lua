local Players = game:GetService("Players")
local Logger = require(script.Parent.Logger)

export type Context = {
	Data: { [string]: any },
	StartTime: number,
}

type Callback = (Context, Player, ...any) -> any
export type MiddlewareCallback = (Context, Player, ...any) -> (boolean, string?)
type CustomCallback = (Context, Player, {}?, ...any) -> (boolean, string?)
type PlayerConnection = { [Player]: number }

export type MiddlewareType = {
	Settings: { Logging: boolean },
	Start: () -> (),
	RateLimit: (self: MiddlewareType, limit: number) -> MiddlewareCallback?,
	Cooldown: (self: MiddlewareType, cooldown: number) -> MiddlewareCallback?,
	Resolve: (self: MiddlewareType, callback: Callback, container: string) -> MiddlewareCallback,
	Types: (self: MiddlewareType, argsTypes: {}) -> MiddlewareCallback,
	Range: (self: MiddlewareType, min: number, max: number) -> MiddlewareCallback,
	Custom: (self: MiddlewareType, callback: CustomCallback, additionalData: {}?) -> MiddlewareCallback,
}

local Middleware = { Settings = { Logging = false } }

local Connections: { RateLimit: { [number]: PlayerConnection }, Cooldown: { [number]: PlayerConnection } } = {
	RateLimit = {},
	Cooldown = {},
}

local Ids = {
	RateLimit = 1,
	Cooldown = 1,
}

function Middleware:Start(): ()
	Players.PlayerRemoving:Connect(function(leavingPlayer)
		for _, data in pairs(Connections) do
			for _, connection in pairs(data) do
				connection[leavingPlayer] = nil
			end
		end
	end)
end

function Middleware:RateLimit(limit: number): MiddlewareCallback?
	if limit <= 0 then
		warn(("Wrong RateLimit: %s"):format(tostring(limit)))
		return
	end
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

function Middleware:Cooldown(cooldown: number): MiddlewareCallback?
	if cooldown <= 0 then
		warn(("Wrong cooldown: %s"):format(tostring(cooldown)))
		return
	end
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

function Middleware:Resolve(callback: Callback, container: string): MiddlewareCallback
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

function Middleware:Types(argsTypes: {}): MiddlewareCallback
	return function(_context, player, ...)
		local args = { ... }
		for i, _ in ipairs(argsTypes) do
			if type(args[i]) ~= argsTypes[i] then
				Logger.Warn(("%s type %s is wrong"):format(player.Name, i), self.Settings.Logging)
				return false, "Types"
			end
		end
		return true, "Types"
	end
end

function Middleware:Range(min: number, max: number): MiddlewareCallback
	return function(_context, player, ...)
		local value = ...
		if type(value) ~= "number" then
			Logger.Warn(("%s argument isn't number"):format(player.Name), self.Settings.Logging)
			return false, "Range"
		end
		if value < min or value > max then
			Logger.Warn(("%s number is higher or lower than can be"):format(player.Name), self.Settings.Logging)
			return false, "Range"
		end
		return true, "Range"
	end
end

function Middleware:Custom(callback: CustomCallback, additionalData: {}?): MiddlewareCallback
	return function(context: Context, player: Player, ...: any)
		return callback(context, player, additionalData, ...)
	end
end

return Middleware :: MiddlewareType
