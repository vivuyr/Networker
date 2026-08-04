local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {
	Remotes = {},
	RemoteFunctions = {},
	Requests = {},
	Middleware = require(script.Parent.Middleware),
	GlobalMiddlewareDefinitions = {},
	Logger = require(ReplicatedStorage.Shared.Logger),
	Settings = {
		ClientToServerFunction = false,
		FirstGlobalMiddleware = true,
		Logging = false,
	},
}

local References = {
	RemotesFolder = nil,
	EventsFolder = nil,
	FunctionsFolder = nil,
	RequestFolder = nil,
	RequestEvent = nil,
}

export type Remote = RemoteEvent | RemoteFunction

export type Context = {
	Data: {},
	StartTime: number,
}

export type Callback = (Context, Player, any) -> any

type RequestData = {
	Name: string,
	Middlewares: {},
	Callback: Callback,
	Error: string?,
}

type Request = { [string]: RequestData }

type Middleware = { Global: { UseAll: boolean?, Disable: { string? | number? }? }?, Middlewares: {}? } | {}

local function createGlobalMiddlewares()
	local globals = {}
	for name, definition in pairs(Network.GlobalMiddlewareDefinitions) do
		globals[name] = definition.Factory(Network.Middleware, table.unpack(definition.Args))
	end
	return globals
end

local function globalMiddlewares(
	name: string,
	middlewares: Middleware,
	t: string,
	context: Context,
	player: Player,
	...: any
)
	local Remotes
	if t == "Remote" then
		Remotes = Network.Remotes
	elseif t == "RemoteFunction" then
		Remotes = Network.RemoteFunctions
	elseif t == "Request" then
		Remotes = Network.Requests
	end
	local remote = Remotes[name]

	local isArray = #remote.GlobalMiddlewares > 0
	local pair
	if isArray then
		pair = ipairs
	else
		pair = pairs
	end
	local globals = middlewares["Global"]

	for globalName, global in pair(remote.GlobalMiddlewares) do
		if global and globals and globals.Disable then
			if type(globalName) == "number" then
				local skip = false

				for _, v in pairs(globals.Disable) do
					if v == globalName then
						skip = true
						break
					end
				end

				if skip then
					continue
				end
			else
				if globals.Disable[globalName] then
					continue
				end
			end
		end
		local ok, middleName = global(context, player, ...)

		if not ok then
			if not middleName then
				middleName = ""
			end
			Network.Logger.Warn(
				("[Networker][%s] %s's (%s) GlobalMiddleware (%s) failed"):format(player.Name, name, t, middleName),
				Network.Settings.Logging
			)
			return
		end
	end
	return true
end

local function normalMiddlewares(
	name: string,
	middlewares: Middleware,
	t: string,
	context: Context,
	player: Player,
	...: any
)
	local middle = middlewares["Middlewares"] or middlewares
	for _, middleware in ipairs(middle) do
		local ok, middleName = middleware(context, player, ...)

		if not ok then
			if not middleName then
				middleName = ""
			end
			Network.Logger.Warn(
				("[Networker][%s] %s's (%s) middleware (%s) failed"):format(player.Name, name, t, middleName),
				Network.Settings.Logging
			)
			return
		end
	end
	return true
end

local function RunMiddlewares(
	remote: Remote | Request,
	t: string,
	player: Player,
	middlewares: Middleware,
	...: any
): Context?
	local name = remote.Name
	local context: Context = {
		Data = {},
		StartTime = os.clock(),
	}
	local globals = middlewares["Global"]
	if globals then
		if globals.UseAll == false then
			local ok = normalMiddlewares(name, middlewares, t, context, player, ...)
			if not ok then
				return
			end
			return context
		end
	end
	if Network.Settings.FirstGlobalMiddleware then
		local success = globalMiddlewares(name, middlewares, t, context, player, ...)
		if not success then
			return
		end
		local ok = normalMiddlewares(name, middlewares, t, context, player, ...)
		if not ok then
			return
		end
	else
		local ok = normalMiddlewares(name, middlewares, t, context, player, ...)
		if not ok then
			return
		end

		local success = globalMiddlewares(name, middlewares, t, context, player, ...)
		if not success then
			return
		end
	end
	return context
end

local function RunCallback(
	remote: Remote | Request,
	player: Player,
	middlewares: Middleware,
	callback: Callback,
	errorInfo: string?,
	...: any
): (boolean, any)
	local name = remote.Name
	local Type = type(remote)
	if Type ~= "RemoteEvent" and Type ~= "RemoteFunction" then
		Type = "Request"
	end
	local context = RunMiddlewares(remote, Type, player, middlewares, ...)
	if not context then
		return false, nil
	end

	local success, result = pcall(callback, context, player, ...)
	if not success then
		result = errorInfo
		Network.Logger.Warn(
			("[Networker][%s] %s (%s) failed:\n%s"):format(player.Name, name, Type, result),
			Network.Settings.Logging
		)
		return false, nil
	end
	return success, result
end

--[[
Init() Check every thing in References and if not exist create
]]

