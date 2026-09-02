# ADR-012: Simple CI/CD Baseline

## Status

Accepted

## Context

SecureDelivery needs reliable automation that can be operated by a small team with little CI/CD experience. The repositories are currently documentation-first and do not yet contain initialized Server, Mobile or Dashboard applications or selected deployment providers.

Introducing provider-specific deployment, several pipeline products or complex infrastructure now would increase maintenance without validating application behavior.

## Decision

Use GitHub Actions as the single CI/CD automation platform while the source repositories are hosted on GitHub.

The workspace exposes one local/CI command:

```text
npm run ci
```

Workspace tooling and hosted CI use Node.js 24 LTS, declared in `.nvmrc`, `package.json` and the GitHub Actions workflow.

Direct validation dependencies are pinned in `package.json`, the complete dependency graph is committed in `package-lock.json`, and monthly grouped Dependabot PRs propose maintenance updates without auto-merge.

The initial CI validates canonical contracts, contract invariants and documentation. Application-specific CI is added only after each application is initialized, using its ordinary lint, test and build commands.

No deployment pipeline is created before a real hosting target, environment ownership, secrets, health check and rollback procedure are decided. The intended future flow is automatic staging delivery from `develop` and manually approved production deployment from `main`.

Workflow permissions default to read-only. Production credentials must use protected GitHub Environments and must never be committed.

## Consequences

- Developers can reproduce CI with one command.
- The team maintains one automation platform and a small number of workflow files.
- Dependency updates are visible, grouped and reviewable.
- CI provides real checks now instead of placeholder application tests.
- Production cannot be deployed accidentally before deployment architecture is defined.
- A future hosting decision requires a follow-up ADR and implementation of staging, production, health checks and rollback.
