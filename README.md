# Movbot — Fleet & Logistics Mobile Platform

Production-oriented Flutter + Supabase foundation for a mobile-first logistics/fleet product inspired by the supplied visual references, with an original dark-navy/orange design system.

## Current baseline
- Flutter 3.47 / Dart 3.9 baseline.
- Supabase Auth + Postgres + Storage + Realtime architecture.
- Strong UUID relationships; no name-based entity joins.
- RLS-oriented schema and server-side booking conflict function.
- Mobile-first shell with persistent bottom navigation.
- Arabic-first RTL with English-ready localization structure.
- Real map integration layer using `flutter_map`; tile provider is configurable.
- Offline/sync service boundary ready for event queue implementation.
- PDF/XLSX report service boundary.
- 3D vehicle asset boundary with explicit states; real GLB assets are intentionally externalized to `assets/vehicles/` and must be supplied under an appropriate license before release.

## Run
1. Install Flutter 3.47+ and Android Studio/Xcode as appropriate.
2. Create a Supabase project.
3. Apply `supabase/migrations/001_initial_schema.sql` in the Supabase SQL editor or through migrations.
4. Configure credentials with build-time defines; never commit secrets.
5. Run `flutter pub get`.
6. Run `flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_PUBLISHABLE_KEY=...`.

Supabase's current Flutter guidance recommends the publishable client key with RLS and warns against treating the client as a trusted boundary. See the official docs.

## Important production gates
This repository is a real application foundation, not a claim that a cloud account, GPS hardware feed, push provider, routing provider, or licensed 3D fleet asset library already exists. Those integrations require deployment credentials/configuration and must be exercised in a real device/production-like environment before release.

## Decisions
See `docs/ARCHITECTURE.md`, `docs/DESIGN_SYSTEM.md`, `docs/DECISIONS.md`, and `docs/RELEASE_CHECKLIST.md`.
