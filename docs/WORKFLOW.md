# End-to-end operational workflow

1. User authenticates.
2. Admin/operations creates carrier, driver, vehicle and documents.
3. Operations creates a trip with UUID references to cargo, loading and delivery locations.
4. Driver sees available trips allowed by RLS.
5. Booking is executed via `book_trip()` transaction; duplicate/race booking is rejected server-side.
6. Trip start is executed via `start_trip()`, creating one tracking session.
7. Driver location/events are queued locally when offline and synced idempotently using `client_event_id`.
8. Arrival at loading is executed via `arrive_at_loading()`, storing GPS/timestamp and creating/updating the delay record.
9. Delay policy is read from `delay_policies`; compensation is not a hard-coded client constant.
10. Proof media is uploaded to private Storage using carrier-scoped paths and metadata references.
11. Loading/moving/unloading events update vehicle/trip state and tracking history.
12. Delivery is finalized through `complete_delivery()`, closing the tracking session and marking shipment/trip complete.
13. Reports query actual operational tables with date/entity filters and are exported to PDF/XLSX.
14. Audit logs capture privileged changes; scheduled reports are represented by persisted report schedules for server execution.
