# SecureDelivery Extensible Device Event Contract

## Goal

New Device-side event detectors should normally be deployable without backend contract changes.

The server understands the common event envelope, not every possible event algorithm.

---

## Event Type

`eventType` is an open namespaced string.

Examples for the MVP:

```text
motion.strong_impact
motion.critical_inclination
motion.possible_fall
motion.abnormal_movement
```

Future examples:

```text
device.sensor_failure
container.door_opened
environment.temperature_out_of_range
```

Future examples do not imply MVP scope.

Do not implement Device-generated event types as a closed backend enum.

---

## Severity

Severity is a stable platform-level enum:

```text
INFO
WARNING
CRITICAL
```

---

## Detector Metadata

Every Device-generated event should identify the detector implementation.

Example:

```json
{
  "name": "inclination-detector",
  "version": "1.0.0"
}
```

Detector versioning is critical for:

- calibration
- false-positive investigation
- behavior comparison
- auditability

---

## Event Attributes

Event-specific values use generic attributes.

`attributes` is always present and may be an empty array when no reliable contextual values are available.

For motion events, the Device should include useful navigation context when reliable speed data is available.

MVP navigation context:

```text
navigation.speed.at_event
navigation.speed.average_5s_before
navigation.speed.maximum_10s_before
navigation.moving
```

Examples:

```json
[
  {
    "key": "motion.peak_pitch",
    "value": 42.7,
    "unit": "deg"
  },
  {
    "key": "detector.configured_threshold",
    "value": 35.0,
    "unit": "deg"
  },
  {
    "key": "navigation.speed.at_event",
    "value": 14.1,
    "unit": "m/s"
  },
  {
    "key": "navigation.speed.average_5s_before",
    "value": 13.8,
    "unit": "m/s"
  },
  {
    "key": "navigation.speed.maximum_10s_before",
    "value": 15.2,
    "unit": "m/s"
  },
  {
    "key": "navigation.moving",
    "value": true
  }
]
```

Speed context must only be included when the Device considers the underlying GNSS data valid enough for interpretation.

This context supports correlation analysis without requiring full per-second route/speed history on the Server.

## Evidence Window

Initial MVP recommendation:

```text
2 seconds before trigger
+
event/trigger interval
+
2 seconds after trigger
```

With a 50 Hz IMU baseline, a four-second surrounding window can preserve roughly 200 high-frequency samples, plus any samples covering the trigger interval itself.

The exact evidence window should remain configurable.

Evidence is persisted locally before synchronization.

Evidence is required for every detected Device event. An event is persisted locally with its detector metadata and evidence before it is eligible for synchronization.

---

## Event Payload

Endpoint:

```text
POST /api/v1/devices/{deviceId}/events
```

Example:

```json
{
  "schemaVersion": 2,
  "eventId": "019912bd-5c67-7cab-a6f7-82033ec24880",
  "monitoringSessionId": "019912a6-b01c-7ba4-b842-f64abfe20f02",
  "eventType": "motion.critical_inclination",
  "severity": "WARNING",
  "occurredAt": "2026-08-25T00:10:34.451Z",

  "location": {
    "latitude": -23.55052,
    "longitude": -46.63331,
    "accuracyMeters": 8.1
  },

  "detector": {
    "name": "inclination-detector",
    "version": "1.0.0"
  },

  "attributes": [
    {
      "key": "motion.peak_pitch",
      "value": 42.7,
      "unit": "deg"
    },
    {
      "key": "navigation.speed.at_event",
      "value": 14.1,
      "unit": "m/s"
    },
    {
      "key": "navigation.speed.average_5s_before",
      "value": 13.8,
      "unit": "m/s"
    },
    {
      "key": "navigation.moving",
      "value": true
    }
  ],

  "evidence": {
    "startedAt": "2026-08-25T00:10:32.451Z",
    "finishedAt": "2026-08-25T00:10:36.451Z",
    "samples": [
      {
        "sequence": 0,
        "sampledAt": "2026-08-25T00:10:34.451Z",
        "observations": [
          {
            "key": "motion.orientation.pitch",
            "value": 42.7,
            "unit": "deg"
          },
          {
            "key": "motion.acceleration.z",
            "value": 7.81,
            "unit": "m/s2"
          }
        ]
      }
    ]
  }
}
```

`location` is always present as a field but may be `null` when no reliable GPS fix is available. Unavailable location or speed context must never be fabricated and must not prevent the event from being persisted.

`occurredAt` is the Device-observed event time. The Server separately records `receivedAt` when ingestion succeeds.

The Device-generated `monitoringSessionId` is the canonical MonitoringSession identifier. It is created before monitoring starts and reused across session creation, telemetry, events, stop synchronization and retries.

The normal telemetry contract does not contain this high-frequency evidence stream.

High-frequency evidence exists specifically for relevant detected events.

## Idempotency

`eventId` is generated once by the Device.

All retries for the same logical event reuse the same `eventId`.

The backend must enforce duplicate protection.

---

## Unknown Events

The server must accept unknown `eventType` values when the envelope is valid.

The Dashboard must not crash on unknown event types.

When no specialized UI exists, use a generic renderer with:

- event type
- severity
- timestamp
- Device/SmartBox display name
- location
- generic attributes

This preserves forward compatibility between independently deployed Device, Server and Dashboard versions.
