-- =====================================================
-- ENUMS
-- =====================================================

create type user_role as enum (
  'admin',
  'observer'
);

create type health_status as enum (
  'healthy',
  'wilting',
  'diseased',
  'recovering'
);

create type log_severity as enum (
  'info',
  'warning',
  'error'
);

-- =====================================================
-- UPDATED_AT TRIGGER
-- =====================================================

create or replace function public.handle_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =====================================================
-- PROFILES
-- =====================================================

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,

  name text not null,
  email text not null,

  role user_role not null default 'observer',

  image_url text,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger profiles_updated_at
before update on public.profiles
for each row
execute function public.handle_updated_at();

-- =====================================================
-- DEVICES
-- =====================================================

create table public.devices (
  id uuid primary key default gen_random_uuid(),

  name text not null,
  location text,

  created_at timestamptz not null default now()
);

-- =====================================================
-- PLANTS
-- =====================================================

create table public.plants (
  id uuid primary key default gen_random_uuid(),

  device_id uuid not null
    references public.devices(id)
    on delete cascade,

  name text not null,
  species text,

  is_active boolean not null default true,

  planted_at date,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger plants_updated_at
before update on public.plants
for each row
execute function public.handle_updated_at();

-- =====================================================
-- DAILY LOGS
-- =====================================================

create table public.daily_logs (
  id uuid primary key default gen_random_uuid(),

  device_id uuid not null
    references public.devices(id)
    on delete cascade,

  log_date date not null,

  reading_count integer not null default 0,

  avg_temperature double precision,
  avg_humidity double precision,

  min_temperature double precision,
  max_temperature double precision,

  min_humidity double precision,
  max_humidity double precision,

  pump_activated boolean not null default false,

  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),

  unique(device_id, log_date)
);

create trigger daily_logs_updated_at
before update on public.daily_logs
for each row
execute function public.handle_updated_at();

-- =====================================================
-- SENSOR READINGS
-- =====================================================

create table public.sensor_readings (
  id uuid primary key default gen_random_uuid(),

  daily_log_id uuid not null
    references public.daily_logs(id)
    on delete cascade,

  temperature double precision,
  humidity double precision,

  soil_moisture_s1 integer,
  soil_moisture_s2 integer,
  soil_moisture_s3 integer,

  pump_status boolean,

  device_status text,

  recorded_at timestamptz not null default now()
);

-- =====================================================
-- PLANT PHOTOS
-- =====================================================

create table public.plant_photos (
  id uuid primary key default gen_random_uuid(),

  plant_id uuid not null
    references public.plants(id)
    on delete cascade,

  daily_log_id uuid not null
    references public.daily_logs(id)
    on delete cascade,

  taken_by uuid not null
    references public.profiles(id)
    on delete restrict,

  photo_date date not null,

  image_url text not null,

  uploaded_at timestamptz not null default now(),

  notes text
);

-- =====================================================
-- PLANT GROWTH LOGS
-- =====================================================

create table public.plant_growth_logs (
  id uuid primary key default gen_random_uuid(),

  plant_id uuid not null
    references public.plants(id)
    on delete cascade,

  daily_log_id uuid not null
    references public.daily_logs(id)
    on delete cascade,

  recorded_by uuid not null
    references public.profiles(id)
    on delete restrict,

  height_cm double precision,

  health_status health_status not null,

  observations text,

  created_at timestamptz not null default now()
);

-- =====================================================
-- SYSTEM LOGS
-- =====================================================

create table public.system_logs (
  id uuid primary key default gen_random_uuid(),

  device_id uuid not null
    references public.devices(id)
    on delete cascade,

  log_type text not null,

  message text not null,

  severity log_severity not null default 'info',

  occurred_at timestamptz not null default now()
);

-- =====================================================
-- INDEXES
-- =====================================================

create index idx_plants_device_id
on public.plants(device_id);

create index idx_daily_logs_device_id
on public.daily_logs(device_id);

create index idx_daily_logs_log_date
on public.daily_logs(log_date);

create index idx_sensor_readings_daily_log_id
on public.sensor_readings(daily_log_id);

create index idx_sensor_readings_recorded_at
on public.sensor_readings(recorded_at);

create index idx_plant_photos_plant_id
on public.plant_photos(plant_id);

create index idx_plant_photos_daily_log_id
on public.plant_photos(daily_log_id);

create index idx_growth_logs_plant_id
on public.plant_growth_logs(plant_id);

create index idx_growth_logs_daily_log_id
on public.plant_growth_logs(daily_log_id);

