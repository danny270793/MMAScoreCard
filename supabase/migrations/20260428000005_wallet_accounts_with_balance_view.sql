-- Aggregated balance per account (non-deleted transactions only).
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
  coalesce(agg.total, 0)::numeric as balance
from public.wallet_accounts a
left join (
  select
    wt."accountId",
    sum(wt.value)::numeric as total
  from public.wallet_transactions wt
  where wt."deletedAt" is null
    and wt."accountId" is not null
  group by wt."accountId"
) agg on agg."accountId" = a.id;

grant select on public.wallet_accounts_with_balance to authenticated;
grant select on public.wallet_accounts_with_balance to service_role;
