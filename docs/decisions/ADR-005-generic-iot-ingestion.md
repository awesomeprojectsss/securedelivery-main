# ADR-005: Generic IoT Ingestion

## Status

Accepted

## Context

The backend should not become coupled to every Device sensor or detector implementation.

## Decision

Telemetry and event ingestion validate common versioned envelopes.

Unknown valid observation keys and unknown valid Device-generated event types are accepted.

Known values may receive specialized downstream processing without becoming an ingestion requirement.

## Consequences

- Device capabilities can evolve independently.
- Ingestion stays forward-compatible.
- Server processing must distinguish generic persistence from optional specialized interpretation.
