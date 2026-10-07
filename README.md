# NURI v2 — Nutrisi & Pertumbuhan Anak

Aplikasi Flutter (offline-first) untuk memantau pertumbuhan balita (z-score TB/U
standar WHO), mencatat asupan gizi harian vs AKG, dan mendukung kader Posyandu
(sesi + entri cepat + rekap). Desain mengikuti referensi Stitch dan PRD NURI v2.0.

## Menjalankan

```bash
flutter pub get
flutter run
```

### Mode demo (tanpa backend)
Bila Supabase tidak dikonfigurasi, aplikasi berjalan penuh secara **offline**
memakai data contoh (ibu "Sari" + anak "Alya"/"Bima"). Cocok untuk demo UI.

## Integrasi Supabase

Integrasi mencakup **Auth (email + kata sandi)**, **Postgres**, **RLS**, dan
**sinkronisasi dua arah** (unggah state lokal + tarik data pengguna). Bila tidak
dikonfigurasi, semua jalur cloud dilewati dan aplikasi tetap jalan offline.

### 1. Siapkan proyek Supabase
1. Buat proyek di <https://supabase.com>.
2. Buka **SQL Editor**, jalankan seluruh isi:
   `supabase/migrations/0001_nuri_schema.sql`
   (membuat tabel + kebijakan RLS untuk `profiles`, `children`,
   `guardian_consents`, `screening_sessions`, `measurements`, `screenings`,
   `food_log_items`).
3. (Opsional) Aktifkan **Email confirmation** di Authentication > Providers.

### 2. Berikan kredensial ke aplikasi
Jangan menuliskan kunci di kode. Gunakan `--dart-define`:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxxxxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=sb_publishable_...
```

Atau untuk build:

```bash
flutter build apk \
  --dart-define=SUPABASE_URL=https://xxxxxxxx.supabase.co \
  --dart-define=SUPABASE_PUBLISHABLE_KEY=...
```

Kunci yang dipakai adalah **publishable/anon key** (aman di klien karena RLS).
`--dart-define=SUPABASE_ANON_KEY` juga masih didukung. **JANGAN** pernah memakai
`sb_secret_...` / `service_role` di aplikasi.
Jangan pernah memakai `service_role` di aplikasi.

### 3. Alur
- **Daftar/Masuk** di layar akun → `authSignUp` / `authSignIn` memanggil Supabase
  Auth, lalu membuat baris `profiles` (id = `auth.uid()`).
- Setelah login, aplikasi **menarik** data pengguna (`pull()`) untuk mengisi
  penyimpanan lokal.
- **Sinkronkan sekarang** di Pengaturan memanggil unggah idempoten
  (upsert) sehingga tidak ada duplikat. Indikator status tampil di kartu
  Sinkronisasi.
- **Hapus item/akun** juga terhubung ke cloud (`deleteFoodItem`,
  `softDeleteChild`; `signOut`).

### 4. Uji RLS (disarankan)
1. Daftar dua akun berbeda (A dan B).
2. Tambah anak di A, lalu login B — B tidak boleh melihat anak A.
3. Sebagai kader (role = `kader`), anak boleh dibaca untuk skrining massal.

## Arsitektur singkat

```
lib/
  core/config/supabase_config.dart   # baca --dart-define
  data/
    reference_data.dart              # aset: WHO LMS, TKPI, AKG, rekomendasi
    nuri_repository.dart             # penyimpanan lokal + outbox + sync
    supabase_service.dart            # Auth + push/pull Supabase
    seed_data.dart                   # data contoh (mode offline)
  domain/                            # mesin Dart murni (Growth/Nutrition/Recommendation)
  state/app_state.dart               # ChangeNotifier + InheritedNotifier
  features/                          # layar (go_router)
supabase/migrations/                 # skema + RLS
assets/data/                         # who_lms.json (LMS resmi WHO 2006), tkpi, akg, rekomendasi
```

- **Z-score** dihitung lokal dari tabel **LMS resmi WHO 2006** (harian), memakai
  rumus LMS dan koreksi metode ukur ±0,7 cm; hasil identik dengan kalkulator WHO.
- UI tidak memanggil Supabase langsung; semua lewat `NuriRepository` (PRD Bagian 5).

## Uji

```bash
dart analyze     # bersih
flutter test     # unit domain + navigasi + responsif (320–1280 px)
```

## Catatan
- Tabel referensi (TKPI/AKG/WHO/rekomendasi) **tidak** disinkronkan; dibundel
  sebagai aset agar tetap tersedia offline.
- Penghapusan akun menghapus data lokal & sesi cloud. Penghapusan baris di
  server sepenuhnya (auth user) memerlukan service role / Edge Function.
