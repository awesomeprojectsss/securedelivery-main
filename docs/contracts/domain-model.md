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

`ADMIN` is an internal platform-wide operator. It is not scoped to one Customer. The MVP has no tenant-administrator role. User email is globally unique, and only `SUPER_ADMIN` manages privileged `ADMIN` and `SUPER_ADMIN` accounts.

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

MVP lifecycle:

```text
PENDING_ACTIVATION -> ACTIVE -> INACTIVE
```

There is no `CREATED` status. Deactivation and authorized reactivation preserve history and the existing Customer association. Customer transfer is outside the MVP.

---

## MonitoringSession

Represents one continuous period in which Device monitoring is enabled.

The Device generates the canonical `monitoringSessionId` before monitoring begins. Session creation and reconciliation are idempotent, so the session can exist locally before the Server is reachable.

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

Idempotent transport envelope containing one or more compact telemetry period summaries.

An online Device normally batches one one-minute period.

An offline Device may synchronize multiple pending periods in one request.

The batch does not contain the continuous 50 Hz raw IMU stream.

---

## TelemetryPeriodSummary

Compact normal telemetry for one period, initially one minute.

May contain:

- latest valid location;
- Device state;
- a required structured navigation summary containing distance traveled, moving duration, stopped duration and maximum speed in canonical SI units;
- future generic observations with business value.

Raw IMU history is not normal telemetry.

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
- canonical `monitoringSessionId`
- namespaced event type
- severity
- occurrence time
- location
- detector metadata
- generic attributes
- evidence

Evidence and detector metadata are required. Contextual attributes may be an empty array. Location is nullable because unavailable GPS must not prevent event persistence.

Device event types are extensible.

---

## Event Evidence

High-frequency data preserved around an event trigger.

Fixed MVP window:

```text
2 seconds before
+
event interval
+
2 seconds after
```

Changing the evidence window after the MVP requires an explicit decision.

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

Ticket message history is paginated and queryable over HTTP. Ticket lifecycle includes explicit resolve and close operations.

---

## DeviceRequest

Technical resource representing a Customer request for one Device. The Dashboard presents it as a SmartBox Request.

The MVP submission has only optional free-form `notes`; it has no quantity, structured address, contact or purpose fields.

Minimum lifecycle:

```text
PENDING -> FULFILLED
PENDING -> CANCELLED
```

Fulfillment is an explicit administrative action that atomically records the associated `fulfilledDeviceId` and `fulfilledAt`. Cancellation is an explicit authorized action that records `cancellationReason` and `cancelledAt`. Only `PENDING` requests may transition; terminal state is immutable.

It does not imply billing, inventory or shipment tracking.

---

## Notification

Persistent user-facing notification owned by an authorized human user/tenant context.

WebSocket `notification.created` is only a realtime signal. Notifications remain listable over HTTP and may be marked read.

---

## Relationship Summary

```text
Customer
   ├── User[]
   ├── Device[]
   │      └── MonitoringSession[]
   │             ├── TelemetryBatch[]
   │             │      └── TelemetryPeriodSummary[]
   │             │             └── Observation[]
   │             └── DeviceEvent[]
   │                    ├── attributes[]
   │                    └── EventEvidence
   ├── DeviceRequest[]
   └── Ticket[]
          └── TicketMessage[]

User
   └── Notification[]
```