function Network:Init(): boolean
	References.RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not References.RemotesFolder then
		References.RemotesFolder = Instance.new("Folder")
		References.RemotesFolder.Name = "Remotes"
		References.RemotesFolder.Parent = ReplicatedStorage
	end
	References.EventsFolder = References.RemotesFolder:FindFirstChild("Events")
	if not References.EventsFolder then
		References.EventsFolder = Instance.new("Folder")
		References.EventsFolder.Name = "Events"
		References.EventsFolder.Parent = References.RemotesFolder
	end
	References.FunctionsFolder = References.RemotesFolder:FindFirstChild("Functions")
	if not References.FunctionsFolder then
		References.FunctionsFolder = Instance.new("Folder")
		References.FunctionsFolder.Name = "Functions"
		References.FunctionsFolder.Parent = References.RemotesFolder
	end
	References.RequestFolder = References.RemotesFolder:FindFirstChild("Requests")
	if not References.RequestFolder then
		References.RequestFolder = Instance.new("Folder")
		References.RequestFolder.Name = "Requests"
		References.RequestFolder.Parent = References.RemotesFolder
	end
	References.RequestEvent = References.RequestFolder:FindFirstChild("RequestEvent")
	if not References.RequestEvent then
		References.RequestEvent = Instance.new("RemoteEvent")
		References.RequestEvent.Name = "RequestEvent"
		References.RequestEvent.Parent = References.RequestFolder
	end
	return true
end
--[[
Start() activate Networker's OnServerEvents
]]
function Network:Start(): ()
	self.Middleware.Start()
	References.RequestEvent.OnServerEvent:Connect(function(player: Player, name: string, requestId: number, ...: any)
		if not Network.Requests[name] then
			References.RequestEvent:FireClient(player, requestId, false)
			return
		end

		local request = Network.Requests[name]

		local success, result = RunCallback(request, player, request.Middlewares, request.Callback, request.Error, ...)
		References.RequestEvent:FireClient(player, requestId, success, result)
	end)
end

function Network:IsRegistered(name, t)
	local Remotes
	if t == "Remote" then
		Remotes = self.Remotes
	elseif t == "RemoteFunction" then
		Remotes = self.RemoteFunctions
	elseif t == "Request" then
		Remotes = self.Requests
	end
	local remote = Remotes[name]
	if not remote then
		return false
	end
	return true
end

function Network:Register(name: string, middlewares: Middleware, callback: Callback): ()
	if self.Remotes[name] then
		self.Logger.Warn(("[Networker] Remote '%s' already exists."):format(name), Network.Settings.Logging)
		return
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = References.EventsFolder
	local global = createGlobalMiddlewares()
	self.Remotes[name] = { Remote = remote, GlobalMiddlewares = global }
	remote.OnServerEvent:Connect(function(player: Player, ...: any)
		local _success, _result = RunCallback(remote, player, middlewares, callback, nil, ...)
	end)
end

function Network:FireClient(player: Player, name: string, ...: any): ()
	local data = self.Remotes[name]
	local remote = data and data.Remote

	if not remote then
		remote = References.EventsFolder:FindFirstChild(name)
		if not remote then
			self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), Network.Settings.Logging)
			return
		end
		local global = createGlobalMiddlewares()
		self.Remotes[name] = { Remote = remote, GlobalMiddlewares = global }
	end

	remote:FireClient(player, ...)
end

function Network:FireAllClients(name: string, ...: any): ()
	local data = self.Remotes[name]
	local remote = data and data.Remote

	if not remote then
		remote = References.EventsFolder:FindFirstChild(name)
		if not remote then
			self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), Network.Settings.Logging)
			return
		end
		local global = createGlobalMiddlewares()
		self.Remotes[name] = { Remote = remote, GlobalMiddlewares = global }
	end

	remote:FireAllClients(...)
end

function Network:RegisterFunction(name: string, middlewares: Middleware, callback: Callback): ()
	if self.RemoteFunctions[name] then
		self.Logger.Warn(("[Networker] RemoteFunction '%s' already exists."):format(name), self.Settings.Logging)
		return
	end
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = References.FunctionsFolder
	local global = createGlobalMiddlewares()

	self.RemoteFunctions[name] = { Remote = remoteFunction, GlobalMiddlewares = global }

	remoteFunction.OnServerInvoke = function(player: Player, ...: any)
		local _success, result = RunCallback(remoteFunction, player, middlewares, callback, nil, ...)

		return result
	end
end

function Network:InvokeClient(player: Player, name: string, ...: any): any
	if not self.Settings.ClientToServerFunction then
		warn("The Client to Server option is disabled. Consider enabling it as it is dangerous!!!")
		return
	end
	local data = self.RemoteFunctions[name]
	local remoteFunction = data and data.Remote
	if not remoteFunction then
		remoteFunction = References.EventsFolder:FindFirstChild(name)
		if not remoteFunction then
			self.Logger.Warn(("[Networker] Function '%s' not exists."):format(name), self.Settings.Logging)
			return
		end
	end

	return remoteFunction:InvokeClient(player, ...)
end

function Network:RegisterRequest(name: string, errorInfo: string?, middlewares: Middleware, callback: Callback): ()
	if self.Requests[name] then
		self.Logger.Warn(("[Networker] Request '%s' already exists."):format(name), self.Settings.Logging)
		return
	end
	local global = createGlobalMiddlewares()
	self.Requests[name] = {
		Name = name,
		GlobalMiddlewares = global,
		Middlewares = middlewares,
		Callback = callback,
		Error = errorInfo,
	}
end

function Network:Destroy(name: string, t: string)
	local Remotes
	local Folder
	if t == "Remote" then
		Remotes = self.Remotes
		Folder = References.EventsFolder
	elseif t == "RemoteFunction" then
		Remotes = self.RemoteFunctions
		Folder = References.FunctionsFolder
	elseif t == "Request" then
		Remotes = self.Requests
	end
	local data = Remotes[name]
	local remote = data and data.Remote
	if not remote then
		return
	end
	Remotes[name] = nil
	if Folder then
		local event = Folder:FindFirstChild(name)
		event:Destroy()
	end
	self.Logger.Print(("%s (%s) deleted"):format(name, t), self.Settings.Logging)
end
return Network
