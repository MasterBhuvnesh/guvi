drop extension if exists "pg_net";

create type "public"."health_status" as enum ('healthy', 'wilting', 'diseased', 'recovering');

create type "public"."log_severity" as enum ('info', 'warning', 'error');

create type "public"."user_role" as enum ('admin', 'observer');


  create table "public"."daily_logs" (
    "id" uuid not null default gen_random_uuid(),
    "device_id" uuid not null,
    "log_date" date not null,
    "reading_count" integer not null default 0,
    "avg_temperature" double precision,
    "avg_humidity" double precision,
    "min_temperature" double precision,
    "max_temperature" double precision,
    "min_humidity" double precision,
    "max_humidity" double precision,
    "pump_activated" boolean not null default false,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."daily_logs" enable row level security;


  create table "public"."devices" (
    "id" uuid not null default gen_random_uuid(),
    "name" text not null,
    "location" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."devices" enable row level security;


  create table "public"."plant_growth_logs" (
    "id" uuid not null default gen_random_uuid(),
    "plant_id" uuid not null,
    "daily_log_id" uuid not null,
    "recorded_by" uuid not null,
    "height_cm" double precision,
    "health_status" public.health_status not null,
    "observations" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."plant_growth_logs" enable row level security;


  create table "public"."plant_photos" (
    "id" uuid not null default gen_random_uuid(),
    "plant_id" uuid not null,
    "daily_log_id" uuid not null,
    "taken_by" uuid not null,
    "photo_date" date not null,
    "image_url" text not null,
    "uploaded_at" timestamp with time zone not null default now(),
    "notes" text
      );


alter table "public"."plant_photos" enable row level security;


  create table "public"."plants" (
    "id" uuid not null default gen_random_uuid(),
    "device_id" uuid not null,
    "name" text not null,
    "species" text,
    "is_active" boolean not null default true,
    "planted_at" date,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."plants" enable row level security;


  create table "public"."profiles" (
    "id" uuid not null,
    "name" text not null,
    "email" text not null,
    "role" public.user_role not null default 'observer'::public.user_role,
    "image_url" text,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."profiles" enable row level security;


  create table "public"."sensor_readings" (
    "id" uuid not null default gen_random_uuid(),
    "daily_log_id" uuid not null,
    "temperature" double precision,
    "humidity" double precision,
    "soil_moisture_s1" integer,
    "soil_moisture_s2" integer,
    "soil_moisture_s3" integer,
    "pump_status" boolean,
    "device_status" text,
    "recorded_at" timestamp with time zone not null default now()
      );


alter table "public"."sensor_readings" enable row level security;


  create table "public"."system_logs" (
    "id" uuid not null default gen_random_uuid(),
    "device_id" uuid not null,
    "log_type" text not null,
    "message" text not null,
    "severity" public.log_severity not null default 'info'::public.log_severity,
    "occurred_at" timestamp with time zone not null default now()
      );


alter table "public"."system_logs" enable row level security;

CREATE UNIQUE INDEX daily_logs_device_id_log_date_key ON public.daily_logs USING btree (device_id, log_date);

CREATE UNIQUE INDEX daily_logs_pkey ON public.daily_logs USING btree (id);

CREATE UNIQUE INDEX devices_pkey ON public.devices USING btree (id);

CREATE INDEX idx_daily_logs_device_id ON public.daily_logs USING btree (device_id);

CREATE INDEX idx_daily_logs_log_date ON public.daily_logs USING btree (log_date);

CREATE INDEX idx_growth_logs_daily_log_id ON public.plant_growth_logs USING btree (daily_log_id);

CREATE INDEX idx_growth_logs_plant_id ON public.plant_growth_logs USING btree (plant_id);

CREATE INDEX idx_plant_photos_daily_log_id ON public.plant_photos USING btree (daily_log_id);

CREATE INDEX idx_plant_photos_plant_id ON public.plant_photos USING btree (plant_id);

CREATE INDEX idx_plants_device_id ON public.plants USING btree (device_id);

CREATE INDEX idx_sensor_readings_daily_log_id ON public.sensor_readings USING btree (daily_log_id);

CREATE INDEX idx_sensor_readings_recorded_at ON public.sensor_readings USING btree (recorded_at);

CREATE INDEX idx_system_logs_device_id ON public.system_logs USING btree (device_id);

CREATE UNIQUE INDEX plant_growth_logs_pkey ON public.plant_growth_logs USING btree (id);

CREATE UNIQUE INDEX plant_photos_pkey ON public.plant_photos USING btree (id);

CREATE UNIQUE INDEX plants_pkey ON public.plants USING btree (id);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX sensor_readings_pkey ON public.sensor_readings USING btree (id);

CREATE UNIQUE INDEX system_logs_pkey ON public.system_logs USING btree (id);

alter table "public"."daily_logs" add constraint "daily_logs_pkey" PRIMARY KEY using index "daily_logs_pkey";

alter table "public"."devices" add constraint "devices_pkey" PRIMARY KEY using index "devices_pkey";

alter table "public"."plant_growth_logs" add constraint "plant_growth_logs_pkey" PRIMARY KEY using index "plant_growth_logs_pkey";

alter table "public"."plant_photos" add constraint "plant_photos_pkey" PRIMARY KEY using index "plant_photos_pkey";

alter table "public"."plants" add constraint "plants_pkey" PRIMARY KEY using index "plants_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."sensor_readings" add constraint "sensor_readings_pkey" PRIMARY KEY using index "sensor_readings_pkey";

alter table "public"."system_logs" add constraint "system_logs_pkey" PRIMARY KEY using index "system_logs_pkey";

alter table "public"."daily_logs" add constraint "daily_logs_device_id_fkey" FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE CASCADE not valid;

alter table "public"."daily_logs" validate constraint "daily_logs_device_id_fkey";

alter table "public"."daily_logs" add constraint "daily_logs_device_id_log_date_key" UNIQUE using index "daily_logs_device_id_log_date_key";

alter table "public"."plant_growth_logs" add constraint "plant_growth_logs_daily_log_id_fkey" FOREIGN KEY (daily_log_id) REFERENCES public.daily_logs(id) ON DELETE CASCADE not valid;

alter table "public"."plant_growth_logs" validate constraint "plant_growth_logs_daily_log_id_fkey";

alter table "public"."plant_growth_logs" add constraint "plant_growth_logs_plant_id_fkey" FOREIGN KEY (plant_id) REFERENCES public.plants(id) ON DELETE CASCADE not valid;

alter table "public"."plant_growth_logs" validate constraint "plant_growth_logs_plant_id_fkey";

alter table "public"."plant_growth_logs" add constraint "plant_growth_logs_recorded_by_fkey" FOREIGN KEY (recorded_by) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."plant_growth_logs" validate constraint "plant_growth_logs_recorded_by_fkey";

alter table "public"."plant_photos" add constraint "plant_photos_daily_log_id_fkey" FOREIGN KEY (daily_log_id) REFERENCES public.daily_logs(id) ON DELETE CASCADE not valid;

alter table "public"."plant_photos" validate constraint "plant_photos_daily_log_id_fkey";

alter table "public"."plant_photos" add constraint "plant_photos_plant_id_fkey" FOREIGN KEY (plant_id) REFERENCES public.plants(id) ON DELETE CASCADE not valid;

alter table "public"."plant_photos" validate constraint "plant_photos_plant_id_fkey";

alter table "public"."plant_photos" add constraint "plant_photos_taken_by_fkey" FOREIGN KEY (taken_by) REFERENCES public.profiles(id) ON DELETE RESTRICT not valid;

alter table "public"."plant_photos" validate constraint "plant_photos_taken_by_fkey";

alter table "public"."plants" add constraint "plants_device_id_fkey" FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE CASCADE not valid;

alter table "public"."plants" validate constraint "plants_device_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."sensor_readings" add constraint "sensor_readings_daily_log_id_fkey" FOREIGN KEY (daily_log_id) REFERENCES public.daily_logs(id) ON DELETE CASCADE not valid;

alter table "public"."sensor_readings" validate constraint "sensor_readings_daily_log_id_fkey";

alter table "public"."system_logs" add constraint "system_logs_device_id_fkey" FOREIGN KEY (device_id) REFERENCES public.devices(id) ON DELETE CASCADE not valid;

alter table "public"."system_logs" validate constraint "system_logs_device_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.handle_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
begin
  new.updated_at = now();
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
AS $function$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$function$
;

grant references on table "public"."daily_logs" to "anon";

grant trigger on table "public"."daily_logs" to "anon";

grant truncate on table "public"."daily_logs" to "anon";

grant references on table "public"."daily_logs" to "authenticated";

grant trigger on table "public"."daily_logs" to "authenticated";

grant truncate on table "public"."daily_logs" to "authenticated";

grant references on table "public"."daily_logs" to "service_role";

grant trigger on table "public"."daily_logs" to "service_role";

grant truncate on table "public"."daily_logs" to "service_role";

grant references on table "public"."devices" to "anon";

grant trigger on table "public"."devices" to "anon";

grant truncate on table "public"."devices" to "anon";

grant references on table "public"."devices" to "authenticated";

grant trigger on table "public"."devices" to "authenticated";

grant truncate on table "public"."devices" to "authenticated";

grant references on table "public"."devices" to "service_role";

grant trigger on table "public"."devices" to "service_role";

grant truncate on table "public"."devices" to "service_role";

grant references on table "public"."plant_growth_logs" to "anon";

grant trigger on table "public"."plant_growth_logs" to "anon";

grant truncate on table "public"."plant_growth_logs" to "anon";

grant references on table "public"."plant_growth_logs" to "authenticated";

grant trigger on table "public"."plant_growth_logs" to "authenticated";

grant truncate on table "public"."plant_growth_logs" to "authenticated";

grant references on table "public"."plant_growth_logs" to "service_role";

grant trigger on table "public"."plant_growth_logs" to "service_role";

grant truncate on table "public"."plant_growth_logs" to "service_role";

grant references on table "public"."plant_photos" to "anon";

grant trigger on table "public"."plant_photos" to "anon";

grant truncate on table "public"."plant_photos" to "anon";

grant references on table "public"."plant_photos" to "authenticated";

grant trigger on table "public"."plant_photos" to "authenticated";

grant truncate on table "public"."plant_photos" to "authenticated";

grant references on table "public"."plant_photos" to "service_role";

grant trigger on table "public"."plant_photos" to "service_role";

grant truncate on table "public"."plant_photos" to "service_role";

grant references on table "public"."plants" to "anon";

grant trigger on table "public"."plants" to "anon";

grant truncate on table "public"."plants" to "anon";

grant references on table "public"."plants" to "authenticated";

grant trigger on table "public"."plants" to "authenticated";

grant truncate on table "public"."plants" to "authenticated";

grant references on table "public"."plants" to "service_role";

grant trigger on table "public"."plants" to "service_role";

grant truncate on table "public"."plants" to "service_role";

grant references on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant references on table "public"."sensor_readings" to "anon";

grant trigger on table "public"."sensor_readings" to "anon";

grant truncate on table "public"."sensor_readings" to "anon";

grant references on table "public"."sensor_readings" to "authenticated";

grant trigger on table "public"."sensor_readings" to "authenticated";

grant truncate on table "public"."sensor_readings" to "authenticated";

grant references on table "public"."sensor_readings" to "service_role";

grant trigger on table "public"."sensor_readings" to "service_role";

grant truncate on table "public"."sensor_readings" to "service_role";

grant references on table "public"."system_logs" to "anon";

grant trigger on table "public"."system_logs" to "anon";

grant truncate on table "public"."system_logs" to "anon";

grant references on table "public"."system_logs" to "authenticated";

grant trigger on table "public"."system_logs" to "authenticated";

grant truncate on table "public"."system_logs" to "authenticated";

grant references on table "public"."system_logs" to "service_role";

grant trigger on table "public"."system_logs" to "service_role";

grant truncate on table "public"."system_logs" to "service_role";


  create policy "daily_logs_read_authenticated"
  on "public"."daily_logs"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "devices_read_authenticated"
  on "public"."devices"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "growth_logs_authenticated_delete"
  on "public"."plant_growth_logs"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "growth_logs_authenticated_insert"
  on "public"."plant_growth_logs"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "growth_logs_authenticated_update"
  on "public"."plant_growth_logs"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "growth_logs_read_authenticated"
  on "public"."plant_growth_logs"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "plant_photos_authenticated_delete"
  on "public"."plant_photos"
  as permissive
  for delete
  to public
using ((auth.uid() IS NOT NULL));



  create policy "plant_photos_authenticated_insert"
  on "public"."plant_photos"
  as permissive
  for insert
  to public
with check ((auth.uid() IS NOT NULL));



  create policy "plant_photos_authenticated_update"
  on "public"."plant_photos"
  as permissive
  for update
  to public
using ((auth.uid() IS NOT NULL));



  create policy "plant_photos_read_authenticated"
  on "public"."plant_photos"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "plants_admin_delete"
  on "public"."plants"
  as permissive
  for delete
  to public
using (public.is_admin());



  create policy "plants_admin_insert"
  on "public"."plants"
  as permissive
  for insert
  to public
with check (public.is_admin());



  create policy "plants_admin_update"
  on "public"."plants"
  as permissive
  for update
  to public
using (public.is_admin());



  create policy "plants_read_authenticated"
  on "public"."plants"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "profiles_read_authenticated"
  on "public"."profiles"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "profiles_update_own"
  on "public"."profiles"
  as permissive
  for update
  to public
using ((id = auth.uid()))
with check ((id = auth.uid()));



  create policy "sensor_readings_read_authenticated"
  on "public"."sensor_readings"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));



  create policy "system_logs_read_authenticated"
  on "public"."system_logs"
  as permissive
  for select
  to public
using ((auth.uid() IS NOT NULL));


CREATE TRIGGER daily_logs_updated_at BEFORE UPDATE ON public.daily_logs FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER plants_updated_at BEFORE UPDATE ON public.plants FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();


  create policy "plant_photos_delete"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'plant-photos'::text) AND (auth.uid() IS NOT NULL)));



  create policy "plant_photos_insert"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'plant-photos'::text) AND (auth.uid() IS NOT NULL)));



  create policy "plant_photos_read"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'plant-photos'::text));



  create policy "plant_photos_update"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'plant-photos'::text) AND (auth.uid() IS NOT NULL)));



  create policy "profile_images_delete"
  on "storage"."objects"
  as permissive
  for delete
  to public
using (((bucket_id = 'profiles'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



  create policy "profile_images_read"
  on "storage"."objects"
  as permissive
  for select
  to public
using ((bucket_id = 'profiles'::text));



  create policy "profile_images_update"
  on "storage"."objects"
  as permissive
  for update
  to public
using (((bucket_id = 'profiles'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



  create policy "profile_images_upload"
  on "storage"."objects"
  as permissive
  for insert
  to public
with check (((bucket_id = 'profiles'::text) AND ((auth.uid())::text = (storage.foldername(name))[1])));



