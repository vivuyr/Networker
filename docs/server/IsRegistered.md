# IsRegistered

Checks whether an endpoint name is present in Networker's server registry.

## Syntax

```lua
local registered = Network:IsRegistered(name, type)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `name` | `string` | Yes | Endpoint name to check. |
| `type` | `"Remote" | "RemoteFunction" | "Request"` | Yes | Registry to inspect. |

## Returns

Returns `true` or `false` for a valid type after `Start()`. Returns `false` before starting. Returns `nil` when `type` is absent or invalid.

## Example

```lua
if not Network:IsRegistered("Notification", "Remote") then
	Network:Register("Notification", {}, function() end)
end
```

## Notes

This checks Networker's table, not merely whether a Roblox instance with that name exists in a folder.
