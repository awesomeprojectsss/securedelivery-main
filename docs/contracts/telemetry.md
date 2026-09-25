# SecureDelivery Lean Telemetry Contract

## Goal

SecureDelivery intentionally does **not** upload continuous raw motion telemetry during normal operation.

The Device uses high-frequency sensor data locally to detect events.

The Server receives:

- compact one-minute operational summaries;
- Device state;
- latest location;
- navigation/speed aggregates;
- high-frequency raw evidence only when an event is detected.

This keeps the MVP useful for KPIs while avoiding storage of large volumes of raw data with little business value.

---

## MVP Acquisition Profile

```text
Raw IMU sampling:                 50 Hz (~20 ms)
Event detection:                  high-frequency local processing
GPS / ground-speed observation:   up to 1 Hz
Normal server telemetry summary:  1 summary/minute
Network batching:                 normally every 1 minute
Event evidence:                   high-frequency samples around event
```

The rates are configuration values and may be calibrated through real-device testing.

---

## What Stays on the Device

During normal operation, the following data is primarily Device-local:

- raw 50 Hz accelerometer samples;
- raw 50 Hz gyroscope samples;
- high-frequency derived orientation samples;
- short rolling IMU evidence buffer;
- per-second GPS/speed observations used to calculate minute summaries.

When no event is detected, old raw IMU data may be discarded after it is no longer needed by the rolling evidence window.

The Device must not continuously send or persist the complete 50 Hz motion stream on the Server.

---

## What the Server Receives Normally

For each completed telemetry period, initially one minute, the Device sends a compact summary.

The MVP summary includes:

### Operational state

- battery;
- connectivity;
- monitoring status.

### Latest location

- latest valid latitude/longitude;
- GPS accuracy;
- timestamp.

The MVP does not reconstruct or persist a full delivery route from normal telemetry.

### Navigation aggregates

Canonical MVP structured navigation fields:

```text
navigation.distanceTraveledMeters
navigation.movingDurationSeconds
navigation.stoppedDurationSeconds
navigation.maximumSpeedMetersPerSecond
```

Quality fields:

```text
navigation.status -> VALID | PARTIAL | UNAVAILABLE
navigation.source -> GNSS | GPS_DERIVED | UNAVAILABLE
```

Canonical units:

```text
distanceTraveledMeters          -> m
movingDurationSeconds           -> s
stoppedDurationSeconds          -> s
maximumSpeedMetersPerSecond     -> m/s
```

All four metric keys are required. Available values are nonnegative numbers; unavailable values are `null`, never zero by substitution. They are strongly structured because they are platform-level MVP KPI inputs.

Consistency rules:

- `VALID`: all metrics are numeric and source is `GNSS` or `GPS_DERIVED`;
- `PARTIAL`: at least one metric is numeric, unavailable metrics are `null`, and source is `GNSS` or `GPS_DERIVED`;
- `UNAVAILABLE`: every metric is `null` and source is `UNAVAILABLE`.

The server can derive:

```text
average moving speed = total distance traveled / total moving duration
```

This is preferable to averaging per-minute averages.

The Dashboard converts canonical SI units for presentation, such as m/s to km/h.

---

## Speed Source

Preferred speed source:

```text
GNSS / operating-system ground speed
```

Do not estimate normal delivery speed by integrating accelerometer acceleration over time because accumulated drift makes it unsuitable for this KPI.

If direct ground speed is unavailable, a Device implementation may derive speed from consecutive valid GPS fixes as a fallback, with explicit accuracy and timestamp filtering.

The movement/stopped classification threshold must be configurable.

Initial engineering baseline:

```text
moving threshold: 1.5 m/s (~5.4 km/h)
```

This threshold is not a business rule and should be calibrated through real motorcycle/delivery tests.

GPS readings that fail the Device's quality criteria must not be treated as reliable speed samples.

---

## Generic Observation

Future/extensible measurements continue to use the generic Observation envelope:

```json
{
  "key": "device.signal.quality",
  "value": 0.93
}
```

Supported values:

- number;
- string;
- boolean.

`unit` is optional.

New sensor metrics may be introduced without changing the common server DTO when the envelope remains valid.

The four canonical schema-version-3 navigation fields are not duplicated in `observations[]`.

---

## Telemetry Period Summary

Example:

```json
{
  "periodId": "019912a7-b2b8-7892-a441-bf9fdcbcab24",
  "periodStartedAt": "2026-08-25T00:10:00.000Z",
  "periodFinishedAt": "2026-08-25T00:10:59.999Z",

  "deviceState": {
    "battery": {
      "levelPercent": 76,
      "charging": false
    },
    "connectivity": {
      "status": "ONLINE",
      "type": "CELLULAR"
    },
    "monitoringStatus": "MONITORING"
  },

  "lastLocation": {
    "latitude": -23.55052,
    "longitude": -46.63331,
    "accuracyMeters": 7.2,
    "recordedAt": "2026-08-25T00:10:58.900Z"
  },

  "navigation": {
    "status": "VALID",
    "source": "GNSS",
    "distanceTraveledMeters": 702.0,
    "movingDurationSeconds": 52.4,
    "stoppedDurationSeconds": 7.6,
    "maximumSpeedMetersPerSecond": 17.2
  },

  "observations": []
}
```

