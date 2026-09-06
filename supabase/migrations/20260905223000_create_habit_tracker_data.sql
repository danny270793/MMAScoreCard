create table if not exists public.habit_tracker_data (
  "userId" uuid primary key references auth.users(id) on delete cascade,
  habits jsonb not null default '[]'::jsonb
    check (jsonb_typeof(habits) = 'array'),
  version integer not null default 1 check (version > 0),
  "createdAt" timestamptz not null default now(),
  "updatedAt" timestamptz not null default now()
);

alter table public.habit_tracker_data enable row level security;
alter table public.habit_tracker_data force row level security;

revoke all on table public.habit_tracker_data from anon;
revoke all on table public.habit_tracker_data from public;
grant select, insert, update, delete on table public.habit_tracker_data
  to authenticated;

create policy "Users can select their own habit data"
  on public.habit_tracker_data
  for select
  to authenticated
  using ((select auth.uid()) = "userId");

create policy "Users can insert their own habit data"
  on public.habit_tracker_data
  for insert
  to authenticated
  with check ((select auth.uid()) = "userId");

create policy "Users can update their own habit data"
  on public.habit_tracker_data
  for update
  to authenticated
  using ((select auth.uid()) = "userId")
  with check ((select auth.uid()) = "userId");

create policy "Users can delete their own habit data"
  on public.habit_tracker_data
  for delete
  to authenticated
  using ((select auth.uid()) = "userId");
