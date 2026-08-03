local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {
	Remotes = {},
	RemoteFunctions = {},
	Requests = {},
	Middleware = require(script.Parent.Middleware),
	GlobalMiddlewares = {},
	Settings = {
		FromClientToServer = false,
		FirstGlobalMiddleware = true,
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

local function globalMiddlewares(name, remotes, t, context, player, ...)
	local isArray = #remotes[name].Global.Middlewares > 0
	local pair
	if isArray then
		pair = ipairs
	else
		pair = pairs
	end
	for _, global in pair(remotes[name].Global.Middlewares) do
		local ok, middleName = global(context, player, ...)

		if not ok then
			if not middleName then
				middleName = ""
			end
			warn(("[Networker] %s's (%s) GlobalMiddleware (%s) failed"):format(name, t, middleName))
			return
		end
	end
end

local function normalMiddlewares(name, t, middlewares, context, player, ...)
	for _, middleware in ipairs(middlewares) do
		local ok, middleName = middleware(context, player, ...)

		if not ok then
			if not middleName then
				middleName = ""
			end
			warn(("[Networker] %s's (%s) middleware (%s) failed"):format(name, t, middleName))
			return
		end
	end
end

local function RunMiddlewares(remote: Remote | Request, t: string, player: Player, middlewares: {}, ...: any): Context?
	local name = remote.Name
	local context: Context = {
		Data = {},
		StartTime = os.clock(),
	}
	local remotes
	if t == "RemoteEvent" then
		remotes = Network.Remotes
	elseif t == "RemoteFunction" then
		remotes = Network.RemoteFunctions
	elseif t == "Request" then
		remotes = Network.Requests
	end
	if remotes[name].Global.GlobalMiddleware then
		if Network.Settings.FirstGlobalMiddleware then
			globalMiddlewares(name, remotes, t, context, player, ...)
			normalMiddlewares(name, t, middlewares, context, player, ...)
		else
			normalMiddlewares(name, t, middlewares, context, player, ...)
			globalMiddlewares(name, remotes, t, context, player, ...)
		end
	end
	return context
end

local function RunCallback(
	remote: Remote | Request,
	player: Player,
	middlewares: {},
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
		warn(("[Networker] %s (%s) failed:\n%s"):format(name, Type, result))
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

function Network:Register(name: string, middlewares: {}, callback: Callback): ()
	if self.Remotes[name] then
		warn(("[Networker] Remote '%s' already exists."):format(name))
		return
	end
	local remote = Instance.new("RemoteEvent")
	remote.Name = name
	remote.Parent = References.EventsFolder
	local global = self.GlobalMiddlewares
	self.Remotes[name] = { Remote = remote, Global = { GlobalMiddleware = true, Middlewares = global } }
	remote.OnServerEvent:Connect(function(player: Player, ...: any)
		local _success, _result = RunCallback(remote, player, middlewares, callback, nil, ...)
	end)
end

function Network:FireClient(player: Player, name: string, ...: any): ()
	local remote = self.Remotes[name].Remote

	if not remote then
		remote = References.EventsFolder:FindFirstChild(name)
		if not remote then
			warn(("[Networker] Remote '%s' not exists."):format(name))
			return
		end
		local global = self.GlobalMiddlewares
		self.Remotes[name] = { Remote = remote, Global = { GlobalMiddleware = true, Middlewares = global } }
	end

	remote:FireClient(player, ...)
end

function Network:FireAllClients(name: string, ...: any): ()
	local remote: RemoteEvent = self.Remotes[name].Remote

	if not remote then
		remote = References.EventsFolder:FindFirstChild(name)
		if not remote then
			warn(("[Networker] Remote '%s' not exists."):format(name))
			return
		end
		local global = self.GlobalMiddlewares
		self.Remotes[name] = { Remote = remote, Global = { GlobalMiddleware = true, Middlewares = global } }
	end

	remote:FireAllClients(...)
end

function Network:RegisterFunction(name: string, middlewares: {}, callback: Callback): ()
	if self.RemoteFunctions[name] then
		warn(("[Networker] RemoteFunction '%s' already exists."):format(name))
		return
	end
	local remoteFunction = Instance.new("RemoteFunction")
	remoteFunction.Name = name
	remoteFunction.Parent = References.FunctionsFolder

	local global = self.GlobalMiddlewares
	self.RemoteFunctions[name] = { Remote = remoteFunction, Global = { GlobalMiddleware = true, Middlewares = global } }

	remoteFunction.OnServerInvoke = function(player: Player, ...: any)
		local _success, result = RunCallback(remoteFunction, player, middlewares, callback, nil, ...)

		return result
	end
end

function Network:InvokeClient(player: Player, name: string, ...: any): any
	if not self.Settings.FromClientToServer then
		warn("The Client to Server option is disabled. Consider enabling it as it is dangerous!!!")
		return
	end
	local remoteFunction: RemoteFunction = self.RemoteFunctions[name].Remote
	if not remoteFunction then
		remoteFunction = References.EventsFolder:FindFirstChild(name)
		if not remoteFunction then
			warn(("[Networker] Function '%s' not exists."):format(name))
			return
		end
	end

	return remoteFunction:InvokeClient(player, ...)
end

function Network:RegisterRequest(name: string, errorInfo: string?, middlewares: {}, callback: Callback): ()
	if self.Requests[name] then
		warn(("[Networker] Request '%s' already exists."):format(name))
		return
	end
	local global = self.GlobalMiddlewares
	self.Requests[name] = {
		Name = name,
		Global = { GlobalMiddleware = true, Middlewares = global },
		Middlewares = middlewares,
		Callback = callback,
		Error = errorInfo,
	}
end

function Network:Destroy(name, t)
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
	local remote = Remotes[name].Remote
	if not remote then
		return
	end
	Remotes[name] = nil
	if Folder then
		local event = Folder:FindFirstChild(name)
		event:Destroy()
	end
	print(("%s (%s) deleted"):format(name, t))
end

return Network
