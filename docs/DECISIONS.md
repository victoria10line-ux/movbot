# Architecture Decisions

1. **Flutter 3.47 baseline**: current stable line at project kickoff; keeps the mobile codebase unified.
2. **Supabase/Postgres**: chosen for managed auth, relational constraints, RLS, storage and realtime capabilities while preserving SQL ownership.
3. **UUID relationships**: prevents collisions when names/codes are duplicated or edited.
4. **Server-side booking RPC**: avoids double booking races that cannot be safely solved by client-only checks.
5. **Soft deletion**: operational records remain auditable.
6. **Configurable map provider**: avoids locking the product to a single tile/routing vendor.
7. **Real-time tracking is opt-in to verified telemetry**: no fabricated “live” position is ever displayed.
8. **3D assets externalized**: production requires licensed, optimized GLB assets; invented placeholder models would violate the product requirement.
9. **A4 report engine**: generated from filtered DB data, not static templates.
10. **Arabic-first**: default RTL, with English LTR parity.
