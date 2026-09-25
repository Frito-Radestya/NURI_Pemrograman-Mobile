# StuntingCare (NURI)

Aplikasi mobile Flutter untuk pencegahan stunting — **Kelompok Free Fire**.

Berdasarkan Mini SRS: **NURI** (Nutrisi & Risiko Stunting di Indonesia).

Dokumentasi kelengkapan tugas: [`DOKUMENTASI_TUGAS.md`](DOKUMENTASI_TUGAS.md)

## Fitur yang tersedia

1. **Splash** + branding NURI.
2. **Login** (validasi kredensial, 3 role, mode demo).
3. **Register** → **OTP (1234)** → Home.
4. **Lupa Password** → OTP → **Reset Password** (validasi kekuatan).
5. **Home**: hero WHO, kategori fitur, berita, banner Food Diary.
6. **Pencarian** informasi (artikel pengetahuan) dari Home & MPASI.
7. **Artikel pengetahuan**: stunting, standar WHO, MPASI, panduan MPASI,
   menu seimbang, berita, konsultasi.
8. **MPASI** → **Daftar Resep** (filter kategori) → **Detail Resep**
   (servings +/-, bookmark tersinkron).
9. **Food Diary** (CRUD): cari, filter kategori, tambah, **edit**, hapus,
   ringkasan gizi per sesi dan harian, relasi ke data anak.
10. **Data Anak** (CRUD): daftar, cari, filter status, detail, form
    tambah/edit, hapus, 20 record simulasi untuk role Kader.
11. **Profil & Pengaturan**: edit profil, pengaturan pengingat, tautan
    Data Anak & Food Diary, tentang aplikasi, dan logout.

## Struktur penting

```
lib/
├── data/          # FoodDatabase (25 item + 7 kategori), SampleData (resep)
├── models/        # UserModel, FoodEntry, ChildProfile, Recipe
├── services/      # AuthService, FoodDiaryService, ChildService,
│                  # RecipeService, AppSettingsService
├── screens/       # 15 layer (splash, auth, home, artikel, mpasi, resep,
│                  # food diary, data anak, profil)
└── widgets/       # komponen reusable
```

## Menjalankan

```bash
flutter pub get
flutter run
```

Kredensial demo (semua role memakai kata sandi `password123`):

| Role | Email / Kontak |
|------|----------------|
| Ibu Balita | `divaputri@gmail.com` |
| Ibu Hamil | `sitirahma@gmail.com` |
| Kader Posyandu | `081234567890` |

Kode OTP demo: `1234`.

## Pengujian

```bash
flutter analyze
flutter test
```

Test mencakup: login benar/salah, OTP, registrasi ganda, isolasi data antar
user, CRUD Food Diary, validasi porsi, CRUD Data Anak, filter resep, sinkronisasi
bookmark, dan halaman profil.

## Catatan

- Data masih simulasi **in-memory** (sesuai kebutuhan coursework), sudah
  diisolasi per `userId` dan dilengkapi relasi ID.
- Kamera/AI scan makanan, deteksi stunting otomatis, dan chatbot (FR-01,
  FR-04, FR-05, FR-06, FR-08) belum diintegrasikan.
- Beberapa gambar memakai URL eksternal; UI tetap aman saat gambar gagal dimuat.
