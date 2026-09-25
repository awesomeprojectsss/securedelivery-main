# Product and MVP

## The problem

Organizations that depend on deliveries need to understand whether impacts, excessive inclination, falls or abnormal movement may have compromised cargo. Fleet tracking alone does not answer that question or preserve enough evidence for later review.

SecureDelivery prioritizes cargo integrity, not driver surveillance or automatic driver scoring.

## The proposition

During a delivery, the SmartBox:

1. collects motion and location on the Device;
2. detects relevant events locally;
3. preserves high-frequency samples around each event;
4. synchronizes summaries and evidence when connectivity is available;
5. lets authorized people investigate through the Dashboard.

## MVP scope

The smartphone represents future dedicated IoT hardware and is fixed horizontally to the box. The MVP includes secure QR activation, 50 Hz local IMU acquisition, up-to-1 Hz GPS/ground speed, one-minute summaries, local event detection, offline synchronization, management, events, notifications, support and explicit SmartBox-request fulfillment or cancellation.

The Device application supports Android 10 and later. It uses at most 50 MiB for managed local payloads, retries synchronization every minute and receives one result per telemetry period even when several periods travel in one batch. Event evidence uses a fixed two-second window before and after the trigger, plus the trigger interval. Monitoring does not start below 15% battery unless charging, stops at Android thermal status `SEVERE` or worse, and is limited to 12 accumulated hours in a rolling 24-hour period. Detector thresholds remain deferred until real-Device study and testing.

Temperature, billing, ecommerce, inventory, request shipment tracking, continuous route storage and continuous raw-IMU upload are outside the MVP.

## Roles

- `SUPER_ADMIN`: platform and privileged administration.
- `ADMIN`: internal platform-wide operator for Customers, `CUSTOMER` users, Devices and support within policy.
- `CUSTOMER`: access only to owned resources, SmartBox activation, events and support.

Server always enforces RBAC and Customer isolation.

Only `SUPER_ADMIN` manages privileged accounts, and email is globally unique. Administrative password reset sets a temporary password, revokes sessions and requires a password change. Customer inactivation blocks its users and new Device ingestion while preserving history for authorized internal operators. Security audit records have an 18-month default retention unless a documented legal obligation, investigation or legal hold applies.

One DeviceRequest represents one SmartBox and contains only optional notes. A Device is created directly as `PENDING_ACTIVATION`. Its opaque QR activation code does not expire while pending and may be scanned repeatedly, but the first confirmation binds ownership and later attempts return already activated without transferring the Device.

## For customers and partners

The intended value is to make transport incidents observable and auditable while controlling network and storage costs. The MVP validates collection, detection, synchronization and operations before dedicated hardware.

Detections support investigation; they are not automatic proof of fault or causality. GPS-dependent metrics explicitly expose unavailable data and never convert missing signal into zero.

[Back to documentation](README.md) · [Contract guide](contract-guide.md)
