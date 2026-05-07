# Implementation plan: SPEC-XXXX

A plan file is optional and lives next to the spec when the
implementation is large enough that the spec body would otherwise
balloon. Use sparingly.

## Approach
What changes in the codebase, ordered by risk. The first paragraph
should answer "what does the diff look like?" without enumerating
files.

## Files touched
- `client/lib/...`
- `backend/supabase/migrations/...`
- `backend/supabase/functions/...`

## Sequencing
1. Backend migration + function — deploy first.
2. Client wiring — ships next.
3. Analytics + docs — last.

## Risks
- <name>: <mitigation>.

## Out of scope (re-stated)
A short reminder of what the implementation must NOT touch.
