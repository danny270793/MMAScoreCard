-- Links paired rows (e.g. same transfer). Nullable for ordinary transactions.
alter table public.wallet_transactions
  add column "transactionGroupId" uuid;

comment on column public.wallet_transactions."transactionGroupId" is
  'Shared UUID for related transactions (e.g. account transfer pair).';

create index wallet_transactions_transaction_group_id_idx
  on public.wallet_transactions ("transactionGroupId")
  where "transactionGroupId" is not null;
