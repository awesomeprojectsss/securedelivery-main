# SecureDelivery Integration Flows

## 1. Device Creation and Activation

```text
Administrator
    ↓
Dashboard
    ↓ HTTP
POST /api/v1/devices
    ↓
Server
    ↓
Device = PENDING_ACTIVATION
```

The mobile application exposes activation material as a QR Code.

```text
Customer scans QR
    ↓
Dashboard/Web activation flow
    ↓
client reads activation material from URL fragment locally
    ↓
POST /api/v1/device-activations/validate
body: { "activationToken": "<redacted>" }
    ↓
POST /api/v1/device-activations/confirm
body: { "activationToken": "<redacted>" }
    ↓
Server associates Device with Customer
    ↓
Device = ACTIVE
```

After confirmation, the Device sends the activation material once in the body of `POST /api/v1/device-credentials/exchange` to retrieve a Device credential. That credential is scoped to the activated `deviceId`, stored securely by Mobile and used for Device-authenticated synchronization calls. Activation material never appears in a path or query string and must be redacted from logs, traces and errors.

---

## 2. Start Monitoring

```text
User enables monitoring
    ↓
Flutter Device
    ↓
creates and durably stores stable monitoringSessionId
    ↓
POST /api/v1/devices/{deviceId}/monitoring-sessions
    ↓
Server
    ↓
MonitoringSession ACTIVE
```

Device begins:

```text
IMU 50 Hz
GPS / ground speed up to 1 Hz
event detection
rolling evidence buffer
1-minute telemetry aggregation
```

The same Device-generated `monitoringSessionId` is the canonical identifier returned by the Server and used by telemetry, events and the stop operation. Session creation is idempotent.

If monitoring starts offline, the Device does not wait for the Server. It persists the session and all dependent data locally. On reconnect it synchronizes in this order:

```text
create/reconcile MonitoringSession with stable monitoringSessionId
    ↓
upload pending telemetry batches and events
    ↓
if monitoring already stopped, send Device-observed finishedAt
```

---

## 3. Normal Telemetry

```text
Raw IMU 50 Hz                     GPS/speed up to 1 Hz
     │                                   │
     └──────── Device-side processing ───┘
                      │
              1-minute aggregation
                      │
       TelemetryPeriodSummary
                      │
          durable local storage
                      │
   POST /api/v1/devices/{deviceId}/telemetry/batches
```

Each normal period summary contains:

```text
latest location
battery/connectivity/monitoring state
navigation.distanceTraveledMeters
navigation.movingDurationSeconds
navigation.stoppedDurationSeconds
navigation.maximumSpeedMetersPerSecond
navigation.status (VALID, PARTIAL or UNAVAILABLE)
navigation.source (GNSS, GPS_DERIVED or UNAVAILABLE)
extensible observations[] (possibly empty)
```

The full raw IMU stream is not uploaded during normal operation.

Unavailable navigation values are `null`, not zero. Only reliable numeric values contribute to KPIs.

If offline:

```text
period completes
  ↓
persist summary locally
  ↓
accumulate pending periods
  ↓
connectivity returns
  ↓
send one batch with one or more periods
  ↓
retry using SAME batchId when required
```

Server:

```text
validate envelope
  ↓
validate Device/session ownership
  ↓
idempotency
  ↓
persist compact summaries
  ↓
derive/index KPI data where appropriate
  ↓
optional BullMQ downstream work
```

## 4. Abnormal Event

```text
IMU 50 Hz
   ↓
Device Event Detector
   ↓
event threshold/algorithm matches
   ↓
Device creates eventId
   ↓
preserve:
  - detector name/version
  - reliable speed/navigation context when available
  - attributes
  - location when reliable, otherwise explicit null
  - pre-event evidence
  - trigger evidence
  - post-event evidence
   ↓
local durable persistence
```

When connectivity is available:

```text
POST /api/v1/devices/{deviceId}/events
```

Server does not re-run the detector.

Server:

```text
validates common envelope
  ↓
accepts unknown valid eventType
  ↓
deduplicates by eventId
  ↓
persists event/evidence
  ↓
background processing
  ↓
event.created WebSocket signal
```

Dashboard:

```text
receives event.created
  ↓
refreshes/loads authoritative event
  ↓
known event? specialized renderer
unknown event? generic fallback renderer
```

---

## 5. Stop Monitoring

```text
User disables monitoring
    ↓
Device stops acquisition where possible
    ↓
flush/persist pending normal data
    ↓
sync when possible
    ↓
POST /api/v1/devices/{deviceId}/monitoring-sessions/{monitoringSessionId}/stop

body: { "finishedAt": "Device-observed UTC timestamp" }
```

Pending offline data remains synchronized through store-and-forward.

The Server never substitutes receipt time for `finishedAt`.

---

## 6. Support Ticket Chat

Customer creates Ticket through Dashboard.

Messages are persisted over HTTP or a future explicit realtime command contract.

Server persists message first.

Then:

```text
Server
  ↓
ticket.message.created
  ↓ WebSocket
Dashboard
```

A missed WebSocket message does not lose chat history because the message remains queryable from the server.

Authoritative recovery endpoint:

```text
GET /api/v1/tickets/{ticketId}/messages?page=1&pageSize=20
```

Ticket resolution and closure are distinct explicit HTTP actions.

---

## 7. Notifications

The Server persists a Notification before publishing `notification.created`.

If the Dashboard misses the signal or reconnects, it recovers authoritative notification state through:

```text
GET /api/v1/notifications
```

Read state is updated through the HTTP API. WebSocket does not own notification state.

---

## 8. Realtime Principle

```text
HTTP API = authoritative state
WebSocket = realtime signal
```

Dashboard reconnect behavior:

```text
WebSocket reconnects
    ↓
re-fetch affected authoritative state
```

Do not use WebSocket as the only copy of business information.

WebSocket connections authenticate human users and are authorized by role and Customer ownership. A Customer receives only tenant-authorized Device, event, ticket and notification signals.
