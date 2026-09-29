# Movbot Architecture

## Product shape
Mobile-first fleet/logistics platform with role-aware workflows for drivers, carriers and operations.

## Layers
- Presentation: Flutter widgets, design system, navigation shell, RTL/LTR.
- Domain: UUID-based entities and workflow rules.
- Data: Supabase repositories and RPC calls.
- Integration: map provider, location, media, notifications, reporting, sync.
- Backend: Postgres constraints, RLS, transactional booking RPC, audit trail, storage.

## Non-negotiable identity rule
Every operational object is addressed by UUID. Human-readable codes (`TRUCK-104`, `TRIP-...`) are display/search identifiers only and never foreign keys.

## Booking consistency
Booking is a server-side transaction through `book_trip()`. The function validates availability and driver/vehicle conflicts, inserts the booking under a unique trip constraint, then transitions the trip/driver/vehicle state.

## Tracking
A `tracking_session` is created per trip. Events use a client-generated UUID and an idempotent unique constraint. The mobile client queues events while offline and upserts them when connectivity returns. The server is authoritative.

## Maps
`flutter_map` renders a real tile source. The tile URL is configuration, not a hard-coded business dependency. Live vehicle markers are only rendered when verified tracking records exist; the UI explicitly distinguishes offline/stale GPS.

## 3D
The app expects optimized GLB assets in `assets/vehicles/`. A model registry should map trailer type/state to licensed assets. The UI must not silently substitute a fake image when a required asset is absent; it should show a controlled “asset unavailable” state in development and block release validation for missing production assets.

## Reporting
Operational reports are generated from database queries with explicit filters. PDF is A4 and XLSX is a real workbook. Report requests are persisted so scheduled reporting can run server-side.

## Offline
Offline is an event-queue problem, not simply a connectivity flag. Queue records must be idempotent, ordered where required, and replayed with conflict handling. Connectivity state is advisory only; network requests still need timeouts/error handling.

## Security
- Supabase publishable key only in the client.
- RLS is the authorization boundary for database reads/writes.
- Sensitive server operations use RPC/Edge Functions.
- Storage paths are scoped by entity UUID and policy.
- Audit logs capture important state transitions.
