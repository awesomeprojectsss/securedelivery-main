# ADR-011: Minimal DeviceRequest Resource

## Status

Accepted

Clarified by ADR-014, which fixes one request to one Device and defines Device eligibility for fulfillment.

## Context

The MVP states that a Customer can request a SmartBox, but the technical contract had no resource representing that request.

## Decision

Use `DeviceRequest` as the canonical technical resource and “SmartBox Request” as the product-facing label.

The minimum HTTP behavior is:

- an authenticated Customer submits one request for exactly one Device, with optional `notes` and no quantity, address, contact or structured-purpose fields;
- authorized users list requests visible to them;
- authorized users read one request.
- an `ADMIN` or `SUPER_ADMIN` fulfills a pending request through `POST /device-requests/{requestId}/fulfill` with the associated `deviceId`;
- the owning `CUSTOMER`, an `ADMIN` or a `SUPER_ADMIN` cancels a pending request through `POST /device-requests/{requestId}/cancel` with an auditable reason.

The minimum lifecycle is:

```text
PENDING
  -> FULFILLED
  -> CANCELLED
```

`FULFILLED` means the operational process has supplied and associated an eligible Device with the requesting Customer. The transition records `fulfilledDeviceId` and `fulfilledAt` atomically. `CANCELLED` means the request will not be fulfilled and records `cancellationReason` and `cancelledAt` atomically.

Only `PENDING` requests may transition. Repeating a transition or attempting a different terminal transition returns a conflict and must not overwrite the audit facts. The Server enforces RBAC, tenant ownership, Device eligibility and atomicity. An eligible fulfillment Device is `PENDING_ACTIVATION`, unassigned to a Customer and not removed from active operation.

This workflow does not introduce billing, ecommerce, delivery tracking or inventory management.

## Consequences

- The documented Customer capability has an authoritative HTTP representation.
- Tenant isolation applies to DeviceRequest reads.
- Future operational workflow can expand through a separate contract decision if needed.
- Terminal transitions are explicit, authorized and auditable.
