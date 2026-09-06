create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new."updatedAt" = now();
  return new;
end;
$$;

create table public.wallet_accounts (
  id          uuid primary key default gen_random_uuid(),
  "userId"    uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  description text,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now(),
  "deletedAt" timestamptz
);

create trigger wallet_accounts_set_updated_at
  before update on public.wallet_accounts
  for each row execute function public.set_updated_at();

create index wallet_accounts_user_id_idx on public.wallet_accounts ("userId");
create index wallet_accounts_deleted_at_idx on public.wallet_accounts ("deletedAt");

alter table public.wallet_accounts enable row level security;

create policy "users can select own accounts"
  on public.wallet_accounts for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own accounts"
  on public.wallet_accounts for insert
  with check (auth.uid() = "userId");

create policy "users can update own accounts"
  on public.wallet_accounts for update
  using (auth.uid() = "userId");
