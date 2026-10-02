-- NURI (Nutrisi & Risiko Stunting di Indonesia) — skema Supabase
-- Jalankan di Supabase Dashboard > SQL Editor (sekali saja, berurutan).
-- Asumsi: pakai auth.users bawaan Supabase Auth (email/OTP).
-- Foto TIDAK disimpan (PRD NFR-02): hanya antropometri + log makanan.

-- 0. Ekstensi
create extension if not exists "pgcrypto";

-- 1. Profil publik (1-1 ke auth.users). Peran: ibu_balita | ibu_hamil | kader.
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  role text not null default 'ibu_balita'
    check (role in ('ibu_balita', 'ibu_hamil', 'kader')),
  full_name text not null default '',
  contact text not null default '',
  posyandu_name text,
  consent_at timestamptz,
  created_at timestamptz not null default now()
);

-- 2. Data anak (ChildProfile). Kader bisa punya banyak anak titipan.
create table if not exists public.children (
  id uuid primary key default gen_random_uuid(),
  owner_user_id uuid not null references public.profiles (id) on delete cascade,
  name text not null,
  birth_date date not null,
  gender char(1) not null default 'P' check (gender in ('L', 'P')),
  mother_name text not null default '',
  weight_kg numeric(5,2) not null check (weight_kg between 1 and 40),
  height_cm numeric(5,2) not null check (height_cm between 30 and 130),
  last_check_date date not null default current_date,
  status text not null default 'Perlu Pemantauan'
    check (status in ('Normal', 'Perlu Pemantauan', 'Risiko Stunting')),
  notes text not null default '',
  created_at timestamptz not null default now()
);
create index if not exists idx_children_owner on public.children (owner_user_id);

-- 3. Riwayat pengukuran (F-04.6, tidak menimpa).
create table if not exists public.measurements (
  id uuid primary key default gen_random_uuid(),
  child_id uuid not null references public.children (id) on delete cascade,
  measured_at date not null default current_date,
  age_months int not null check (age_months between 0 and 59),
  weight_kg numeric(5,2) not null check (weight_kg between 1 and 40),
  measured_cm numeric(5,2) not null check (measured_cm between 30 and 130),
  measured_is_length boolean not null default true,
  corrected_cm numeric(5,2) not null,
  is_length boolean not null,
  created_at timestamptz not null default now(),
  unique (child_id, measured_at, corrected_cm)
);
create index if not exists idx_measurements_child on public.measurements (child_id, measured_at);

-- 4. Hasil skrining z-score (1-1 ke measurement). Foto tidak disimpan.
create table if not exists public.screening_results (
  id uuid primary key default gen_random_uuid(),
  measurement_id uuid not null unique references public.measurements (id) on delete cascade,
  z_score numeric(6,3) not null,
  category text not null
    check (category in ('Sangat Pendek', 'Pendek', 'Normal', 'Tinggi')),
  photo_indicator text,
  photo_score numeric(5,3),
  model_version text not null default 'who-lms-demo-v1',
  created_at timestamptz not null default now()
);

-- 5. Katalog makanan TKPI (read-only, di-seed dari FoodDatabase 25 item).
create table if not exists public.food_items (
  id text primary key,
  name text not null,
  category text not null,
  category_id text not null,
  default_unit text not null default 'gram',
  default_portion_g numeric(7,2) not null default 100,
  calories_per_100g numeric(7,2) not null default 0,
  protein_per_100g numeric(7,2) not null default 0,
  carbs_per_100g numeric(7,2) not null default 0,
  fat_per_100g numeric(7,2) not null default 0
);

-- 6. Referensi AKG per kelompok umur/jk (ganti angka demo dengan tabel resmi).
create table if not exists public.akg_reference (
  id serial primary key,
  age_min_months int not null,
  age_max_months int not null,
  gender char(1) not null default 'B' check (gender in ('L', 'P', 'B')),
  calories numeric(7,2) not null,
  protein_g numeric(7,2) not null,
  carbs_g numeric(7,2) not null,
  fat_g numeric(7,2) not null
);

