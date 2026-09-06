-- Add weighted (value * percentage / 100) and counted (sum where not ignore) alongside full balance.

create or replace view public.wallet_accounts_with_balance
with (security_invoker = true)
as
select
  a.id,
  a."userId",
  a.name,
  a.description,
  a."createdAt",
  a."updatedAt",
  a."deletedAt",
  coalesce(agg.total_all, 0)::numeric as balance,
  coalesce(agg.total_weighted, 0)::numeric as "balanceWeighted",
  coalesce(agg.total_counted, 0)::numeric as "balanceCounted"
from public.wallet_accounts a
left join (
  select
    wt."accountId",
    sum(wt.value)::numeric as total_all,
    sum(wt.value * wt.percentage / 100.0)::numeric as total_weighted,
    sum(wt.value) filter (where not wt."ignore")::numeric as total_counted
  from public.wallet_transactions wt
  where wt."deletedAt" is null
    and wt."accountId" is not null
  group by wt."accountId"
) agg on agg."accountId" = a.id;

create or replace view public.wallet_cards_with_balance
with (security_invoker = true)
as
select
  c.id,
  c."userId",
  c.name,
  c.description,
  c."createdAt",
  c."updatedAt",
  c."deletedAt",
  coalesce(agg.total_all, 0)::numeric as balance,
  coalesce(agg.total_weighted, 0)::numeric as "balanceWeighted",
  coalesce(agg.total_counted, 0)::numeric as "balanceCounted"
from public.wallet_cards c
left join (
  select
    wt."cardId",
    sum(wt.value)::numeric as total_all,
    sum(wt.value * wt.percentage / 100.0)::numeric as total_weighted,
    sum(wt.value) filter (where not wt."ignore")::numeric as total_counted
  from public.wallet_transactions wt
  where wt."deletedAt" is null
    and wt."cardId" is not null
  group by wt."cardId"
) agg on agg."cardId" = c.id;
