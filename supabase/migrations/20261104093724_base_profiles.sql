-- Base schema: extensions, profiles, RLS, triggers.

create extension if not exists postgis with schema extensions;

create type public.user_role as enum ('seeker', 'host');

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role public.user_role not null default 'seeker',
  display_name text check (display_name is null or char_length(display_name) between 1 and 50),
  -- Nullable: the row is created at signup, birthdate is collected in onboarding.
  -- Age only grows, so a fixed 18+ check stays valid for existing rows.
  birthdate date check (birthdate is null or birthdate <= (current_date - interval '18 years')::date),
  bio text check (bio is null or char_length(bio) <= 500),
  locale text not null default 'de' check (locale in ('de', 'en')),
  onboarding_done boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

-- Clients never delete rows directly; account deletion goes through a privileged function / auth cascade.
revoke all on public.profiles from anon, authenticated;
grant select, insert, update on public.profiles to authenticated;

create policy "profiles_select_own" on public.profiles
  for select to authenticated
  using ((select auth.uid()) = id);

create policy "profiles_insert_own" on public.profiles
  for insert to authenticated
  with check ((select auth.uid()) = id);

create policy "profiles_update_own" on public.profiles
  for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create function public.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- Creates the profile row when a user signs up. Runs as owner because the
-- new user has no session yet; search_path is pinned to avoid hijacking.
create function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id) values (new.id);
  return new;
end;
$$;

revoke all on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();
