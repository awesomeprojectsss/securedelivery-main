# ADR-010: Structured MVP Navigation Summary with Extensible Observations

## Status

Accepted

## Context

The four MVP navigation values are required for platform KPIs. Encoding them only as generic observations permits missing values, inconsistent units and invalid negative measurements.

At the same time, the Observation envelope must remain open so future valid measurements do not require a server release.

## Decision

Every normal telemetry period contains a structured `navigation` summary with:

- `status`: `VALID`, `PARTIAL` or `UNAVAILABLE`;
- `source`: `GNSS`, `GPS_DERIVED` or `UNAVAILABLE`;

- `distanceTraveledMeters`;
- `movingDurationSeconds`;
- `stoppedDurationSeconds`;
- `maximumSpeedMetersPerSecond`.

Values use canonical SI units and are nonnegative when available. All metric keys remain present, but unavailable values are `null`, never a fabricated zero.

The invariants are:

- `VALID`: source is `GNSS` or `GPS_DERIVED`, and all four metrics are numeric;
- `PARTIAL`: source is `GNSS` or `GPS_DERIVED`, at least one metric is numeric, and unavailable metrics are `null`;
- `UNAVAILABLE`: source is `UNAVAILABLE`, and all four metrics are `null`.

Only numeric, reliable values contribute to KPIs. The structured fields are the authoritative source for MVP navigation KPIs.

The optional/extensible `observations` array remains available for future business-value measurements. Unknown valid observation keys remain ingestible. The four structured navigation values must not also be duplicated as generic observations in telemetry schema version 3.

Normal summaries continue to exclude continuous raw IMU history.

## Consequences

- Backend, Mobile and Dashboard share one strongly typed KPI basis.
- Units and basic numeric validity are machine-verifiable.
- Average moving speed remains derived as total distance divided by total moving duration.
- Missing navigation data cannot silently become real zero distance, duration or speed.
- Future sensor and business observations remain extensible.
