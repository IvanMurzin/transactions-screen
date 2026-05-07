# Flavors

Two: `dev` and `prod`. Both target iOS + Android.

| | dev | prod |
| - | --- | ---- |
| Bundle id (Android `applicationId`) | `<app_id>.dev` | `<app_id>` |
| Bundle id (iOS `PRODUCT_BUNDLE_IDENTIFIER`) | `<app_id>.dev` | `<app_id>` |
| Display name | `<App Name> (dev)` | `<App Name>` |
| Deep link scheme | `<scheme>dev` | `<scheme>` |
| App icon | `AppIcon-dev` (greyscale) | `AppIcon` |
| Config file | `.config.dev.json` | `.config.prod.json` |
| Signing | debug keystore | release keystore (Android) / dist cert (iOS) |

## Run

```bash
flutter run --flavor dev  --dart-define-from-file=../.config.dev.json
flutter run --flavor prod --dart-define-from-file=../.config.prod.json
```

## Build

```bash
flutter build apk       --flavor prod --release --dart-define-from-file=../.config.prod.json
flutter build appbundle --flavor prod --release --dart-define-from-file=../.config.prod.json
flutter build ios       --flavor prod --release --dart-define-from-file=../.config.prod.json
```

## Where the flavor lives

- Android: `client/android/app/build.gradle.kts` — `productFlavors {
  create("dev") { … } create("prod") { … } }`.
- iOS: `client/ios/Flutter/Flavor-{dev,prod}.xcconfig` (and the
  matching schemes in `Runner.xcodeproj`).
- Dart: `AppFlavor` enum in `client/lib/core/config/app_config.dart`,
  populated from the `FLAVOR` dart-define.

## Adding a new flavor

Generally don't. Two flavors cover dev / prod for almost every
mobile app. If you need a third (e.g. `staging`), it's a PROP- spec.
