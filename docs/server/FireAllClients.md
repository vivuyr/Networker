# FireAllClients

Sends an event to every connected client.

## Syntax

```lua
Network:FireAllClients(name, ...)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Event name in `Remotes.Events`. |
| `...` | `any` | No | Values delivered to every client's `On` callback. |

## Returns

Returns nothing. A missing event is optionally logged and nothing is sent.

## Example

```lua
Network:FireAllClients("MatchStarted", arenaId)
```

## Notes

Like `FireClient`, it can cache an event that already exists in `Remotes.Events`; it never creates an event.

## Warnings

> [!WARNING]
> Every payload is sent to every client. Avoid broadcasting private player data.
