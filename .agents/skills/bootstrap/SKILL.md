---
name: bootstrap
description: Use right after cloning sdd_template into a new project directory. Renames the Flutter package, replaces bundle ids, scaffolds dev/prod configs, runs format + analyze, and creates the initial git commit. Supports --reinit-git for cloned repos with existing .git history. Required arguments app_name and app_id; default app_id format com.yourname.appname.
---

# bootstrap

Turns a freshly-cloned template into a real project. Assumes you
cloned the template and are now inside the cloned directory.

## Inputs

- `app_name` — display name. Used for iOS `DISPLAY_NAME`, Android
  `app_name` resource, dev variant gets `(dev)` appended automatically.
- `app_id` — reverse-DNS bundle id. Default format
  `com.<owner>.<name>`. Dev variant gets `.dev` suffix automatically.
- `--reinit-git` — optional flag. If `.git/` already exists (after clone),
  remove template history and create a clean repo.

## Pre-flight checks

1. We're not inside `sdd_template` itself (refuse if `pwd` ends with
   `/sdd_template` — bootstrap is destructive and would corrupt the
   template).
2. If `.git/` exists, use `--reinit-git` to remove template history
   and create a clean repo with the first commit.
3. Required tools installed: `flutter`, `dart`, `git`. Print versions.

## What it does (delegates to scripts/bootstrap.sh)

1. Replace `template_app` package name throughout `client/` (Dart
   imports, `pubspec.yaml`).
2. Replace `com.example.appname` placeholder with `app_id`:
   - Android: `client/android/app/build.gradle.kts`
     (`namespace`, `applicationId`), MainActivity package directory,
     deep link scheme.
   - iOS: `client/ios/Flutter/Flavor-{dev,prod}.xcconfig`,
     `client/ios/Runner.xcodeproj/project.pbxproj`,
     `client/ios/Runner/Info.plist` (URL name).
3. Replace `Template App` display name with `app_name`. Dev variant
   becomes `<app_name> (dev)`.
4. Replace Supabase `project_id` in `backend/supabase/config.toml`
   with a sluggified `app_name`.
5. Copy `.config.dev.json.example` → `.config.dev.json`,
   `.config.prod.json.example` → `.config.prod.json`,
   `.env.example` → `.env`.
6. `cd client && flutter pub get && (dart run build_runner build --delete-conflicting-outputs || dart run build_runner build --force-jit)`.
7. `dart format .` then `flutter analyze` — both must exit clean.
8. If `--reinit-git` is passed and `.git/` exists, remove `.git/` first.
9. `git init && git add -A && git commit -m "chore: bootstrap from sdd_template"`.

## What it does NOT do

- Run `flutter create` (the template ships pre-generated iOS/Android shells).
- Run tests.
- Set up a remote git repository or push anywhere.
- Add real Firebase / RevenueCat / Supabase credentials.

## Output

A printed manual checklist:

- [ ] Add `client/android/app/google-services.json` and
      `client/ios/Runner/GoogleService-Info.plist`, then set
      `ENABLE_FIREBASE=true` in both `.config.*.json`.
- [ ] Replace `rcat_placeholder_*` keys in `.config.*.json` with real
      RevenueCat keys, then set `ENABLE_REVENUECAT=true`.
- [ ] Fill `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `.config.*.json`.
- [ ] Replace placeholder app icons and splash screen.
- [ ] Configure Android signing (`client/android/key.properties`).
- [ ] Configure iOS signing & capabilities in Xcode.

## Next steps after bootstrap

Bootstrap only renames packages and verifies the Flutter toolchain.
After it completes, follow this order:

```
Step 1: /create-product
   Fill docs/product/* — product vision, audience, JTBD, MVP scope.
   All future specs and the design system are derived from these docs.

Step 2: /setup-design-system
   Creates the full project DS from scratch using ui-ux-pro-max.
   Generates tokens, typography, palette, and 14 core components
   tailored to your product's brand and audience.
   Required before any UI spec can be written or implemented.

Step 3: /create-all-specs
   Reads product docs + DS, breaks the product into all feature areas,
   generates design docs per area (ui-ux-pro-max), creates all specs
   with full technical + design + product detail.
   Interactive — section by section.
   After this: every spec is at status "open" and ready for development.

Step 4: /mvp-orchestrator
   Implements specs one by one, P0 first. Runs format + analyze + tests
   after each spec. One spec → one subagent → one commit.
```

## On failure

If any step fails, the script aborts with a clear error. Re-run after
fixing — bootstrap is **not** idempotent; restore from a fresh clone
of the template if state gets weird.
