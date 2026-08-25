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
GET /api/v1/device-activations/{token}
    ↓
POST /api/v1/device-activations/{token}/confirm
    ↓
Server associates Device with Customer
    ↓
Device = ACTIVE
```

The exact credential/provisioning mechanism used by the Flutter Device to authenticate itself is a separate architectural decision.

---

## 2. Start Monitoring

```text
User enables monitoring
    ↓
Flutter Device
    ↓
creates stable clientSessionId
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
GPS up to 1 Hz
event detection
rolling evidence buffer
normal snapshot 1 Hz
```

---

## 3. Normal Telemetry

```text
Raw sensors
   ↓ 50 Hz IMU
Device detector/processing
   ↓
1 Hz normal snapshot
   ↓
Local durable storage
   ↓
~60 snapshots
   ↓
1-minute TelemetryBatch
   ↓
POST /api/v1/devices/{deviceId}/telemetry/batches
```

If offline:

```text
send fails
  ↓
keep batch locally
  ↓
retry later using SAME batchId
```

Server:

```text
validate envelope
  ↓
validate Device/session ownership
  ↓
idempotency
  ↓
persist
  ↓
optional BullMQ downstream work
  ↓
publish compact realtime signal
```

---

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
  - attributes
  - location
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
POST /api/v1/devices/{deviceId}/monitoring-sessions/{sessionId}/stop
```

Pending offline data remains synchronized through store-and-forward.

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

---

## 7. Realtime Principle

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
