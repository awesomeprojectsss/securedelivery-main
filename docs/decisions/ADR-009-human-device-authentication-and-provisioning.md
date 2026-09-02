# ADR-009: Separate Human and Device Authentication

## Status

Accepted

## Context

SecureDelivery has human users governed by RBAC and independently operating Devices that upload monitoring data. Treating both as one authentication context would blur authorization boundaries and make Device credential provisioning ambiguous.

## Decision

Use separate bearer-token authentication contexts:

- `UserBearerAuth` authenticates `SUPER_ADMIN`, `ADMIN` and `CUSTOMER` users;
- `DeviceBearerAuth` authenticates one specific Device for monitoring synchronization and ingestion.

Human authorization is enforced by the Server using RBAC and Customer ownership. Device authorization is scoped to the Device represented by the credential; a Device credential cannot upload data for a different `deviceId`.

Device credential provisioning uses the existing activation lifecycle:

1. the Device receives short-lived activation material and displays it as a QR Code;
2. an authenticated Customer validates and confirms the activation;
3. after confirmation, the Device exchanges the activation material once for its Device credential;
4. the Device stores that credential using secure operating-system storage;
5. subsequent monitoring and ingestion calls use `DeviceBearerAuth`.

Activation material is accepted only in JSON request bodies:

- `POST /device-activations/validate`;
- `POST /device-activations/confirm`;
- `POST /device-credentials/exchange`.

It must not appear in URL paths or query strings, where proxies, browser history, analytics and access logs may retain it. A web activation QR may encode the bootstrap secret in the URL fragment (`#...`); the client reads the fragment locally and sends the value in the JSON body. Clients must remove the fragment from visible browser history after capture and all layers must redact the secret from logs, traces and errors.

Activation material is a bootstrap secret, is not a normal user credential, expires, and cannot be used to access another Device. The exact token format, signing mechanism, credential rotation and secure-storage package remain implementation decisions.

Human refresh tokens are explicit request values in the HTTP contract. Clients must store access and refresh material securely; the contract does not require one framework-specific storage mechanism.

WebSocket connections use human authentication and server-side authorization. A Customer is subscribed only to authorized tenant resources. Realtime delivery never bypasses RBAC or tenant isolation.

## Consequences

- Human and Device privileges cannot be confused accidentally.
- Activation has a defined path to authenticated Device API access.
- Device credentials remain scoped and revocable independently from user sessions.
- Activation secrets avoid common URL logging and history surfaces.
- Dashboard visibility remains user experience behavior, not an authorization boundary.
