# Optional patterns

This directory hosts design patterns from the source project that are
**not** part of the template's mandatory architecture but may be
useful for specific app domains.

Adopt them when they fit your problem. Skip them otherwise.

| Pattern | When useful |
| ------- | ----------- |
| [`auth_route_guard.md`](auth_route_guard.md) | Wiring `AuthRouteGuard` into `go_router` once you've added sign-in / sign-up pages. |
| [`subscriptions_revenuecat.md`](subscriptions_revenuecat.md) | Understanding the RevenueCat ↔ Supabase data flow before extending paywall / entitlements logic. |
