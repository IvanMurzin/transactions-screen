-- Wires `handle_new_user` to fire after every auth.users insert.
--
-- Drop-then-create keeps the migration idempotent on re-application.
drop trigger if exists trg_auth_user_created on auth.users;

create trigger trg_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();
