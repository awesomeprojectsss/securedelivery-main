# SecureDelivery — Project Context

> New audience-oriented documentation: [Português (Brasil)](pt-BR/README.md) · [English](en/README.md). This detailed document remains available as a compatibility reference.

## Overview

SecureDelivery is a delivery-quality monitoring platform focused on establishments that require consistent delivery quality and want to prove, with data, the conditions under which a product was transported until it reached the customer.

The product is not primarily a fleet-tracking solution. Its main goal is to monitor delivery quality and cargo integrity.

The core product question is:

> Can we reliably determine whether something happened during a delivery that may have compromised the cargo, and provide enough evidence to audit that conclusion later?

The MVP uses a smartphone as the primary IoT device. The phone will be physically fixed with tape to a flat horizontal surface on the delivery box during tests, allowing the team to simulate the orientation of a future dedicated IoT device and test angle, acceleration, impact and fall detection in realistic conditions.

The MVP does not include temperature monitoring.

---

## Product Principles

SecureDelivery should prioritize:

1. Delivery-quality evidence over driver surveillance.
2. Cargo integrity over driving-style classification.
3. Reliable telemetry over high-frequency network traffic.
4. Local event detection on the IoT device.
5. Offline-first operation.
6. Store-and-forward synchronization.
7. Idempotent writes.
8. Auditability of detected events.
9. Clear customer isolation.
10. A simple MVP architecture that can evolve without requiring a rewrite.

A courier may perform an unusual maneuver without compromising the cargo. SecureDelivery should care about what happened to the cargo and SmartBox, not about judging the maneuver itself.

---

## SmartBox Concept

`Device` is the canonical technical domain term.

Use `Device` in:

- API routes
- backend modules
- persistence entities
- cross-repository contracts
- logs
- telemetry/event ownership
- identifiers such as `deviceId`

`SmartBox` is the product-facing label displayed to users.

In the MVP:

```text
Product UI: SmartBox
Technical entity: Device
Implementation: Flutter application on a smartphone mounted horizontally on the delivery box
```

Future:

```text
Product UI: SmartBox
Technical entity: Device
Implementation: dedicated IoT hardware
```

The Device contract must remain independent from the current smartphone implementation.

Shared communication contracts are defined under:

```text
docs/contracts/
```

## Main System Areas

SecureDelivery is initially divided into three repositories:

```text
securedelivery-server
securedelivery-mobile
securedelivery-dashboard
```

### SecureDelivery Server

Central backend and source of truth for the platform.

Main responsibilities:

- authentication
- authorization
- RBAC
- users
- customers
- administrators
- Devices
- Device activation
- Device credential provisioning
- Device requests
- deliveries
- telemetry
- events
- event evidence
- speed and distance operational KPIs
- device health
- support tickets
- notifications
- realtime support chat
- realtime dashboard updates
- persistence
- idempotency
- auditability
- background processing

### SecureDelivery Mobile

Acts as the primary IoT device in the MVP.

Main responsibilities:

- collect smartphone sensor data
- collect GPS location
- collect battery state
- collect connectivity state
- perform event detection locally
- persist telemetry locally
- persist events locally
- preserve evidence associated with events
- batch telemetry
- store-and-forward
- retry synchronization
- operate in background while monitoring is enabled

### SecureDelivery Dashboard

Management and monitoring interface for platform users.

Main responsibilities:

- user and RBAC management
- customer management
- administrator management
- Device management presented as SmartBoxes in the UI
- Device activation flows presented as SmartBox activation
- Device request flows presented as SmartBox requests
- Device monitoring presented as SmartBox monitoring
- customer-scoped monitoring
- global operational monitoring for administrators
- event visualization
- external Google Maps links
- support tickets
- notifications
- realtime support chat

---

# RBAC

The MVP has three main roles:

```text
SUPER_ADMIN
ADMIN
CUSTOMER
```

Authorization must be enforced by the backend.

The dashboard may hide or disable actions according to permissions, but frontend behavior must never be considered a security boundary.

Human users authenticate separately from Devices. Human APIs use user bearer credentials and enforce RBAC plus Customer ownership. Monitoring synchronization and Device ingestion use a Device bearer credential scoped to exactly one `deviceId`.

---

## SUPER_ADMIN

A Super Administrator has all Administrator capabilities.

Additional capabilities:

