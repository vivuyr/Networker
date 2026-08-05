# Start

Starts Networker's server request listener and middleware cleanup.

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
Network:Init()
Network:Start()
Network:Register("OpenShop", {}, function(_context, player)
	print(player.Name, "opened the shop")
end)
```

## Notes

It connects the shared Request event and calls `Network.Middleware:Start()`. Calling it again only optionally logs a warning; it does not create another listener.

## Warnings

> [!WARNING]
> Call `Init()` first. `Start()` assumes the reference hierarchy has already been found or created.
