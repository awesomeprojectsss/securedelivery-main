# Simple SecureDelivery CI/CD

## What exists now

The main workspace uses GitHub Actions. Developers and GitHub run the same command:

Tooling uses Node.js 24 LTS. With `nvm`, run `nvm use` at the workspace root to select the version declared in `.nvmrc`.

```bash
npm ci
npm run ci
```

CI validates OpenAPI, AsyncAPI, critical contract invariants and local documentation links across repositories present in the workspace. It runs for Pull Requests, pushes to `develop`/`main`, and manual dispatches. Superseded runs on the same branch are cancelled.

The three application repositories call a reusable documentation workflow maintained by `securedelivery-main`. Publish the main-repository workflow to `main` first, then publish the Server, Mobile and Dashboard workflows.

## Beginner routine

You should not need to edit the workflow during normal development:

1. make the change;
2. run `npm ci` when dependencies change;
3. run `npm run ci`;
4. open a Pull Request;
5. wait for **Contracts and documentation** to become green;
6. if it is red, open the job and read the first failing step.

Do not make a check green by deleting validation. Fix the failing contract, document, test or build.

## Maintenance automation

Dependabot checks monthly, groups CI-tool and GitHub Actions updates, and limits open PRs to three per ecosystem. It never auto-merges: a person reviews the change and lets CI verify it.

Direct versions live in `package.json`; `package-lock.json` fixes the entire dependency tree so local and GitHub checks use the same tools.

## Why deployment is not automated yet

Server, Mobile and Dashboard do not contain initialized applications or selected hosting targets. A deployment workflow today would have to invent a provider, environments, credentials and rollback policy.

Until those decisions exist, CI is required, production credentials do not exist in the repository, deployment is not automatic, and production release requires human approval.

## CD model after application bootstrap

Keep only three environments:

```text
local -> staging -> production
```

- Pull Request: lint, tests and build; no deployment.
- Merge to `develop`: automatic staging deployment.
- Release from `main`: production deployment with manual approval.
- Failure: stop; never continue silently.

Expected minimum application checks:

| Project | Minimum CI |
|---|---|
| NestJS Server | `npm ci`, lint, tests and build |
| Next.js Dashboard | `npm ci`, lint, tests and build |
| Flutter Mobile | `flutter pub get`, `flutter analyze` and `flutter test` |

Each repository should have one small workflow calling its official commands. Do not add Jenkins, Kubernetes, Argo CD, multiple pipeline systems or parallel deployment strategies without demonstrated need and an ADR.

## One-time GitHub setup

After publishing these changes, enable GitHub Actions and protect `develop` and `main`. Require **Contracts and documentation** in the workspace and **Repository documentation** in each application repository. Keep workflow permissions read-only and add no secrets until a real staging/production target exists. Production should later use a protected Environment with required approval.

[Bilingual glossary](../terminology.md) · [Development guide](development-guide.md)

Official references: [Node.js releases](https://nodejs.org/en/about/previous-releases) · [GitHub Actions](https://docs.github.com/actions) · [Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference) · [Deployment environments](https://docs.github.com/en/actions/how-tos/deploy/configure-and-manage-deployments/manage-environments)