- create Super Administrators
- create Administrators
- create Customers
- create and manage Customer-scoped users
- change roles of authorized users
- reset passwords of authorized users
- activate authorized users and Customers
- deactivate authorized users and Customers

Restrictions:

- cannot deactivate or demote their own user;
- cannot deactivate, remove or demote the last active Super Administrator;
- privileged actions must be auditable.

A Super Administrator must not be able to accidentally lock themselves out through self-deactivation.

---

## ADMIN

Administrators are internal, platform-wide SecureDelivery operators. They manage Customers, Customer-scoped users, SmartBoxes and support operations. They are not administrators restricted to one Customer, and the MVP does not define a `CUSTOMER_ADMIN` role.

Capabilities include:

- create Customers
- edit Customers
- activate Customers
- deactivate Customers
- create and manage `CUSTOMER` users
- create SmartBoxes
- edit SmartBoxes
- deactivate SmartBoxes
- remove SmartBoxes from active operation
- associate SmartBoxes with Customers through the activation flow
- inspect SmartBoxes by Customer
- inspect all SmartBoxes globally
- view last known GPS location
- view connectivity
- view battery
- view device health
- view last communication time
- inspect delivery events
- provide customer support
- view support tickets
- assume ticket ownership
- participate in realtime ticket conversations
- close or resolve tickets

SmartBox removal should preserve historical traceability. The initial architectural recommendation is soft deletion rather than destructive deletion.

Only a Super Administrator may create or manage privileged `ADMIN` and `SUPER_ADMIN` accounts. User email addresses are globally unique.

An administrative password reset assigns a temporary password, revokes every existing session for the affected user and requires a password change before normal protected capabilities become available. Passwords and reset material must never be logged.

Customer deactivation blocks new authentication, revokes existing sessions and causes the Server to reject new monitoring, telemetry and event writes from that Customer's Devices. Historical records remain stored but are not visible to Customer users while the Customer is inactive. Authorized Administrators retain access to pending requests and support tickets. Reactivating the Customer does not silently reactivate its individual users or Devices.

Security audit records are retained for 18 months by default and are then deleted or irreversibly anonymized unless a documented legal obligation, investigation or legal hold applies. Access is restricted to authorized internal operators. This policy must be periodically reviewed against the LGPD principles of purpose, necessity and retention; a fixed duration alone does not guarantee compliance.

---

## CUSTOMER

Customers can access only their own data.

Capabilities include:

- view their SmartBoxes
- request a SmartBox
- activate a SmartBox
- validate a SmartBox through QR Code activation
- monitor SmartBox health
- monitor battery
- monitor connectivity
- view latest known location
- open the latest location in Google Maps through an external link
- inspect events associated with deliveries
- open support tickets
- participate in realtime support chat

Tenant isolation must be guaranteed by the backend.

A Customer must never be able to access SmartBoxes, deliveries, events, tickets or users belonging to another Customer.

SmartBox requests are represented technically as tenant-scoped `DeviceRequest` resources. One request represents exactly one Device and contains only optional free-form `notes` in the MVP. A pending request is explicitly fulfilled by an authorized Administrator with an eligible `deviceId`, or cancelled by an authorized actor with a reason. An eligible Device is `PENDING_ACTIVATION`, unassigned and not removed. Terminal transitions are immutable and auditable; the MVP does not attach quantity, structured address/contact/purpose, billing, ecommerce, inventory or shipment tracking to this resource.

---

# Device Lifecycle

The Device is created by an Administrator and later activated by a Customer. The Dashboard presents the Device as a SmartBox.

Canonical MVP lifecycle:

```text
PENDING_ACTIVATION
    ↓
ACTIVE
    ↓
INACTIVE
```

Historical records should be retained.

A Device may also have a soft-deleted state internally if needed.

---

## Device Activation

The MVP uses QR Code activation.

The QR Code is exposed by the mobile application during the MVP.

Conceptual flow:

```text
Administrator creates Device
            ↓
Device enters PENDING_ACTIVATION
            ↓
Customer scans QR Code
            ↓
Activation token is validated
            ↓
Device is associated with Customer
            ↓
Device becomes ACTIVE
```

The QR Code must not expose a sequential or internal Device identifier. It carries a high-entropy opaque activation code associated with the physical Device.

