# SecureDelivery Contract Versioning

## API Version

HTTP routes use a major API prefix:

```text
/api/v1
```

Breaking HTTP API changes require an explicit compatibility decision and may require a new API major version.

---

## IoT Schema Version

Telemetry and Device-generated event envelopes carry:

```json
{
  "schemaVersion": 1
}
```

This version is independent from `/api/v1`.

---

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
