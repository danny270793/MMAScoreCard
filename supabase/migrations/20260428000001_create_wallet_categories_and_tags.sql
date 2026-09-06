create table public.wallet_categories (
  id          uuid primary key default gen_random_uuid(),
  "userId"    uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  description text,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now(),
  "deletedAt" timestamptz
);

create trigger wallet_categories_set_updated_at
  before update on public.wallet_categories
  for each row execute function public.set_updated_at();

create index wallet_categories_user_id_idx on public.wallet_categories ("userId");
create index wallet_categories_deleted_at_idx on public.wallet_categories ("deletedAt");

alter table public.wallet_categories enable row level security;

create policy "users can select own categories"
  on public.wallet_categories for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own categories"
  on public.wallet_categories for insert
  with check (auth.uid() = "userId");

create policy "users can update own categories"
  on public.wallet_categories for update
  using (auth.uid() = "userId");

create table public.wallet_tags (
  id          uuid primary key default gen_random_uuid(),
  "userId"    uuid not null references auth.users(id) on delete cascade,
  name        text not null,
  description text,
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now(),
  "deletedAt" timestamptz
);

create trigger wallet_tags_set_updated_at
  before update on public.wallet_tags
  for each row execute function public.set_updated_at();

create index wallet_tags_user_id_idx on public.wallet_tags ("userId");
create index wallet_tags_deleted_at_idx on public.wallet_tags ("deletedAt");

alter table public.wallet_tags enable row level security;

create policy "users can select own tags"
  on public.wallet_tags for select
  using (auth.uid() = "userId" and "deletedAt" is null);

create policy "users can insert own tags"
  on public.wallet_tags for insert
  with check (auth.uid() = "userId");

create policy "users can update own tags"
  on public.wallet_tags for update
  using (auth.uid() = "userId");
