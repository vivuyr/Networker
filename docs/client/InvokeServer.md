# InvokeServer

Invokes a named server `RemoteFunction` and waits for its response.

## Syntax

```lua
local success, result = Network:InvokeServer(name, ...)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Function name registered by `RegisterFunction`. |
| `...` | `any` | No | Values passed to the server callback after `player`. |

## Returns

Returns the values from `RemoteFunction:InvokeServer()`: Networker's server handler returns a success Boolean and callback result. Missing functions return no values.

## Example

```lua
local success, coins = Network:InvokeServer("GetCoins")
if success then
	CoinsLabel.Text = tostring(coins)
end
```

## Notes

This method is not controlled by `Server.Settings.ClientToServerFunction`; that setting applies only to server `InvokeClient`.

## Warnings

> [!CAUTION]
> This yields until the server responds. For client-to-server gameplay systems, prefer [Request](../requests.md) for timeout behavior.
