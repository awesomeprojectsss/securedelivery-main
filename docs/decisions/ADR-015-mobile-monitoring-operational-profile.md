# ADR-015: MVP Mobile Monitoring Operational Profile

## Status

Accepted, with detector calibration deferred

## Context

The existing contracts define lean telemetry and on-Device detection but do not set the supported Android baseline, local storage budget, retry acknowledgement, safety stops or daily operating limit for the smartphone-based MVP.

## Decision

The MVP Mobile application supports Android 10 (API level 29) and later. iOS is not an MVP target unless a later decision adds it.

Raw IMU acquisition targets 50 Hz on supported test Devices. The implementation must measure the effective sample rate and tests must define an acceptable tolerance before release; it must not silently claim 50 Hz when the operating system or hardware cannot sustain it.

Monitoring uses at most 50 MiB of managed local payload storage. When a new durable write would exceed the budget, cleanup occurs in this order:

1. remove data already acknowledged by the Server;
2. remove the oldest normal telemetry summaries;
3. preserve unsynchronized Device events and their evidence for as long as possible;
4. if no safe cleanup is possible, reject the new local record, persist a minimal local diagnostic outside the payload queue when feasible, and raise `device.storage_low` for later synchronization.

The application must never report unsaved data as durable. Event evidence has higher retention priority than normal telemetry, but the 50 MiB hard budget still applies.

Pending data is sent in batches. The Server acknowledges each telemetry period individually so Mobile deletes only accepted items. A partial rejection leaves rejected items available for diagnosis/retry and raises `device.sync_partial_failure`; an invalid item must not prevent valid sibling items from being accepted. The baseline retry interval is one minute. Clients must honor an explicit server `Retry-After` instruction. Exponential backoff is not required for the initial MVP, but retry loops must avoid concurrent duplicate sends.

The event evidence window is fixed for the MVP:

```text
2 seconds before trigger
+ trigger interval
+ 2 seconds after trigger
```

Monitoring requires background-operation permission. When permission or the necessary operating-system exemption is missing, the application explains why it is needed and provides a direct action to the relevant Android settings screen.

Monitoring must not start, and an active session must stop safely, when:

- battery level is below 15% and the Device is not charging;
- Android reports thermal status `SEVERE`, `CRITICAL`, `EMERGENCY` or `SHUTDOWN`;
- cumulative monitoring reaches 12 hours in a rolling 24-hour period.

A raw temperature such as 90 °C is not used as the operational threshold. Android's thermal-status API is the canonical safety signal because safe component temperatures vary by hardware. Any available temperature may be retained only as diagnostic context.

Detector algorithms, thresholds, calibration procedure and acceptable false-positive/false-negative targets remain deliberately undecided. Implementations must not invent production thresholds. This deferred decision requires Device testing and a dedicated ADR before detector behavior is accepted for the MVP.

## Consequences

- Mobile storage and acknowledgement behavior are testable rather than implementation folklore.
- The telemetry contract needs stable per-period identifiers and per-period acknowledgement results.
- Low-storage and partial-sync failures use extensible namespaced Device events.
- Thermal and battery stops must preserve the MonitoringSession's Device-observed finish time and pending data.
- Detector calibration remains a visible blocker for production acceptance, not for scaffolding the surrounding flow.

