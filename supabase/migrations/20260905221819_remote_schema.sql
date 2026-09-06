drop extension if exists "pg_net";


  create table "public"."health_folder_shares" (
    "id" uuid not null default gen_random_uuid(),
    "folderId" uuid not null,
    "sharedByUserId" uuid not null,
    "email" text not null,
    "createdAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone
      );


alter table "public"."health_folder_shares" enable row level security;


  create table "public"."health_folders" (
    "id" uuid not null default gen_random_uuid(),
    "userId" uuid not null,
    "name" text not null,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone
      );


alter table "public"."health_folders" enable row level security;


  create table "public"."health_pills" (
    "id" uuid not null default gen_random_uuid(),
    "userId" uuid not null,
    "folderId" uuid not null,
    "name" text not null,
    "details" text not null default ''::text,
    "photoBase64" text,
    "quantity" integer not null default 1,
    "price" double precision not null default 0,
    "createdAt" timestamp with time zone not null default now(),
    "updatedAt" timestamp with time zone not null default now(),
    "deletedAt" timestamp with time zone
      );


alter table "public"."health_pills" enable row level security;

CREATE INDEX health_folder_shares_deleted_at_idx ON public.health_folder_shares USING btree ("deletedAt");

CREATE INDEX health_folder_shares_email_idx ON public.health_folder_shares USING btree (lower(email));

CREATE UNIQUE INDEX "health_folder_shares_folderId_email_key" ON public.health_folder_shares USING btree ("folderId", email);

CREATE INDEX health_folder_shares_folder_id_idx ON public.health_folder_shares USING btree ("folderId");

CREATE UNIQUE INDEX health_folder_shares_pkey ON public.health_folder_shares USING btree (id);

CREATE INDEX health_folders_deleted_at_idx ON public.health_folders USING btree ("deletedAt");

CREATE UNIQUE INDEX health_folders_pkey ON public.health_folders USING btree (id);

CREATE INDEX health_folders_user_id_idx ON public.health_folders USING btree ("userId");

CREATE INDEX health_pills_deleted_at_idx ON public.health_pills USING btree ("deletedAt");

CREATE INDEX health_pills_folder_id_idx ON public.health_pills USING btree ("folderId");

CREATE UNIQUE INDEX health_pills_pkey ON public.health_pills USING btree (id);

CREATE INDEX health_pills_user_id_idx ON public.health_pills USING btree ("userId");

alter table "public"."health_folder_shares" add constraint "health_folder_shares_pkey" PRIMARY KEY using index "health_folder_shares_pkey";

alter table "public"."health_folders" add constraint "health_folders_pkey" PRIMARY KEY using index "health_folders_pkey";

alter table "public"."health_pills" add constraint "health_pills_pkey" PRIMARY KEY using index "health_pills_pkey";

alter table "public"."health_folder_shares" add constraint "health_folder_shares_folderId_email_key" UNIQUE using index "health_folder_shares_folderId_email_key";

alter table "public"."health_folder_shares" add constraint "health_folder_shares_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES public.health_folders(id) ON DELETE CASCADE not valid;

alter table "public"."health_folder_shares" validate constraint "health_folder_shares_folderId_fkey";

alter table "public"."health_folder_shares" add constraint "health_folder_shares_sharedByUserId_fkey" FOREIGN KEY ("sharedByUserId") REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."health_folder_shares" validate constraint "health_folder_shares_sharedByUserId_fkey";

alter table "public"."health_folders" add constraint "health_folders_userId_fkey" FOREIGN KEY ("userId") REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."health_folders" validate constraint "health_folders_userId_fkey";

alter table "public"."health_pills" add constraint "health_pills_folderId_fkey" FOREIGN KEY ("folderId") REFERENCES public.health_folders(id) ON DELETE CASCADE not valid;

alter table "public"."health_pills" validate constraint "health_pills_folderId_fkey";

alter table "public"."health_pills" add constraint "health_pills_userId_fkey" FOREIGN KEY ("userId") REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."health_pills" validate constraint "health_pills_userId_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.has_health_folder_access(p_folder_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select exists (
    select 1
    from public.health_folders f
    where f.id = p_folder_id
      and f."deletedAt" is null
      and (
        f."userId" = auth.uid()
        or exists (
          select 1
          from public.health_folder_shares s
          where s."folderId" = f.id
            and s."deletedAt" is null
            and lower(s.email) = lower(coalesce(auth.jwt() ->> 'email', ''))
        )
      )
  );
$function$
;

CREATE OR REPLACE FUNCTION public.rls_auto_enable()
 RETURNS event_trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'pg_catalog'