-- 7. Referensi WHO LMS (ganti anchor demo dengan CSV resmi 0-60 bln).
create table if not exists public.who_growth_ref (
  id serial primary key,
  indicator text not null default 'lhfa' check (indicator in ('lhfa', 'hfa')),
  gender char(1) not null check (gender in ('L', 'P')),
  age_months int not null check (age_months between 0 and 60),
  l numeric(8,5) not null default 1,
  m numeric(8,4) not null,
  s numeric(8,5) not null,
  unique (indicator, gender, age_months)
);

-- 8. Food diary: satu log per anak per tanggal.
create table if not exists public.food_logs (
  id uuid primary key default gen_random_uuid(),
  child_id uuid references public.children (id) on delete set null,
  user_id uuid not null references public.profiles (id) on delete cascade,
  log_date date not null default current_date,
  session text not null default 'siang'
    check (session in ('pagi', 'siang', 'malam', 'snack')),
  created_at timestamptz not null default now()
);
create index if not exists idx_food_logs_user_date on public.food_logs (user_id, log_date);

-- 9. Item log makanan (sumber scan/manual + kepercayaan AI).
create table if not exists public.food_log_items (
  id uuid primary key default gen_random_uuid(),
  food_log_id uuid not null references public.food_logs (id) on delete cascade,
  food_item_id text references public.food_items (id),
  food_name text not null,
  portion_g numeric(7,2) not null check (portion_g between 1 and 2000),
  calories numeric(8,2) not null default 0,
  protein_g numeric(8,2) not null default 0,
  carbs_g numeric(8,2) not null default 0,
  fat_g numeric(8,2) not null default 0,
  source text not null default 'manual' check (source in ('scan', 'manual')),
  confidence numeric(4,3),
  created_at timestamptz not null default now()
);
create index if not exists idx_food_log_items_log on public.food_log_items (food_log_id);

-- 10. Bank rekomendasi statis (F-06).
create table if not exists public.recommendations (
  id serial primary key,
  status_category text not null,
  age_min_months int not null default 0,
  age_max_months int not null default 60,
  content text not null
);

-- 11. Sesi skrining kader + anggotanya.
create table if not exists public.screening_sessions (
  id uuid primary key default gen_random_uuid(),
  kader_user_id uuid not null references public.profiles (id) on delete cascade,
  posyandu_name text not null,
  session_date date not null default current_date,
  created_at timestamptz not null default now()
);
create table if not exists public.session_entries (
  id uuid primary key default gen_random_uuid(),
  session_id uuid not null references public.screening_sessions (id) on delete cascade,
  measurement_id uuid not null references public.measurements (id) on delete cascade,
  unique (session_id, measurement_id)
);

-- 12. Riwayat chat (hanya bila chatbot dipakai).
create table if not exists public.chat_messages (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  role text not null check (role in ('user', 'assistant', 'system')),
  content text not null,
  created_at timestamptz not null default now()
);
create index if not exists idx_chat_user on public.chat_messages (user_id, created_at);

-- 13. RLS: nyalakan + kebijakan pemilik-data.
alter table public.profiles enable row level security;
alter table public.children enable row level security;
alter table public.measurements enable row level security;
alter table public.screening_results enable row level security;
alter table public.food_logs enable row level security;
alter table public.food_log_items enable row level security;
alter table public.screening_sessions enable row level security;
alter table public.session_entries enable row level security;
alter table public.chat_messages enable row level security;

-- Profil: user kelola miliknya sendiri.
drop policy if exists profiles_self on public.profiles;
create policy profiles_self on public.profiles
  for all using (auth.uid() = id) with check (auth.uid() = id);

-- Anak: pemilik kelola miliknya; kader membaca semua untuk skrining massal.
drop policy if exists children_owner on public.children;
create policy children_owner on public.children
  for all using (auth.uid() = owner_user_id) with check (auth.uid() = owner_user_id);
drop policy if exists children_kader_read on public.children;
create policy children_kader_read on public.children
  for select using (
    exists (select 1 from public.profiles p
      where p.id = auth.uid() and p.role = 'kader')
  );

