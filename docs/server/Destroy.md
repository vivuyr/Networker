# Destroy

Unregisters a named endpoint and destroys its event or function instance when applicable.

## Syntax

```lua
Network:Destroy(name, type)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Endpoint name. |
| `type` | `"Remote" | "RemoteFunction" | "Request"` | Yes | Registry to remove from. |

## Returns

Returns nothing.

## Example

```lua
Network:Destroy("SeasonalShop", "Remote")
```

## Notes

`"Remote"` removes the entry and destroys a child of `Remotes.Events`; `"RemoteFunction"` does the same in `Functions`. `"Request"` only removes the request registry entry because Requests have no per-name instance.

## Warnings

> [!WARNING]
> Clients with an existing event connection may retain a connection to the destroyed instance. Coordinate endpoint lifetime carefully.
