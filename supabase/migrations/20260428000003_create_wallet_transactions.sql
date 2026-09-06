create table public.wallet_transactions (
  id               uuid primary key default gen_random_uuid(),
  "userId"         uuid not null references auth.users(id) on delete cascade,
  "accountId"      uuid references public.wallet_accounts(id) on delete set null,
  "cardId"         uuid references public.wallet_cards(id) on delete set null,
  "categoryId"     uuid references public.wallet_categories(id) on delete set null,
  "tagId"          uuid references public.wallet_tags(id) on delete set null,
  "transactedAt"   timestamptz not null default now(),
  value            numeric not null default 0,
  "ignore"         boolean not null default false,
  percentage       numeric not null default 0,
  "createdAt"      timestamptz not null default now(),
  "updatedAt"      timestamptz not null default now(),
  "deletedAt"      timestamptz
);

create trigger wallet_transactions_set_updated_at
  before update on public.wallet_transactions
  for each row execute function public.set_updated_at();

create index wallet_transactions_user_id_idx on public.wallet_transactions ("userId");
create index wallet_transactions_deleted_at_idx on public.wallet_transactions ("deletedAt");
create index wallet_transactions_transacted_at_idx on public.wallet_transactions ("transactedAt");
create index wallet_transactions_account_id_idx on public.wallet_transactions ("accountId");
create index wallet_transactions_card_id_idx on public.wallet_transactions ("cardId");
create index wallet_transactions_category_id_idx on public.wallet_transactions ("categoryId");
create index wallet_transactions_tag_id_idx on public.wallet_transactions ("tagId");

alter table public.wallet_transactions enable row level security;

create policy "users can select own transactions"
  on public.wallet_transactions for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own transactions"
  on public.wallet_transactions for insert
  with check (auth.uid() = "userId");

create policy "users can update own transactions"
  on public.wallet_transactions for update
  using (auth.uid() = "userId");
