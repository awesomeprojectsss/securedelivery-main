# AGENTS.md — SecureDelivery Workspace

## Purpose

This workspace contains three applications:

- `securedelivery-server`
- `securedelivery-mobile`
- `securedelivery-dashboard`

Before cross-repository work, read:

- `docs/project.md`
- `docs/contracts/README.md`
- relevant files under `docs/contracts/`
- relevant shared ADRs under `docs/decisions/`
- the target repository's `AGENTS.md`
- the target repository's `docs/architecture.md`

---

## Repository Ownership

### Server

Owns:

- persistent business state
- RBAC and authorization
- customers/users
- Devices
- activation
- monitoring-session persistence
- generic telemetry/event ingestion
- tickets
- realtime publication
- background server processing

### Mobile

Owns:

- Device-side sensor collection
- high-frequency IMU acquisition
- Device-side event detection
- evidence capture
- local durable persistence
- batching
- store-and-forward
- synchronization

### Dashboard

Owns:

- product-facing SmartBox UI
- management and monitoring UX
- role-specific experiences
- generic/specialized event presentation
- realtime presentation
- support UX

---

## Canonical Terminology

Use `Device` in technical contracts and code shared across repositories.

`SmartBox` is a product-facing UI label only.

Do not create `/smartboxes` API routes.

---

## Shared Contract Policy

`docs/contracts/` is authoritative.

Do not invent cross-repository payloads.

When changing a shared contract:

1. update the canonical contract first;
2. evaluate compatibility;
3. update the server implementation;
4. update/regenerate affected clients;
5. update Mobile and/or Dashboard consumers;
6. update tests;
7. update ADRs/documentation when required.

---

## Extensible IoT Protocol

New sensor measurements use generic observations.

New Device-generated event types use namespaced strings.

The server must not require releases for every new valid sensor key or Device event type.

Do not convert the extensible observation/event namespaces into closed enums.

---

## Lean Telemetry Policy

Do not continuously upload normal raw IMU data.

The MVP separates acquisition from server retention:

```text
IMU raw:                  50 Hz, Device-local
GPS/ground speed:         up to 1 Hz, Device-local
normal Server telemetry:  1-minute summaries
event evidence:           high-frequency around events
```

Normal telemetry summaries should preserve business-value data such as:

- Device state;
- latest location;
- distance traveled;
- moving/stopped duration;
- maximum speed.

Average moving speed is derived from total distance / total moving duration.

Motion events should include reliable speed context when available.

## Sampling Baseline

Initial MVP:

```text
IMU raw sampling:              50 Hz
GPS / ground-speed sampling:   up to 1 Hz
normal server telemetry:       1-minute summaries
network batching:              normally every 1 minute
event evidence:                high-frequency samples around event
```

Do not reintroduce continuous normal server-side raw IMU telemetry without an explicit architecture decision.

Do not reduce IMU sampling back to 1 Hz without test evidence and an explicit architecture decision.

