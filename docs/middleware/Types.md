# Types

Creates middleware that checks Lua runtime types of positional arguments.

## Syntax

```lua
local middleware = Network.Middleware:Types(argumentTypes)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `argumentTypes` | `table` | Yes | Array of expected `type()` strings, in argument order. |

## Returns

Returns a middleware callback.

## Example

```lua
Network:Register("UpdateSettings", {
	Middlewares = {
		Network.Middleware:Types({ "string", "boolean" }),
	},
}, UpdateSettings)
```

## Notes

It iterates `argumentTypes` with `ipairs` and compares `type(args[index])` exactly. It validates only listed positions; additional supplied arguments are allowed. A mismatch returns `false, "Types"`.

## Warnings

> [!WARNING]
> A type mismatch blocks the endpoint only when `Network.Settings.PcallMiddlewares = false`; with the default setting the false return is ignored by the middleware runner.

## Best Practices

Use it before accessing or comparing client arguments. Follow it with `Range` when the first argument is numeric.
