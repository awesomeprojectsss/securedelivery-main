# SecureDelivery documentation

SecureDelivery monitors delivery quality and provides evidence about conditions that may compromise cargo. In the MVP, a smartphone fixed horizontally to the delivery box acts as the technical `Device`; the product UI presents it as a **SmartBox**.

## Choose by goal

| Audience | Start here | What it covers |
|---|---|---|
| Project Manager, PO and business | [Product and MVP](product-and-mvp.md) | problem, value, scope, actors and boundaries |
| PO and Project Manager organizing delivery | [Trello backlog guide](trello-backlog-guide.md) | distinct responsibilities, hybrid process, Kanban flow, asynchronous communication, Ready and Done |
| Engineering and QA | [Development guide](development-guide.md) | architecture, workflow, invariants and checklist |
| Technical beginners | [Bilingual glossary](../terminology.md) | abbreviations and terms explained without assumed experience |
| CI/CD and automation | [Simple CI/CD guide](ci-cd.md) | one command, checks, maintenance and future deployment |
| Integration and architecture | [Contract guide](contract-guide.md) | OpenAPI, AsyncAPI, versions and critical rules |
| Prospective customers and partners | [Product and MVP](product-and-mvp.md#for-customers-and-partners) | benefits, operation and current MVP limits |

## Quick rules

- `Device` is the technical term; **SmartBox** is the product label.
- Server is authoritative for state, authorization and Customer isolation.
- Mobile detects events locally and works offline-first.
- Dashboard presents authorized data and is never a security boundary.
- Normal telemetry uses one-minute summaries; 50 Hz raw IMU remains on the Device except for event evidence.
- New observations and event types use extensible names, not closed enums.

[Documentação em português](../pt-BR/README.md)
