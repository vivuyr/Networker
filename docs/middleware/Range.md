# Range

Creates middleware that requires the first client argument to be a number in an inclusive range.

## Syntax

```lua
local middleware = Network.Middleware:Range(minimum, maximum)
```

## Parameters

| Parameter | Type | Required | Description |
|---|---|---|---|
| `minimum` | `number` | Yes | Inclusive lower bound. |
| `maximum` | `number` | Yes | Inclusive upper bound. |

## Returns

Returns a middleware callback.

## Example

```lua
Network:Register("SelectLoadout", {
	Middlewares = {
		Network.Middleware:Types({ "number" }),
		Network.Middleware:Range(1, 6),
	},
}, SelectLoadout)
```

## Notes

Only the first forwarded argument is read. A non-number, a number below `minimum`, or a number above `maximum` returns `false, "Range"`.

## Warnings

> [!WARNING]
> Range's false return blocks the endpoint only when `Network.Settings.PcallMiddlewares = false`; the default setting does not honor it.

## Best Practices

Run `Types` before `Range`, then perform domain checks such as ownership in the callback.