create index idx_system_logs_device_id
on public.system_logs(device_id);

-- =====================================================
-- HELPER FUNCTION
-- =====================================================

create or replace function public.is_admin()
returns boolean
language sql
stable
security definer
as $$
  select exists (
    select 1
    from public.profiles
    where id = auth.uid()
      and role = 'admin'
  );
$$;

-- =====================================================
-- RLS ENABLE
-- =====================================================

alter table public.profiles enable row level security;
alter table public.devices enable row level security;
alter table public.plants enable row level security;
alter table public.daily_logs enable row level security;
alter table public.sensor_readings enable row level security;
alter table public.plant_photos enable row level security;
alter table public.plant_growth_logs enable row level security;
alter table public.system_logs enable row level security;

-- =====================================================
-- PROFILES
-- =====================================================

create policy "profiles_read_authenticated"
on public.profiles
for select
using (auth.uid() is not null);

create policy "profiles_update_own"
on public.profiles
for update
using (id = auth.uid())
with check (id = auth.uid());

-- =====================================================
-- DEVICES
-- =====================================================

create policy "devices_read_authenticated"
on public.devices
for select
using (auth.uid() is not null);

-- =====================================================
-- PLANTS
-- =====================================================

create policy "plants_read_authenticated"
on public.plants
for select
using (auth.uid() is not null);

create policy "plants_admin_insert"
on public.plants
for insert
with check (public.is_admin());

create policy "plants_admin_update"
on public.plants
for update
using (public.is_admin());

create policy "plants_admin_delete"
on public.plants
for delete
using (public.is_admin());

-- =====================================================
-- DAILY LOGS
-- =====================================================

create policy "daily_logs_read_authenticated"
on public.daily_logs
for select
using (auth.uid() is not null);

-- =====================================================
-- SENSOR READINGS
-- =====================================================

create policy "sensor_readings_read_authenticated"
on public.sensor_readings
for select
using (auth.uid() is not null);

-- =====================================================
-- PLANT PHOTOS
-- =====================================================

create policy "plant_photos_read_authenticated"
on public.plant_photos
for select
using (auth.uid() is not null);

create policy "plant_photos_authenticated_insert"
on public.plant_photos
for insert
with check (auth.uid() is not null);

create policy "plant_photos_authenticated_update"
on public.plant_photos
for update
using (auth.uid() is not null);

create policy "plant_photos_authenticated_delete"
on public.plant_photos
for delete
using (auth.uid() is not null);

-- =====================================================
-- PLANT GROWTH LOGS
-- =====================================================

create policy "growth_logs_read_authenticated"
on public.plant_growth_logs
for select
using (auth.uid() is not null);

create policy "growth_logs_authenticated_insert"
on public.plant_growth_logs
for insert
with check (auth.uid() is not null);

create policy "growth_logs_authenticated_update"
on public.plant_growth_logs
for update
using (auth.uid() is not null);

create policy "growth_logs_authenticated_delete"
on public.plant_growth_logs
for delete
using (auth.uid() is not null);

-- =====================================================
-- SYSTEM LOGS
-- =====================================================

create policy "system_logs_read_authenticated"
on public.system_logs
for select
using (auth.uid() is not null);

-- =====================================================
-- PROFILE BUCKET POLICIES
-- =====================================================

create policy "profile_images_read"
on storage.objects
for select
using (bucket_id = 'profiles');

create policy "profile_images_upload"
on storage.objects
for insert
with check (
  bucket_id = 'profiles'
  and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "profile_images_update"
on storage.objects
for update
using (
  bucket_id = 'profiles'
  and auth.uid()::text = (storage.foldername(name))[1]
);

create policy "profile_images_delete"
on storage.objects
for delete
using (
  bucket_id = 'profiles'
  and auth.uid()::text = (storage.foldername(name))[1]
);

-- =====================================================
-- PLANT PHOTOS BUCKET POLICIES
-- =====================================================

create policy "plant_photos_read"
on storage.objects
for select
using (
  bucket_id = 'plant-photos'
);

create policy "plant_photos_insert"
on storage.objects
for insert
with check (
  bucket_id = 'plant-photos'
  and auth.uid() is not null
);

create policy "plant_photos_update"
on storage.objects
for update
using (
  bucket_id = 'plant-photos'
  and auth.uid() is not null
);

create policy "plant_photos_delete"
on storage.objects
for delete
using (
  bucket_id = 'plant-photos'
  and auth.uid() is not null
);