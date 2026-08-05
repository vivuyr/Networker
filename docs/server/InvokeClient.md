# InvokeClient

Invokes a client's handler for a named `RemoteFunction` and waits for its response.

## Syntax

```lua
local success, result = Network:InvokeClient(player, name, ...)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `player` | `Player` | Yes | Client to invoke. |
| `name` | `string` | Yes | Function name in `Remotes.Functions`. |
| `...` | `any` | No | Values passed to the client's `OnServerInvoke` callback. |

## Returns

For a found function with the option enabled, returns the values from Roblox `RemoteFunction:InvokeClient()`. Otherwise returns no values.

## Example

```lua
-- Server: required before InvokeClient can invoke the client.
Network.Settings.ClientToServerFunction = true

local success, accepted = Network:InvokeClient(player, "ConfirmTrade", tradeId)
if success and accepted then
	CompleteTrade(tradeId)
end
```

## Notes

Networker checks `Network.Settings.ClientToServerFunction` before invoking. It must be `true` or this method returns without invoking the client. The client must also call `OnServerInvoke` for the same function name. It looks up an uncached function but does not add that lookup to `RemoteFunctions`.

## Warnings

> [!CAUTION]
> This yields the server thread and trusts a client-controlled response. To make it work, the server must set `Network.Settings.ClientToServerFunction = true`; enable that option only when necessary and validate every returned value server-side.

## Best Practices

Prefer events or Requests for normal gameplay. Use `InvokeClient` only for a short client interaction that genuinely requires an immediate response, and see [Server Settings](Settings.md).
