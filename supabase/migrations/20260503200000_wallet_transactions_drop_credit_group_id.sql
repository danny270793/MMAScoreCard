-- Installments attach only via wallet_transactions.creditId (wallet_credits row).
drop index if exists public.wallet_transactions_credit_group_id_idx;

alter table public.wallet_transactions
  drop column if exists "creditGroupId";