While the Device remains `PENDING_ACTIVATION`, the activation code has no time-based expiration and may be scanned or validated repeatedly. It is not a bearer credential and never grants Device API access by itself. The first authenticated Customer confirmation atomically associates the Device and changes it to `ACTIVE`; later attempts return `ALREADY_ACTIVATED` and never transfer ownership. Validation and confirmation must be rate-limited.

Activation material is accepted only in JSON request bodies. It must not appear in URL paths or query strings. A web QR link may place it in the URL fragment so the client can capture it locally, remove it from browser history and submit it in the request body. Every layer must redact it from logs, traces and errors.

The exact token design may evolve.

After an authenticated Customer confirms activation, the Device exchanges its activation material once for a Device credential. The credential represents only that Device, is separate from human authentication, and must be stored by the Flutter app using secure operating-system storage. In the MVP it has no time-based expiration and remains valid until explicitly revoked, the Device becomes inactive/removed, or its Customer becomes inactive. Expired or revoked credentials are never accepted; pending offline data remains queued until authentication becomes valid again. The exact credential format, signing/rotation mechanism and storage package remain implementation details.

Deactivation and authorized reactivation preserve history and the existing Customer association. Reactivation does not repeat the QR ownership flow. Transfer between Customers is outside the MVP.

---

# Device Monitoring

Administrators need two operational views.

## Customer View

An Administrator can select a Customer and view all Devices associated with that Customer (displayed as SmartBoxes).

For each Device, the platform should expose operational information such as:

- latest known location
- connectivity
- battery
- health
- last communication
- status
- recent events

## Global View

Administrators can inspect all Devices from all Customers to monitor platform-wide device health.

This view is intended for support and operations.

---

# Location

The MVP does not implement full route tracking.

Location is collected primarily to answer:

> Where was the SmartBox when a relevant event occurred?

and:

> What is the latest known location of the SmartBox?

The dashboard can expose an external Google Maps link using the last recorded latitude and longitude.

The MVP does not require route reconstruction or a full Google Maps Platform integration.

Future versions may introduce route visualization, origin and destination tracking, event markers along routes and other logistics capabilities.

---

# Mobile IoT Monitoring

The smartphone acts as the IoT device during the MVP. The supported baseline is Android 10 (API level 29) or later; iOS is outside the initial MVP unless a later decision adds it.

The test phone will be mounted horizontally on a flat surface of the SmartBox.

This provides a known physical orientation that can be used to test:

- acceleration
- angle changes
- inclination
- strong impacts
- falls
- abnormal movements
- possible cargo compromise

The implementation should remain device-oriented so a dedicated IoT device can replace the smartphone later.

---

## Monitoring Control

The mobile application must allow monitoring to be explicitly enabled or disabled.

Conceptually:

```text
MONITORING_OFF
MONITORING_ON
```

When monitoring is disabled:

- continuous sensor monitoring should stop
- background monitoring should stop where possible
- energy consumption should be minimized

When monitoring is enabled:

- required sensors are sampled
- event detection runs
- telemetry is persisted locally
- synchronization runs according to policy
- critical events are persisted immediately

Monitoring requires background-operation permission. If permission or the required operating-system exemption is missing, Mobile must explain the need and provide a direct action to the appropriate Android settings screen.

Monitoring must not start, and an active session must stop safely, when the battery is below 15% and the Device is not charging, when Android reports a thermal status of `SEVERE` or worse, or when the Device reaches 12 accumulated monitoring hours in a rolling 24-hour period. Android thermal status, rather than a fixed raw value such as 90 °C, is the canonical safety signal.

Before acquisition starts, the Device generates and durably stores the canonical `monitoringSessionId`. The same UUID is used for session creation, telemetry, events, stop synchronization and every retry. The Server does not assign a competing identifier.

Monitoring may start and stop without connectivity. On reconnect, the Device idempotently creates/reconciles the session, uploads dependent telemetry/events, and sends the Device-observed `finishedAt`. Server receipt time must not replace the actual stop time.

---

# Sensor Collection

Sensor acquisition, normal telemetry and network transmission have intentionally different rates.

Initial MVP profile:

```text
Raw IMU sampling target:         50 Hz (~20 ms)
Event detection:                 high-frequency local processing
GPS / ground-speed observation:  up to 1 Hz
Normal server telemetry:         1-minute summary
Network batch:                   normally every 1 minute
```

Raw IMU data is primarily Device-local.

The Server does not normally receive continuous accelerometer/gyroscope history when no relevant event is detected.

