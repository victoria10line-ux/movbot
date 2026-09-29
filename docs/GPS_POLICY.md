# GPS/Tracking policy

- Never label a coordinate as “live” unless it came from a verified tracking event within the configured freshness window.
- Suggested foreground cadence: 10–30 seconds and/or 50–100m distance, adjusted after battery testing.
- Background tracking requires explicit Android/iOS permission and platform-specific configuration.
- Tracking events carry UUIDs and timestamps; duplicates are ignored by `client_event_id`.
- Offline events remain queued until connectivity is restored.
- A stale GPS state is shown separately from offline app connectivity.
