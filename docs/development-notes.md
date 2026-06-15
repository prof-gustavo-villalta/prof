# Development Notes

## Demo data

Development and testing should include demo data for DS3, PAM2, WEB2 and students with and without photos. Demo data is not part of the user-facing MVP.

## UI drift check

Run `npm run check:ui` before commits that touch `lib/ui`.

The check reports common visual values that should usually come from the Design System: direct `Colors.*`, direct `TextStyle(`, numeric `EdgeInsets` and manual `BoxDecoration(`. It scans only UI files and skips `lib/ui/design_system`, where tokens and theme definitions live.

When a direct visual value is intentional, keep it with a nearby comment containing `ui-drift-ok:` and a short reason.