The Device keeps a rolling high-frequency buffer so abnormal events can preserve precise evidence.

Temperature remains outside the MVP.

# Edge Event Detection

Event detection is performed on the Device.

The backend is not responsible for re-running Device detection algorithms from the normal telemetry stream.

Conceptual pipeline:

```text
High-frequency sensors
   ↓
Sensor Collector
   ↓
Event Detection Engine
   ↓
Event + Evidence
   ↓
Local Durable Persistence
   ↓
Sync Engine
```

Initial Device-generated event types use namespaced strings:

```text
motion.strong_impact
motion.critical_inclination
motion.possible_fall
motion.abnormal_movement
```

Event types are intentionally extensible.

New event detectors should normally be deployable on the Device without requiring a backend contract change.

The exact algorithms, thresholds, calibration procedure and acceptable false-positive/false-negative targets remain undecided. Production thresholds must not be invented without real-Device testing and a dedicated architecture decision.

# Event Evidence

Every detected event must preserve enough data to explain why it was detected.

Conceptually:

```text
Event
 ├── eventId
 ├── eventType
 ├── severity
 ├── occurredAt
 ├── deviceId
 ├── monitoringSessionId
 ├── location
 ├── detector name/version
 ├── attributes[]
 └── evidence
      └── high-frequency observations[]
```

Fixed MVP evidence window:

```text
2 seconds before trigger
+
trigger/event interval
+
2 seconds after trigger
```

At a 50 Hz IMU baseline, this preserves motion detail at roughly 20 ms intervals.

Changing this window after the MVP requires an explicit configuration/architecture decision.

Evidence supports:

- debugging
- auditing
- false-positive analysis
- algorithm calibration
- detector-version comparison
- future model improvement

# Telemetry Store-and-Forward

Normal telemetry is intentionally compact.

Conceptual flow:

```text
IMU 50 Hz                         GPS/speed up to 1 Hz
   │                                      │
   └──────────── Device processing ───────┘
                     │
           event detection + rolling buffer
                     │
            1-minute operational summary
                     │
              durable local storage
                     │
                batch / retry
                     │
              SecureDelivery Server
```

The normal one-minute summary contains operationally useful information such as:

- latest valid location;
- battery;
- connectivity;
- monitoring status;
- distance traveled in the period;
- moving duration;
- stopped duration;
- maximum speed.

The Server derives average moving speed from total distance and total moving duration.

High-frequency motion data is synchronized primarily as evidence when an event is detected.

Offline period summaries remain stored locally and are sent later through the same idempotent batch contract. Mobile sends pending periods in batches, while the Server acknowledges each period independently. Valid sibling periods may be accepted when another period is rejected. A partial rejection remains locally diagnosable/retryable and raises `device.sync_partial_failure` for later synchronization.

The baseline retry interval is one minute. Mobile must honor an explicit server `Retry-After` instruction and must not start concurrent duplicate sends. Exponential backoff is not required in the initial MVP.

Mobile manages at most 50 MiB of durable monitoring payloads. Before rejecting a new write, it removes Server-acknowledged data and then the oldest normal telemetry. Unsynchronized events and evidence have higher retention priority. If no safe cleanup is possible, Mobile must not claim the new data was stored; it records a minimal diagnostic when feasible and raises `device.storage_low` for later synchronization.

# MVP Navigation and Speed Telemetry

Speed is an official MVP telemetry capability.

Preferred source:

```text
GNSS / operating-system ground speed
```

The Device observes GPS/speed at up to 1 Hz but normally sends only one-minute aggregates to the Server.

Canonical structured normal telemetry fields:

```text
navigation.distanceTraveledMeters          [m]
navigation.movingDurationSeconds           [s]
navigation.stoppedDurationSeconds          [s]
navigation.maximumSpeedMetersPerSecond     [m/s]
```

All four keys are required KPI inputs in telemetry schema version 4. Available values are nonnegative; unavailable values are `null`, never a fabricated zero. `navigation.status` (`VALID`, `PARTIAL`, `UNAVAILABLE`) and `navigation.source` (`GNSS`, `GPS_DERIVED`, `UNAVAILABLE`) make completeness explicit. Version 4 also gives every period a stable `periodId` for per-item acknowledgement. Generic `observations[]` remains available for future extensible business-value measurements and does not carry duplicate copies of these four fields.

The Server derives:

```text
average moving speed =
total distance traveled / total moving duration
```

