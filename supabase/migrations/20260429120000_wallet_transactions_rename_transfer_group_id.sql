-- Rename transactionGroupId → transferGroupId (paired account/card transfer legs).

alter table public.wallet_transactions
  rename column "transactionGroupId" to "transferGroupId";

comment on column public.wallet_transactions."transferGroupId" is
  'Shared UUID for paired account/card transfer rows; null for normal transactions.';

alter index wallet_transactions_transaction_group_id_idx
  rename to wallet_transactions_transfer_group_id_idx;
