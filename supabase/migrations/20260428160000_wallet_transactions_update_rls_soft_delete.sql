-- Soft-delete sets "deletedAt"; some Postgres/RLS setups need an explicit WITH CHECK
-- so the updated row (still owned by the same user) is allowed.
drop policy if exists "users can update own transactions" on public.wallet_transactions;

create policy "users can update own transactions"
  on public.wallet_transactions
  for update
  using (auth.uid() = "userId")
  with check (auth.uid() = "userId");
