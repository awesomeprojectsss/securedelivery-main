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

Event-specific calculated values use generic attributes.

Example:

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
    "key": "motion.duration",
    "value": 1.42,
    "unit": "s"
  }
]
```

---

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

---

## Event Payload

Endpoint:

```text
POST /api/v1/devices/{deviceId}/events
```

Example:

```json
{
  "schemaVersion": 1,
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
      "key": "detector.configured_threshold",
      "value": 35.0,
      "unit": "deg"
    }
  ],
  "evidence": {
    "startedAt": "2026-08-25T00:10:32.451Z",
    "finishedAt": "2026-08-25T00:10:36.451Z",
    "samples": [
      {
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

---

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
