# Print

Prints text only when logging is active.

## Syntax

```lua
Logger.Print(text, active)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `text` | `string` | Yes | Text passed to Roblox `print`. |
| `active` | `boolean` | Yes | When true, allows the output. |

## Returns

Returns nothing.

## Example

```lua
Network.Logger.Print("Shop refreshed", Network.Settings.Logging)
```

## Notes

When `active` is false, it does nothing.

## Best Practices

Pass the relevant Networker logging setting so diagnostics remain opt-in.