This supports KPIs such as:

- average moving speed;
- maximum speed;
- distance traveled;
- moving/stopped time;
- events per 100 km;
- event rate by speed range.

For detected motion events, the Device should attach reliable speed context when available:

```text
navigation.speed.at_event
navigation.speed.average_5s_before
navigation.speed.maximum_10s_before
navigation.moving
```

Speed correlation must not be presented as proven causality without additional evidence.

Initial movement/stopped threshold:

```text
1.5 m/s (~5.4 km/h)
```

The threshold is configurable and subject to calibration.

Full route tracking remains outside the MVP.

# Offline-First Requirements

Mobile connectivity is considered unreliable by design.

The system must tolerate:

- no internet
- temporary disconnections
- backend unavailability
- timeouts
- duplicated transmissions
- delayed transmissions
- out-of-order arrival
- batch retransmission

The mobile application must use store-and-forward.

Data generated while offline must retain the correct original timestamps.

---

# Idempotency

Telemetry and event delivery must be idempotent.

The mobile application must generate stable unique identifiers before transmission.

Examples:

```text
batchId
periodId
eventId
```

If the same payload is transmitted multiple times because an acknowledgement was lost, the backend must persist the logical record only once.

Idempotency must not depend only on application code.

Important uniqueness guarantees should also be enforced with database constraints where practical.

---

# Timestamps

Client timestamps and server ingestion timestamps represent different facts and should not be conflated.

The system should preserve:

- when data was generated on the device
- when an event occurred
- when the server received the data

Use UTC for backend persistence unless an explicit future decision changes this.

---

# Support Tickets

Customers can request support through the dashboard.

A support ticket should support:

- creation
- status
- conversation history
- assignment
- Administrator ownership
- realtime messages
- resolution/closure

Ticket message history is paginated and queryable through HTTP. `ticket.message.created` is only a realtime signal; after reconnect, the Dashboard reloads authoritative history. Resolve and close are distinct explicit HTTP actions.

Administrators can assume a ticket conversation and interact with the Customer in realtime.

The exact chat transport may be implemented through WebSocket.

Persistent message history must not depend on WebSocket delivery.

---

# Notifications

Notifications are persisted server-side and remain queryable through HTTP. `notification.created` is a realtime signal only. Missing the signal must not lose the Notification, and read state is changed through the HTTP API.

Notification delivery follows human RBAC and tenant isolation. A Customer must never receive another Customer's notification.

---

# Shared Repository Contracts

Cross-repository communication is defined under:

```text
docs/contracts/
```

The canonical contracts include:

- `openapi.yaml` for HTTP
- `asyncapi.yaml` for realtime events
- `common.md` for shared conventions
- `telemetry.md` for the extensible telemetry protocol
- `events.md` for the extensible Device event protocol
- `versioning.md` for compatibility rules

Core rules:

1. `Device` is the canonical technical term.
2. `SmartBox` is a product-facing UI label.
3. Sensor and derived telemetry measurements use generic namespaced observations.
4. Device-generated `eventType` values are open namespaced strings.
5. Unknown valid observation keys and event types must remain ingestible.
6. Clients must not invent payloads independently from the canonical contract.
7. Breaking contract changes must be explicitly versioned and coordinated.

Shared cross-repository architectural decisions are stored under:

```text
docs/decisions/
```

# Backend Technology Baseline

The backend MVP uses:

- NestJS
- TypeScript
- PostgreSQL
- Redis
- BullMQ
- WebSocket
- Docker
- Docker Compose

Redis and BullMQ are intentionally retained in the MVP.

They should support asynchronous processing and help the architecture evolve toward larger scale without forcing premature microservices.

The MVP backend should still begin as a modular monolith.

Redis is not the source of truth.

PostgreSQL remains the primary persistent database.

BullMQ should be used when asynchronous work provides a clear benefit, such as:

- event processing
- alert processing
- support notifications
- background synchronization-related tasks
- KPI recalculation
- operational jobs
- retryable server-side work

Do not route every operation through a queue without reason.

---

# Dashboard and Mobile Technologies

The technology baseline is now defined for both client applications.

## SecureDelivery Dashboard

The web dashboard uses:

- Next.js
- TypeScript

The exact frontend architecture may still evolve through explicit architectural decisions, including topics such as:

- routing conventions
- rendering strategy
- state management
- data-fetching strategy
- WebSocket client strategy
- component library / design system
- authentication token handling
- testing strategy
- deployment strategy

