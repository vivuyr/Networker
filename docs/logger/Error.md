# Error

Raises an error only when logging is active.

## Syntax

```lua
Logger.Error(text, active)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `text` | `string` | Yes | Text passed to Roblox `error`. |
| `active` | `boolean` | Yes | When true, raises the error. |

## Returns

Does not return when `active` is true because `error(text)` is raised. Returns nothing when false.

## Example

```lua
Network.Logger.Error("Required setup is missing", Network.Settings.Logging)
```

## Notes

When `active` is false, this method does nothing and does not raise an error.

## Warnings

> [!WARNING]
> This interrupts the current thread when active. Networker itself does not use `Logger.Error` in its implementation.

## Best Practices

Use it only for conditions that should stop the current flow.
