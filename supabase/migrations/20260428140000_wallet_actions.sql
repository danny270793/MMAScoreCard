-- Client-side diagnostics: caught errors, custom events, and uncaught framework/async errors.

create table public.wallet_actions (
  id               uuid primary key default gen_random_uuid(),
  type             text not null check (type in ('error', 'custom')),
  "customTitle"    text,
  "customPayload"  jsonb,
  "errorMessage"   text,
  "errorStack"     text,
  "appVersion"     text not null,
  "userId"         uuid references auth.users(id) on delete set null,
  os               text not null,
  "createdAt"      timestamptz not null default now()
);

create index wallet_actions_user_id_idx on public.wallet_actions ("userId");
create index wallet_actions_type_idx on public.wallet_actions (type);
create index wallet_actions_created_at_idx on public.wallet_actions ("createdAt" desc);

alter table public.wallet_actions enable row level security;

-- Signed-out clients (anon): only rows with no user id.
create policy "anon can insert wallet_actions without user"
  on public.wallet_actions for insert
  to anon
  with check ("userId" is null);

-- Signed-in clients: row must belong to the current user.
create policy "authenticated insert own wallet_actions"
  on public.wallet_actions for insert
  to authenticated
  with check ("userId" = auth.uid());

-- Optional: users can read their own diagnostic rows (disable if you prefer service_role-only reads).
create policy "users select own wallet_actions"
  on public.wallet_actions for select
  to authenticated
  using ("userId" = auth.uid());

comment on table public.wallet_actions is
  'App diagnostics: errors (try/catch or uncaught) and custom events; includes app version, OS, optional user.';
