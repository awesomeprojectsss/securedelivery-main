# ADR-014: Device Lifecycle and Persistent Physical Activation Code

## Status

Accepted

## Context

The product documentation mentioned a `CREATED` Device state that did not exist in the canonical contract. The original activation design also treated the QR payload as short-lived, while a future physical SmartBox needs a QR Code printed on or permanently associated with the hardware.

## Decision

The MVP Device lifecycle is:

```text
PENDING_ACTIVATION -> ACTIVE -> INACTIVE
```

An Administrator creates a Device in `PENDING_ACTIVATION`. There is no `CREATED` state. A Device becomes `ACTIVE` only after an authenticated Customer confirms activation through the QR Code flow.

Each Device has a high-entropy, opaque activation code represented by its physical or on-screen QR Code. While the Device remains `PENDING_ACTIVATION`, the same code:

- has no time-based expiration;
- may be scanned and validated repeatedly;
- never grants Device API access by itself;
- must not expose a sequential or internal Device identifier;
- must be rate-limited and redacted from logs, traces and errors.

The first successful confirmation atomically associates the Device with the authenticated Customer and changes it to `ACTIVE`. Any later activation attempt returns `ALREADY_ACTIVATED` and must not transfer ownership. Credential provisioning for that activation remains a one-time exchange.

For the MVP, a provisioned Device credential has no time-based expiration. It remains scoped to one `deviceId` and valid until explicitly revoked, the Device is made inactive, removed from operation, or its Customer is made inactive. An expired or revoked credential is never accepted. If time-based expiration is introduced later, a renewal contract must let an otherwise eligible activated Device renew safely; offline data remains queued until authentication succeeds.

Deactivation and authorized reactivation preserve history. Reactivation restores the existing Customer association and does not run the QR ownership flow again. Transfer between Customers is outside the MVP and requires a later decision covering credential rotation, history and tenant isolation.

One `DeviceRequest` requests exactly one Device. Submission contains only optional `notes`. Fulfillment associates one eligible Device that is `PENDING_ACTIVATION`, unassigned and not removed. The owning Customer may cancel only its own `PENDING` request; `ADMIN` and `SUPER_ADMIN` may cancel an authorized pending request, always with an auditable reason.

## Consequences

- `CREATED` must be removed from product documentation.
- The activation code is a persistent bootstrap identifier/secret, not a bearer credential.
- Physical possession of an unactivated QR Code is security-relevant; high entropy, rate limiting and authenticated Customer confirmation are mandatory.
- Activation never permits automatic Customer transfer or theft of an already activated Device.
- Device credential revocation must be checked during ingestion.

