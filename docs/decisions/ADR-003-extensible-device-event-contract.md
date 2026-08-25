# ADR-003: Extensible Device-Generated Event Contract

## Status

Accepted

## Context

New event detectors will be created as Device algorithms evolve.

A closed backend event enum would require coordinated backend releases for every detector.

## Decision

Use open namespaced `eventType` strings inside a stable event envelope.

Examples:

```text
motion.strong_impact
motion.critical_inclination
motion.possible_fall
```

The server accepts unknown valid event types.

`severity` remains a closed platform enum.

## Consequences

- New Device event types normally do not require backend contract changes.
- Dashboard must safely render unknown events using a generic fallback.
- Detector metadata/version is preserved for auditability.
