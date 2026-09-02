# Trello backlog guide for the PO and Project Manager

The Brazilian Portuguese [PO and Project Manager Trello guide](../pt-BR/guia-backlog-trello.md) is the primary operational version. This page preserves the essential rules in English.

In SecureDelivery, `PM` means **Project Manager**, not Product Manager. The PO is accountable for product value, the Product Goal, Product Backlog ordering and outcome inspection. The PM coordinates project planning, delivery follow-up, dependencies, risks, communication and stakeholder alignment. They collaborate, but neither role replaces the other.

## Operating model

Use one Product Backlog, not independent Server, Mobile and Dashboard backlogs. Customer value usually crosses contracts and repositories. Create linked technical cards only when components can move independently:

```text
Product story
  ├── CONTRACT
  ├── SERVER
  ├── MOBILE
  └── DASHBOARD
```

The product story is Done only when the required end-to-end behavior works.

Create a separate component card when it has a different owner or PR, can start/finish independently, needs its own estimate/evidence, or explicitly blocks another component. Use a checklist for small work completed in the same PR. Every component card links to its product story; every story lists its required component cards.

SecureDelivery does not practice formal Scrum because it has no Daily Scrum or complete set of prescribed Scrum events. Describe it as a **hybrid process inspired by Scrum, with Kanban flow**. It retains a product goal, ordered backlog, clear PO accountability, outcome inspection and retrospective learning. Trello visualizes continuous flow, pulled work and WIP limits.

There is no required daily meeting or daily written status report.

## Recommended lists

1. `00 — Goals and templates`
2. `01 — Inbox`
3. `02 — Discovery`
4. `03 — Refinement`
5. `04 — Ready / Product Backlog`
6. `05 — Selected for the cycle`
7. `06 — In progress — WIP 3`
8. `07 — Review and QA — WIP 3`
9. `08 — Product validation — WIP 2`
10. `09 — Done this cycle`

For a solo Developer use WIP 1. Keep blocked work in its real stage with a red `BLOCKED` label, a cause and a next action.

## Card rules

- Stories describe actor, capability and outcome.
- Acceptance criteria are observable and cover relevant failure cases.
- PO orders and makes the Product Backlog transparent, clarifies value and inspects outcomes; the Project Manager follows delivery, dependencies and risks; Developers own solution, task split and estimates.
- Shared work follows Contract → Server → clients → Mobile/Dashboard → integrated acceptance.
- Use linked component cards and Pull Requests as evidence.
- Never include production secrets, tokens or Customer data in Trello.

## Ready and Done

Ready means value, scope, testable acceptance criteria, dependencies, affected components and relevant security/offline implications are understood and the item is small enough to advance meaningfully within one cycle.

Done means acceptance criteria, contracts, implementation, review, tests, CI, integration, RBAC/tenant isolation, relevant offline behavior and documentation are complete. Product validation inspects the outcome but does not replace the Definition of Done or make quality depend on unilateral PO approval. A completed component does not make an incomplete product flow Done.

## Cadence and asynchronous communication

There is no Daily Scrum. Hold one integrated meeting roughly every two weeks for delivery review, flow/blockers, a short retrospective, top-of-backlog refinement, and replenishment/goal setting for the next cycle. Work continues to flow between meetings.

Send messages when a card changes stage, help or a decision is needed, a blocker/risk appears, a PR is ready, or completed work unblocks someone. Link the Trello card, keep durable context in its comments and record meeting decisions in Trello or project documentation. Do not introduce a mandatory daily written check-in.

Keep a fixed `[RULE] Communication, help and meetings` card documenting the roughly biweekly cadence, channels, when to request help, team-agreed response expectations and the rule that decisions made in calls/messages are summarized in Trello or canonical documentation.

Track cycle-goal success, throughput, cycle time, WIP age and reopen rate. Never use points or card counts to judge individuals.

## Minimal automation

After the manual flow is stable, automate start-date capture, blocked-work prompts, completion marking and reminders for the roughly biweekly review. Never automate prioritization, product validation or security decisions.

## Initial SecureDelivery themes

1. development foundation, contracts and CI;
2. human authentication, RBAC and Customer isolation;
3. Device lifecycle, activation and credentials;
4. DeviceRequest;
5. MonitoringSession lifecycle;
6. Mobile acquisition and local persistence;
7. lean telemetry and offline synchronization;
8. event detection and evidence;
9. Dashboard monitoring and events;
10. tickets, support chat and notifications;
11. security, observability, integration tests and release readiness.

[Official Scrum Guide](https://scrumguides.org/scrum-guide.html) · [Official Trello documentation](https://support.atlassian.com/trello/docs/using-trello) · [Bilingual terminology](../terminology.md)
