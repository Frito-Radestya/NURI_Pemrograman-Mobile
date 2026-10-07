-- =====================================================================
-- NURI v2.0 — SKEMA CLOUD LENGKAP (Supabase / PostgreSQL 15+)
-- Mencakup 3 persona: Ibu Balita, Ibu Hamil, Kader + login/register,
-- profil, notifikasi, pengaturan. Sumber: PRD NURI v2.0 + desain aplikasi.
--
-- Cara pakai: SQL Editor Supabase -> New query -> tempel semua -> Run.
-- Idempoten: aman dijalankan ulang.
-- =====================================================================

-- ---------------------------------------------------------------------
-- 0. Schema privat (helper RLS, tidak diekspos PostgREST)
-- ---------------------------------------------------------------------
create schema if not exists private;
revoke all on schema private from public;
grant usage on schema private to authenticated;

-- ---------------------------------------------------------------------
-- 1. Enum
-- ---------------------------------------------------------------------
do $$
begin
  if not exists (select 1 from pg_type where typname = 'user_role') then
    create type public.user_role as enum ('ibu_balita', 'ibu_hamil', 'kader');
  end if;
  if not exists (select 1 from pg_type where typname = 'child_sex') then
    create type public.child_sex as enum ('L', 'P');
  end if;
  if not exists (select 1 from pg_type where typname = 'consent_method') then
    create type public.consent_method as enum ('lisan', 'kertas', 'aplikasi');
  end if;
  if not exists (select 1 from pg_type where typname = 'measure_method') then
    create type public.measure_method as enum ('berbaring', 'berdiri');
  end if;
  if not exists (select 1 from pg_type where typname = 'growth_status') then
    create type public.growth_status as enum ('sangat_pendek', 'pendek', 'normal', 'tinggi');
  end if;
  if not exists (select 1 from pg_type where typname = 'meal_type') then
    create type public.meal_type as enum ('pagi', 'siang', 'malam', 'snack');
  end if;
  if not exists (select 1 from pg_type where typname = 'food_source') then
    create type public.food_source as enum ('scan', 'manual');
  end if;
  if not exists (select 1 from pg_type where typname = 'traffic_light') then
    create type public.traffic_light as enum ('kurang', 'cukup', 'lebih');
  end if;
end $$;

-- ---------------------------------------------------------------------
-- 2. Fungsi murni (deterministik) — sama dengan GrowthEngine aplikasi
-- ---------------------------------------------------------------------
create or replace function public.age_in_months(p_birth date, p_on date)
returns integer language sql immutable parallel safe as $$
  select ((extract(year  from p_on)::int - extract(year  from p_birth)::int) * 12
        +  extract(month from p_on)::int - extract(month from p_birth)::int
        - case when extract(day from p_on) < extract(day from p_birth) then 1 else 0 end)
$$;

create or replace function public.calc_zscore(x double precision, l double precision,
                                              m double precision, s double precision)
returns double precision language sql immutable parallel safe as $$
  select case when l = 0 then ln(x / m) / s else (power(x / m, l) - 1) / (l * s) end
$$;

create or replace function public.sd_value(z double precision, l double precision,
                                           m double precision, s double precision)
returns double precision language sql immutable parallel safe as $$
  select case when l = 0 then m * exp(s * z) else m * power(1 + l * s * z, 1 / l) end
$$;

create or replace function public.classify_haz(z double precision)
returns public.growth_status language sql immutable parallel safe as $$
  select case when z < -3 then 'sangat_pendek'::public.growth_status
              when z < -2 then 'pendek'::public.growth_status
              when z <= 3 then 'normal'::public.growth_status
              else 'tinggi'::public.growth_status end
$$;

create or replace function public.classify_intake(p_pct numeric)
returns public.traffic_light language sql immutable parallel safe as $$
  select case when p_pct < 80 then 'kurang'::public.traffic_light
              when p_pct <= 120 then 'cukup'::public.traffic_light
              else 'lebih'::public.traffic_light end
$$;

