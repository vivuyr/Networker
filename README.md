<<<<<<< HEAD
# Networker

> A middleware-first Roblox networking library for RemoteEvents, RemoteFunctions, and timeout-aware client requests.

Networker keeps remote creation and server-side validation in one place. It provides a shared middleware pipeline, a lightweight Request protocol, and optional logging—without hiding Roblox's networking model.

## Features

- Register and handle `RemoteEvent` and `RemoteFunction` endpoints.
- Send events to one client or every client.
- Build single-result request/response endpoints over one shared `RemoteEvent`.
- Validate calls with rate limits, cooldowns, types, ranges, resolvers, and custom middleware.
- Share data from middleware to callbacks through `context.Data`.
- Add global middleware to newly registered endpoints.
- Opt in to diagnostic logging.

## Installation

Install the Wally package:

```toml
[dependencies]
Networker = "vivuyr/networker@0.1.0"
```

Or place the server, client, and shared modules in locations that match the library's module references. The included Rojo project maps `Shared` to `ReplicatedStorage.Shared`, server modules to `ServerScriptService.Server`, and client modules to `StarterPlayerScripts.Client`.

> [!IMPORTANT]
> `NetworkerServer` requires `ReplicatedStorage.Shared.Logger`. Both `Init()` calls rely on the `ReplicatedStorage.Remotes` hierarchy created by the server.

## Quick Start

Start the server before clients attempt to initialize, then register endpoints after starting:

```lua
-- ServerScriptService/Server/Main.server.lua
local ServerScriptService = game:GetService("ServerScriptService")
local Network = require(ServerScriptService.Server.NetworkerServer)

Network:Init()
Network:Start()
Network.Settings.PcallMiddlewares = false -- enforce middleware false returns

Network:RegisterRequest("GetDailyReward", nil, {
	Middlewares = {
		Network.Middleware:Cooldown(1),
	},
}, function(_context, player)
	return {
		coins = 100,
		claimedFor = player.UserId,
	}
end)
```

```lua
-- StarterPlayerScripts/Client/Main.client.lua
local Players = game:GetService("Players")
local Network = require(Players.LocalPlayer.PlayerScripts.Client.NetworkerClient)

assert(Network:Init(), "Networker remotes were not created by the server")
Network:Start()

local reward = Network:Request("GetDailyReward", 5)
if reward then
	print(reward.coins)
end
```

## Documentation

- [Getting started](docs/getting-started.md)
- [Server API](docs/server/Init.md)
- [Server settings and defaults](docs/server/Settings.md)
- [Client API](docs/client/Init.md)
- [Middleware](docs/middleware/Types.md)
- [Request system](docs/requests.md)
- [Context](docs/context.md) and [Logger](docs/logger.md)
- [Best practices](docs/best-practices.md)
- [Examples](docs/examples/README.md)

## License

This project is licensed under the MIT License.
=======

>>>>>>> 07e128fa82ff09dde02628875f20e2461f1e8045
