-- Soft-delete RPCs for wallet_accounts / wallet_cards / wallet_categories / wallet_tags.
-- Same rationale as soft_delete_wallet_transaction: bypasses UPDATE RLS edge cases.

create or replace function public.soft_delete_wallet_account(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  update public.wallet_accounts
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

create or replace function public.soft_delete_wallet_card(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  update public.wallet_cards
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

create or replace function public.soft_delete_wallet_category(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  update public.wallet_categories
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

create or replace function public.soft_delete_wallet_tag(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  update public.wallet_tags
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

revoke all on function public.soft_delete_wallet_account(uuid) from public;
grant execute on function public.soft_delete_wallet_account(uuid) to authenticated;

revoke all on function public.soft_delete_wallet_card(uuid) from public;
grant execute on function public.soft_delete_wallet_card(uuid) to authenticated;

revoke all on function public.soft_delete_wallet_category(uuid) from public;
grant execute on function public.soft_delete_wallet_category(uuid) to authenticated;

revoke all on function public.soft_delete_wallet_tag(uuid) from public;
grant execute on function public.soft_delete_wallet_tag(uuid) to authenticated;
