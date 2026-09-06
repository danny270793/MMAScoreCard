-- Opening-balance marker for a transaction row (not exposed in app UI).
alter table public.wallet_transactions
  add column "initialBalance" boolean not null default false;

comment on column public.wallet_transactions."initialBalance" is
  'When true, row represents an initial balance entry; app inserts/updates do not set this via API.';
