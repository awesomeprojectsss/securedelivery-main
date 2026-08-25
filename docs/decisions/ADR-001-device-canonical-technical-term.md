# ADR-001: Device as the Canonical Technical Term

## Status

Accepted

## Context

The product originally used `SmartBox` as both a product name and a technical entity name.

That would couple API routes, backend entities and contracts to a current product-facing label.

The MVP Device is a smartphone, while future versions may use dedicated IoT hardware.

## Decision

Use `Device` as the canonical technical term.

Use `SmartBox` only as the product-facing label in user interfaces.

Examples:

```text
Technical: Device, deviceId, /api/v1/devices
UI: SmartBox, My SmartBoxes, SmartBox Health
```

## Consequences

- Server modules and routes use `Device`.
- Cross-repository contracts use `Device`.
- Database entities/columns use Device terminology.
- Dashboard maps Device resources to SmartBox product labels.
- Future hardware can replace the smartphone without renaming the platform contract.
