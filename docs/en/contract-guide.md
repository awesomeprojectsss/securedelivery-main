# Contract guide

## Sources of truth

- [`openapi.yaml`](../contracts/openapi.yaml): HTTP operations, authentication, bodies and responses.
- [`asyncapi.yaml`](../contracts/asyncapi.yaml): realtime server publications.
- [`common.md`](../contracts/common.md): IDs, time, enums and errors.
- [`telemetry.md`](../contracts/telemetry.md): local acquisition, summaries and retention.
- [`events.md`](../contracts/events.md): extensible events and evidence.
- [`kpis.md`](../contracts/kpis.md): formulas and unavailable-data handling.
- [`versioning.md`](../contracts/versioning.md): compatibility policy.
- [ADRs](../decisions/README.md): decision rationale and consequences.

OpenAPI and AsyncAPI are canonical. This guide explains intent but does not redefine schemas.

## Three critical flows

### Activation without a secret in the URL

The web QR carries bootstrap material in a URL fragment, the client submits `{ "activationToken": "..." }` to the body-based validate and confirm endpoints, and the Device performs its one-time exchange through `POST /device-credentials/exchange`. Every layer redacts the secret from logs, traces and errors.

The high-entropy code does not expire while the Device is `PENDING_ACTIVATION`; it may be validated again but does not authorize Device APIs. The first confirmation activates and associates the SmartBox. Later attempts return `ALREADY_ACTIVATED` and never transfer ownership. Server rate-limits attempts.

### Navigation quality

| `status` | `source` | Metrics |
|---|---|---|
| `VALID` | `GNSS` or `GPS_DERIVED` | all numeric and nonnegative |
| `PARTIAL` | `GNSS` or `GPS_DERIVED` | at least one numeric; the rest `null` |
| `UNAVAILABLE` | `UNAVAILABLE` | all `null` |

Zero is a measured zero. Missing data is `null`. Each KPI includes only reliable numeric values.

### DeviceRequest transitions

```text
PENDING --fulfill(deviceId)--> FULFILLED
PENDING --cancel(reason)-----> CANCELLED
```

Only Server authorizes and commits transitions. Terminal states cannot return to `PENDING` or change into one another.

Each request represents exactly one Device, accepts only optional `notes`, and may be fulfilled only with a `PENDING_ACTIVATION`, unassigned, non-removed Device.

### Per-period telemetry acknowledgement

Mobile sends several periods in a batch, but every period has a stable `periodId` and receives its own result. Accepted items may be removed locally; rejected items remain for diagnosis or retry. One invalid item does not discard valid siblings.

## Current versions

- HTTP route: `/api/v1`;
- OpenAPI document: `1.4.0`;
- telemetry envelope: `schemaVersion = 4`;
- Device-event envelope: `schemaVersion = 2`.

[Back to documentation](README.md) · [Development guide](development-guide.md)
