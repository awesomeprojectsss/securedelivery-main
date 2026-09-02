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

Temperature, billing, ecommerce, inventory, request shipment tracking, continuous route storage and continuous raw-IMU upload are outside the MVP.

## Roles

- `SUPER_ADMIN`: platform and privileged administration.
- `ADMIN`: Customer, Device and support management within policy.
- `CUSTOMER`: access only to owned resources, SmartBox activation, events and support.

Server always enforces RBAC and Customer isolation.

## For customers and partners

The intended value is to make transport incidents observable and auditable while controlling network and storage costs. The MVP validates collection, detection, synchronization and operations before dedicated hardware.

Detections support investigation; they are not automatic proof of fault or causality. GPS-dependent metrics explicitly expose unavailable data and never convert missing signal into zero.

[Back to documentation](README.md) · [Contract guide](contract-guide.md)
