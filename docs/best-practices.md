# Best Practices

## Prefer Request for client-to-server gameplay replies

Use Request for things such as inventory snapshots, a matchmaking result, or a reward claim. It provides a five-second default timeout and avoids a dedicated `RemoteFunction` per endpoint.

> [!IMPORTANT]
> Request returns `nil` for all failures. Make successful response shapes explicit and handle `nil` as failure.

## Validate every client argument

Clients control every value they send. Use `Types` before code that depends on argument types, then use `Range` for a numeric first argument. For their `false` returns to block the callback in the current implementation, set `Network.Settings.PcallMiddlewares = false` before handling calls.

```lua
Middlewares = {
	Network.Middleware:Types({ "number" }),
	Network.Middleware:Range(1, 20),
}
```

`Range` itself checks that the first argument is a number, but placing `Types` first keeps validation policy clear and supports additional arguments.

## Use RateLimit and Cooldown together

`RateLimit` limits call frequency in calls per second; `Cooldown` blocks a player for a duration after an accepted call. Use both on expensive or state-changing endpoints, with `PcallMiddlewares` disabled so their rejection returns are honored.

```lua
Middlewares = {
	Network.Middleware:RateLimit(8),
	Network.Middleware:Cooldown(0.25),
}
```

## Use Resolve to avoid repeated lookup code

Load a profile, character state, or permission once in `Resolve`, then consume it from `context.Data` in the callback. Rejecting a missing value there prevents callback code from operating on `nil`.

## Keep middleware lightweight

Middleware runs for every accepted incoming server call and in the order configured. Avoid slow yields and unnecessary datastore or network work. Put cheap rejection checks first.

## Treat client responses as untrusted

`InvokeClient` asks the client to execute code and return data. Only enable `ClientToServerFunction` when required, and validate any client return value on the server.

> [!CAUTION]
> A client can delay, fail to answer, or return manipulated values. Never use client RPC as authority for purchases, rewards, moderation, or player data.

## Register before use

Register endpoints only after server `Start()`. On the client, call `On` only after the matching server event exists. In practice, start the server and register endpoints before players join.
