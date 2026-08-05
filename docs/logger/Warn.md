# Warn

Warns only when logging is active.

## Syntax

```lua
Logger.Warn(text, active)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `text` | `string` | Yes | Text passed to Roblox `warn`. |
| `active` | `boolean` | Yes | When true, allows the warning. |

## Returns

Returns nothing.

## Example

```lua
Network.Logger.Warn("Inventory cache was empty", Network.Settings.Logging)
```

## Notes

Networker uses this method for optional missing-remote, timeout, callback, and middleware diagnostics.

## Best Practices

Enable logging while integrating endpoints, then choose deliberately whether to keep it enabled in production.
