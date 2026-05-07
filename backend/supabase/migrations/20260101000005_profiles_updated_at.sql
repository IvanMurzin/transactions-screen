-- Keep `profiles.updated_at` in sync on every UPDATE.
drop trigger if exists trg_profiles_set_updated_at on public.profiles;

create trigger trg_profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();
