-- Tighten billing days to 1–30 (not 31). Safe for DBs created with 1–31 checks.
-- Runs after 20260504100000 (already applied); do not edit that migration.
update public.wallet_cards
  set "cutDay" = 30
  where "cutDay" > 30;
update public.wallet_cards
  set "payDay" = 30
  where "payDay" > 30;

alter table public.wallet_cards drop constraint if exists wallet_cards_cut_day_range;
alter table public.wallet_cards drop constraint if exists wallet_cards_pay_day_range;

alter table public.wallet_cards
  add constraint wallet_cards_cut_day_range check ("cutDay" between 1 and 30),
  add constraint wallet_cards_pay_day_range check ("payDay" between 1 and 30);
