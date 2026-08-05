# FireClient

Sends a registered or existing event to one client.

## Syntax

```lua
Network:FireClient(player, name, ...)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `player` | `Player` | Yes | Recipient. |
| `name` | `string` | Yes | Event name in `Remotes.Events`. |
| `...` | `any` | No | Values delivered to the client's `On` callback. |

## Returns

Returns nothing. A missing event is optionally logged and nothing is sent.

## Example

```lua
Network:FireClient(player, "Notification", "Daily reward claimed")
```

## Notes

If the event is not already in `Network.Remotes`, Networker looks it up under `Events` and caches it. It does not run middleware for outbound events.

## Best Practices

Pair it with `Client:On` for notifications and server-pushed state.
