-- Owned assets tracked outside transactions (investments, property, etc.).

create table public.wallet_assets (
  id               uuid primary key default gen_random_uuid(),
  "userId"         uuid not null references auth.users(id) on delete cascade,
  name             text not null,
  provider         text not null default '',
  value            numeric not null default 0,
  "boughtAt"       timestamptz not null default now(),
  "endedAt"        timestamptz,
  "soldValue"      numeric,
  "createdAt"      timestamptz not null default now(),
  "updatedAt"      timestamptz not null default now(),
  "deletedAt"      timestamptz
);

create trigger wallet_assets_set_updated_at
  before update on public.wallet_assets
  for each row execute function public.set_updated_at();

create index wallet_assets_user_id_idx on public.wallet_assets ("userId");
create index wallet_assets_deleted_at_idx on public.wallet_assets ("deletedAt");

alter table public.wallet_assets enable row level security;

create policy "users can select own assets"
  on public.wallet_assets for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own assets"
  on public.wallet_assets for insert
  with check (auth.uid() = "userId");

create policy "users can update own assets"
  on public.wallet_assets for update
  using (auth.uid() = "userId");

create or replace function public.soft_delete_wallet_asset(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  update public.wallet_assets
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

revoke all on function public.soft_delete_wallet_asset(uuid) from public;
grant execute on function public.soft_delete_wallet_asset(uuid) to authenticated;
