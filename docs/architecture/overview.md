# Architecture overview

Three pieces, deliberately decoupled.

```
┌──────────────────┐     ┌──────────────────────────┐     ┌────────────────────┐
│  Flutter client  │ ──► │  Supabase Edge Function  │ ──► │  Postgres + api_*  │
│  (iOS / Android) │     │  (auth + envelope only)  │     │  (RLS-locked)      │
└──────────────────┘     └──────────────────────────┘     └────────────────────┘
        │                                                          ▲
        │                                                          │
        ▼                                                          │
   Firebase / RevenueCat (optional, gated by config flags)         │
        │                                                          │
        └────── analytics events / purchase events ────────────────┘
```

## Principles

- **Single backend.** No separate dev/prod Supabase projects. Flavor
  is a client-side distinction.
- **Server-authoritative.** Business rules live in Postgres `api_*`
  RPCs called via SECURITY DEFINER. The client never bypasses RLS.
- **Envelope everywhere.** Every edge function returns
  `{ ok: true|false, … }` with stable error codes. Clients switch on
  codes, never strings.
- **Spec-driven.** No code change exists without a spec in
  `docs/specs/open/` or `docs/specs/closed/`.

## Client → backend contract

Documented in `docs/contracts/api-surface.md` (created when you add
the first endpoint). The shape:

```http
POST https://<project-ref>.supabase.co/functions/v1/api/<route>
Authorization: Bearer <user JWT>
Content-Type: application/json

{ … route-specific JSON body … }
```

Response (success):

```json
{ "ok": true, "data": { … }, "meta": { … (optional) } }
```

Response (failure):

```json
{
  "ok": false,
  "error": { "code": "VALIDATION_ERROR", "message": "…", "details": { … } }
}
```

## Cross-cutting docs

- [`client.md`](client.md) — top-level Flutter architecture.
- [`backend.md`](backend.md) — top-level Supabase architecture.
- [`integrations.md`](integrations.md) — Firebase, RevenueCat, anything
  that lives at the edges.
- [`patterns/`](patterns/) — opt-in patterns (e.g. money-atomic
  helpers) you can adopt or skip per project.
