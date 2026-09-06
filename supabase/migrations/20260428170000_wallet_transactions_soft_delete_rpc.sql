-- Soft-delete via SECURITY DEFINER so it succeeds even when UPDATE RLS policies
-- (e.g. WITH CHECK on deletedAt) block direct client updates.

create or replace function public.soft_delete_wallet_transaction(p_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  n int;
begin
  update public.wallet_transactions
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$$;

revoke all on function public.soft_delete_wallet_transaction(uuid) from public;
grant execute on function public.soft_delete_wallet_transaction(uuid) to authenticated;
