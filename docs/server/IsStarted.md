# IsStarted

Reports whether this server Networker module has been started.

## Syntax

```lua
local started = Network:IsStarted()
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| — | — | — | This function has no parameters. |

## Returns

Returns `true` after a successful first `Start()` call; otherwise `false`.

## Example

```lua
if not Network:IsStarted() then
	Network:Init()
	Network:Start()
end
```

## Notes

The started flag belongs to the loaded module instance and is not reset by `Destroy()`.
