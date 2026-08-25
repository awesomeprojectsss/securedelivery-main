# ADR-006: High-Frequency IMU Sampling with Low-Frequency Telemetry Batching

## Status

Accepted

## Context

A 1 Hz IMU sampling rate can completely miss short impacts or rapid angle changes occurring within tens or hundreds of milliseconds.

Continuously transmitting high-frequency raw IMU data would create unnecessary network, storage and battery cost.

## Decision

Initial MVP profile:

```text
Raw IMU sampling:          50 Hz (~20 ms)
Event detection:           high-frequency local processing
Normal telemetry snapshot: 1 Hz
GPS/location snapshot:     up to 1 Hz as required
Network telemetry batch:   every 1 minute
Event evidence:            high-frequency window around detected event
```

Initial event-evidence target:

```text
approximately 2 seconds before
+
trigger/event interval
+
approximately 2 seconds after
```

All rates remain configurable and subject to real-device calibration.

## Consequences

- Rapid events are much less likely to be missed.
- Server receives compact normal telemetry.
- High-frequency raw data is uploaded primarily as event evidence.
- Mobile must maintain an efficient rolling buffer for recent IMU samples.
- Battery and platform background limits must be measured during tests.
