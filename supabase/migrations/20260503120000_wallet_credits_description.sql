alter table public.wallet_credits
  add column description text;

comment on column public.wallet_credits.description is
  'Optional user note for this deferred purchase (stored without installment prefix).';
