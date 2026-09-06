-- Deferred credit purchases: metadata per installment group; transactions reference via creditId.
create table public.wallet_credits (
  id               uuid primary key default gen_random_uuid(),
  "userId"         uuid not null references auth.users(id) on delete cascade,
  "transactedAt"   timestamptz not null,
  "graceMonths"    integer not null default 0 check ("graceMonths" >= 0 and "graceMonths" <= 2400),
  "termMonths"     integer not null check ("termMonths" >= 2 and "termMonths" <= 600),
  "createdAt"      timestamptz not null default now(),
  "updatedAt"      timestamptz not null default now(),
  "deletedAt"      timestamptz
);

create trigger wallet_credits_set_updated_at
  before update on public.wallet_credits
  for each row execute function public.set_updated_at();

create index wallet_credits_user_id_idx on public.wallet_credits ("userId");
create index wallet_credits_deleted_at_idx on public.wallet_credits ("deletedAt");

alter table public.wallet_credits enable row level security;

create policy "users can select own credits"
  on public.wallet_credits for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own credits"
  on public.wallet_credits for insert
  with check (auth.uid() = "userId");

create policy "users can update own credits"
  on public.wallet_credits for update
  using (auth.uid() = "userId");

alter table public.wallet_transactions
  add column "creditId" uuid references public.wallet_credits(id) on delete restrict;

comment on column public.wallet_transactions."creditId" is
  'FK to wallet_credits; installments share the same creditId. Legacy rows may use creditGroupId only.';

create index wallet_transactions_credit_id_idx
  on public.wallet_transactions ("creditId")
  where "creditId" is not null;
