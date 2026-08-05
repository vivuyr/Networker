# Init

Creates the server-side remote hierarchy in `ReplicatedStorage` when it does not already exist.

## Syntax

```lua
local ready = Network:Init()
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| — | — | — | This function has no parameters. |

## Returns

Returns `true` after ensuring `Remotes`, `Events`, `Functions`, `Requests`, and `RequestEvent` exist.

## Example

```lua
Network:Init()
Network:Start()
```

## Notes

It creates missing `Folder` instances and a `RemoteEvent` named `RequestEvent`. It does not start listeners.

## Best Practices

Call it exactly once during server startup, before `Start()`.
