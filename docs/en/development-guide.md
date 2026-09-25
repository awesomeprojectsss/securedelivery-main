# Development guide

## Workspace map

| Repository | Primary responsibility |
|---|---|
| `securedelivery-server` | persistent state, authentication, RBAC, ingestion, tickets, notifications and realtime |
| `securedelivery-mobile` | sensors, local detection, evidence, offline persistence, batching and synchronization |
| `securedelivery-dashboard` | management, monitoring, events, requests, notifications and support |

Before cross-repository work, refresh the workspace with the command for your environment:

```bash
# Linux, macOS or Git Bash
./scripts/refresh-local-workspace.sh
```

```powershell
# Windows PowerShell 5.1 or PowerShell 7
.\scripts\refresh-local-workspace.ps1
```

Then read the root and target `AGENTS.md`, target architecture, relevant contracts and ADRs. Preserve and investigate warnings about diverged branches, local changes or network failures; the script does not discard history to resolve them.

## Shared-change order

1. Update the canonical [`docs/contracts`](../contracts/README.md) contract first.
2. Classify compatibility and version the change.
3. Update Server.
4. Update or regenerate typed clients.
5. Update affected Mobile and Dashboard consumers.
6. Test rules and failure cases.
7. Update ADRs and both languages when the public explanation changes.

Never invent a local payload that contradicts OpenAPI or AsyncAPI.

## Required invariants

- Human APIs use `UserBearerAuth`; Device ingestion uses `DeviceBearerAuth` scoped to one `deviceId`.
- Server enforces RBAC and Customer isolation for HTTP and WebSocket.
- Activation secrets appear only in JSON bodies, never in a path, query, log, trace or error.
- The QR code does not expire while `PENDING_ACTIVATION`, but it is not a credential; after first activation, later attempts return `ALREADY_ACTIVATED`.
- Normal acquisition remains 50 Hz IMU and up-to-1 Hz GPS locally, with one-minute Server summaries.
- Telemetry follows schema version 4; every period has a stable `periodId`, acknowledgement is per period, unavailable navigation metrics are `null`, not zero, and only reliable numbers enter KPIs.
- Device-created `monitoringSessionId`, `batchId`, `periodId` and `eventId` values make offline synchronization idempotent.
- Observation keys and Device event types remain extensible.
- Only `PENDING` DeviceRequests transition; fulfillment and cancellation are explicit, authorized, atomic and auditable.

## Delivery checklist

- contract validators pass;
- examples use current envelope versions;
- secrets do not appear in URLs;
- invalid transitions do not overwrite audit facts;
- offline retries remain idempotent;
- cross-Customer access fails;
- unknown events render through a safe Dashboard fallback;
- pt-BR and English documentation agree on essential rules.

[Bilingual glossary](../terminology.md) · [Simple CI/CD](ci-cd.md) · [Contract guide](contract-guide.md) · [Shared ADRs](../decisions/README.md)
