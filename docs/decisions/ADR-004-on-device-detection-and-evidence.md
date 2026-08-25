# ADR-004: On-Device Event Detection and Evidence Preservation

## Status

Accepted

## Context

SecureDelivery needs event detection to continue even with unreliable connectivity and must be able to audit why an event was generated.

## Decision

Perform sensor interpretation and abnormal-event detection on the Device.

Persist the generated event and supporting evidence locally before synchronization.

The server receives the event result, detector metadata and evidence; it does not need to re-run the detector.

## Consequences

- Detection works offline.
- Mobile algorithms can evolve independently.
- Backend stays generic.
- Event evidence supports calibration and false-positive investigation.
