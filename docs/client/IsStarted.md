# IsStarted

Reports whether this client Networker module has been started.

## Syntax

```lua
local started = Network:IsStarted()
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| — | — | — | This function has no parameters. |

## Returns

Returns `true` after the first successful `Start()` call; otherwise `false`.

## Example

```lua
if not Network:IsStarted() and Network:Init() then
	Network:Start()
end
```

## Notes

This checks only the client module's internal started flag.
