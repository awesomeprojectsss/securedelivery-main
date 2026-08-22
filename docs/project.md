# SecureDelivery — Project Context

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

`SmartBox` is a logical domain entity representing a delivery box equipped with a monitoring device.

In the MVP:

```text
SmartBox
    └── Mobile IoT Device
          └── Smartphone mounted horizontally on the box
```

In a future product version:

```text
SmartBox
    └── Dedicated IoT Device
          ├── MCU
          ├── IMU
          ├── GNSS
          ├── Battery
          └── Independent Connectivity
```

The software should not couple the SmartBox domain model to the smartphone implementation. The smartphone is the first device implementation, not the final definition of SmartBox.

---

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
- SmartBoxes
- SmartBox activation
- deliveries
- telemetry
- events
- event evidence
- device health
- support tickets
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
- SmartBox management
- SmartBox activation flows
- SmartBox monitoring
- customer-scoped monitoring
- global operational monitoring for administrators
- event visualization
- external Google Maps links
- support tickets
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

---

## SUPER_ADMIN

A Super Administrator has all Administrator capabilities.

Additional capabilities:

- create Super Administrators
- create Administrators
- create Customers
- change roles of Administrators and Customers
- reset passwords of Administrators and Customers
- activate Administrators and Customers
- deactivate Administrators and Customers

Restrictions:

- cannot reset the password of another Super Administrator
- cannot deactivate another Super Administrator
- cannot deactivate their own user
- privileged actions should be auditable

A Super Administrator must not be able to accidentally lock themselves out through self-deactivation.

---

## ADMIN

Administrators manage customers, administrators, SmartBoxes and support operations.

Capabilities include:

- create Customers
- edit Customers
- activate Customers
- deactivate Customers
- create Administrators
- manage Administrators within allowed RBAC rules
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

---

# SmartBox Lifecycle

The SmartBox is created by an Administrator and later activated by a Customer.

Suggested conceptual lifecycle:

```text
CREATED
    ↓
PENDING_ACTIVATION
    ↓
ACTIVE
    ↓
INACTIVE
```

Historical records should be retained.

A SmartBox may also have a soft-deleted state internally if needed.

---

## SmartBox Activation

The MVP uses QR Code activation.

The QR Code is exposed by the mobile application during the MVP.

Conceptual flow:

```text
Administrator creates SmartBox
            ↓
SmartBox enters PENDING_ACTIVATION
            ↓
Customer scans QR Code
            ↓
Activation token is validated
            ↓
SmartBox is associated with Customer
            ↓
SmartBox becomes ACTIVE
```

The QR Code should not simply expose an internal SmartBox identifier.

Prefer a secure activation token with an explicit lifecycle and expiration strategy.

The exact token design may evolve.

---

# SmartBox Monitoring

Administrators need two operational views.

## Customer View

An Administrator can select a Customer and view all SmartBoxes associated with that Customer.

For each SmartBox, the platform should expose operational information such as:

- latest known location
- connectivity
- battery
- health
- last communication
- status
- recent events

## Global View

Administrators can inspect all SmartBoxes from all Customers to monitor platform-wide device health.

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

The smartphone acts as the IoT device during the MVP.

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

---

# Sensor Collection

Initial MVP sampling interval:

```text
1 sample per second
```

The application should collect the relevant sensor and operational state required for the current algorithms.

Possible sources include:

- accelerometer
- gyroscope
- GPS
- battery
- connectivity

The exact sensor payload may evolve while the team calibrates event detection.

Temperature is outside the MVP.

---

# Edge Event Detection

Event detection is performed on the mobile device.

The backend is not responsible for reconstructing raw sensor streams in order to decide whether an event happened.

Conceptual pipeline:

```text
Sensors
   ↓
Sensor Collector
   ↓
Event Detection Engine
   ↓
Local Persistence
   ↓
Sync Engine
```

Initial event categories may include:

```text
STRONG_IMPACT
CRITICAL_INCLINATION
POSSIBLE_FALL
ABNORMAL_MOVEMENT
```

The exact algorithms and thresholds are intentionally not fixed yet.

They will evolve through real tests.

---

# Event Evidence

Every detected event must preserve the data that caused the event to be detected.

An event should not only say:

```text
POSSIBLE_FALL
```

It should carry enough evidence for future audit and algorithm validation.

Conceptually:

```text
Event
 ├── eventId
 ├── type
 ├── occurredAt
 ├── SmartBox
 ├── delivery
 ├── location
 └── evidence
      ├── accelerometer samples
      ├── gyroscope samples
      ├── calculated values
      └── relevant raw measurements
```

This supports:

- debugging
- auditing
- false-positive analysis
- algorithm calibration
- future model improvement

---

# Telemetry Store-and-Forward

Sensor collection and network transmission happen at different frequencies.

Initial MVP strategy:

```text
Sensor sampling: every 1 second
Telemetry transmission: every 1 minute
```

Conceptually:

```text
1-second samples
      ↓
Local durable storage
      ↓
1-minute telemetry batch
      ↓
Synchronization attempt
      ↓
SecureDelivery Server
```

Critical events may be eligible for earlier synchronization, but local persistence must happen first or as part of a reliable write path.

---

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
telemetryBatchId
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

Administrators can assume a ticket conversation and interact with the Customer in realtime.

The exact chat transport may be implemented through WebSocket.

Persistent message history must not depend on WebSocket delivery.

---

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

The frontend and mobile application technologies are not yet fixed.

Their architecture documents may define boundaries, responsibilities and required capabilities without selecting a framework prematurely.

The team will update those architecture documents when the technology decisions are made.

TypeScript is preferred where supported by the selected frameworks.

---

# Development Standards

The project should use:

- Git
- GitHub
- Pull Requests
- Code Review
- Conventional Commits
- automated tests
- documentation

The branch strategy may use GitFlow or another strategy agreed by the team.

Do not silently introduce a different team workflow.

---

# MVP Scope

The MVP should focus on:

- RBAC
- user management
- customer management
- administrator management
- SmartBox management
- QR-based SmartBox activation
- mobile IoT monitoring
- 1-second sensor collection
- on-device event detection
- local durable telemetry storage
- 1-minute telemetry batching
- store-and-forward
- retry
- idempotent telemetry ingestion
- idempotent event ingestion
- event evidence
- latest location
- battery
- connectivity
- health
- support tickets
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
