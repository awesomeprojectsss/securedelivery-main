# SecureDelivery Contract Conventions

## Identifiers

Public entity identifiers use UUID-compatible opaque strings.

Clients must treat IDs as opaque.

Example:

```json
{
  "id": "019912a7-b2b8-7892-a441-bf9fdcbcab23"
}
```

Human-readable codes may exist separately:

```json
{
  "id": "019912a7-b2b8-7892-a441-bf9fdcbcab23",
  "code": "SD-000042"
}
```

Never use the human-readable code as the persistence primary key.

---

## Time

All contract timestamps use ISO 8601 with UTC.

Example:

```text
2026-08-25T00:10:34.451Z
```

Preserve different facts separately:

- `sampledAt`: when a sensor sample was captured
- `occurredAt`: when an event occurred
- `startedAt` / `finishedAt`: logical interval
- `receivedAt`: when the server accepted data
- `createdAt` / `updatedAt`: resource lifecycle timestamps

Never replace Device timestamps with server arrival timestamps.

---

## Technical Terminology

Canonical technical term:

```text
Device
```

Product-facing UI label:

```text
SmartBox
```

Do not use `smartbox` in API paths, cross-repository DTO names or persistence entity names.

---

## Namespaced Keys

Extensible measurement/event names use lowercase namespaced strings.

### Observation examples

```text
motion.acceleration.x
motion.acceleration.y
motion.acceleration.z
motion.gyroscope.x
motion.orientation.pitch
environment.temperature
container.door.open
```

### Event examples

```text
motion.strong_impact
motion.critical_inclination
motion.possible_fall
motion.abnormal_movement
device.sensor_failure
environment.temperature_out_of_range
```

Preferred pattern:

```text
<domain>.<subject-or-event>[.<metric>]
```

Do not use localized names inside protocol identifiers.

Avoid:

```text
queda
FallEvent
EVENT_005
xpto_sensor
```

---

## Global Closed Enums

Only platform concepts with stable global semantics should use closed enums.

### UserRole

```text
SUPER_ADMIN
ADMIN
CUSTOMER
```

### DeviceStatus

```text
PENDING_ACTIVATION
ACTIVE
INACTIVE
```

### DeviceHealth

```text
HEALTHY
WARNING
CRITICAL
UNKNOWN
```

### ConnectivityStatus

```text
ONLINE
OFFLINE
UNKNOWN
```

### MonitoringStatus

```text
MONITORING
STOPPED
UNKNOWN
```

### EventSeverity

```text
INFO
WARNING
CRITICAL
```

Sensor keys and Device-generated event types are intentionally **not** closed enums.

---

## Error Model

All HTTP errors should follow a stable envelope:

```json
{
  "statusCode": 409,
  "code": "DEVICE_ALREADY_ACTIVATED",
  "message": "Device is already activated.",
  "details": {},
  "requestId": "019912bd-5c67-7cab-a6f7-82033ec24880",
  "timestamp": "2026-08-25T00:15:00.000Z"
}
```

Clients should branch on `code`, not on human-readable `message`.

---

## Pagination

Default list response:

```json
{
  "items": [],
  "pagination": {
    "page": 1,
    "pageSize": 20,
    "totalItems": 143,
    "totalPages": 8
  }
}
```

Query example:

```text
GET /api/v1/devices?page=1&pageSize=20&status=ACTIVE&search=SD-000
```

Large collections must be paginated.

---

## Schema Version

IoT payloads include:

```json
{
  "schemaVersion": 1
}
```

`schemaVersion` versions the payload/envelope schema.

It is independent from HTTP API versioning such as:

```text
/api/v1
```