Do not replace Next.js with another frontend framework without an explicit architectural decision.

## SecureDelivery Mobile

The mobile IoT application uses:

- Flutter
- Dart

The exact mobile architecture may still evolve through explicit architectural decisions, including topics such as:

- target mobile platforms
- state management
- local durable persistence
- background execution
- sensor plugins
- GPS/location integration
- secure storage
- transport protocol
- retry strategy implementation
- QR/deep-link implementation
- testing strategy

Do not replace Flutter with another mobile framework without an explicit architectural decision.

---

# Development Standards

The project should use:

- Git
- GitHub
- Pull Requests
- Code Review
- Conventional Commits
- automated tests
- simple GitHub Actions CI
- documentation

The branch strategy may use GitFlow or another strategy agreed by the team.

Do not silently introduce a different team workflow.

Product delivery uses a hybrid process inspired by Scrum with continuous Kanban flow in Trello. It has no Daily Scrum or mandatory daily status report. The main integrated review/refinement/replenishment meeting happens approximately every two weeks, while help, blockers and decisions are coordinated asynchronously through messages and recorded on the relevant card or canonical document. The operational policy is defined in `docs/pt-BR/guia-backlog-trello.md`.

The workspace exposes `npm run ci` as the single contract/documentation validation command. Application pipelines are added after each application is initialized. Deployment automation remains intentionally absent until a hosting target, staging/production environments, health checks, secrets and rollback procedure are explicitly decided. Production deployment always requires human approval.

---

# Repository Development Documentation

Each SecureDelivery repository must maintain four complementary documentation layers:

- `AGENTS.md`: operational instructions for AI coding agents.
- `docs/architecture.md`: current architecture, boundaries and technical decisions of that repository.
- `docs/development-guide.pt-BR.md`: practical engineering guidance for human developers.
- `docs/git-workflow.pt-BR.md`: Git, GitHub, branching, Pull Request, review and release workflow for human developers.

The workspace provides audience-oriented human documentation in Brazilian Portuguese and English, plus one bilingual beginner glossary at `docs/terminology.md`. Repository-specific practical guides may remain in Brazilian Portuguese while the team is primarily Brazilian.

AI-agent operational documentation remains in English for consistency with the engineering toolchain.

The development guides must prefer idiomatic, framework-native solutions and official conventions over unnecessary custom abstractions.

The Git workflow uses `develop` as the integration branch and `main` as the stable/release branch. All implementation work must occur on isolated branches and reach `develop` through Pull Requests and Code Review before promotion to `main`.

# MVP Scope

The MVP should focus on:

- RBAC
- user management
- customer management
- administrator management
- Device management (displayed as SmartBox in the UI)
- QR-based Device activation (displayed as SmartBox activation)
- Device requests (displayed as SmartBox requests)
- mobile IoT monitoring
- 50 Hz raw IMU sampling with configurable rates
- on-Device event detection
- 1-minute compact telemetry summaries with local durable store-and-forward
- 1-minute normal telemetry summaries/batching
- store-and-forward
- retry
- idempotent telemetry ingestion
- idempotent event ingestion
- event evidence
- speed and distance operational KPIs
- latest location
- battery
- connectivity
- health
- support tickets
- notifications
- realtime support chat
- monitoring dashboard
- event visualization
- external Google Maps location links

---

# Explicitly Outside the MVP

Unless a future decision changes scope, the MVP does not include:

- temperature monitoring
- DS18B20
- ESP32 as the primary device
- dedicated GNSS hardware
- Iridium
- satellite communication
- full route tracking
- route reconstruction
- Google Maps Platform route integration
- iFood integration
- Rappi integration
- ERP integration
- machine learning
- advanced driver scoring
- Kubernetes
- microservices
- dedicated hardware production
- large-scale logistics operations

---

# Future Evolution

Potential future areas include:

- dedicated SmartBox IoT hardware
- independent cellular connectivity
- satellite connectivity
- Iridium
- Google Maps route visualization
- route event markers
- external delivery-platform integrations
- logistics integrations
- multi-unit enterprise operations
- device fleet operations
- large-scale infrastructure
- Kubernetes where justified
- commercial plans
- hardware manufacturing
- logistics and reverse logistics
- device provisioning standards
- calibration processes
- operational support standards

These are future possibilities, not MVP requirements.
