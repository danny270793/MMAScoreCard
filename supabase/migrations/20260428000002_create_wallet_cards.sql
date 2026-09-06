create table public.wallet_cards (
  id          uuid primary key default gen_random_uuid(),
  "userId"    uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  description text,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now(),
  "deletedAt" timestamptz
);

create trigger wallet_cards_set_updated_at
  before update on public.wallet_cards
  for each row execute function public.set_updated_at();

create index wallet_cards_user_id_idx on public.wallet_cards ("userId");
create index wallet_cards_deleted_at_idx on public.wallet_cards ("deletedAt");

alter table public.wallet_cards enable row level security;

create policy "users can select own cards"
  on public.wallet_cards for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own cards"
  on public.wallet_cards for insert
  with check (auth.uid() = "userId");

create policy "users can update own cards"
  on public.wallet_cards for update
  using (auth.uid() = "userId");
