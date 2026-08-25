# SecureDelivery Shared Domain Model

## Purpose

This document defines shared concepts used across repositories.

It does not define database tables or framework-specific classes.

---

## Customer

Represents an organization using SecureDelivery.

A Customer owns or is associated with Devices and can access only its own tenant data.

---

## User

Authenticated human platform user.

Roles:

```text
SUPER_ADMIN
ADMIN
CUSTOMER
```

---

## Device

Canonical technical entity representing a monitored IoT endpoint.

In the MVP:

```text
Device
  └── Flutter application running on smartphone
```

The smartphone is physically fixed horizontally to the delivery box during tests.

Future:

```text
Device
  └── Dedicated IoT hardware
```

Product UI label:

```text
SmartBox
```

Technical term:

```text
Device
```

---

## MonitoringSession

Represents one continuous period in which Device monitoring is enabled.

A MonitoringSession groups:

- normal telemetry
- Device-generated events
- evidence
- Device operational state

Conceptually:

```text
Device
   └── MonitoringSession
          ├── TelemetryBatch[]
          └── DeviceEvent[]
```

This allows tests to exist without requiring a commercial Delivery entity.

Future deliveries may reference or own MonitoringSessions according to a later domain decision.

---

## TelemetryBatch

Idempotent collection of normal telemetry snapshots.

Initial profile:

```text
~1 snapshot/second
~1 batch/minute
```

The batch does not normally contain the complete 50 Hz raw IMU stream.

---

## TelemetrySample

Lower-rate operational snapshot.

May contain:

- location
- generic sensor observations
- timestamp
- sequence

---

## Observation

Generic sensor/measurement tuple:

```text
key
value
unit?
```

Example:

```json
{
  "key": "motion.acceleration.x",
  "value": 0.18,
  "unit": "m/s2"
}
```

Observation keys are extensible.

---

## DeviceEvent

Event detected by Device-side algorithms.

Contains:

- stable event ID
- namespaced event type
- severity
- occurrence time
- location
- detector metadata
- generic attributes
- evidence

Device event types are extensible.

---

## Event Evidence

High-frequency data preserved around an event trigger.

Initial target:

```text
2 seconds before
+
event interval
+
2 seconds after
```

The evidence window is configurable.

---

## Device State

Platform-understood operational information such as:

- battery
- connectivity
- monitoring status
- latest location
- last seen

This is intentionally more structured than arbitrary sensor observations because the platform uses it for operational health.

---

## Ticket

Persistent customer-support conversation context.

A Ticket contains persisted messages and may be assigned to an Administrator.

Realtime WebSocket publication supplements but never replaces persistent history.

---

## Relationship Summary

```text
Customer
   ├── User[]
   ├── Device[]
   │      └── MonitoringSession[]
   │             ├── TelemetryBatch[]
   │             │      └── TelemetrySample[]
   │             │             └── Observation[]
   │             └── DeviceEvent[]
   │                    ├── attributes[]
   │                    └── EventEvidence
   └── Ticket[]
          └── TicketMessage[]
```
