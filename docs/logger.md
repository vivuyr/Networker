# Logger

`NetworkerServer.Logger`, `NetworkerClient.Logger`, and `NetworkerServer.Middleware` use the same small logger module. Each method only outputs when its `active` argument is truthy.

| Function | Output |
|---|---|
| [`Print`](logger/Print.md) | Calls `print(text)`. |
| [`Warn`](logger/Warn.md) | Calls `warn(text)`. |
| [`Error`](logger/Error.md) | Calls `error(text)`. |

Enable the relevant setting to see library diagnostics:

```lua
Network.Settings.Logging = true
Network.Middleware.Settings.Logging = true
```

> [!NOTE]
> Logger calls are intentionally silent by default. `Logger.Error` raises an error only when `active` is true.
