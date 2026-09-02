# ADR-007: Lean Telemetry Summaries and MVP Speed Context

## Status

Accepted

Amended by ADR-010, which makes the four MVP navigation aggregates structured fields while preserving generic observations for extensibility.

## Context

The original telemetry contract persisted normal one-second motion snapshots on the Server while the Device sampled IMU data at 50 Hz.

Most raw motion data has little direct business value when no abnormal event occurs.

At the same time, delivery speed has useful KPI value and provides important context for interpreting impacts, falls and abnormal movements.

A design is needed that preserves:

- precise local event detection;
- speed KPIs;
- event correlation;
- offline synchronization;
- low server storage growth.

## Decision

Use the following MVP profile:

```text
Raw IMU:                       50 Hz, Device-local
GNSS / ground-speed samples:   up to 1 Hz, Device-local
Normal server telemetry:       1-minute summaries
Network batch:                 normally every 1 minute
Event evidence:                high-frequency samples around events
```

Normal one-minute telemetry summaries contain:

- latest valid location;
- battery;
- connectivity;
- monitoring status;
- structured distance traveled in meters;
- structured moving duration in seconds;
- structured stopped duration in seconds;
- structured maximum speed in meters per second.

Average moving speed is derived from:

```text
total distance / total moving duration
```

Motion events should include valid speed context when available:

```text
navigation.speed.at_event
navigation.speed.average_5s_before
navigation.speed.maximum_10s_before
navigation.moving
```

The initial movement threshold is configurable, with an engineering baseline of:

```text
1.5 m/s (~5.4 km/h)
```

The preferred speed source is GNSS/operating-system ground speed.

Continuous raw IMU history with no event is not uploaded to the Server.

## Consequences

- Server telemetry volume is substantially reduced.
- Average/max speed and distance KPIs remain available.
- Events can be correlated with speed context.
- Events-per-distance KPIs become possible.
- Full route reconstruction is still outside the MVP.
- Raw motion evidence remains available when an abnormal event matters.
- Future continuous-value sensors such as temperature may define different retention profiles while using the same generic Observation envelope.
