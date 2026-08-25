# ADR-002: Extensible Observation-Based Telemetry

## Status

Accepted

## Context

SecureDelivery must support future sensors without requiring server DTO and API changes for every new measurement.

Sensor-specific fields such as `accelerometerX` or `temperature` would create tight coupling.

## Decision

Represent sensor measurements using generic namespaced observations:

```json
{
  "key": "motion.orientation.pitch",
  "value": 42.7,
  "unit": "deg"
}
```

The server validates the generic envelope and accepts unknown valid observation keys.

## Consequences

- New sensor metrics normally require Device-side changes only.
- Known metrics may receive specialized indexing/processing.
- Unknown metrics remain ingestible.
- Contract-breaking changes are limited to changes in the generic envelope itself.
