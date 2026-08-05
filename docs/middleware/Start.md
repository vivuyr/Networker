# Start

Installs middleware cleanup for players who leave.

## Syntax

```lua
Network.Middleware:Start()
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| — | — | — | This function has no parameters. |

## Returns

Returns nothing.

## Example

```lua
Network:Init()
Network:Start() -- calls Middleware:Start() automatically
```

## Notes

It removes leaving players from all RateLimit and Cooldown tracking tables. Server `Network:Start()` calls it automatically.

## Best Practices

Do not call it separately in normal Networker setup.
