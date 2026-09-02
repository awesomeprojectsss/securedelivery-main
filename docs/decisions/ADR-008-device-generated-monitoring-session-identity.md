# ADR-008: Device-Generated Monitoring Session Identity

## Status

Accepted

## Context

Monitoring and event detection must start while the Device is offline. A Device cannot depend on a server-generated identifier before it can persist telemetry, events, evidence or the actual monitoring stop time.

The earlier contract used both `clientSessionId` and a server `MonitoringSession.id`, leaving offline records without a canonical relationship.

## Decision

The Device generates a UUID named `monitoringSessionId` before monitoring starts. That identifier is the canonical MonitoringSession identifier across Device and Server.

The same stable `monitoringSessionId` is used for:

- MonitoringSession creation;
- telemetry batches;
- Device events and evidence;
- MonitoringSession stop;
- retries and offline reconciliation.

Session creation is idempotent by `monitoringSessionId`. The Device persists the start and stop timestamps locally. After connectivity returns, it synchronizes session creation before dependent telemetry/events and sends the Device-observed `finishedAt` when stopping the session.

The Server records separate receipt and processing timestamps where needed and never substitutes them for Device lifecycle timestamps.

## Consequences

- Monitoring can start, run and stop without connectivity.
- There is no competing client/server session identifier.
- Retry and reconciliation can use a database uniqueness constraint on `monitoringSessionId`.
- Synchronization ordering remains explicit: create/reconcile session, upload dependent records, then reconcile stop state.
