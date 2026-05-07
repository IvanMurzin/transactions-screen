# Pattern: Subscriptions (RevenueCat-bound)

The template's subscription module is intentionally tied to
RevenueCat. If your product uses a different billing provider (raw
StoreKit / Google Play Billing, Stripe, …), replace the
implementation; the contracts in `domain/subscription/` are
provider-agnostic.

## Source of truth

`profiles.plan` in Postgres is the only value the app trusts.
RevenueCat events flow into the database via two paths:

1. **Webhook (push):** `revenuecat_webhook` edge function, called by
   RevenueCat on every entitlement change. Idempotent via
   `webhook_events(source, external_id)`. Calls
   `api_apply_revenuecat_event` to update `profiles.plan`.
2. **Refresh (pull):** `/api/revenuecat/refresh`, called by the
   client after a purchase / restore / on app foreground. The edge
   function reads entitlements from RevenueCat's REST API and writes
   the resulting plan back via the same RPC.

The client never reads entitlements from the SDK as the source of
truth — `RevenueCatService` is only used to initiate purchases, log
in / out the app_user_id, and trigger restores.

## Client lifecycle

```
AuthCubit (session stream)
  └─► SubscriptionCubit (listens)
        ├─► on signedIn(userId):
        │     • RevenueCat.logIn(userId)   ← bind identity
        │     • POST /api/revenuecat/refresh
        │     • GET  /api/me
        │     • emit synced + plan
        └─► on signedOut:
              • RevenueCat.logOut()
              • emit initial
```

`SubscriptionCubit.bootstrap()` is called once in `app.dart`. It
subscribes to `AuthCubit.stream` and runs the loop above; products
don't need to wire anything else for the bind to work.

## Free / pro semantics

`profiles.plan` is `'free' | 'pro'`. The template does not ship a
limits table — products that need plan-specific quotas add their own
migration (e.g. `plan_limits(plan, max_xxx, …)`) and surface the
limits via a project-specific RPC. Keep the `free`/`pro` enum stable
and prefer adding fine-grained entitlements as new boolean columns
on `profiles`, not as more plan strings.

## When to call `refresh` from the UI

- After a purchase completes successfully (the SDK emits a paywall
  result; the cubit's `restorePurchases` already chains a refresh).
- On app foreground, if more than ~60 seconds have passed since the
  last successful sync.
- After the user enables / re-enables push notifications, since
  iOS may have queued an entitlement change while the app was
  backgrounded.

Don't poll. The webhook is the primary path; `refresh` is a
self-heal for the cases where the webhook hasn't landed yet.

## Disabling subscriptions

Set `ENABLE_REVENUECAT=false` in the active flavor config. The DI
module swaps in `NoopRevenueCatService`; `SubscriptionRepository`
keeps working but every `bindUser` / `restorePurchases` becomes a
no-op. The backend webhook can remain deployed — it just won't
receive traffic until you publish RevenueCat-managed offerings.
