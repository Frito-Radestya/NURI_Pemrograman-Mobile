# Dokumentasi Kelengkapan Tugas UTS — NURI (Kelompok Free Fire)

Dokumen ini memetakan setiap ketentuan pada slide tugas ke implementasi di
kode dan alur yang dapat didemokan.

## 1. Ide aplikasi

NURI (Nutrisi & Risiko Stunting di Indonesia) — aplikasi mobile Flutter untuk
pencegahan stunting bagi keluarga dan kader Posyandu.
Referensi: `Mini SRS Kelompok Free Fire.md`.

## 2. Persona utama

**Ibu Balita** (Diva Putri Adilla, 20–40 tahun, memiliki balita usia 0–5 tahun).
Tujuan utama: memantau gizi harian, mengenalkan MPASI bergizi, dan memantau
risiko stunting anak. Role `Ibu Balita` menjadi akun default dan demo utama.

## 3. Alur pengguna (4 alur lengkap)

| Alur | Langkah | Status |
|------|---------|--------|
| Login | Splash → Login (validasi) → Home | Berfungsi |
| Food Diary | Home → Food Diary → cari/filter → tambah → edit → hapus → ringkasan | Berfungsi |
| MPASI & Resep | Home → MPASI → Daftar Resep (filter) → Detail (servings, bookmark) | Berfungsi |
| Data Anak | Home/Profil → Data Anak → tambah → detail → edit → hapus | Berfungsi |
| Akun | Login → Register → OTP → Home / Lupa Password → OTP → Reset | Berfungsi |

## 4. Layer/fitur (15 screen)

1. Splash — `lib/screens/splash_screen.dart`
2. Login — `login_screen.dart`
3. Register — `register_screen.dart`
4. OTP — `otp_verification_screen.dart`
5. Lupa Password — `forgot_password_screen.dart`
6. Reset Password — `reset_password_screen.dart`
7. Home — `home_screen.dart`
8. Artikel pengetahuan — `article_screen.dart`
9. Menu MPASI — `mpasi_menu_screen.dart`
10. Daftar Resep — `recipe_list_screen.dart`
11. Detail Resep — `recipe_detail_screen.dart`
12. Food Diary — `food_diary_screen.dart`
13. Data Anak (daftar) — `child_list_screen.dart`
14. Detail/form Data Anak — `child_detail_screen.dart`, `child_form_screen.dart`
15. Profil & Pengaturan — `profile_screen.dart`

Jenis layer wajib: **daftar** (resep/data anak), **detail** (resep/data anak),
**form** (register/reset/tambah anak/tambah makanan), **profil & pengaturan**
(Profil & Pengaturan).

## 5. Modul CRUD + relasi ID

### Modul 1 — Food Diary (`lib/services/food_diary_service.dart`)

- Create: tambah entry makanan.
- Read: daftar per sesi + ringkasan gizi harian/per sesi.
- Update: edit porsi dan sesi makanan.
- Delete: swipe-to-delete.
- Relasi: `userId`, `foodItemId`, `categoryId`, `childId`, `dateKey`.

### Modul 2 — Data Anak (`lib/services/child_service.dart`)

- Create: tambah data anak.
- Read: daftar + pencarian + filter status + detail.
- Update: edit data anak.
- Delete: hapus data anak.
- Relasi: `ownerUserId`; `childId` dipakai Food Diary.

Tabel referensi kategori: `FoodDatabase.categoryIds` (7 kategori).
Katalog makanan: `FoodDatabase.items` (25 record, relasi `foodItemId`).

## 6. Jumlah record

| Data | Jumlah |
|------|--------|
| Makanan (FoodItem) | 25 |
| Kategori makanan | 7 |
| Data anak (role Kader) | 20 |
| Data anak demo (Ibu Balita) | 1 |
| Resep MPASI | 5 |
| Sesi makan | 4 |
| Artikel pengetahuan | 7 |

## 7. Fungsi utama, validasi, navigasi, dan state

- **Validasi login:** kredensial demo/terdaftar diverifikasi; password salah
  ditolak dengan pesan.
- **OTP:** hanya `1234` yang diterima.
- **Email/kontak:** pola email atau nomor `08...` divalidasi.
- **Password:** minimal 8 karakter + huruf + angka (register & reset).
- **Porsi makanan:** 1–2000 gram; nilai negatif ditolak.
- **Data anak:** nama, ibu, berat (1–40 kg), tinggi (30–130 cm) divalidasi.
- **Navigasi:** semua tombol utama memiliki tujuan; search bar membuka
  pencarian artikel; kartu kategori, hero, berita, panduan MPASI, laporan,
  dan konsultasi membuka layer artikel.
- **State:** diary terisolasi per `userId`; bookmark resep tersinkron via
  `RecipeService`; pengaturan profil tersimpan di `AuthService` saat runtime.

## 8. Pengujian

`flutter analyze` bersih. `flutter test` menjalankan 18 test:
login (berhasil/gagal), OTP, registrasi, isolasi data, CRUD Food Diary
(termasuk edit melalui UI), validasi porsi, CRUD Data Anak, filter resep,
sinkronisasi bookmark, dan halaman profil.
