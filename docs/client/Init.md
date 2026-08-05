# Init

Finds the server-created remote hierarchy required by the client module.

## Syntax

```lua
local ready = Network:Init()
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| — | — | — | This function has no parameters. |

## Returns

Returns `true` when `Remotes`, `Events`, `Functions`, `Requests`, and `RequestEvent` are all found. Returns `false` if a missing component is still absent after five one-second checks.

## Example

```lua
assert(Network:Init(), "Server networking is unavailable")
Network:Start()
```

## Notes

It never creates instances. It waits independently for each missing component.

Client diagnostics are controlled separately through `Network.Settings.Logging`, which defaults to `false`. This is the client module's setting and does not enable server or middleware logging.

## Best Practices

Check the return value before `Start()` so a missing server setup does not cause later errors.
