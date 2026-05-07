# Firebase

Firebase Analytics + Crashlytics are wired up but disabled by default
so the template can boot, analyze, and run without any Firebase
project.

## Enable

1. Create a Firebase project (or reuse one).
2. Register Android app with the right `applicationId` (one per
   flavor — `<app_id>` for prod, `<app_id>.dev` for dev). Download
   `google-services.json` and place it at
   `client/android/app/google-services.json`. The file is gitignored.
3. Register the iOS app(s) similarly. Download
   `GoogleService-Info.plist` and place it at
   `client/ios/Runner/GoogleService-Info.plist`. The file is
   gitignored.
4. Set `ENABLE_FIREBASE=true` in `.config.dev.json` and/or
   `.config.prod.json`.
5. Rebuild.

## What's gated by the flag

- `FirebaseInitializer.init()` returns immediately when the flag is
  false (no `Firebase.initializeApp()`, no Crashlytics setup).
- `AppAnalytics` events fall back to `logger.i('analytics_event …')`
  when the flag is false or the build isn't release.

## Verifying

Send a test event from `RemoteConfig`/console; it should show up in
Firebase within a minute or two for prod-release builds.
