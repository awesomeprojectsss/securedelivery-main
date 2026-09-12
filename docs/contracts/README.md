# SecureDelivery Shared Contracts

> Developer guides: [Português (Brasil)](../pt-BR/guia-dos-contratos.md) · [English](../en/contract-guide.md).

## Purpose

This directory is the canonical source of truth for communication between SecureDelivery repositories.

The repositories are independent applications, but they must communicate through explicitly versioned contracts.

```text
securedelivery-mobile
        │
        │ HTTP
        ▼
securedelivery-server
        │
        ├── HTTP
        └── WebSocket
        ▼
securedelivery-dashboard
```

The server owns and implements the public platform contract.

Mobile and Dashboard consume the published contract.

Do not invent request or response payloads independently inside client repositories.

---

## Canonical Terminology

### Device

`Device` is the canonical technical domain term.

Use `Device` in:

- API routes
- backend modules
- DTOs
- persistence entities
- contract schemas
- logs
- cross-repository communication

Examples:

```text
Device
DeviceService
DeviceController
DeviceRepository
/api/v1/devices
deviceId
```

### SmartBox

`SmartBox` is the product-facing label used in the user interface.

The Dashboard may display:

```text
SmartBox
My SmartBoxes
SmartBox Health
```

while consuming:

```text
GET /api/v1/devices
```

In the MVP, a Device is implemented by the SecureDelivery Flutter application running on a smartphone physically attached to the delivery box.

Future dedicated IoT hardware must remain compatible with the same Device contract.

---

## Contract Files

### `openapi.yaml`

Canonical HTTP/REST contract.

Covers:

- authentication
- users
- customers
- devices
- device activation
- Device credential provisioning
- Device requests
- monitoring sessions
- telemetry ingestion
- event ingestion/query
- support tickets
- notifications

### `asyncapi.yaml`

Canonical realtime messaging contract.

Covers server-published events such as:

- device status changes
- device health changes
- new Device-generated events
- ticket messages
- notifications

### `common.md`

Shared conventions:

- identifiers
- timestamps
- naming
- enums
- error model
- pagination
- extensibility rules

### `telemetry.md`

Lean extensible telemetry protocol: one-minute operational summaries, navigation/speed aggregates and event-specific high-frequency evidence.

### `events.md`

Generic extensible event protocol.

### `versioning.md`

Compatibility and versioning policy.

### `domain-model.md`

Shared conceptual domain model.

### `integration-flows.md`

End-to-end flows showing how Mobile, Server and Dashboard communicate.

### `kpis.md`

Canonical MVP KPI definitions for speed, distance, movement time and event correlation.

---

## Contract Ownership

The contract is changed before or together with the server implementation.

When a contract change affects Mobile or Dashboard:

1. update the canonical contract;
2. evaluate backward compatibility;
3. update the server implementation;
4. regenerate/update typed clients when client generation is configured;
5. update all affected repositories;
6. update tests;
7. update architecture documentation or ADRs when required.

---

## Typed Clients

The intended direction is:

```text
OpenAPI
   ├── TypeScript client -> Next.js Dashboard
   └── Dart client       -> Flutter Mobile
```

Client-generation tooling will be selected separately.

Until generation is configured, manually written clients must still follow `openapi.yaml` exactly.

---

## Extensibility Principle

Adding a new sensor, sensor metric or Device-generated event should normally require only a Device-side release.

The server must accept unknown observation keys and unknown event types when they conform to the generic envelope.

The shared contract changes only when the envelope itself needs a new capability.

## Current MVP Telemetry Profile

```text
IMU raw acquisition:          50 Hz, Device-local
GPS / ground speed:           up to 1 Hz, Device-local
normal Server telemetry:      one-minute summaries
normal network batch:         normally every minute
event evidence:               high-frequency around detected events
```

Normal telemetry intentionally excludes continuous raw IMU history.

MVP navigation summary keys:

```text
navigation.distanceTraveledMeters
navigation.movingDurationSeconds
navigation.stoppedDurationSeconds
navigation.maximumSpeedMetersPerSecond
```

These four KPI inputs are structured platform fields in telemetry schema version 4. The summary also declares navigation quality and source, uses `null` rather than zero for unavailable metrics, and carries a stable `periodId` for per-period acknowledgement. Generic `observations[]` remains available for future extensible business-value measurements.

Motion events may additionally carry speed-at-event and short pre-event speed context.
