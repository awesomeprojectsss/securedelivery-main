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

Canonical MVP observations:

```text
navigation.distance.traveled
navigation.moving.duration
navigation.stopped.duration
navigation.speed.maximum
```

Canonical units:

```text
navigation.distance.traveled -> m
navigation.moving.duration   -> s
navigation.stopped.duration  -> s
navigation.speed.maximum     -> m/s
```

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

Extensible measurements continue to use the generic Observation envelope:

```json
{
  "key": "navigation.speed.maximum",
  "value": 14.7,
  "unit": "m/s"
}
```

Supported values:

- number;
- string;
- boolean.

`unit` is optional.

New sensor metrics may be introduced without changing the common server DTO when the envelope remains valid.

---

## Telemetry Period Summary

Example:

```json
{
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

  "observations": [
    {
      "key": "navigation.distance.traveled",
      "value": 702.0,
      "unit": "m"
    },
    {
      "key": "navigation.moving.duration",
      "value": 52.4,
      "unit": "s"
    },
    {
      "key": "navigation.stopped.duration",
      "value": 7.6,
      "unit": "s"
    },
    {
      "key": "navigation.speed.maximum",
      "value": 17.2,
      "unit": "m/s"
    }
  ]
}
```

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
  "schemaVersion": 2,
  "batchId": "019912a7-b2b8-7892-a441-bf9fdcbcab23",
  "monitoringSessionId": "019912a6-b01c-7ba4-b842-f64abfe20f02",
  "periods": [
    {
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
      "observations": [
        {
          "key": "navigation.distance.traveled",
          "value": 702.0,
          "unit": "m"
        },
        {
          "key": "navigation.moving.duration",
          "value": 52.4,
          "unit": "s"
        },
        {
          "key": "navigation.stopped.duration",
          "value": 7.6,
          "unit": "s"
        },
        {
          "key": "navigation.speed.maximum",
          "value": 17.2,
          "unit": "m/s"
        }
      ]
    }
  ]
}
```

An online Device normally sends one period per batch.

An offline Device may send multiple accumulated period summaries after connectivity returns.

---

## Idempotency

`batchId` is generated before transmission.

Retries of the same logical batch reuse the same `batchId`.

Acknowledgement:

```json
{
  "id": "019912a7-b2b8-7892-a441-bf9fdcbcab23",
  "status": "ACCEPTED",
  "receivedAt": "2026-08-25T00:11:03.121Z"
}
```

A repeated accepted batch returns `ALREADY_ACCEPTED`.

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
