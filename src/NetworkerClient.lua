local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Logger = require(script.Parent.Logger)

type Logger = typeof(Logger)

type Callback = (any) -> any

export type NetworkerClient = {
	Remotes: { [string]: RemoteEvent },
	RemoteFunctions: { [string]: RemoteFunction },
	RequestsResults: { [number]: BindableEvent },
	Logger: Logger,
	Settings: {
		Logging: boolean,
	},

	Init: (self: NetworkerClient) -> boolean,
	Start: (self: NetworkerClient) -> (),
	IsStarted: (self: NetworkerClient) -> boolean,
	On: (self: NetworkerClient, name: string, callback: Callback) -> (),
	FireServer: (self: NetworkerClient, name: string, any) -> (),
	InvokeServer: (self: NetworkerClient, name: string, any) -> (boolean?, any?),
	OnServerInvoke: (self: NetworkerClient, name: string, callback: Callback) -> (),
	Request: (self: NetworkerClient, name: string, counter: number?, any) -> any,
}

local Network = {
	Remotes = {},
	RemoteFunctions = {},
	RequestsResults = {},
	Logger = Logger,
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

local STARTED = false

local PendingRequests = {}
local CurrentRequestId: number = 0

function Network:Init(): boolean
	local ready = true
	References.RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
	if not References.RemotesFolder then
		ready = false
		for _i = 1, 5 do
			task.wait(1)
			References.RemotesFolder = ReplicatedStorage:FindFirstChild("Remotes")
			if References.RemotesFolder then
				ready = true
				break
			end
		end
		if not ready then
			self.Logger.Warn("[Networker] RemotesFolder not exist", self.Settings.Logging)
			return false
		end
	end

	References.EventsFolder = References.RemotesFolder:FindFirstChild("Events")
	if not References.EventsFolder then
		ready = false
		for _i = 1, 5 do
			task.wait(1)
			References.EventsFolder = ReplicatedStorage:FindFirstChild("Events")
			if References.EventsFolder then
				ready = true
				break
			end
		end
		if not ready then
			self.Logger.Warn("[Networker] EventsFolder not exist", self.Settings.Logging)
			return false
		end
	end

	References.FunctionsFolder = References.RemotesFolder:FindFirstChild("Functions")
	if not References.FunctionsFolder then
		ready = false
		for _i = 1, 5 do
			task.wait(1)
			References.FunctionsFolder = ReplicatedStorage:FindFirstChild("Functions")
			if References.FunctionsFolder then
				ready = true
				break
			end
		end
		if not ready then
			self.Logger.Warn("[Networker] FunctionsFolder not exist", self.Settings.Logging)
			return false
		end
	end
	References.RequestsFolder = References.RemotesFolder:FindFirstChild("Requests")
	if not References.RequestsFolder then
		ready = false
		for _i = 1, 5 do
			task.wait(1)
			References.RequestsFolder = ReplicatedStorage:FindFirstChild("Requests")
			if References.RequestsFolder then
				ready = true
				break
			end
		end
		if not ready then
			self.Logger.Warn("[Networker] RequestsFolder not exist", self.Settings.Logging)
			return false
		end
	end
	References.RequestEvent = References.RequestsFolder:FindFirstChild("RequestEvent")
	if not References.RequestEvent then
		ready = false
		for _i = 1, 5 do
			task.wait(1)
			References.RequestEvent = References.RequestsFolder:FindFirstChild("RequestEvent")
			if References.RequestEvent then
				ready = true
				break
			end
		end
		if not ready then
			self.Logger.Warn("[Networker] RequestEvent not exist", self.Settings.Logging)
			return false
		end
	end

	return true
end

function Network:Start(): ()
	if self:IsStarted() then
		self.Logger.Warn("[Networker] Networker cannot be run multiple times", self.Settings.Logging)
		return
	end
	STARTED = true
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

function Network:IsStarted(): boolean
	if STARTED then
		return true
	end
	return false
end

function Network:On(name: string, callback: Callback): ()
	if not self:IsStarted() then
		warn("Networker didn't launch")
		return
	end
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
	if not self:IsStarted() then
		warn("Networker didn't launch")
		return
	end
	local remote = References.EventsFolder:FindFirstChild(name)
	if not remote then
		self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), self.Settings.Logging)
		return
	end
	self.Remotes[name] = remote

	remote:FireServer(...)
end

function Network:InvokeServer(name: string, ...: any): (boolean?, any?)
	if not self:IsStarted() then
		warn("Networker didn't launch")
		return
	end
	local remoteFunction = References.FunctionsFolder:FindFirstChild(name)
	if not remoteFunction then
		self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), self.Settings.Logging)
		return
	end
	self.RemoteFunctions[name] = remoteFunction
	return remoteFunction:InvokeServer(...)
end

function Network:OnServerInvoke(name: string, callback: Callback): ()
	if not self:IsStarted() then
		warn("Networker didn't launch")
		return
	end
	local remoteFunction = References.FunctionsFolder:FindFirstChild(name)
	if not remoteFunction then
		self.Logger.Warn(("[Networker] Remote '%s' not exists."):format(name), self.Settings.Logging)
		return
	end
	self.RemoteFunctions[name] = remoteFunction
	remoteFunction.OnClientInvoke = function(...: any)
		local success, result = pcall(callback, ...)
		if not success then
			self.Logger.Warn(("[Networker] %s failed:\n%s"):format(name, result), self.Settings.Logging)
		end

		return success, result
	end
end

function Network:Request(name: string, counter: number?, ...: any): any
	if not self:IsStarted() then
		warn("Networker didn't launch")
		return
	end
	local bindable = Instance.new("BindableEvent")
	local requestId = CurrentRequestId + 1

	CurrentRequestId += 1
	local defaultCounter = 5
	if counter and counter <= 0 then
		counter = defaultCounter
		self.Logger.Warn(
			("[Networker] %s The counter is invalid and has been set to default: %s. "):format(name, defaultCounter),
			self.Settings.Logging
		)
	end
	task.delay(counter or defaultCounter, function()
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
return Network :: NetworkerClient