AS $function$
DECLARE
  cmd record;
BEGIN
  FOR cmd IN
    SELECT *
    FROM pg_event_trigger_ddl_commands()
    WHERE command_tag IN ('CREATE TABLE', 'CREATE TABLE AS', 'SELECT INTO')
      AND object_type IN ('table','partitioned table')
  LOOP
     IF cmd.schema_name IS NOT NULL AND cmd.schema_name IN ('public') AND cmd.schema_name NOT IN ('pg_catalog','information_schema') AND cmd.schema_name NOT LIKE 'pg_toast%' AND cmd.schema_name NOT LIKE 'pg_temp%' THEN
      BEGIN
        EXECUTE format('alter table if exists %s enable row level security', cmd.object_identity);
        RAISE LOG 'rls_auto_enable: enabled RLS on %', cmd.object_identity;
      EXCEPTION
        WHEN OTHERS THEN
          RAISE LOG 'rls_auto_enable: failed to enable RLS on %', cmd.object_identity;
      END;
     ELSE
        RAISE LOG 'rls_auto_enable: skip % (either system schema or not in enforced list: %.)', cmd.object_identity, cmd.schema_name;
     END IF;
  END LOOP;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.share_health_folder(p_folder_id uuid, p_email text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  v_is_owner boolean;
begin
  select exists (
    select 1 from public.health_folders
    where id = p_folder_id and "userId" = auth.uid() and "deletedAt" is null
  ) into v_is_owner;

  if not v_is_owner then
    return false;
  end if;

  insert into public.health_folder_shares ("folderId", "sharedByUserId", email)
  values (p_folder_id, auth.uid(), lower(trim(p_email)))
  on conflict ("folderId", email)
  do update set "deletedAt" = null, "createdAt" = now();

  return true;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.soft_delete_health_folder(p_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  n int;
begin
  update public.health_folders
  set "deletedAt" = now()
  where id = p_id
    and "userId" = auth.uid()
    and "deletedAt" is null;
  get diagnostics n = row_count;

  if n > 0 then
    update public.health_pills
    set "deletedAt" = now()
    where "folderId" = p_id
      and "deletedAt" is null;
  end if;

  return n > 0;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.soft_delete_health_pill(p_id uuid)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  n int;
  v_folder_id uuid;
begin
  select "folderId" into v_folder_id
  from public.health_pills
  where id = p_id and "deletedAt" is null;

  if v_folder_id is null or not public.has_health_folder_access(v_folder_id) then
    return false;
  end if;

  update public.health_pills
  set "deletedAt" = now()
  where id = p_id
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.unshare_health_folder(p_folder_id uuid, p_email text)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare
  n int;
  v_is_owner boolean;
begin
  select exists (
    select 1 from public.health_folders
    where id = p_folder_id and "userId" = auth.uid() and "deletedAt" is null
  ) into v_is_owner;

  if not v_is_owner then
    return false;
  end if;

  update public.health_folder_shares
  set "deletedAt" = now()
  where "folderId" = p_folder_id
    and lower(email) = lower(trim(p_email))
    and "deletedAt" is null;
  get diagnostics n = row_count;
  return n > 0;
end;
$function$
;

grant delete on table "public"."health_folder_shares" to "anon";

grant insert on table "public"."health_folder_shares" to "anon";

grant references on table "public"."health_folder_shares" to "anon";

grant select on table "public"."health_folder_shares" to "anon";

grant trigger on table "public"."health_folder_shares" to "anon";

grant truncate on table "public"."health_folder_shares" to "anon";

grant update on table "public"."health_folder_shares" to "anon";

grant delete on table "public"."health_folder_shares" to "authenticated";

grant insert on table "public"."health_folder_shares" to "authenticated";

grant references on table "public"."health_folder_shares" to "authenticated";

grant select on table "public"."health_folder_shares" to "authenticated";

grant trigger on table "public"."health_folder_shares" to "authenticated";

grant truncate on table "public"."health_folder_shares" to "authenticated";

grant update on table "public"."health_folder_shares" to "authenticated";

grant delete on table "public"."health_folder_shares" to "service_role";

grant insert on table "public"."health_folder_shares" to "service_role";

grant references on table "public"."health_folder_shares" to "service_role";

grant select on table "public"."health_folder_shares" to "service_role";

grant trigger on table "public"."health_folder_shares" to "service_role";

grant truncate on table "public"."health_folder_shares" to "service_role";

grant update on table "public"."health_folder_shares" to "service_role";

grant delete on table "public"."health_folders" to "anon";

grant insert on table "public"."health_folders" to "anon";

grant references on table "public"."health_folders" to "anon";

grant select on table "public"."health_folders" to "anon";

grant trigger on table "public"."health_folders" to "anon";

grant truncate on table "public"."health_folders" to "anon";

grant update on table "public"."health_folders" to "anon";

grant delete on table "public"."health_folders" to "authenticated";

grant insert on table "public"."health_folders" to "authenticated";

grant references on table "public"."health_folders" to "authenticated";

grant select on table "public"."health_folders" to "authenticated";

grant trigger on table "public"."health_folders" to "authenticated";

grant truncate on table "public"."health_folders" to "authenticated";

grant update on table "public"."health_folders" to "authenticated";

grant delete on table "public"."health_folders" to "service_role";

grant insert on table "public"."health_folders" to "service_role";

grant references on table "public"."health_folders" to "service_role";

grant select on table "public"."health_folders" to "service_role";

grant trigger on table "public"."health_folders" to "service_role";

grant truncate on table "public"."health_folders" to "service_role";

grant update on table "public"."health_folders" to "service_role";

grant delete on table "public"."health_pills" to "anon";

grant insert on table "public"."health_pills" to "anon";

grant references on table "public"."health_pills" to "anon";

grant select on table "public"."health_pills" to "anon";

grant trigger on table "public"."health_pills" to "anon";

grant truncate on table "public"."health_pills" to "anon";

grant update on table "public"."health_pills" to "anon";

grant delete on table "public"."health_pills" to "authenticated";

grant insert on table "public"."health_pills" to "authenticated";

grant references on table "public"."health_pills" to "authenticated";

grant select on table "public"."health_pills" to "authenticated";

grant trigger on table "public"."health_pills" to "authenticated";

grant truncate on table "public"."health_pills" to "authenticated";

grant update on table "public"."health_pills" to "authenticated";

grant delete on table "public"."health_pills" to "service_role";

grant insert on table "public"."health_pills" to "service_role";

grant references on table "public"."health_pills" to "service_role";

grant select on table "public"."health_pills" to "service_role";

grant trigger on table "public"."health_pills" to "service_role";

grant truncate on table "public"."health_pills" to "service_role";

grant update on table "public"."health_pills" to "service_role";


  create policy "folder owner can create shares"
  on "public"."health_folder_shares"
  as permissive
  for insert
  to public
with check ((("sharedByUserId" = auth.uid()) AND (EXISTS ( SELECT 1
   FROM public.health_folders f
  WHERE ((f.id = health_folder_shares."folderId") AND (f."userId" = auth.uid()))))));



  create policy "folder owner can update shares"
  on "public"."health_folder_shares"
  as permissive
  for update
  to public
using ((EXISTS ( SELECT 1
   FROM public.health_folders f
  WHERE ((f.id = health_folder_shares."folderId") AND (f."userId" = auth.uid())))))
with check ((EXISTS ( SELECT 1
   FROM public.health_folders f
  WHERE ((f.id = health_folder_shares."folderId") AND (f."userId" = auth.uid())))));



  create policy "folder owner can view shares"
  on "public"."health_folder_shares"
  as permissive
  for select
  to public
using ((EXISTS ( SELECT 1
   FROM public.health_folders f
  WHERE ((f.id = health_folder_shares."folderId") AND (f."userId" = auth.uid())))));



  create policy "users can insert own folders"
  on "public"."health_folders"
  as permissive
  for insert
  to public
with check ((auth.uid() = "userId"));



  create policy "users can select accessible folders"
  on "public"."health_folders"
  as permissive
  for select
  to public
using (public.has_health_folder_access(id));



  create policy "users can update own folders"
  on "public"."health_folders"
  as permissive
  for update
  to public
using ((auth.uid() = "userId"))
with check ((auth.uid() = "userId"));



  create policy "users can insert pills into accessible folders"
  on "public"."health_pills"
  as permissive
  for insert
  to public
with check ((public.has_health_folder_access("folderId") AND ("userId" = auth.uid())));



  create policy "users can select accessible pills"
  on "public"."health_pills"
  as permissive
  for select
  to public
using ((public.has_health_folder_access("folderId") AND ("deletedAt" IS NULL)));



  create policy "users can update pills in accessible folders"
  on "public"."health_pills"
  as permissive
  for update
  to public
using (public.has_health_folder_access("folderId"))
with check (public.has_health_folder_access("folderId"));


CREATE TRIGGER health_folders_set_updated_at BEFORE UPDATE ON public.health_folders FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER health_pills_set_updated_at BEFORE UPDATE ON public.health_pills FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();


