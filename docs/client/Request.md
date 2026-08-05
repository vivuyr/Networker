# Request

Sends a Request route to the server and yields for a matched response or timeout.

## Syntax

```lua
local result = Network:Request(name, timeout, ...)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Route registered by `Server:RegisterRequest`. |
| `timeout` | `number?` | No | Seconds to wait. Defaults to `5`; values `<= 0` are replaced with `5`. |
| `...` | `any` | No | Values supplied to the server callback after `player`. |

## Returns

On a successful server response, returns the server callback's first response value. On timeout or unsuccessful response, returns `nil`.

## Example

```lua
local inventory = Network:Request("Inventory", 4)
if inventory then
	RenderInventory(inventory)
else
	ShowRetryMessage()
end
```

## Notes

Every Request shares a single `RemoteEvent`. Networker assigns a local incrementing request ID and waits for that response only. The response listener is installed by `Start()`.

## Warnings

> [!WARNING]
> `nil` covers timeout, unknown route, an enforced middleware rejection, and callback failure. It is not an error object and cannot distinguish those cases.

## Best Practices

Use it for client-to-server operations requiring a response; see [Request System](../requests.md) for trade-offs.
