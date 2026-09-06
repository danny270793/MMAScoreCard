-- Per-card balance on /cards should not include deferred credit installments
-- (wallet_transactions.creditId set); those totals live under /credits.

drop view if exists public.wallet_cards_with_balance;

create view public.wallet_cards_with_balance
with (security_invoker = true)
as
select
  c.id,
  c."userId",
  c.name,
  c.description,
  c."cutDay",
  c."payDay",
  c."createdAt",
  c."updatedAt",
  c."deletedAt",
  coalesce(agg.total, 0)::numeric as balance
from public.wallet_cards c
left join (
  select
    wt."cardId",
    sum(wt.value)::numeric as total
  from public.wallet_transactions wt
  where wt."deletedAt" is null
    and wt."cardId" is not null
    and wt."creditId" is null
  group by wt."cardId"
) agg on agg."cardId" = c.id;

grant select on public.wallet_cards_with_balance to authenticated;
grant select on public.wallet_cards_with_balance to service_role;
