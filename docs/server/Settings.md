# Server Settings

`NetworkerServer.Settings` controls selected server-side Networker behavior. Configure it during server startup, before clients can call an endpoint.

## Syntax

```lua
Network.Settings.SettingName = value
```

## Settings

| Setting | Type | Default | Description |
|---|---|---:|---|
| `ClientToServerFunction` | `boolean` | `false` | Allows `Network:InvokeClient(...)` to invoke a client's `OnServerInvoke` handler. |
| `FirstGlobalMiddleware` | `boolean` | `true` | Runs global middleware before endpoint middleware. When `false`, endpoint middleware runs first. |
| `Logging` | `boolean` | `false` | Enables messages emitted through `Network.Logger` by server networking APIs. |
| `PcallMiddlewares` | `boolean` | `true` | Catches errors thrown by middleware. In this implementation, it also means returned `false` values are not enforced. |

## Example

```lua
Network.Settings.FirstGlobalMiddleware = false
Network.Settings.Logging = true
Network.Settings.PcallMiddlewares = false
```

## Notes

`Network.Middleware.Settings.Logging` is separate from `Network.Settings.Logging`; enable it as well to see diagnostics emitted inside built-in middleware.

The client has its own independent logging option: `NetworkerClient.Settings.Logging`, which defaults to `false`. Enable it on the client to see client-side missing-remote, callback, and Request timeout diagnostics.

`ClientToServerFunction` is only checked by server `InvokeClient`. It does not control client `InvokeServer` calls.

## Warnings

> [!CAUTION]
> Enabling `ClientToServerFunction` permits the server to yield while asking a client for a value. A client response is untrusted and must never be used as server authority.

> [!WARNING]
> With the default `PcallMiddlewares = true`, a middleware that returns `false` does not stop the callback. Set it to `false` if you rely on `RateLimit`, `Cooldown`, `Types`, `Range`, `Resolve`, or `Custom` to reject calls by return value; thrown middleware errors will then not be caught by Networker's middleware runner.

## Best Practices

Set all options once during startup. Keep `ClientToServerFunction` disabled unless server-to-client `RemoteFunction` invocation is truly needed, and use `FirstGlobalMiddleware = true` unless an endpoint specifically needs its local checks to run first.
