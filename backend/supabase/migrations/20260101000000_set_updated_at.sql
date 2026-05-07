-- Generic trigger function: sets `updated_at = now()` on UPDATE.
-- Attach via `before update on <table> for each row execute function public.set_updated_at();`
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $func$
begin
  new.updated_at = now();
  return new;
end;
$func$;
