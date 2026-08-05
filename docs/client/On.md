# On

Connects a callback to a server-to-client `RemoteEvent`.

## Syntax

```lua
Network:On(name, callback)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Event name in `Remotes.Events`. |
| `callback` | `function(...)` | Yes | Runs with the values sent by `FireClient` or `FireAllClients`. |

## Returns

Returns nothing. If no matching event exists, no callback is connected.

## Example

```lua
Network:On("Notification", function(message)
	ShowToast(message)
end)
```

## Notes

Callback errors are caught; they can be logged through `Network.Settings.Logging`. Calling `On` more than once for the same name adds multiple connections.

## Best Practices

Connect once during client initialization and keep the callback short.
