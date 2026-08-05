# Start

Starts the client listener that receives Request responses.

## Syntax

```lua
Network:Start()
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| — | — | — | This function has no parameters. |

## Returns

Returns nothing.

## Example

```lua
if Network:Init() then
	Network:Start()
end
```

## Notes

Calling it a second time does not add another Request response listener.

## Warnings

> [!WARNING]
> `Request()` needs this listener. Call `Init()` before `Start()`.