`lastLocation` is required as a field but may be `null` when the period has no valid location. The Device must not fabricate a GPS position.

---

## Telemetry Batch

The transport remains batch-oriented so offline Devices can synchronize multiple pending periods in one request.

Endpoint:

```text
POST /api/v1/devices/{deviceId}/telemetry/batches
```

Example:

```json
{
  "schemaVersion": 4,
  "batchId": "019912a7-b2b8-7892-a441-bf9fdcbcab23",
  "monitoringSessionId": "019912a6-b01c-7ba4-b842-f64abfe20f02",
  "periods": [
    {
      "periodId": "019912a7-b2b8-7892-a441-bf9fdcbcab24",
      "periodStartedAt": "2026-08-25T00:10:00.000Z",
      "periodFinishedAt": "2026-08-25T00:10:59.999Z",
      "deviceState": {
        "battery": {
          "levelPercent": 76,
          "charging": false
        },
        "connectivity": {
          "status": "ONLINE",
          "type": "CELLULAR"
        },
        "monitoringStatus": "MONITORING"
      },
      "lastLocation": {
        "latitude": -23.55052,
        "longitude": -46.63331,
        "accuracyMeters": 7.2,
        "recordedAt": "2026-08-25T00:10:58.900Z"
      },
      "navigation": {
        "status": "VALID",
        "source": "GNSS",
        "distanceTraveledMeters": 702.0,
        "movingDurationSeconds": 52.4,
        "stoppedDurationSeconds": 7.6,
        "maximumSpeedMetersPerSecond": 17.2
      },
      "observations": []
    }
  ]
}
```

An online Device normally sends one period per batch.

An offline Device may send multiple accumulated period summaries after connectivity returns.

The Device generates `monitoringSessionId` before monitoring begins and persists it with every local period. After reconnecting, it first creates/reconciles that MonitoringSession idempotently, then uploads its pending batches. It never waits for a server-generated session identifier.

---

## Idempotency

`batchId` and every `periodId` are generated before transmission.

Retries of the same logical batch reuse the same `batchId`.

Retries of the same logical period reuse the same `periodId`, even if Mobile places that period in a later retry batch.

The Server acknowledges every period independently. A malformed batch envelope fails as a whole. Once the envelope is valid, one rejected period does not prevent valid sibling periods from being accepted.

Acknowledgement:

```json
{
  "batchId": "019912a7-b2b8-7892-a441-bf9fdcbcab23",
  "receivedAt": "2026-08-25T00:11:03.121Z",
  "items": [
    {
      "periodId": "019912a7-b2b8-7892-a441-bf9fdcbcab24",
      "status": "ACCEPTED"
    }
  ]
}
```

A repeated accepted period returns `ALREADY_ACCEPTED`. A rejected result includes a stable machine-readable `code` and human-readable `message`. Mobile retains rejected items for diagnosis/retry and raises `device.sync_partial_failure` for later synchronization.

---

## MVP Mobile Operational Limits

- supported operating system: Android 10 (API level 29) or later;
- managed local monitoring payload budget: 50 MiB;
- baseline retry interval: one minute, while honoring server `Retry-After`;
- fixed evidence window: two seconds before, the trigger interval, and two seconds after;
- monitoring is blocked below 15% battery unless charging;
- monitoring stops when Android thermal status is `SEVERE` or worse;
- monitoring is limited to 12 accumulated hours in a rolling 24-hour period.

When storage pressure occurs, Mobile first deletes acknowledged data, then the oldest normal telemetry, and preserves unsynchronized events/evidence for as long as the hard budget permits. If it cannot store a new record safely, it must not claim durability and raises `device.storage_low` for later synchronization.

---

## KPI Basis

With normal telemetry summaries, the platform can calculate:

- total monitored distance;
- average moving speed;
- maximum speed;
- moving time;
- stopped time;
- average speed by Customer;
- average speed by Device;
- average speed by monitoring session/delivery;
- events per 100 km;
- events by speed range when combined with event context.

No continuous server-side raw IMU history is required for these KPIs.

---

## Retention Principle

Store server-side data according to business value.

### Keep

- telemetry period summaries;
- Device operational state;
- navigation aggregates;
- event records;
- event evidence;
- audit-relevant metadata.

### Do not normally keep

- continuous raw IMU data with no event;
- continuous gyroscope history with no event;
- full per-second route history solely because it is available.

Future dedicated IoT Devices may introduce measurements such as temperature or humidity whose continuous history has business value. Those measurements can use the same generic Observation contract and may have a different retention profile.

---

## Server Compatibility Rule

The server must not reject a valid telemetry summary because it contains an unknown valid Observation key.

Known metrics may receive specialized indexing or KPI processing without making ingestion dependent on compile-time knowledge of every future sensor.

The Server validates the structured `navigation` values separately from generic observations and rejects negative values, inconsistent status/source combinations or malformed units-by-field semantics. Only reliable numeric values enter KPI aggregates.
