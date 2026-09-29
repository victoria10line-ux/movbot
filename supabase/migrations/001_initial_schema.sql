-- Movbot core schema. Apply through Supabase migrations/SQL editor.
create extension if not exists pgcrypto;
create extension if not exists postgis;

create or replace function public.set_updated_at() returns trigger language plpgsql as $$
begin new.updated_at = now(); return new; end; $$;

create table if not exists public.carriers (
  id uuid primary key default gen_random_uuid(),
  legal_name text not null,
  display_name text not null,
  registration_no text unique,
  phone text,
  email text,
  address text,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid
);

create table if not exists public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  full_name text not null,
  phone text,
  role text not null check (role in ('admin','operations','carrier','driver')),
  carrier_id uuid references public.carriers(id),
  locale text not null default 'ar' check (locale in ('ar','en')),
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.drivers (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid unique references public.profiles(id),
  carrier_id uuid not null references public.carriers(id),
  driver_code text not null,
  full_name text not null,
  phone text,
  national_id text,
  status text not null default 'available' check (status in ('available','assigned','rest','suspended','inactive')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid,
  unique(carrier_id, driver_code),
  unique(carrier_id, national_id)
);

create table if not exists public.vehicles (
  id uuid primary key default gen_random_uuid(),
  carrier_id uuid not null references public.carriers(id),
  vehicle_code text not null,
  plate_number text not null,
  vin text,
  vehicle_type text not null default 'truck',
  trailer_type text not null check (trailer_type in ('curtain','flatbed','sidewall','refrigerated')),
  current_driver_id uuid references public.drivers(id),
  status text not null default 'idle' check (status in ('moving','idle','loading','unloading','fueling','rest','breakdown','offline','delivered')),
  capacity_kg numeric(12,2),
  load_kg numeric(12,2) not null default 0,
  load_percent numeric(5,2) not null default 0 check (load_percent between 0 and 100),
  last_location geography(point,4326),
  last_latitude double precision,
  last_longitude double precision,
  speed_kph numeric(8,2) not null default 0,
  heading_deg numeric(7,2) not null default 0 check (heading_deg >= 0 and heading_deg < 360),
  gps_status text not null default 'offline' check (gps_status in ('online','offline','stale')),
  last_updated_at timestamptz,
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid,
  unique(carrier_id, vehicle_code),
  unique(carrier_id, plate_number),
);

create unique index if not exists ux_vehicles_vin_nonempty on public.vehicles (vin) where vin is not null and vin <> '';

create table if not exists public.loading_locations (
  id uuid primary key default gen_random_uuid(),
  carrier_id uuid references public.carriers(id),
  name text not null,
  address text,
  location geography(point,4326),
  contact_name text,
  contact_phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.delivery_locations (
  id uuid primary key default gen_random_uuid(),
  carrier_id uuid references public.carriers(id),
  name text not null,
  address text,
  location geography(point,4326),
  contact_name text,
  contact_phone text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.cargo (
  id uuid primary key default gen_random_uuid(),
  cargo_type text not null,
  weight_kg numeric(12,2) not null check (weight_kg > 0),
  quantity numeric(12,2),
  pallets integer check (pallets is null or pallets >= 0),
  boxes integer check (boxes is null or boxes >= 0),
  length_cm numeric(10,2), width_cm numeric(10,2), height_cm numeric(10,2),
  special_requirements text,
  tie_down_required boolean not null default false,
  chains_required boolean not null default false,
  belts_required boolean not null default false,
  temperature_min_c numeric(6,2), temperature_max_c numeric(6,2),
  fragile boolean not null default false,
  hazardous boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.trips (
  id uuid primary key default gen_random_uuid(),
  trip_code text not null unique,
  carrier_id uuid not null references public.carriers(id),
  vehicle_id uuid references public.vehicles(id),
  driver_id uuid references public.drivers(id),
  loading_location_id uuid references public.loading_locations(id),
  delivery_location_id uuid references public.delivery_locations(id),
  cargo_id uuid references public.cargo(id),
  origin_name text not null,
  destination_name text not null,
  loading_at timestamptz,
  delivery_due_at timestamptz,
  price numeric(14,2),
  currency text not null default 'SAR',
  requirements text,
  status text not null default 'available' check (status in ('available','booked','active','completed','cancelled')),
  booked_at timestamptz,
  completed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid
);

create table if not exists public.shipments (
  id uuid primary key default gen_random_uuid(),
  shipment_code text not null unique,
  trip_id uuid references public.trips(id),
  carrier_id uuid not null references public.carriers(id),
  cargo_id uuid references public.cargo(id),
  status text not null default 'created' check (status in ('created','booked','loading','in_transit','delivered','cancelled')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  deleted_by uuid
);

create table if not exists public.bookings (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id),
  vehicle_id uuid not null references public.vehicles(id),
  driver_id uuid not null references public.drivers(id),
  booked_by uuid not null references public.profiles(id),
  status text not null default 'confirmed' check (status in ('confirmed','cancelled')),
  created_at timestamptz not null default now(),
  cancelled_at timestamptz,
  unique(trip_id)
);

create table if not exists public.tracking_sessions (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id),
  vehicle_id uuid not null references public.vehicles(id),
  driver_id uuid not null references public.drivers(id),
  started_at timestamptz not null default now(),
  ended_at timestamptz,
  status text not null default 'active' check (status in ('active','ended','paused')),
  unique(trip_id)
);

create table if not exists public.tracking_events (
  id uuid primary key default gen_random_uuid(),
  tracking_session_id uuid not null references public.tracking_sessions(id),
  trip_id uuid not null references public.trips(id),
  vehicle_id uuid not null references public.vehicles(id),
  driver_id uuid not null references public.drivers(id),
  event_type text not null check (event_type in ('trip_started','moving','stopped','rest','fueling','breakdown','off_route','arrived_loading','loading_started','loading_completed','arrived_delivery','unloading_started','delivered','trip_completed')),
  occurred_at timestamptz not null default now(),
  location geography(point,4326),
  latitude double precision,
  longitude double precision,
  speed_kph numeric(8,2),
  heading_deg numeric(7,2),
  payload jsonb not null default '{}'::jsonb,
  client_event_id uuid not null,
  created_at timestamptz not null default now(),
  unique(client_event_id)
);

create table if not exists public.vehicle_events (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id),
  driver_id uuid references public.drivers(id),
  trip_id uuid references public.trips(id),
  event_type text not null,
  severity text not null default 'info' check (severity in ('info','warning','critical')),
  title text not null,
  description text,
  location geography(point,4326),
  latitude double precision,
  longitude double precision,
  media_paths text[] not null default '{}',
  created_at timestamptz not null default now()
);

create table if not exists public.maintenance_records (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id),
  category text not null check (category in ('oil','tires','brakes','engine','cooling','electrical','inspection','general')),
  service_date timestamptz not null,
  next_service_date timestamptz,
  mileage_km numeric(12,2),
  next_mileage_km numeric(12,2),
  notes text,
  cost numeric(14,2),
  currency text not null default 'SAR',
  workshop text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.inspection_records (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id),
  driver_id uuid references public.drivers(id),
  trip_id uuid references public.trips(id),
  inspection_type text not null default 'pre_trip',
  result text not null check (result in ('passed','failed','conditional')),
  checklist jsonb not null default '{}'::jsonb,
  notes text,
  inspected_at timestamptz not null default now(),
  created_at timestamptz not null default now()
);

create table if not exists public.delay_policies (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  threshold_hours numeric(8,2) not null check (threshold_hours >= 0),
  compensation_amount numeric(14,2) not null check (compensation_amount >= 0),
  currency text not null default 'SAR',
  active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.delay_records (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id),
  shipment_id uuid references public.shipments(id),
  vehicle_id uuid not null references public.vehicles(id),
  driver_id uuid not null references public.drivers(id),
  loading_location_id uuid references public.loading_locations(id),
  arrival_at timestamptz not null,
  delay_started_at timestamptz,
  elapsed_hours numeric(10,2) not null default 0,
  compensation_amount numeric(14,2) not null default 0,
  currency text not null default 'SAR',
  status text not null default 'pending' check (status in ('pending','approved','rejected','paid')),
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique(trip_id)
);

create table if not exists public.proofs (
  id uuid primary key default gen_random_uuid(),
  trip_id uuid not null references public.trips(id),
  shipment_id uuid references public.shipments(id),
  vehicle_id uuid not null references public.vehicles(id),
  driver_id uuid not null references public.drivers(id),
  proof_type text not null check (proof_type in ('arrival','delay','delivery','loading','unloading')),
  file_path text not null,
  captured_at timestamptz,
  latitude double precision,
  longitude double precision,
  trip_code_snapshot text not null,
  metadata jsonb not null default '{}'::jsonb,
  notes text,
  created_at timestamptz not null default now()
);

create table if not exists public.vehicle_documents (
  id uuid primary key default gen_random_uuid(),
  vehicle_id uuid not null references public.vehicles(id),
  document_type text not null,
  issue_date date,
  expiry_date date,
  status text not null default 'valid' check (status in ('valid','expiring','expired','pending_verification')),
  file_path text not null,
  verification_status text not null default 'pending' check (verification_status in ('pending','verified','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.driver_documents (
  id uuid primary key default gen_random_uuid(),
  driver_id uuid not null references public.drivers(id),
  document_type text not null,
  issue_date date,
  expiry_date date,
  status text not null default 'valid' check (status in ('valid','expiring','expired','pending_verification')),
  file_path text not null,
  verification_status text not null default 'pending' check (verification_status in ('pending','verified','rejected')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.bills_of_lading (
  id uuid primary key default gen_random_uuid(),
  shipment_id uuid not null references public.shipments(id),
  trip_id uuid not null references public.trips(id),
  document_number text not null unique,
  language text not null default 'ar' check (language in ('ar','en')),
  payload jsonb not null,
  pdf_path text,
  created_by uuid references public.profiles(id),
  created_at timestamptz not null default now()
);

create table if not exists public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles(id),
  type text not null,
  title text not null,
  body text not null,
  data jsonb not null default '{}'::jsonb,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table if not exists public.report_schedules (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles(id),
  report_type text not null,
  frequency text not null check (frequency in ('daily','weekly','monthly')),
  filters jsonb not null default '{}'::jsonb,
  active boolean not null default true,
  next_run_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists public.reports (
  id uuid primary key default gen_random_uuid(),
  report_type text not null,
  requested_by uuid not null references public.profiles(id),
  filters jsonb not null default '{}'::jsonb,
  generated_at timestamptz,
  pdf_path text,
  xlsx_path text,
  status text not null default 'queued' check (status in ('queued','running','completed','failed')),
  error_message text,
  created_at timestamptz not null default now()
);

create table if not exists public.system_settings (
  key text primary key,
  value jsonb not null,
  updated_by uuid references public.profiles(id),
  updated_at timestamptz not null default now()
);

create table if not exists public.audit_logs (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid references public.profiles(id),
  action text not null,
  entity_type text not null,
  entity_id uuid,
  before_data jsonb,
  after_data jsonb,
  ip_address inet,
  user_agent text,
  created_at timestamptz not null default now()
);

-- Updated-at triggers.
do $$ declare t text; begin foreach t in array array['carriers','profiles','drivers','vehicles','loading_locations','delivery_locations','trips','shipments','maintenance_records','delay_policies','delay_records','vehicle_documents','driver_documents','report_schedules'] loop execute format('drop trigger if exists trg_%s_updated_at on public.%s',t,t); execute format('create trigger trg_%s_updated_at before update on public.%s for each row execute function public.set_updated_at()',t,t); end loop; end $$;

create or replace function public.current_role() returns text language sql stable security definer set search_path=public as $$
  select role from public.profiles where id = auth.uid();
$$;

create or replace function public.current_carrier_id() returns uuid language sql stable security definer set search_path=public as $$
  select carrier_id from public.profiles where id = auth.uid();
$$;

create or replace function public.book_trip(p_trip_id uuid, p_vehicle_id uuid, p_driver_id uuid) returns public.bookings
language plpgsql security definer set search_path=public as $$
declare b public.bookings;
begin
  if auth.uid() is null then raise exception 'AUTH_REQUIRED'; end if;
  if not exists (select 1 from public.trips t where t.id=p_trip_id and t.status='available' and t.deleted_at is null) then raise exception 'TRIP_NOT_AVAILABLE'; end if;
  if public.current_role() in ('carrier','driver') and not exists (select 1 from public.trips t where t.id=p_trip_id and t.carrier_id=public.current_carrier_id()) then raise exception 'FORBIDDEN_TRIP'; end if;
  if not exists (select 1 from public.vehicles v where v.id=p_vehicle_id and v.active and v.deleted_at is null) then raise exception 'VEHICLE_NOT_AVAILABLE'; end if;
  if public.current_role() in ('carrier','driver') and not exists (select 1 from public.vehicles v where v.id=p_vehicle_id and v.carrier_id=public.current_carrier_id()) then raise exception 'FORBIDDEN_VEHICLE'; end if;
  if not exists (select 1 from public.drivers d where d.id=p_driver_id and d.status in ('available','rest') and d.deleted_at is null) then raise exception 'DRIVER_NOT_AVAILABLE'; end if;
  if public.current_role() in ('carrier','driver') and not exists (select 1 from public.drivers d where d.id=p_driver_id and d.carrier_id=public.current_carrier_id()) then raise exception 'FORBIDDEN_DRIVER'; end if;
  if exists (select 1 from public.bookings x join public.trips t on t.id=x.trip_id where x.vehicle_id=p_vehicle_id and x.status='confirmed' and t.status in ('booked','active') and coalesce(t.loading_at,now()) <= coalesce((select delivery_due_at from public.trips where id=p_trip_id),now()) and coalesce(t.delivery_due_at,now()) >= coalesce((select loading_at from public.trips where id=p_trip_id),now())) then raise exception 'VEHICLE_CONFLICT'; end if;
  if exists (select 1 from public.bookings x join public.trips t on t.id=x.trip_id where x.driver_id=p_driver_id and x.status='confirmed' and t.status in ('booked','active') and coalesce(t.loading_at,now()) <= coalesce((select delivery_due_at from public.trips where id=p_trip_id),now()) and coalesce(t.delivery_due_at,now()) >= coalesce((select loading_at from public.trips where id=p_trip_id),now())) then raise exception 'DRIVER_CONFLICT'; end if;
  insert into public.bookings(trip_id,vehicle_id,driver_id,booked_by) values(p_trip_id,p_vehicle_id,p_driver_id,auth.uid()) returning * into b;
  update public.trips set vehicle_id=p_vehicle_id,driver_id=p_driver_id,status='booked',booked_at=now() where id=p_trip_id and status='available';
  if not found then raise exception 'TRIP_RACE_CONDITION'; end if;
  update public.vehicles set current_driver_id=p_driver_id,status='idle' where id=p_vehicle_id;
  update public.drivers set status='assigned' where id=p_driver_id;
  return b;
exception when unique_violation then raise exception 'TRIP_ALREADY_BOOKED';
end;
$$;

-- RLS: default deny; policies are intentionally conservative.
do $$ declare t text; begin foreach t in array array['carriers','profiles','drivers','vehicles','loading_locations','delivery_locations','cargo','trips','shipments','bookings','tracking_sessions','tracking_events','vehicle_events','maintenance_records','inspection_records','delay_policies','delay_records','proofs','vehicle_documents','driver_documents','bills_of_lading','notifications','report_schedules','reports','system_settings','audit_logs'] loop execute format('alter table public.%s enable row level security',t); end loop; end $$;

create policy "profiles self read" on public.profiles for select using (id=auth.uid() or public.current_role() in ('admin','operations'));
create policy "profiles self update" on public.profiles for update using (id=auth.uid()) with check (id=auth.uid());
create policy "carrier scoped drivers" on public.drivers for select using (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier scoped vehicles" on public.vehicles for select using (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier scoped trips" on public.trips for select using (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier scoped shipments" on public.shipments for select using (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "users own notifications" on public.notifications for select using (user_id=auth.uid());
create policy "users update own notifications" on public.notifications for update using (user_id=auth.uid()) with check (user_id=auth.uid());
create policy "users own reports" on public.reports for select using (requested_by=auth.uid() or public.current_role() in ('admin','operations'));
create policy "admin settings" on public.system_settings for all using (public.current_role()='admin') with check (public.current_role()='admin');
create policy "admin audit read" on public.audit_logs for select using (public.current_role() in ('admin','operations'));

-- Server-side function access. Clients should call this RPC instead of mutating booking state directly.
grant execute on function public.book_trip(uuid,uuid,uuid) to authenticated;

-- Default delay policy: editable by admin; not hard-coded in the application.
insert into public.delay_policies(name,threshold_hours,compensation_amount,currency,active)
select 'Standard loading delay',24,300,'SAR',true
where not exists (select 1 from public.delay_policies where name='Standard loading delay');

-- Write policies are scoped to the authenticated carrier/driver role. Operationally sensitive state changes use RPCs.
create policy "carrier create drivers" on public.drivers for insert with check (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier update drivers" on public.drivers for update using (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations')) with check (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier create vehicles" on public.vehicles for insert with check (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier update vehicles" on public.vehicles for update using (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations')) with check (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier create trips" on public.trips for insert with check (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier update trips" on public.trips for update using (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations')) with check (carrier_id=public.current_carrier_id() or public.current_role() in ('admin','operations'));
create policy "carrier create cargo" on public.cargo for insert with check (public.current_role() in ('admin','operations','carrier'));
create policy "carrier read cargo" on public.cargo for select using (public.current_role() in ('admin','operations','carrier','driver'));
create policy "driver create tracking events" on public.tracking_events for insert with check (driver_id in (select id from public.drivers where profile_id=auth.uid()) or public.current_role() in ('admin','operations'));
create policy "driver read own tracking" on public.tracking_events for select using (driver_id in (select id from public.drivers where profile_id=auth.uid()) or public.current_role() in ('admin','operations'));
create policy "driver create vehicle events" on public.vehicle_events for insert with check (driver_id in (select id from public.drivers where profile_id=auth.uid()) or public.current_role() in ('admin','operations'));
create policy "carrier read vehicle events" on public.vehicle_events for select using (public.current_role() in ('admin','operations') or vehicle_id in (select id from public.vehicles where carrier_id=public.current_carrier_id()));
create policy "carrier read maintenance" on public.maintenance_records for select using (public.current_role() in ('admin','operations') or vehicle_id in (select id from public.vehicles where carrier_id=public.current_carrier_id()));
create policy "carrier create maintenance" on public.maintenance_records for insert with check (public.current_role() in ('admin','operations') or vehicle_id in (select id from public.vehicles where carrier_id=public.current_carrier_id()));
create policy "carrier read documents" on public.vehicle_documents for select using (public.current_role() in ('admin','operations') or vehicle_id in (select id from public.vehicles where carrier_id=public.current_carrier_id()));
create policy "carrier read driver documents" on public.driver_documents for select using (public.current_role() in ('admin','operations') or driver_id in (select id from public.drivers where carrier_id=public.current_carrier_id()));

-- Private storage buckets. Paths should start with the carrier UUID: <carrier_uuid>/<entity_uuid>/<file>.
insert into storage.buckets(id,name,public) values ('vehicle-documents','vehicle-documents',false) on conflict (id) do nothing;
insert into storage.buckets(id,name,public) values ('driver-documents','driver-documents',false) on conflict (id) do nothing;
insert into storage.buckets(id,name,public) values ('proofs','proofs',false) on conflict (id) do nothing;

create policy "carrier read private fleet files" on storage.objects for select using (
  bucket_id in ('vehicle-documents','driver-documents','proofs') and
  (public.current_role() in ('admin','operations') or (storage.foldername(name))[1] = public.current_carrier_id()::text)
);
create policy "carrier upload private fleet files" on storage.objects for insert with check (
  bucket_id in ('vehicle-documents','driver-documents','proofs') and
  (public.current_role() in ('admin','operations') or (storage.foldername(name))[1] = public.current_carrier_id()::text)
);
create policy "carrier update private fleet files" on storage.objects for update using (
  bucket_id in ('vehicle-documents','driver-documents','proofs') and
  (public.current_role() in ('admin','operations') or (storage.foldername(name))[1] = public.current_carrier_id()::text)
) with check (
  bucket_id in ('vehicle-documents','driver-documents','proofs') and
  (public.current_role() in ('admin','operations') or (storage.foldername(name))[1] = public.current_carrier_id()::text)
);

create or replace function public.start_trip(p_trip_id uuid, p_vehicle_id uuid, p_driver_id uuid) returns uuid
language plpgsql security definer set search_path=public as $$
declare sid uuid;
begin
  if public.current_role() not in ('admin','operations','carrier','driver') then raise exception 'FORBIDDEN'; end if;
  if public.current_role()='driver' and not exists(select 1 from public.drivers where id=p_driver_id and profile_id=auth.uid()) then raise exception 'FORBIDDEN_DRIVER'; end if;
  if not exists(select 1 from public.trips where id=p_trip_id and vehicle_id=p_vehicle_id and driver_id=p_driver_id and status='booked') then raise exception 'INVALID_TRIP_STATE'; end if;
  insert into public.tracking_sessions(trip_id,vehicle_id,driver_id) values(p_trip_id,p_vehicle_id,p_driver_id) returning id into sid;
  update public.trips set status='active' where id=p_trip_id;
  update public.vehicles set status='moving',gps_status='offline',last_updated_at=now() where id=p_vehicle_id;
  update public.drivers set status='assigned' where id=p_driver_id;
  insert into public.tracking_events(tracking_session_id,trip_id,vehicle_id,driver_id,event_type,payload,client_event_id)
  values(sid,p_trip_id,p_vehicle_id,p_driver_id,'trip_started','{}',gen_random_uuid());
  return sid;
exception when unique_violation then raise exception 'TRACKING_SESSION_EXISTS';
end;
$$;

grant execute on function public.start_trip(uuid,uuid,uuid) to authenticated;

create or replace function public.arrive_at_loading(p_trip_id uuid, p_vehicle_id uuid, p_driver_id uuid, p_lat double precision, p_lng double precision) returns uuid
language plpgsql security definer set search_path=public as $$
declare delay_id uuid; arrival timestamptz := now();
begin
  if public.current_role()='driver' and not exists(select 1 from public.drivers where id=p_driver_id and profile_id=auth.uid()) then raise exception 'FORBIDDEN_DRIVER'; end if;
  if not exists(select 1 from public.trips where id=p_trip_id and vehicle_id=p_vehicle_id and driver_id=p_driver_id and status='active') then raise exception 'INVALID_TRIP_STATE'; end if;
  update public.vehicles set status='loading',last_latitude=p_lat,last_longitude=p_lng,last_location=st_setsrid(st_makepoint(p_lng,p_lat),4326)::geography,last_updated_at=arrival where id=p_vehicle_id;
  insert into public.delay_records(trip_id,vehicle_id,driver_id,loading_location_id,arrival_at)
  select t.id,t.vehicle_id,t.driver_id,t.loading_location_id,arrival from public.trips t where t.id=p_trip_id
  on conflict(trip_id) do update set arrival_at=excluded.arrival_at
  returning id into delay_id;
  insert into public.tracking_events(tracking_session_id,trip_id,vehicle_id,driver_id,event_type,occurred_at,location,latitude,longitude,client_event_id)
  select ts.id,p_trip_id,p_vehicle_id,p_driver_id,'arrived_loading',arrival,st_setsrid(st_makepoint(p_lng,p_lat),4326)::geography,p_lat,p_lng,gen_random_uuid()
  from public.tracking_sessions ts where ts.trip_id=p_trip_id and ts.status='active';
  return delay_id;
end;
$$;

grant execute on function public.arrive_at_loading(uuid,uuid,uuid,double precision,double precision) to authenticated;

create or replace function public.complete_delivery(p_trip_id uuid, p_vehicle_id uuid, p_driver_id uuid, p_lat double precision, p_lng double precision) returns void
language plpgsql security definer set search_path=public as $$
begin
  if public.current_role()='driver' and not exists(select 1 from public.drivers where id=p_driver_id and profile_id=auth.uid()) then raise exception 'FORBIDDEN_DRIVER'; end if;
  if not exists(select 1 from public.trips where id=p_trip_id and vehicle_id=p_vehicle_id and driver_id=p_driver_id and status='active') then raise exception 'INVALID_TRIP_STATE'; end if;
  update public.trips set status='completed',completed_at=now() where id=p_trip_id;
  update public.shipments set status='delivered' where trip_id=p_trip_id and status <> 'cancelled';
  update public.tracking_sessions set status='ended',ended_at=now() where trip_id=p_trip_id and status='active';
  update public.vehicles set status='delivered',last_latitude=p_lat,last_longitude=p_lng,last_location=st_setsrid(st_makepoint(p_lng,p_lat),4326)::geography,last_updated_at=now() where id=p_vehicle_id;
  update public.drivers set status='available' where id=p_driver_id;
  insert into public.tracking_events(tracking_session_id,trip_id,vehicle_id,driver_id,event_type,location,latitude,longitude,client_event_id)
  select ts.id,p_trip_id,p_vehicle_id,p_driver_id,'delivered',st_setsrid(st_makepoint(p_lng,p_lat),4326)::geography,p_lat,p_lng,gen_random_uuid()
  from public.tracking_sessions ts where ts.trip_id=p_trip_id order by ts.started_at desc limit 1;
end;
$$;

grant execute on function public.complete_delivery(uuid,uuid,uuid,double precision,double precision) to authenticated;
