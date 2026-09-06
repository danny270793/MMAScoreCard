-- Optional grouping for related credit transactions (e.g. deferred/card legs). No FK yet.
alter table public.wallet_transactions
  add column "creditGroupId" uuid;

comment on column public.wallet_transactions."creditGroupId" is
  'Shared UUID grouping related credit-linked rows when applicable (same purchase, splits, installments).';

create index wallet_transactions_credit_group_id_idx
  on public.wallet_transactions ("creditGroupId")
  where "creditGroupId" is not null;