-- Helper: cek kepemilikan anak / log untuk kebijakan di bawah.
create or replace function public.is_child_owner(c uuid) returns boolean
  language sql stable as $$
    select exists (select 1 from public.children
      where id = c and owner_user_id = auth.uid());
  $$;

-- Measurements: pemilik anak.
drop policy if exists measurements_owner on public.measurements;
create policy measurements_owner on public.measurements
  for all using (public.is_child_owner(child_id))
  with check (public.is_child_owner(child_id));

-- Screening results: ikut kepemilikan anak via measurement.
drop policy if exists screening_results_owner on public.screening_results;
create policy screening_results_owner on public.screening_results
  for all using (
    exists (select 1 from public.measurements m
      join public.children c on c.id = m.child_id
      where m.id = measurement_id and c.owner_user_id = auth.uid())
  ) with check (
    exists (select 1 from public.measurements m
      join public.children c on c.id = m.child_id
      where m.id = measurement_id and c.owner_user_id = auth.uid())
  );

-- Food logs: milik user.
drop policy if exists food_logs_owner on public.food_logs;
create policy food_logs_owner on public.food_logs
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Food log items: ikut log milik user.
drop policy if exists food_log_items_owner on public.food_log_items;
create policy food_log_items_owner on public.food_log_items
  for all using (
    exists (select 1 from public.food_logs l
      where l.id = food_log_id and l.user_id = auth.uid())
  ) with check (
    exists (select 1 from public.food_logs l
      where l.id = food_log_id and l.user_id = auth.uid())
  );

-- Sesi kader: kader kelola miliknya.
drop policy if exists sessions_owner on public.screening_sessions;
create policy sessions_owner on public.screening_sessions
  for all using (auth.uid() = kader_user_id)
  with check (auth.uid() = kader_user_id);
drop policy if exists session_entries_owner on public.session_entries;
create policy session_entries_owner on public.session_entries
  for all using (
    exists (select 1 from public.screening_sessions s
      where s.id = session_id and s.kader_user_id = auth.uid())
  ) with check (
    exists (select 1 from public.screening_sessions s
      where s.id = session_id and s.kader_user_id = auth.uid())
  );

-- Chat: milik user.
drop policy if exists chat_owner on public.chat_messages;
create policy chat_owner on public.chat_messages
  for all using (auth.uid() = user_id) with check (auth.uid() = user_id);

-- Referensi (food_items, akg, who, recommendations): baca publik, tulis service_role.
alter table public.food_items enable row level security;
alter table public.akg_reference enable row level security;
alter table public.who_growth_ref enable row level security;
alter table public.recommendations enable row level security;
drop policy if exists ref_read on public.food_items;
create policy ref_read on public.food_items for select using (true);
drop policy if exists ref_read_akg on public.akg_reference;
create policy ref_read_akg on public.akg_reference for select using (true);
drop policy if exists ref_read_who on public.who_growth_ref;
create policy ref_read_who on public.who_growth_ref for select using (true);
drop policy if exists ref_read_rec on public.recommendations;
create policy ref_read_rec on public.recommendations for select using (true);

-- 14. Seed: 25 item TKPI dari FoodDatabase (id sama dengan Dart).
insert into public.food_items
  (id, name, category, category_id, default_unit, default_portion_g,
   calories_per_100g, protein_per_100g, carbs_per_100g, fat_per_100g)
