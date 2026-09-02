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
- Device credential provisioning
- Device requests
- monitoring-session persistence
- generic telemetry/event ingestion
- tickets
- notifications
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
- Device-request and notification UX

---

## Canonical Terminology

Use `Device` in technical contracts and code shared across repositories.

`SmartBox` is a product-facing UI label only.

Do not create `/smartboxes` API routes.

---

## Workspace Refresh Before Agent Work

When this repository is being used as the SecureDelivery workspace with Git submodules, refresh local Git state before reading documentation, planning cross-repository work, or modifying code.

Preferred commands:

### Linux / macOS / Git Bash

```bash
./scripts/refresh-local-workspace.sh
```

### PowerShell

```powershell
.\scripts\refresh-local-workspace.ps1
```

The refresh process exists so agents work with the latest safely available remote information across:

- the `securedelivery-main` repository;
- `securedelivery-server`;
- `securedelivery-mobile`;
- `securedelivery-dashboard`;
- recursively initialized Git submodules.

The refresh script may:

- fetch remote references;
- prune deleted remote references;
- fetch tags;
- fast-forward local branches when they are strictly behind their matching remote branch;
- initialize and refresh submodules.

The refresh script must **not**:

- push;
- force-push;
- create commits;
- rebase;
- reset with `--hard`;
- create merge commits;
- discard local changes;
- automatically resolve diverged branches.

If a branch:

- contains local commits ahead of the remote;
- has diverged from the remote;
- is checked out in another worktree;
- or cannot be safely fast-forwarded;

preserve it and report the condition instead of modifying history.

If the current working tree contains uncommitted changes, do not perform an automatic fast-forward that could interfere with those changes.

### Agent Rule

Before relying on local `project.md`, contracts, ADRs, or repository documentation for cross-repository decisions:

1. determine whether this checkout is the main SecureDelivery workspace;
2. if the refresh scripts are available, run the appropriate refresh script;
3. inspect any warnings produced by the script;
4. do not assume a diverged or locally-ahead branch matches the latest remote state;
5. only after refresh, read:
   - `docs/project.md`;
   - `docs/contracts/`;
   - shared ADRs;
   - the target repository `AGENTS.md`;
   - the target repository `docs/architecture.md`.

A successful `git fetch` updates remote-tracking references, but local branches may still differ. The refresh script intentionally updates local branches only when the change is a safe fast-forward.

Do not bypass this policy by running destructive Git commands merely to make a branch appear current.

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

## Documentation Languages and Audiences

Use `docs/pt-BR/` as the primary developer and product-documentation entry point for the Brazilian team. Maintain the equivalent English navigation and essential rules under `docs/en/`.

Keep machine-readable contracts unique under `docs/contracts/` and shared ADRs unique under `docs/decisions/`; do not create translated copies that can become competing sources of truth.

Organize explanatory documentation so developers/QA, Project Manager/PO/business readers and prospective customers/partners can each find an explicit entry point. In SecureDelivery, `PM` means Project Manager, not Product Manager. When a contract or product rule changes, update both language guides that explain it.

Keep `docs/terminology.md` beginner-friendly and bilingual. Add an abbreviation or technical term when it appears in project documentation and may not be clear to a new contributor.

## CI/CD Policy

GitHub Actions is the single automation platform unless an ADR changes this decision. The workspace validation entry point is `npm run ci`; keep local and hosted CI behavior aligned.

Prefer one small workflow per repository using the project's ordinary lint, test and build commands. Do not create placeholder checks that imply an uninitialized application was tested.

Do not add deployment automation until the hosting target, environments, secrets, health checks and rollback process are explicit. Future production deployment requires manual approval through a protected environment.

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
