# OnServerInvoke

Sets the client handler used when the server invokes a named `RemoteFunction`.

## Syntax

```lua
Network:OnServerInvoke(name, callback)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Function name in `Remotes.Functions`. |
| `callback` | `function(...)` | Yes | Called when the server uses `InvokeClient`. |

## Returns

Returns nothing. If the function is missing, no handler is assigned.

## Example

```lua
-- The server must enable this before calling InvokeClient:
-- Network.Settings.ClientToServerFunction = true
Network:OnServerInvoke("ConfirmTrade", function(tradeId)
	return IsTradeDialogOpen(tradeId)
end)
```

## Notes

The installed handler calls your callback with `pcall` and returns `success, result` to the server. A callback error therefore returns `false` and the error message as the second value.

For the server to invoke this handler, it must set `NetworkerServer.Settings.ClientToServerFunction = true` and call `NetworkerServer:InvokeClient(...)`. Without that setting, `InvokeClient` returns without contacting the client.

## Warnings

> [!CAUTION]
> This handler supplies client-controlled information. It is part of a dangerous server-to-client `RemoteFunction` flow: the server yields and the client can delay, fail, or manipulate its response. The server must not treat it as authoritative.

## Best Practices

Register this handler before the server can invoke it. Return only UI confirmation or other non-authoritative information, and validate any response again on the server.