values
  ('nasi_putih','Nasi Putih','Karbohidrat','cat_karbohidrat','porsi',150,130,2.4,28.6,0.1),
  ('nasi_merah','Nasi Merah','Karbohidrat','cat_karbohidrat','porsi',150,111,2.6,23.5,0.9),
  ('roti_gandum','Roti Gandum','Karbohidrat','cat_karbohidrat','lembar',30,247,8.4,48.3,3.2),
  ('ubi_jalar','Ubi Jalar','Karbohidrat','cat_karbohidrat','buah sedang',100,86,1.6,20.1,0.1),
  ('singkong','Singkong','Karbohidrat','cat_karbohidrat','potong',80,154,1.2,36.8,0.3),
  ('ayam_goreng','Ayam Goreng','Protein Hewani','cat_protein_hewani','potong',80,298,24.8,3.0,20.2),
  ('ikan_goreng','Ikan Goreng','Protein Hewani','cat_protein_hewani','potong',60,253,26.0,0.0,16.0),
  ('telur_ayam','Telur Ayam','Protein Hewani','cat_protein_hewani','butir',55,154,12.4,0.7,10.8),
  ('daging_sapi','Daging Sapi','Protein Hewani','cat_protein_hewani','porsi',80,207,18.8,0.0,14.0),
  ('udang','Udang','Protein Hewani','cat_protein_hewani','porsi',80,91,21.0,0.0,0.8),
  ('tahu','Tahu','Protein Nabati','cat_protein_nabati','potong',80,68,7.8,1.6,4.6),
  ('tempe','Tempe','Protein Nabati','cat_protein_nabati','potong',50,201,20.8,13.5,8.8),
  ('kacang_merah','Kacang Merah','Protein Nabati','cat_protein_nabati','sendok makan',20,336,22.1,58.5,1.7),
  ('bayam','Bayam','Sayuran','cat_sayuran','porsi',100,36,3.5,4.5,0.5),
  ('kangkung','Kangkung','Sayuran','cat_sayuran','porsi',100,29,3.0,5.4,0.3),
  ('brokoli','Brokoli','Sayuran','cat_sayuran','porsi',100,34,2.8,6.6,0.4),
  ('wortel','Wortel','Sayuran','cat_sayuran','buah sedang',80,42,1.0,9.6,0.2),
  ('pisang','Pisang','Buah','cat_buah','buah',100,90,1.2,23.4,0.2),
  ('pepaya','Pepaya','Buah','cat_buah','potong',150,46,0.5,12.2,0.0),
  ('apel','Apel','Buah','cat_buah','buah',120,58,0.3,14.9,0.4),
  ('jeruk','Jeruk','Buah','cat_buah','buah',100,47,0.9,11.8,0.1),
  ('susu_sapi','Susu Sapi','Susu & Olahan','cat_susu_olahan','gelas',200,61,3.2,4.8,3.5),
  ('keju','Keju','Susu & Olahan','cat_susu_olahan','lembar',20,326,22.8,2.1,25.9),
  ('yogurt','Yogurt','Susu & Olahan','cat_susu_olahan','cup',150,59,3.5,7.0,1.5),
  ('jus_jeruk','Jus Jeruk','Minuman','cat_minuman','gelas',200,45,0.7,10.4,0.2)
on conflict (id) do update set
  name = excluded.name, category = excluded.category,
  category_id = excluded.category_id, default_unit = excluded.default_unit,
  default_portion_g = excluded.default_portion_g,
  calories_per_100g = excluded.calories_per_100g,
  protein_per_100g = excluded.protein_per_100g,
  carbs_per_100g = excluded.carbs_per_100g,
  fat_per_100g = excluded.fat_per_100g;

-- Seed AKG demo (ganti dengan tabel resmi).
insert into public.akg_reference
  (age_min_months, age_max_months, gender, calories, protein_g, carbs_g, fat_g)
values
  (0, 5, 'B', 550, 9, 60, 30),
  (6, 11, 'B', 800, 15, 105, 30),
  (12, 35, 'B', 1350, 20, 175, 45),
  (36, 60, 'B', 1400, 25, 190, 50)
on conflict do nothing;

-- Seed rekomendasi F-06.
insert into public.recommendations (status_category, age_min_months, age_max_months, content)
values
  ('Normal', 0, 5, 'ASI eksklusif + pantau BB/TB bulanan.'),
  ('Normal', 6, 60, 'Pertahankan menu seimbang + pantau kurva WHO tiap bulan.'),
  ('Pendek', 0, 60, 'MPASI tinggi protein + jadwal kontrol ke Puskesmas/posyandu. Pantau tiap bulan.'),
  ('Sangat Pendek', 0, 60, 'SEGERA ke Puskesmas/posyandu. MPASI tinggi protein + ASI bila <24 bln. Jangan tunda.'),
  ('Tinggi', 0, 60, 'Tinggi di atas +3SD. Konsultasikan ke tenaga kesehatan untuk evaluasi.')
on conflict do nothing;
