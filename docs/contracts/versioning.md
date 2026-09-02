# SecureDelivery Contract Versioning

## API Version

HTTP routes use a major API prefix:

```text
/api/v1
```

Breaking HTTP API changes require an explicit compatibility decision and may require a new API major version.

OpenAPI document version `1.3.0` is a coordinated pre-implementation correction. It replaces activation-token path operations with body-based validate, confirm and credential-exchange operations. No production compatibility with the removed token-in-path shapes is promised; Server, Mobile and Dashboard must implement only the corrected contract. Once a production API is published, the normal major-version compatibility policy applies.

---

## IoT Schema Version

Telemetry envelopes carry:

```json
{
  "schemaVersion": 3
}
```

This version is independent from `/api/v1`.

Device-event envelopes currently carry:

```json
{
  "schemaVersion": 2
}
```

---

## Current IoT Schema

Current envelope versions:

```text
telemetry schemaVersion = 3
Device-event schemaVersion = 2
```

Telemetry version 3 retains the lean telemetry model introduced in version 2 and adds explicit navigation quality semantics:

- normal one-minute period summaries;
- no continuous normal server-side raw IMU samples;
- navigation/speed summary metrics;
- event-specific high-frequency evidence;
- event speed context;
- required `navigation.status` and `navigation.source`;
- nullable navigation metrics when reliable data is unavailable;
- a prohibition on substituting zero for unknown navigation data.

Version 3 is a coordinated breaking change from version 2 because it adds required quality fields and permits null metric values. Server, Mobile and Dashboard must deploy compatible handling before version 3 telemetry is enabled.

## Additive Changes

Normally backward-compatible:

- adding an optional field;
- introducing a new observation key;
- introducing a new `eventType`;
- introducing a new optional event attribute;
- adding a new WebSocket event that old clients can ignore.

---

## Breaking Changes

Potentially breaking:

- removing or renaming a required field;
- changing a field type;
- changing identifier semantics;
- changing timestamp semantics;
- changing idempotency semantics;
- changing the meaning of an existing closed enum value;
- making an optional field required.

Breaking changes must be documented and coordinated across affected repositories.

---

## Forward Compatibility

The Server must tolerate unknown observation keys and unknown Device-generated event types.

The Dashboard must render unknown Device-generated events safely using generic fallback UI.

The Mobile must not depend on Dashboard support before sending a new valid event type.

---

## Deployment Compatibility

Prefer compatibility across at least adjacent application versions where practical.

Example:

```text
new Mobile -> current Server -> current Dashboard
```

should continue ingesting data even if the Dashboard does not yet have a specialized renderer for a newly introduced event type.
