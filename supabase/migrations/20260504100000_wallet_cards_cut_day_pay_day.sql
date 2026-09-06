-- Statement cut and payment days of month (1–31), default 24 for existing and new rows.
alter table public.wallet_cards
  add column "cutDay" smallint not null default 24
    constraint wallet_cards_cut_day_range check ("cutDay" between 1 and 31),
  add column "payDay" smallint not null default 24
    constraint wallet_cards_pay_day_range check ("payDay" between 1 and 31);

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
  group by wt."cardId"
) agg on agg."cardId" = c.id;

grant select on public.wallet_cards_with_balance to authenticated;
grant select on public.wallet_cards_with_balance to service_role;
