# ADR-013: Access Governance and Audit Retention

## Status

Accepted

## Context

The MVP needs an unambiguous distinction between internal platform operators and Customer-scoped users. It also needs safe account recovery, Customer deactivation and audit retention rules that do not depend on Dashboard behavior.

## Decision

The three MVP roles remain:

```text
SUPER_ADMIN
ADMIN
CUSTOMER
```

`ADMIN` is an internal, platform-wide SecureDelivery operator. It is not a tenant administrator. The MVP does not introduce a `CUSTOMER_ADMIN` role.

Only `SUPER_ADMIN` may create, activate, deactivate, promote, demote or reset the password of a privileged `ADMIN` or `SUPER_ADMIN` account. An `ADMIN` may manage Customers, Customer-scoped `CUSTOMER` users, Devices, DeviceRequests and support operations according to RBAC. User email addresses are globally unique.

The Server must prevent removal, deactivation or demotion of the last active `SUPER_ADMIN`. It must also prevent a privileged user from bypassing the documented self-action restrictions.

An administrative password reset sets a temporary password, revokes all existing sessions for the affected user and sets `mustChangePassword = true`. The user must change that password before accessing normal protected product capabilities. Passwords and reset material are never logged.

When a Customer becomes inactive, the Server performs the following as one auditable administrative operation:

- blocks new authentication for its users;
- revokes their active sessions;
- rejects new telemetry, event and monitoring-session writes from its Devices;
- preserves historical business records;
- prevents Customer users from reading those records while the Customer is inactive;
- keeps pending requests and support tickets visible to authorized `ADMIN` and `SUPER_ADMIN` operators.

Customer reactivation does not silently reactivate users or Devices. Those resources retain their explicit status and require authorized reactivation where applicable.

Security audit records have a default retention period of 18 months from occurrence. After that period they are deleted or irreversibly anonymized unless a documented legal obligation, investigation or legal hold requires longer preservation. Access is restricted to authorized internal operators. The retention period is a product policy and must be reviewed against purpose, necessity and the termination/conservation rules in [LGPD articles 15 and 16](https://www.planalto.gov.br/ccivil_03/_ato2015-2018/2018/lei/l13709compilado.htm); the duration alone does not establish LGPD compliance.

## Consequences

- Product stories must not describe `ADMIN` as restricted to one Customer.
- A future tenant-administrator capability requires a separate role/permission decision.
- Deactivation is enforced by the Server and is not merely a UI state.
- Session revocation and forced password change are required acceptance criteria for administrative password reset.
- Audit cleanup must be automated and preserve documented legal holds.
