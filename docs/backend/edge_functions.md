# Edge functions

One function: `api`. Authenticated. Dispatches every product action.

## Adding a route

1. **Migration**: `api_<verb>_<resource>(p_user_id uuid, …)`.
2. **Schema**: add a Zod schema in
   `backend/supabase/functions/_shared/validation.ts` if the route
   has a JSON body.
3. **Handler**: a small async function in
   `backend/supabase/functions/api/index.ts`:

   ```ts
   async function handleFoo(req: Request, userId: string): Promise<Response> {
     const body = await parseJsonBody(req, fooSchema);
     const data = await rpc<FooPayload>('api_create_foo', {
       p_user_id: userId,
       p_name: body.name,
     });
     return ok(data);
   }
   ```

4. **Route**: add to the `Deno.serve` switch:

   ```ts
   } else if (method === 'POST' && path === '/foo/create') {
     response = await handleFoo(req, user.id);
   }
   ```

5. **Document**: append to `docs/contracts/api-surface.md`.

## Local serving

```bash
supabase --workdir backend functions serve api
```

The function reads `SUPABASE_URL`, `SUPABASE_SERVICE_ROLE_KEY`, and any
secrets you pass via `--env-file backend/.env.local` (gitignored).

## Logging

```ts
console.log(JSON.stringify({ function: 'api', method, path, status, duration_ms }));
```

Supabase log search picks up structured fields — keep them stable.

## Error envelope

Throw `ApiHttpError(status, code, message, details?)` from a handler.
The wrapper in `Deno.serve` converts it into the standard error
envelope with the right HTTP status.
