# FireServer

Fires a named client-to-server `RemoteEvent`.

## Syntax

```lua
Network:FireServer(name, ...)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Event name registered by the server. |
| `...` | `any` | No | Values passed to the server callback after `player`. |

## Returns

Returns nothing. A missing event is optionally logged and nothing is sent.

## Example

```lua
BuyButton.Activated:Connect(function()
	Network:FireServer("BuyItem", selectedItemId)
end)
```

## Notes

The event is looked up in `Remotes.Events` on each call and stored in `Network.Remotes`.

## Warnings

> [!WARNING]
> All values sent by clients are untrusted. The server endpoint must validate them.
