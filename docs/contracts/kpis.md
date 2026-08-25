# SecureDelivery MVP KPI Definitions

## Purpose

This document defines KPI semantics that depend on shared Device telemetry.

It prevents different repositories from calculating the same KPI differently.

The Server is the authoritative place for cross-period KPI calculations.

The Dashboard presents the resulting values.

---

## Monitored Distance

Source:

```text
navigation.distance.traveled
```

Formula:

```text
monitoredDistance =
sum(valid period distance traveled)
```

Canonical unit:

```text
m
```

Presentation may convert to kilometers.

---

## Moving Duration

Source:

```text
navigation.moving.duration
```

Formula:

```text
movingDuration =
sum(valid period moving duration)
```

Canonical unit:

```text
s
```

---

## Stopped Duration

Source:

```text
navigation.stopped.duration
```

Formula:

```text
stoppedDuration =
sum(valid period stopped duration)
```

Canonical unit:

```text
s
```

---

## Average Moving Speed

This is the primary MVP average-speed KPI.

Formula:

```text
averageMovingSpeed =
total monitored distance / total moving duration
```

Canonical unit:

```text
m/s
```

Presentation unit:

```text
km/h
```

Do not calculate this KPI as:

```text
average(period average speeds)
```

because periods may contain different moving durations and distances.

If moving duration is zero or unavailable, the KPI is unavailable rather than zero by assumption.

---

## Maximum Speed

Source:

```text
navigation.speed.maximum
```

Formula:

```text
maximumSpeed =
max(valid period maximum speed)
```

Canonical unit:

```text
m/s
```

---

## Event Speed

Source, when reliable:

```text
navigation.speed.at_event
```

Represents Device ground speed close to the event occurrence timestamp.

Do not fabricate this value when navigation quality is insufficient.

---

## Pre-Event Speed Context

Optional motion-event attributes:

```text
navigation.speed.average_5s_before
navigation.speed.maximum_10s_before
navigation.moving
```

These support investigation and correlation.

---

## Events per 100 km

Formula:

```text
eventsPer100Km =
(eventCount / monitoredDistanceKm) * 100
```

Only calculate when monitored distance is sufficiently valid and greater than zero.

The same formula can be scoped by:

- Customer;
- Device;
- monitoring session;
- event type;
- severity;
- period.

---

## Events by Speed Range

The platform may group events by the reliable `navigation.speed.at_event` value.

Speed ranges are presentation/analytics configuration and are not part of the ingestion contract.

Do not classify events with unavailable/unreliable speed into a fabricated numeric band.

Use an `UNKNOWN`/unavailable bucket when needed.

---

## Correlation, Not Automatic Causality

SecureDelivery may show relationships such as:

```text
event frequency by speed range
impact count at higher/lower speed ranges
event rate per distance
```

These are correlations.

Do not state that speed caused an event without a separately validated causal-analysis method.

Possible confounding factors include:

- road quality;
- bumps/holes;
- loading/unloading;
- cargo fixation;
- vehicle type;
- curves;
- braking;
- environmental conditions.

The product focuses on cargo/delivery integrity rather than automatically judging driver behavior.

---

## Future KPI Extensibility

Future dedicated IoT Devices may introduce continuous-value observations such as:

```text
environment.temperature
environment.humidity
container.door.open
```

New KPI definitions should be documented here when they become product requirements.

The generic Observation contract allows those metrics without redesigning the ingestion envelope.
