select 'fights' as table, count(1) as quantity from public.fights
union all
select 'referees' as table, count(1) as quantity from public.referees
union all
select 'categories' as table, count(1) as quantity from public.categories
union all
select 'fighters' as table, count(1) as quantity from public.fighters
union all
select 'events' as table, count(1) as quantity from public.events
union all
select 'locations' as table, count(1) as quantity from public.locations
union all
select 'cities' as table, count(1) as quantity from public.cities
union all
select 'countries' as table, count(1) as quantity from public.countries;