-- =====================================================================
-- 3. PERSONA & PROFIL
-- =====================================================================
create table if not exists public.profiles (
  id                uuid primary key references auth.users (id) on delete cascade,
  role              public.user_role not null,
  display_name      text not null check (char_length(btrim(display_name)) between 1 and 80),
  email             text not null default '',
  phone             text,
  avatar_emoji      text,
  city              text,
  posyandu_name     text,
  privacy_version   text not null default 'v1',
  privacy_at        timestamptz not null default now(),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

-- Data personal ibu (balita maupun hamil)
create table if not exists public.mother_profiles (
  user_id           uuid primary key references public.profiles (id) on delete cascade,
  birth_date        date,
  height_cm         numeric(5,1),
  education         text,
  occupation        text,
  marital_status    text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

-- Data personal kader
create table if not exists public.kader_profiles (
  user_id           uuid primary key references public.profiles (id) on delete cascade,
  posyandu_name     text not null default '',
  wilayah           text,
  puskesmas_name    text,
  employee_no       text,
  verified_at       timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

-- Preferensi & pengaturan aplikasi
create table if not exists public.user_preferences (
  user_id            uuid primary key references public.profiles (id) on delete cascade,
  notif_posyandu     boolean not null default true,
  notif_meal         boolean not null default true,
  notif_immunization boolean not null default true,
  notif_whatsapp     boolean not null default false,
  reminder_time      time not null default '07:00',
  unit_system        text not null default 'kg_cm' check (unit_system in ('kg_cm')),
  font_scale         text not null default 'normal' check (font_scale in ('kecil','normal','besar')),
  language           text not null default 'id',
  data_saver         boolean not null default false,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now(),
  deleted_at         timestamptz,
  device_id          text,
  server_updated_at  timestamptz not null default now()
);

-- Akses pendamping keluarga (ayah, wali, dll)
create table if not exists public.companion_access (
  id                uuid primary key default gen_random_uuid(),
  owner_user_id     uuid not null references public.profiles (id) on delete cascade,
  companion_user_id uuid references public.profiles (id) on delete set null,
  companion_name    text not null,
  relationship      text,
  status            text not null default 'active' check (status in ('pending','active','revoked')),
  invited_at        timestamptz not null default now(),
  accepted_at       timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

-- =====================================================================
-- 4. ANAK, PEMANTAUAN & POSYANDU
-- =====================================================================
create table if not exists public.children (
  id                uuid primary key default gen_random_uuid(),
  created_by        uuid not null references public.profiles (id) on delete cascade,
  nickname          text not null check (char_length(btrim(nickname)) between 1 and 50),
  birth_date        date not null,
  sex               public.child_sex not null,
  posyandu_name     text,
  blood_type        text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

create table if not exists public.guardian_consents (
  id                uuid primary key default gen_random_uuid(),
  child_id          uuid not null unique references public.children (id) on delete cascade,
  method            public.consent_method not null,
  consented_at      timestamptz not null,
  recorded_by       uuid references public.profiles (id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

create table if not exists public.screening_sessions (
  id                uuid primary key default gen_random_uuid(),
  kader_id          uuid not null references public.profiles (id) on delete cascade,
  posyandu_name     text not null check (char_length(btrim(posyandu_name)) between 1 and 120),
  held_on           date not null,
  closed            boolean not null default false,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

create table if not exists public.session_entries (
  id                uuid primary key default gen_random_uuid(),
  session_id        uuid not null references public.screening_sessions (id) on delete cascade,
  child_id          uuid not null references public.children (id) on delete cascade,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now(),
  unique (session_id, child_id)
);

create table if not exists public.measurements (
  id                    uuid primary key default gen_random_uuid(),
  child_id              uuid not null references public.children (id) on delete cascade,
  session_id            uuid references public.screening_sessions (id) on delete set null,
  measured_on           date not null,
  age_months            smallint not null check (age_months between 0 and 59),
  weight_kg             numeric(5,2) not null check (weight_kg > 0 and weight_kg <= 40),
  length_height_cm      numeric(4,1) not null check (length_height_cm between 20 and 150),
  method                public.measure_method not null,
  adjusted_cm           numeric(4,1) not null check (adjusted_cm between 20 and 150),
  head_circumference_cm numeric(4,1),
  lila_cm               numeric(4,1),
  recorded_by           uuid references public.profiles (id) on delete set null,
  created_at            timestamptz not null default now(),
  updated_at            timestamptz not null default now(),
  deleted_at            timestamptz,
  device_id             text,
  server_updated_at     timestamptz not null default now()
);
comment on column public.measurements.adjusted_cm is
  'PB/TB terkoreksi (X pada rumus LMS). Koreksi ±0,7 cm divalidasi di GrowthEngine aplikasi.';

create table if not exists public.screenings (
  id                   uuid primary key default gen_random_uuid(),
  measurement_id       uuid not null unique references public.measurements (id) on delete cascade,
  haz                  double precision not null check (haz between -6 and 6),
  status               public.growth_status not null,
  -- hasil kuesioner kondisi & perilaku (skrining)
  appetite             text check (appetite in ('baik','kurang')),
  illness_2w           text check (illness_2w in ('tidak_ada','ispa','diare','demam')),
  edema                boolean,
  child_active         boolean,
  risk_level           text check (risk_level in ('rendah','sedang','tinggi')),
  interpretation       text,
  ai_posture_verified  boolean not null default false,
  ai_posture_score     numeric(4,3),
  ref_version          text not null,
  app_version          text not null,
  created_at           timestamptz not null default now(),
  updated_at           timestamptz not null default now(),
  deleted_at           timestamptz,
  device_id            text,
  server_updated_at    timestamptz not null default now(),
  constraint screenings_status_matches_haz check (status = public.classify_haz(haz))
);

create table if not exists public.referrals (
  id                uuid primary key default gen_random_uuid(),
  child_id          uuid not null references public.children (id) on delete cascade,
  session_id        uuid references public.screening_sessions (id) on delete set null,
  created_by        uuid references public.profiles (id) on delete set null,
  priority          smallint not null default 1 check (priority between 1 and 3),
  reason            text not null,
  status            text not null default 'draft' check (status in ('draft','sent','accepted','completed')),
  facility          text,
  notes             text,
  sent_at           timestamptz,
  completed_at      timestamptz,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

create table if not exists public.immunizations (
  id                uuid primary key default gen_random_uuid(),
  child_id          uuid not null references public.children (id) on delete cascade,
  kind              text not null check (kind in ('vaksin','vitamin_a','obat_cacing','pmt')),
  name              text not null,
  dose              text,
  given_on          date,
  next_due          date,
  given_by          uuid references public.profiles (id) on delete set null,
  facility          text,
  notes             text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

create table if not exists public.posyandu_events (
  id                uuid primary key default gen_random_uuid(),
  posyandu_name     text not null,
  title             text not null,
  kind              text not null default 'penimbangan'
                    check (kind in ('penimbangan','imunisasi','vitamin_a','anc','lainnya')),
  event_date        date not null,
  start_time        time,
  location          text,
  notes             text,
  created_by        uuid references public.profiles (id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

create table if not exists public.kader_activities (
  id                uuid primary key default gen_random_uuid(),
  kader_id          uuid not null references public.profiles (id) on delete cascade,
  child_id          uuid references public.children (id) on delete set null,
  session_id        uuid references public.screening_sessions (id) on delete set null,
  kind              text not null
                    check (kind in ('pendataan','antropometri','gizi','rujukan','kunjungan_rumah','konseling','imunisasi')),
  note              text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

-- =====================================================================
-- 5. IBU HAMIL (kehamilan & ANC)
-- =====================================================================
create table if not exists public.pregnancies (
  id                     uuid primary key default gen_random_uuid(),
  user_id                uuid not null references public.profiles (id) on delete cascade,
  hpht                   date,                 -- hari pertama haid terakhir
  hpl                    date,                 -- perkiraan lahir
  gravida                smallint,
  para                   smallint,
  abortus                smallint,
  pre_pregnancy_weight_kg numeric(5,2),
  height_cm              numeric(5,1),
  blood_type             text,
  risk_status            text not null default 'low' check (risk_status in ('low','high')),
  status                 text not null default 'active' check (status in ('active','ended')),
  ended_at               date,
  notes                  text,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  deleted_at             timestamptz,
  device_id              text,
  server_updated_at      timestamptz not null default now()
);

create table if not exists public.pregnancy_checkups (
  id                uuid primary key default gen_random_uuid(),
  pregnancy_id      uuid not null references public.pregnancies (id) on delete cascade,
  checkup_date      date not null,
  gestation_week    smallint,
  weight_kg         numeric(5,2),
  systolic          smallint,
  diastolic         smallint,
  fundal_height_cm  numeric(4,1),
  fetal_heart_rate  smallint,
  hb_gdl            numeric(4,1),
  lila_cm           numeric(4,1),
  ttd_given         boolean not null default false,
  location          text,
  provider          text,
  notes             text,
  next_checkup      date,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

create table if not exists public.pregnancy_daily_logs (
  id                uuid primary key default gen_random_uuid(),
  pregnancy_id      uuid not null references public.pregnancies (id) on delete cascade,
  log_date          date not null,
  ttd_taken         boolean not null default false,
  water_glasses     smallint,
  fetal_movements   smallint,
  symptoms          text,
  mood              text,
  note              text,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now(),
  unique (pregnancy_id, log_date)
);

-- =====================================================================
-- 6. GIZI (diary makan & analisis piring)
-- =====================================================================
create table if not exists public.food_logs (
  id                uuid primary key default gen_random_uuid(),
  child_id          uuid not null references public.children (id) on delete cascade,
  log_date          date not null,
  meal              public.meal_type not null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now(),
  unique (child_id, log_date, meal)
);

create table if not exists public.food_log_items (
  id                uuid primary key default gen_random_uuid(),
  food_log_id       uuid not null references public.food_logs (id) on delete cascade,
  tkpi_id           text,
  food_name         text not null,
  portion_label     text not null,
  grams             numeric(7,1) not null check (grams > 0),
  source            public.food_source not null,
  confidence        numeric(4,3) check (confidence between 0 and 1),
  nutrients_json    jsonb check (nutrients_json is null or jsonb_typeof(nutrients_json) = 'object'),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now(),
  constraint food_log_items_confidence_ck check (source = 'scan' or confidence is null)
);
comment on column public.food_log_items.nutrients_json is
  'Kunci: energy_kcal, protein_g, fat_g, carb_g, iron_mg, zinc_mg, calcium_mg, vit_a_mcg. null = data tidak tersedia (bukan nol).';

create table if not exists public.plate_scans (
  id                uuid primary key default gen_random_uuid(),
  child_id          uuid not null references public.children (id) on delete cascade,
  food_log_id       uuid references public.food_logs (id) on delete set null,
  log_date          date not null,
  meal              public.meal_type not null,
  status            text not null check (status in ('success','failed')),
  dominant_food     text,
  total_energy_kcal numeric(8,2),
  total_protein_g   numeric(8,2),
  total_iron_mg     numeric(8,3),
  confidence        numeric(4,3) check (confidence between 0 and 1),
  ai_model_version  text,
  created_by        uuid references public.profiles (id) on delete set null,
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  deleted_at        timestamptz,
  device_id         text,
  server_updated_at timestamptz not null default now()
);

-- =====================================================================
-- 7. NURI CARE (notifikasi & edukasi)
-- =====================================================================
create table if not exists public.notifications (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  child_id   uuid references public.children (id) on delete set null,
  category   text not null
             check (category in ('posyandu','nutrition','growth','immunization','consultation','system')),
  title      text not null,
  body       text not null,
  data       jsonb,
  read_at    timestamptz,
  created_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.care_contents (
  id              uuid primary key default gen_random_uuid(),
  title           text not null,
  summary         text,
  category        text not null default 'umum',
  age_min_months  smallint,
  age_max_months  smallint,
  body            text not null,
  read_minutes    smallint,
  source          text,
  reviewed_by     text,
  reviewed_at     date,
  created_at      timestamptz not null default now()
);

create table if not exists public.content_reads (
  id         uuid primary key default gen_random_uuid(),
  user_id    uuid not null references public.profiles (id) on delete cascade,
  content_id uuid not null references public.care_contents (id) on delete cascade,
  read_at    timestamptz not null default now(),
  unique (user_id, content_id)
);

-- =====================================================================
-- 8. TABEL REFERENSI (read-only; server opsional, app pakai aset offline)
-- =====================================================================
create table if not exists public.ref_versions (
  version     text primary key,
  description text,
  is_current  boolean not null default false,
  created_at  timestamptz not null default now()
);
create unique index if not exists ref_versions_one_current on public.ref_versions (is_current) where is_current;

create table if not exists public.ref_who_lms (
  ref_version text not null references public.ref_versions (version) on delete cascade,
  indicator   text not null default 'hfa' check (indicator in ('hfa')),
  sex         public.child_sex not null,
  age_months  smallint not null check (age_months between 0 and 60),
  l           double precision not null,
  m           double precision not null,
  s           double precision not null,
  primary key (ref_version, indicator, sex, age_months)
);

create table if not exists public.ref_tkpi (
  ref_version text not null references public.ref_versions (version) on delete cascade,
  tkpi_id     text not null,
  name        text not null,
  food_group  text,
  energy_kcal numeric(8,2),
  protein_g   numeric(8,2),
  fat_g       numeric(8,2),
  carb_g      numeric(8,2),
  iron_mg     numeric(8,3),
  zinc_mg     numeric(8,3),
  calcium_mg  numeric(8,2),
  vit_a_mcg   numeric(9,2),
  primary key (ref_version, tkpi_id)
);

create table if not exists public.ref_food_portions (
  ref_version text not null,
  tkpi_id     text not null,
  label       text not null,
  grams       numeric(7,1) not null check (grams > 0),
  is_default  boolean not null default false,
  primary key (ref_version, tkpi_id, label),
  foreign key (ref_version, tkpi_id) references public.ref_tkpi (ref_version, tkpi_id) on delete cascade
);

create table if not exists public.ref_food_classes (
  ref_version text not null references public.ref_versions (version) on delete cascade,
  class_id    smallint not null,
  label       text not null,
  tkpi_id     text,
  primary key (ref_version, class_id),
  foreign key (ref_version, tkpi_id) references public.ref_tkpi (ref_version, tkpi_id)
);

create table if not exists public.ref_akg (
  ref_version    text not null references public.ref_versions (version) on delete cascade,
  sex            public.child_sex not null,
  age_min_months smallint not null,
  age_max_months smallint not null,
  energy_kcal    numeric(8,2) not null,
  protein_g      numeric(8,2) not null,
  fat_g          numeric(8,2) not null,
  carb_g         numeric(8,2) not null,
  iron_mg        numeric(8,3) not null,
  zinc_mg        numeric(8,3) not null,
  calcium_mg     numeric(8,2) not null,
  vit_a_mcg      numeric(9,2) not null,
  primary key (ref_version, sex, age_min_months),
  check (age_max_months >= age_min_months)
);

create table if not exists public.ref_recommendations (
  ref_version text not null references public.ref_versions (version) on delete cascade,
  status      public.growth_status not null,
  age_band    text not null check (age_band in ('under24', 'over24')),
  seq         smallint not null,
  title       text not null,
  body        text not null,
  reviewed_by text,
  reviewed_at date,
  primary key (ref_version, status, age_band, seq)
);

-- =====================================================================
-- 9. INDEX
-- =====================================================================
create index if not exists children_created_by_idx        on public.children (created_by) where deleted_at is null;
create index if not exists guardian_consents_recorded_idx on public.guardian_consents (recorded_by);
create index if not exists sessions_kader_idx             on public.screening_sessions (kader_id, held_on desc);
create index if not exists session_entries_child_idx      on public.session_entries (child_id);
create index if not exists measurements_child_idx         on public.measurements (child_id, measured_on desc, created_at desc);
create index if not exists measurements_session_idx       on public.measurements (session_id) where session_id is not null;
create index if not exists referrals_child_idx            on public.referrals (child_id, created_at desc);
create index if not exists immunizations_child_idx        on public.immunizations (child_id, given_on desc);
create index if not exists posyandu_events_date_idx       on public.posyandu_events (event_date desc);
create index if not exists kader_activities_kader_idx     on public.kader_activities (kader_id, created_at desc);
create index if not exists pregnancies_user_idx           on public.pregnancies (user_id) where deleted_at is null;
create index if not exists pregnancy_checkups_idx         on public.pregnancy_checkups (pregnancy_id, checkup_date desc);
create index if not exists pregnancy_daily_idx            on public.pregnancy_daily_logs (pregnancy_id, log_date desc);
create index if not exists food_log_items_log_idx         on public.food_log_items (food_log_id);
create index if not exists plate_scans_child_idx          on public.plate_scans (child_id, log_date desc);
create index if not exists notifications_user_idx         on public.notifications (user_id, created_at desc) where deleted_at is null;
create index if not exists companion_owner_idx            on public.companion_access (owner_user_id);
create index if not exists ref_who_lms_lookup_idx         on public.ref_who_lms (ref_version, sex, age_months);

-- kursor tarik-data
create index if not exists profiles_srv_idx          on public.profiles (server_updated_at);
create index if not exists children_srv_idx          on public.children (server_updated_at);
create index if not exists guardian_consents_srv_idx on public.guardian_consents (server_updated_at);
create index if not exists sessions_srv_idx          on public.screening_sessions (server_updated_at);
create index if not exists measurements_srv_idx      on public.measurements (server_updated_at);
create index if not exists screenings_srv_idx        on public.screenings (server_updated_at);
create index if not exists food_logs_srv_idx         on public.food_logs (server_updated_at);
create index if not exists food_log_items_srv_idx    on public.food_log_items (server_updated_at);
create index if not exists pregnancies_srv_idx       on public.pregnancies (server_updated_at);
create index if not exists notifications_srv_idx     on public.notifications (created_at);

-- =====================================================================
-- 10. TRIGGER
-- =====================================================================
-- 10.1 LWW sinkron (baris generik dengan updated_at & server_updated_at)
create or replace function private.sync_guard()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.updated_at > now() + interval '10 minutes' then
    new.updated_at := now();
  end if;
  if tg_op = 'INSERT' then
    new.server_updated_at := now();
    return new;
  end if;
  if new.updated_at < old.updated_at then
    return null;
  end if;
  new.created_at        := old.created_at;
  new.server_updated_at := now();
  return new;
end $$;

do $$
declare t text;
begin
  foreach t in array array[
    'profiles','mother_profiles','kader_profiles','user_preferences','companion_access',
    'children','guardian_consents','screening_sessions','session_entries','measurements',
    'screenings','referrals','immunizations','posyandu_events','kader_activities',
    'pregnancies','pregnancy_checkups','pregnancy_daily_logs',
    'food_logs','food_log_items','plate_scans']
  loop
    execute format('drop trigger if exists t00_sync_guard on public.%I', t);
    execute format('create trigger t00_sync_guard before insert or update on public.%I
                    for each row execute function private.sync_guard()', t);
  end loop;
end $$;

-- 10.2 Peran akun tidak bisa diubah
create or replace function private.profile_role_immutable()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.role is distinct from old.role then
    raise exception 'peran akun tidak dapat diubah' using errcode = 'integrity_constraint_violation';
  end if;
  return new;
end $$;
drop trigger if exists t10_role_immutable on public.profiles;
create trigger t10_role_immutable before update on public.profiles
  for each row execute function private.profile_role_immutable();

-- 10.3 Tanggal lahir anak tidak boleh masa depan
create or replace function private.validate_child()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.birth_date > current_date + 1 then
    raise exception 'tanggal lahir tidak boleh di masa depan' using errcode = 'check_violation';
  end if;
  return new;
end $$;
drop trigger if exists t10_validate_child on public.children;
create trigger t10_validate_child before insert or update of birth_date on public.children
  for each row execute function private.validate_child();

-- 10.4 Validasi pengukuran (umur & consent)
create or replace function private.validate_measurement()
returns trigger language plpgsql set search_path = '' as $$
declare v_birth date; v_role public.user_role;
begin
  select birth_date into v_birth from public.children where id = new.child_id;
  if new.measured_on > current_date + 1 then
    raise exception 'tanggal ukur tidak boleh di masa depan' using errcode = 'check_violation';
  end if;
  if v_birth is not null and new.measured_on < v_birth then
    raise exception 'tanggal ukur sebelum tanggal lahir' using errcode = 'check_violation';
  end if;
  if v_birth is not null and new.age_months <> public.age_in_months(v_birth, new.measured_on) then
    raise exception 'age_months tidak sesuai tanggal lahir dan tanggal ukur' using errcode = 'check_violation';
  end if;
  select role into v_role from public.profiles where id = new.recorded_by;
  if v_role = 'kader' and not exists (
       select 1 from public.guardian_consents gc
       where gc.child_id = new.child_id and gc.deleted_at is null) then
    raise exception 'consent wali belum tercatat untuk anak ini' using errcode = 'check_violation';
  end if;
  return new;
end $$;
drop trigger if exists t10_validate_measurement on public.measurements;
create trigger t10_validate_measurement before insert on public.measurements
  for each row execute function private.validate_measurement();

-- 10.5 Append-only pengukuran
create or replace function private.measurements_append_only()
returns trigger language plpgsql set search_path = '' as $$
begin
  if new.child_id         is distinct from old.child_id
  or new.measured_on      is distinct from old.measured_on
  or new.age_months       is distinct from old.age_months
  or new.weight_kg        is distinct from old.weight_kg
  or new.length_height_cm is distinct from old.length_height_cm
  or new.method           is distinct from old.method
  or new.adjusted_cm      is distinct from old.adjusted_cm
  or new.recorded_by      is distinct from old.recorded_by
  or (new.session_id is distinct from old.session_id and new.session_id is not null) then
    raise exception 'measurements bersifat append-only' using errcode = 'integrity_constraint_violation';
  end if;
  return new;
end $$;
drop trigger if exists t20_append_only on public.measurements;
create trigger t20_append_only before update on public.measurements
  for each row execute function private.measurements_append_only();

-- 10.6 Auto-buat profil saat user baru daftar
create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path = public as $$
declare v_role public.user_role;
begin
  v_role := case new.raw_user_meta_data->>'role'
              when 'kader' then 'kader'::public.user_role
              when 'ibu_hamil' then 'ibu_hamil'::public.user_role
              else 'ibu_balita'::public.user_role end;
  insert into public.profiles (id, role, display_name, email, privacy_version, privacy_at)
  values (new.id, v_role,
          coalesce(new.raw_user_meta_data->>'display_name', split_part(new.email, '@', 1)),
          coalesce(new.email, ''), 'v1', now())
  on conflict (id) do nothing;
  return new;
end $$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
  for each row execute function public.handle_new_user();

-- =====================================================================
-- 11. HELPER RLS
-- =====================================================================
create or replace function private.is_kader()
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.profiles p
                 where p.id = (select auth.uid()) and p.role = 'kader')
$$;

create or replace function private.owns_session(p_session_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.screening_sessions s
                 where s.id = p_session_id and s.kader_id = (select auth.uid()))
$$;

create or replace function private.child_in_my_session(p_child_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.measurements m
                 join public.screening_sessions s on s.id = m.session_id
                 where m.child_id = p_child_id and s.kader_id = (select auth.uid()))
$$;

create or replace function private.can_access_child(p_child_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.children c
                 where c.id = p_child_id and c.created_by = (select auth.uid()))
      or private.child_in_my_session(p_child_id)
$$;

create or replace function private.can_access_measurement(p_measurement_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.measurements m
                 where m.id = p_measurement_id and private.can_access_child(m.child_id))
$$;

create or replace function private.can_access_food_log(p_food_log_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.food_logs f
                 where f.id = p_food_log_id and private.can_access_child(f.child_id))
$$;

create or replace function private.owns_pregnancy(p_pregnancy_id uuid)
returns boolean language sql stable security definer set search_path = '' as $$
  select exists (select 1 from public.pregnancies p
                 where p.id = p_pregnancy_id and p.user_id = (select auth.uid()))
$$;

grant execute on all functions in schema private to authenticated;

-- =====================================================================
-- 12. ROW LEVEL SECURITY
-- =====================================================================
do $$
declare t text;
begin
  foreach t in array array[
    'profiles','mother_profiles','kader_profiles','user_preferences','companion_access',
    'children','guardian_consents','screening_sessions','session_entries','measurements',
    'screenings','referrals','immunizations','posyandu_events','kader_activities',
    'pregnancies','pregnancy_checkups','pregnancy_daily_logs',
    'food_logs','food_log_items','plate_scans','notifications',
    'care_contents','content_reads',
    'ref_versions','ref_who_lms','ref_tkpi','ref_food_portions','ref_food_classes',
    'ref_akg','ref_recommendations']
  loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- 12.1 Profil & data personal: hanya milik sendiri
drop policy if exists profiles_self on public.profiles;
create policy profiles_self on public.profiles for all to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

drop policy if exists mother_profiles_self on public.mother_profiles;
create policy mother_profiles_self on public.mother_profiles for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

drop policy if exists kader_profiles_self on public.kader_profiles;
create policy kader_profiles_self on public.kader_profiles for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

drop policy if exists user_preferences_self on public.user_preferences;
create policy user_preferences_self on public.user_preferences for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- companion: owner penuh; companion boleh membaca
drop policy if exists companion_owner on public.companion_access;
create policy companion_owner on public.companion_access for all to authenticated
  using (owner_user_id = (select auth.uid())) with check (owner_user_id = (select auth.uid()));
drop policy if exists companion_read on public.companion_access;
create policy companion_read on public.companion_access for select to authenticated
  using (companion_user_id = (select auth.uid()));

-- 12.2 Anak
drop policy if exists children_select on public.children;
create policy children_select on public.children for select to authenticated
  using (created_by = (select auth.uid()) or private.child_in_my_session(id));
drop policy if exists children_insert on public.children;
create policy children_insert on public.children for insert to authenticated
  with check (created_by = (select auth.uid()));
drop policy if exists children_update on public.children;
create policy children_update on public.children for update to authenticated
  using (created_by = (select auth.uid())) with check (created_by = (select auth.uid()));

drop policy if exists consents_select on public.guardian_consents;
create policy consents_select on public.guardian_consents for select to authenticated
  using (private.can_access_child(child_id));
drop policy if exists consents_write on public.guardian_consents;
create policy consents_write on public.guardian_consents for insert to authenticated
  with check (recorded_by = (select auth.uid()) and private.can_access_child(child_id));
drop policy if exists consents_update on public.guardian_consents;
create policy consents_update on public.guardian_consents for update to authenticated
  using (private.can_access_child(child_id)) with check (private.can_access_child(child_id));

-- 12.3 Sesi & entri kader
drop policy if exists sessions_all on public.screening_sessions;
create policy sessions_all on public.screening_sessions for all to authenticated
  using (kader_id = (select auth.uid())) with check (kader_id = (select auth.uid()));
drop policy if exists session_entries_all on public.session_entries;
create policy session_entries_all on public.session_entries for all to authenticated
  using (private.owns_session(session_id)) with check (private.owns_session(session_id));

-- 12.4 Pengukuran, skrining, rujukan, imunisasi, aktivitas
drop policy if exists measurements_select on public.measurements;
create policy measurements_select on public.measurements for select to authenticated
  using (private.can_access_child(child_id));
drop policy if exists measurements_insert on public.measurements;
create policy measurements_insert on public.measurements for insert to authenticated
  with check (recorded_by = (select auth.uid()) and private.can_access_child(child_id)
              and (session_id is null or private.owns_session(session_id)));
drop policy if exists measurements_update on public.measurements;
create policy measurements_update on public.measurements for update to authenticated
  using (private.can_access_child(child_id)) with check (private.can_access_child(child_id));

drop policy if exists screenings_select on public.screenings;
create policy screenings_select on public.screenings for select to authenticated
  using (private.can_access_measurement(measurement_id));
drop policy if exists screenings_write on public.screenings;
create policy screenings_write on public.screenings for insert to authenticated
  with check (private.can_access_measurement(measurement_id));
drop policy if exists screenings_update on public.screenings;
create policy screenings_update on public.screenings for update to authenticated
  using (private.can_access_measurement(measurement_id))
  with check (private.can_access_measurement(measurement_id));

drop policy if exists referrals_access on public.referrals;
create policy referrals_access on public.referrals for all to authenticated
  using (private.can_access_child(child_id)) with check (private.can_access_child(child_id));

drop policy if exists immunizations_access on public.immunizations;
create policy immunizations_access on public.immunizations for all to authenticated
  using (private.can_access_child(child_id)) with check (private.can_access_child(child_id));

drop policy if exists events_read on public.posyandu_events;
create policy events_read on public.posyandu_events for select to authenticated using (true);
drop policy if exists events_write on public.posyandu_events;
create policy events_write on public.posyandu_events for all to authenticated
  using (private.is_kader()) with check (private.is_kader());

drop policy if exists activities_all on public.kader_activities;
create policy activities_all on public.kader_activities for all to authenticated
  using (kader_id = (select auth.uid())) with check (kader_id = (select auth.uid()));

-- 12.5 Kehamilan (pemilik)
do $$
declare t text;
begin
  foreach t in array array['pregnancies','pregnancy_checkups','pregnancy_daily_logs'] loop
    execute format('drop policy if exists %I_self on public.%I', t, t);
  end loop;
end $$;
drop policy if exists pregnancies_self on public.pregnancies;
create policy pregnancies_self on public.pregnancies for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists pregnancy_checkups_self on public.pregnancy_checkups;
create policy pregnancy_checkups_self on public.pregnancy_checkups for all to authenticated
  using (private.owns_pregnancy(pregnancy_id)) with check (private.owns_pregnancy(pregnancy_id));
drop policy if exists pregnancy_daily_self on public.pregnancy_daily_logs;
create policy pregnancy_daily_self on public.pregnancy_daily_logs for all to authenticated
  using (private.owns_pregnancy(pregnancy_id)) with check (private.owns_pregnancy(pregnancy_id));

-- 12.6 Gizi
drop policy if exists food_logs_access on public.food_logs;
create policy food_logs_access on public.food_logs for all to authenticated
  using (private.can_access_child(child_id)) with check (private.can_access_child(child_id));
drop policy if exists food_items_access on public.food_log_items;
create policy food_items_access on public.food_log_items for all to authenticated
  using (private.can_access_food_log(food_log_id)) with check (private.can_access_food_log(food_log_id));
drop policy if exists plate_scans_access on public.plate_scans;
create policy plate_scans_access on public.plate_scans for all to authenticated
  using (private.can_access_child(child_id)) with check (private.can_access_child(child_id));

-- 12.7 NURI Care
drop policy if exists notifications_self on public.notifications;
create policy notifications_self on public.notifications for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));
drop policy if exists care_contents_read on public.care_contents;
create policy care_contents_read on public.care_contents for select to authenticated using (true);
drop policy if exists content_reads_self on public.content_reads;
create policy content_reads_self on public.content_reads for all to authenticated
  using (user_id = (select auth.uid())) with check (user_id = (select auth.uid()));

-- 12.8 Referensi (baca saja)
do $$
declare t text;
begin
  foreach t in array array['ref_versions','ref_who_lms','ref_tkpi','ref_food_portions',
                           'ref_food_classes','ref_akg','ref_recommendations'] loop
    execute format('drop policy if exists %I_read on public.%I', t, t);
    execute format('create policy %I_read on public.%I for select to authenticated using (true)', t, t);
  end loop;
end $$;

revoke all on all tables in schema public from anon;

-- =====================================================================
-- 13. VIEW
-- =====================================================================
create or replace view public.v_growth_history with (security_invoker = true) as
select m.child_id, m.id as measurement_id, m.session_id, m.measured_on, m.age_months,
       m.weight_kg, m.length_height_cm, m.method, m.adjusted_cm,
       m.head_circumference_cm, m.lila_cm, s.haz, s.status, s.ref_version
from public.measurements m
left join public.screenings s on s.measurement_id = m.id and s.deleted_at is null
where m.deleted_at is null;

create or replace view public.v_child_latest_status with (security_invoker = true) as
select distinct on (c.id)
       c.id as child_id, c.nickname, c.sex, c.birth_date,
       g.measured_on, g.age_months, g.haz, g.status
from public.children c
left join public.v_growth_history g on g.child_id = c.id
where c.deleted_at is null
order by c.id, g.measured_on desc nulls last;

create or replace view public.v_session_children with (security_invoker = true) as
select distinct on (m.session_id, m.child_id)
       m.session_id, m.child_id, c.nickname, m.measured_on, m.age_months,
       m.weight_kg, m.adjusted_cm, s.haz, s.status
from public.measurements m
join public.children c on c.id = m.child_id and c.deleted_at is null
left join public.screenings s on s.measurement_id = m.id and s.deleted_at is null
where m.session_id is not null and m.deleted_at is null
order by m.session_id, m.child_id, m.measured_on desc, m.created_at desc;

create or replace view public.v_session_recap with (security_invoker = true) as
select ss.id as session_id, ss.kader_id, ss.posyandu_name, ss.held_on,
       count(sc.child_id)                                              as total_anak,
       count(*) filter (where sc.status = 'normal')                    as normal,
       count(*) filter (where sc.status = 'pendek')                    as pendek,
       count(*) filter (where sc.status = 'sangat_pendek')             as sangat_pendek,
       count(*) filter (where sc.status = 'tinggi')                    as tinggi,
       count(*) filter (where sc.status in ('pendek','sangat_pendek')) as perlu_tindak_lanjut
from public.screening_sessions ss
left join public.v_session_children sc on sc.session_id = ss.id
where ss.deleted_at is null
group by ss.id;

create or replace view public.v_session_followup with (security_invoker = true) as
select session_id, child_id, nickname, age_months, weight_kg, adjusted_cm, haz, status
from public.v_session_children
where status in ('pendek', 'sangat_pendek');

create or replace view public.v_daily_nutrition with (security_invoker = true) as
select fl.child_id, fl.log_date,
       sum((i.nutrients_json->>'energy_kcal')::numeric) as energy_kcal,
       sum((i.nutrients_json->>'protein_g')::numeric)   as protein_g,
       sum((i.nutrients_json->>'fat_g')::numeric)       as fat_g,
       sum((i.nutrients_json->>'carb_g')::numeric)      as carb_g,
       sum((i.nutrients_json->>'iron_mg')::numeric)     as iron_mg,
       sum((i.nutrients_json->>'zinc_mg')::numeric)     as zinc_mg,
       sum((i.nutrients_json->>'calcium_mg')::numeric)  as calcium_mg,
       sum((i.nutrients_json->>'vit_a_mcg')::numeric)   as vit_a_mcg,
       count(*) filter (where i.nutrients_json is null) as items_without_data
from public.food_logs fl
join public.food_log_items i on i.food_log_id = fl.id and i.deleted_at is null
where fl.deleted_at is null
group by fl.child_id, fl.log_date;

-- Ringkasan kehamilan + ANC terakhir
create or replace view public.v_pregnancy_summary with (security_invoker = true) as
select p.id as pregnancy_id, p.user_id, p.hpht, p.hpl, p.gravida, p.para,
       p.risk_status, p.status,
       pc.checkup_date, pc.gestation_week, pc.weight_kg, pc.hb_gdl, pc.lila_cm,
       pc.ttd_given, pc.next_checkup
from public.pregnancies p
left join lateral (
  select * from public.pregnancy_checkups c
  where c.pregnancy_id = p.id and c.deleted_at is null
  order by c.checkup_date desc limit 1
) pc on true
where p.deleted_at is null;

grant select on public.v_growth_history, public.v_child_latest_status,
                public.v_session_children, public.v_session_recap,
                public.v_session_followup, public.v_daily_nutrition,
                public.v_pregnancy_summary to authenticated;

-- =====================================================================
-- 14. RPC
-- =====================================================================
create or replace function public.fn_daily_nutrition_vs_akg(p_child_id uuid, p_date date, p_ref_version text default null)
returns table (nutrient text, intake numeric, target numeric, pct numeric, light public.traffic_light)
language sql stable security invoker set search_path = '' as $$
  with c as (
    select sex, public.age_in_months(birth_date, p_date) as age_m
    from public.children where id = p_child_id and deleted_at is null
  ),
  a as (
    select akg.* from public.ref_akg akg, c
    where akg.ref_version = coalesce(p_ref_version,
            (select version from public.ref_versions where is_current limit 1))
      and akg.sex = c.sex
      and c.age_m between akg.age_min_months and akg.age_max_months
    limit 1
  ),
  d as (
    select * from public.v_daily_nutrition where child_id = p_child_id and log_date = p_date
  )
  select r.nutrient, r.intake, r.target, r.pct, public.classify_intake(r.pct)
  from a left join d on true
  cross join lateral (
    select v.nutrient, v.intake, v.target,
           round(coalesce(v.intake, 0) * 100 / nullif(v.target, 0), 1) as pct
    from (values
      ('energy_kcal', d.energy_kcal, a.energy_kcal),
      ('protein_g',   d.protein_g,   a.protein_g),
      ('fat_g',       d.fat_g,       a.fat_g),
      ('carb_g',      d.carb_g,      a.carb_g),
      ('iron_mg',     d.iron_mg,     a.iron_mg),
      ('zinc_mg',     d.zinc_mg,     a.zinc_mg),
      ('calcium_mg',  d.calcium_mg,  a.calcium_mg),
      ('vit_a_mcg',   d.vit_a_mcg,   a.vit_a_mcg)
    ) as v(nutrient, intake, target)
  ) r
$$;

create or replace function public.create_child_with_consent(
  p_child_id uuid, p_nickname text, p_birth_date date, p_sex public.child_sex,
  p_posyandu_name text, p_consent_id uuid, p_method public.consent_method,
  p_consented_at timestamptz, p_device_id text default null)
returns void language plpgsql security invoker set search_path = '' as $$
begin
  insert into public.children (id, created_by, nickname, birth_date, sex, posyandu_name, device_id)
  values (p_child_id, (select auth.uid()), p_nickname, p_birth_date, p_sex, p_posyandu_name, p_device_id);
  insert into public.guardian_consents (id, child_id, method, consented_at, recorded_by, device_id)
  values (p_consent_id, p_child_id, p_method, p_consented_at, (select auth.uid()), p_device_id);
end $$;

create or replace function public.delete_my_account()
returns void language plpgsql security definer set search_path = '' as $$
begin
  if (select auth.uid()) is null then
    raise exception 'tidak terautentikasi' using errcode = '28000';
  end if;
  delete from auth.users where id = (select auth.uid());
end $$;
revoke all on function public.delete_my_account() from public, anon;
grant execute on function public.delete_my_account() to authenticated;

grant select on public.ref_versions, public.ref_who_lms, public.ref_tkpi, public.ref_food_portions,
                public.ref_food_classes, public.ref_akg, public.ref_recommendations to authenticated;
grant select, insert, update on public.profiles, public.mother_profiles, public.kader_profiles,
                public.user_preferences, public.companion_access, public.children, public.guardian_consents,
                public.screening_sessions, public.session_entries, public.measurements, public.screenings,
                public.referrals, public.immunizations, public.posyandu_events, public.kader_activities,
                public.pregnancies, public.pregnancy_checkups, public.pregnancy_daily_logs,
                public.food_logs, public.food_log_items, public.plate_scans, public.notifications,
                public.care_contents, public.content_reads to authenticated;

-- =====================================================================
-- 15. SEED MINIMAL
-- =====================================================================
insert into public.ref_versions (version, description, is_current)
values ('2026.1', 'WHO LMS TB/U 0-59 bln, TKPI, AKG Permenkes 28/2019, rekomendasi', true)
on conflict (version) do nothing;

-- =====================================================================
-- SELESAI
-- =====================================================================
