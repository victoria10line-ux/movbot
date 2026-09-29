# Package baseline verified at project kickoff

- Flutter stable line: 3.47 (released Aug 12, 2026).
- `supabase_flutter`: 2.17.2 (Dart >=3.9).
- `go_router`: 17.2.3 (Dart >=3.9; 18.x requires Dart 3.12).
- `flutter_map`: 8.3.2 (Dart >=3.6).
- `geolocator`: 14.1.1 (Dart >=3.5).
- `image_picker`: 1.2.3 (Dart >=3.10; if Flutter's bundled Dart is below 3.10, pin 1.2.2 or later compatible version before `pub get`).
- `connectivity_plus`: 7.3.1.
- `intl`: 0.20.3 (Dart >=3.9).
- `pdf`: 3.12.0 (kept below 3.13 because 3.13 requires Dart 3.12).
- `printing`: 5.14.3 (kept below 5.15 because 5.15 requires Dart 3.12).
- `excel`: 4.0.6.
- `uuid`: 4.6.0.
- `path_provider`: 2.1.6.

**Compatibility gate:** package minimum SDKs are intentionally documented here because Flutter package releases can move faster than the SDK. CI must run `flutter pub get`, `flutter analyze`, tests and release builds before accepting an SDK/package update.
