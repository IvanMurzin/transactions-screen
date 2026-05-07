# Acceptance criteria

Each AC is **observable**, **binary**, and **traceable**.

- Observable: a reviewer can run the app or query the DB and see the
  outcome — no internal-state assertions.
- Binary: it either passes or fails. Avoid "the page should feel
  fast" and similar fuzzy phrasing.
- Traceable: linked to one or more functional requirements.

## Pattern

```
AC-N: Given <precondition>, when <action>, then <observable outcome>.
```

## Examples

- AC-1: Given an unauthenticated user on `/`, when they tap "Sign in",
  then the app navigates to `/sign-in` within 200ms.
- AC-2: Given a free-plan user with 5 accounts, when they call
  `POST /api/accounts/create`, then the response is
  `{ ok: false, error.code: "LIMIT_REACHED" }` with HTTP 409.
- AC-3: Given Russian as the device locale, when the user opens the
  example screen, then the page title reads "Добро пожаловать".
