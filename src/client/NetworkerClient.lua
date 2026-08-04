local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Network = {
	Remotes = {},
	RemoteFunctions = {},
	RequestsResults = {},
	Logger = require(ReplicatedStorage.Shared.Logger),
	Settings = {
		Logging = false,
	},
}

local References = {
	RemotesFolder = nil,
	EventsFolder = nil,
	FunctionsFolder = nil,
	RequestsFolder = nil,
	RequestEvent = nil,
}

local PendingRequests = {}
local CurrentRequestId: number = 0

type Callback = (any) -> any

function Network:Init(): boolean
	References.RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not References.RemotesFolder then
		self.Logger.Warn("[Networker] RemotesFolder not exist", self.Settings.Logging)
		return false
	end

	References.EventsFolder = References.RemotesFolder:FindFirstChild("Events")
	if not References.EventsFolder then
		self.Logger.Warn("[Networker] EventsFolder not exist", self.Settings.Logging)
		return false
	end

	References.FunctionsFolder = References.RemotesFolder:FindFirstChild("Functions")
	if not References.FunctionsFolder then
		self.Logger.Warn("[Networker] FunctionsFolder not exist", self.Settings.Logging)
		return false
	end
	References.RequestsFolder = References.RemotesFolder:FindFirstChild("Requests")
	if not References.RequestsFolder then
		self.Logger.Warn("[Networker] RequestsFolder not exist", self.Settings.Logging)
		return false
	end
	References.RequestEvent = References.RequestsFolder:FindFirstChild("RequestEvent")
	if not References.RequestEvent then
		self.Logger.Warn("[Networker] RequestEvent not exist", self.Settings.Logging)
		return false
	end

	return true
end

function Network:Start(): ()
	References.RequestEvent.OnClientEvent:Connect(function(requestId, success, ...)
		local bindable = PendingRequests[requestId]

		if not bindable then
			return
		end

		PendingRequests[requestId] = nil
		Network.RequestsResults[requestId] = {
			Success = success,
			Data = table.pack(...),
		}
		bindable:Fire(true)
		bindable:Destroy()
	end)
end

function Network:On(name: string, callback: Callback): ()
	local remote = References.EventsFolder:FindFirstChild(name)
	if not remote then
		self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), self.Settings.Logging)
		return
	end
	self.Remotes[name] = remote
	remote.OnClientEvent:Connect(function(...: any)
		local success, err = pcall(callback, ...)

		if not success then
			self.Logger.Warn(("[Networker] %s failed:\n%s"):format(name, err), self.Settings.Logging)
			return
		end
	end)
end

function Network:FireServer(name: string, ...: any): ()
	local remote = References.EventsFolder:FindFirstChild(name)
	if not remote then
		self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), self.Settings.Logging)
		return
	end
	self.Remotes[name] = remote

	remote:FireServer(...)
end

function Network:InvokeServer(name: string, ...: any): any
	local remoteFunction = References.FunctionsFolder:FindFirstChild(name)
	if not remoteFunction then
		self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), self.Settings.Logging)
		return
	end
	self.RemoteFunctions[name] = remoteFunction
	return remoteFunction:InvokeServer(...)
end

function Network:OnServerInvoke(name: string, callback: Callback): ()
	local remoteFunction = References.FunctionsFolder:FindFirstChild(name)
	if not remoteFunction then
		self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), self.Settings.Logging)
		return
	end
	self.RemoteFunctions[name] = remoteFunction
	remoteFunction.OnClientInvoke = function(...: any)
		local _success, result = pcall(callback, ...)

		return result
	end
end

function Network:Request(name: string, counter: number?, ...: any): any
	local bindable = Instance.new("BindableEvent")
	local requestId = CurrentRequestId + 1

	CurrentRequestId += 1

	task.delay(counter or 5, function()
		if PendingRequests[requestId] then
			bindable:Fire(false)
			PendingRequests[requestId] = nil
			bindable:Destroy()
		end
	end)

	PendingRequests[requestId] = bindable
	References.RequestEvent:FireServer(name, requestId, ...)
	local success = bindable.Event:Wait()
	if not success then
		self.Logger.Warn(("[Networker] Request %s timeout"):format(name), self.Settings.Logging)
		return
	end
	local result = self.RequestsResults[requestId]
	local data = table.unpack(result.Data)
	self.RequestsResults[requestId] = nil
	if result.Success then
		return data
	end
	self.Logger.Warn(("[Networker] Request %s is nil"):format(name), self.Settings.Logging)
	if data then
		self.Logger.Warn(("[Networker] Request %s: %s"):format(name, data), self.Settings.Logging)
	end
	return
end
return Network
