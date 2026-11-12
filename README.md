# NURI

**Nutrisi & Risiko Stunting di Indonesia** — aplikasi pendamping tumbuh kembang ibu dan balita untuk demo mata kuliah.

NURI adalah aplikasi Flutter Android (juga dapat dipreview di web) dengan tiga peran:

| Peran | Akun demo | Fokus |
| --- | --- | --- |
| Ibu hamil | `ibu@nuri.id` (Siti Rahma) | Kehamilan, TTD, ANC, diary makan, edukasi |
| Ibu balita | `ibu@nuri.id` / `sinta@nuri.id` | Pertumbuhan anak, z-score TB/U, MPASI, diary, rekomendasi |
| Kader Posyandu | `kader@nuri.id` (Nur Aisyah) | Roster sesi, pengukuran, rujukan, rekap, scan QR |

> **Catatan medis:** NURI adalah alat skrining awal, bukan diagnosis. Semua hasil pertumbuhan dan gizi perlu dikonsultasikan dengan bidan atau dokter. Disclaimer ini ditampilkan pada layar yang relevan.

---

## Cara menjalankan

Prasyarat: Flutter 3.47+ / Dart 3.13+ dan Android SDK untuk build APK.

```bash
flutter pub get
flutter run -d chrome          # preview web
flutter run -d <device-id>     # Android
flutter build apk --release    # APK demo
```

Hasil build APK: `build/app/outputs/flutter-apk/app-release.apk`.

Di Android, data demo disimpan di SQLite (`nuri.db`) dengan migrasi otomatis dari `SharedPreferences` lama (`nuri_state_v1`). Preview web tetap memakai `SharedPreferences`/localStorage. Untuk mengulang dari awal:

- **Android:** hapus data aplikasi / uninstall, atau gunakan tombol reset di Profil.
- **Web:** hapus `localStorage` untuk `127.0.0.1`, atau tombol reset di Profil.

### Firebase

- Proyek Firebase: `nuri-5cddb`
- Android package: `id.nuri.nuri`
- Konfigurasi Android: `android/app/google-services.json`
- SDK Flutter: `firebase_core` dan `firebase_auth`
- Firebase diinisialisasi di `main.dart`; bila konfigurasi gagal, aplikasi tetap berjalan dengan penyimpanan lokal.
- Aktifkan **Authentication → Sign-in method → Email/Password** di Firebase Console.

Alur login dan registrasi saat ini masih memakai akun demo lokal. Migrasi ke Firebase Auth dilakukan terpisah agar data demo dan alur offline tetap stabil.

### Akun demo

- `ibu@nuri.id` — Siti Rahma, ibu hamil + ibu dari Rafi (18 bulan).
- `sinta@nuri.id` — Sinta, ibu dari Maya Clarissa (22 bulan).
- `kader@nuri.id` — Nur Aisyah, kader Posyandu Melati II.

Password apa pun dengan **minimal 6 karakter** diterima untuk akun demo (contoh: `nuri123`). Tombol **Masuk sebagai Ibu** / **Masuk sebagai Kader** di halaman login juga tersedia. Pendaftaran akun baru membuat akun lokal di perangkat, bukan akun Firebase.

---

## Fitur yang dapat dicoba

### Ibu

- **Beranda** — ringkasan status anak/kehamilan, akses cepat ke pencatatan dan edukasi.
- **Pertumbuhan** — kurva TB/U dengan pita −3 SD, −2 SD, median, +2 SD, +3 SD; z-score dihitung dari tabel WHO HFA harian; input pengukuran dengan validasi; riwayat pengukuran dan catatan koreksi posisi.
- **Makan** — kamera (deteksi simulasi), pencarian manual TKPI, atur porsi gram, simpan ke diary; ringkasan energi/protein/lemak/karbohidrat terhadap AKG.
- **Diary** — rekap asupan harian, item per waktu makan, status gizi.
- **Rekomendasi** — menu MPASI/ibu hamil dengan estimasi gizi dan bahan.
- **Kehamilan** — checklist TTD, jadwal ANC, catatan pemeriksaan, dan alur "sudah melahirkan" yang membuat profil bayi.
- **Edukasi** — artikel bersumber Kemenkes dengan pencarian, filter, dan penanda sudah dibaca.
- **Profil** — ganti peran, kelola anak/kehamilan, kode QR keluarga & Posyandu, kontrol akses data untuk kader, pengingat, dan reset data.

### Kader

- **Dashboard** — statistik sesi (hadir, menunggu, tidak hadir), distribusi status gizi, dan daftar tindak lanjut.
- **Roster** — 52 sasaran demo (38 balita + 14 ibu hamil); cari, filter status, dan buka detail.
- **Tambah sasaran** — anak tanpa akun atau ibu hamil; validasi usia 0–59 bulan, BB/PB lahir, LiLA, dan Hb.
- **Pengukuran** — input TB/PB, berat, posisi ukur, tanggal; hasil z-score dan kategori langsung.
- **Rekap** — ringkasan sesi dan pratinjau CSV siap salin ke e-PPGBM.
- **Tindak lanjut** — daftar kasus stunting/berisiko, ubah status, catat tindakan.
- **Scan QR** — hasil scan disimulasikan; kode manual juga dapat dimasukkan.

---

## Arsitektur

```
lib/
  main.dart                     bootstrap, load aset, restore state
  app.dart                      MaterialApp, routing, splash, lokalisasi id_ID
  core/theme/                   warna, tipografi, komponen Material 3
  core/utils/                   formatter tanggal/angka
  domain/
    models.dart                 AppState, Child, Measurement, RosterEntry, dll.
    growth/                     tabel LMS WHO + GrowthCalculator
    nutrition/                  katalog TKPI + NutritionCalculator (AKG)
    pregnancy/                  PregnancyCalculator
  data/
    app_repository.dart         kontrak penyimpanan (seam Firebase)
    sqlite_repository.dart      penyimpanan Android: tabel per domain + migrasi
    local_repository.dart       fallback web/test berbasis SharedPreferences
    app_selectors.dart          selector Riverpod untuk rebuild terbatas
    demo_seed.dart              data demo 52 sasaran, artikel, akun
    app_controller.dart         state inti + re-export aksi fitur
    controllers/                aksi auth, kehamilan, anak, makan, kader
  features/
    landing/ auth/ shell/       alur masuk, onboarding, navigasi per peran
    mother/                     beranda, pertumbuhan, makan, diary, kehamilan
    kader/                      dashboard, roster, ukur, rekap, tindak lanjut
    profile/ education/         profil, privasi, artikel
  shared/                       widget dan primitif form yang dipakai ulang
assets/
  data/                         WHO HFA (LMS harian) + subset TKPI 2017
  fonts/ images/                Nunito, Inter, foto demo
test/
  domain_test.dart              36 uji domain + konsistensi data demo
  widget_test.dart              smoke test landing page
```

Prinsip utama:

- **Offline-first.** Di Android, state disimpan di SQLite dengan tabel terpisah untuk pengguna, anak, kehamilan, catatan makan, roster, sesi, konten, dan grant akses. Hanya perubahan baris yang ditulis ulang. Aksi kader dan pencatatan harian tidak membutuhkan jaringan.
- **Satu seam untuk backend.** UI dan `AppController` hanya bergantung pada `AppRepository`. Implementasi Firebase dapat menggantikan `SqliteRepository` tanpa mengubah layar.
- **Aksi terpisah per fitur.** `AppController` menyimpan state inti; aksi auth, kehamilan, anak, makan, dan kader berada di `lib/data/controllers/` dan memakai `commitState` sebagai satu jalur tulis.
- **Rebuild terbatas.** Selector di `app_selectors.dart` memakai `select()` agar dashboard kader tidak dibangun ulang saat data yang tidak relevan berubah.
- **Logika domain terpisah dari UI.** Perhitungan z-score, AKG, dan kehamilan dapat diuji tanpa widget.
- **Aset terbundel.** Tabel WHO dan TKPI dimuat saat startup; `WhoReference.setInstance` dan `FoodCatalog.setInstance` harus dipanggil sebelum `DemoSeed.build` (sudah dilakukan di `main.dart` dan setup test).

### Penyimpanan

- `SqliteRepository` membuat tabel `users`, `pregnancies`, `children`, `food_logs`, `roster`, `sessions`, `contents`, `access_grants`, dan `meta`.
- Setiap koleksi disimpan per baris (`id`, `payload` JSON), sehingga penambahan catatan makan atau sesi tidak menulis ulang seluruh state.
- Saat pertama dijalankan, data `SharedPreferences` lama dimigrasikan ke SQLite lalu kunci lama dihapus.
- Preview web memakai `LocalRepository` karena sqflite tidak tersedia di browser.

### Perhitungan pertumbuhan

- Tabel WHO Height-for-Age, harian, 0–1856 hari, terpisah laki-laki dan perempuan (1857 baris per tabel).
- Interpolasi linear antar baris harian; nilai di luar rentang di-clamp.
- z-score memakai metode LMS: `z = ((y/M)^L − 1) / (L × S)` (atau `ln(y/M)/S` saat `L = 0`).
- Koreksi posisi: **+0,7 cm** bila anak < 24 bulan diukur berdiri; **−0,7 cm** bila ≥ 24 bulan diukur berbaring. Koreksi dicatat pada hasil.
- Kategori: `z < −3` sangat pendek, `−3 ≤ z < −2` pendek, `−2 ≤ z ≤ +3` normal, `z > +3` tinggi.
- Nilai z ekstrem ditolak sebagai tidak masuk akal kecuali pengguna mengonfirmasi; hasil menyimpan versi tabel referensi.

### Perhitungan gizi

- 58 bahan pangan subset **TKPI 2017** (panganku.org), nilai per 100 g bagian dapat dimakan.
- Energi, protein, lemak, karbohidrat, serat, zat besi, zinc, kalsium, vitamin A, dan vitamin C.
- Target harian memakai **AKG Kemenkes 2019**, dipilih otomatis dari usia/jenis kelamin anak atau trimester kehamilan.
- Nutrisi yang tidak tersedia di TKPI ditampilkan sebagai data belum lengkap, bukan nol.
- Deteksi foto pada demo **disimulasikan**; jalur pencarian manual TKPI berfungsi penuh.

### Kehamilan

- HPL = HPHT + 280 hari (aturan Naegele), trimester berpindah pada minggu 14 dan 28.
- Progres kehamilan, ukuran janin ilustratif, checklist TTD, dan jadwal ANC.

---

## Data demo

Seed dirancang agar angka antarlayar konsisten:

- 52 sasaran: 38 balita + 14 ibu hamil.
- Sesi berjalan: 38 hadir, 12 menunggu, 2 tidak hadir.
- Distribusi balita: 31 normal, 5 pendek, 2 sangat pendek.
- 7 tindak lanjut aktif.
- Rafi: sarapan 375 kkal + makan siang 310 kkal = **685 kkal**, sesuai target tampilan.

Nama, usia, dan nominal mengikuti skenario PRD/screenshot. Data ini fiktif dan hanya untuk demonstrasi.

---

## Pengujian

```bash
flutter analyze   # harus: No issues found!
flutter test      # 37 test lulus
```

Cakupan test:

- LMS WHO: median, interpolasi, clamp, z = 0.
- Klasifikasi batas −3 SD, −2 SD, +3 SD; koreksi posisi; validasi input.
- Penurunan flag turunan `Measurement`.
- AKG per kelompok usia/trimester, status gizi, protein hewani, total nutrisi.
- Rumus HPL, trimester, progres, dan ukuran janin.
- Konsistensi data demo (52 sasaran, 38 hadir, distribusi kategori, 685 kkal, akun demo).
- Label ramah keluarga untuk kategori pertumbuhan.
- Aksi controller: login kader, pengukuran kader (hadir + antrean sinkron), dan pengukuran ibu (langsung tersinkron).
- Smoke test landing page setelah splash.

---

## Batasan demo

Ini adalah demo lokal untuk mata kuliah, bukan produk produksi:

1. **Firebase Auth baru terpasang sebagian.** Proyek `nuri-5cddb` sudah terhubung dan `firebase_core`/`firebase_auth` sudah diinisialisasi, tetapi login/registrasi masih memakai akun demo lokal. Firestore, Functions, FCM, App Check, dan Crashlytics belum aktif. Autentikasi lokal ini tidak aman untuk produksi.
2. **Sinkronisasi hanya simulasi UI.** Antrean "pending sync" dan tombol "Sinkronkan" tidak mengirim data ke server.
3. **Deteksi makanan disimulasikan.** Tidak ada model TFLite/dataset (PRD OQ-5). Jalur manual TKPI tetap lengkap.
4. **Scan QR disimulasikan.** Kode keluarga/Posyandu dibuat aplikasi; pemindaian kamera dan verifikasi grant server belum ada.
5. **Rekap CSV berupa pratinjau + salin.** Berbagi/menyimpan berkas dan integrasi e-PPGBM belum diimplementasikan.
6. **Edukasi statis.** Artikel dibundel; belum ada CMS/alur draft–tinjau–terbit.
7. **Web hanya untuk preview.** Target utama Android; di web data berada di `localStorage`.
8. **Belum ada verifikasi klinis.** Ambang, koreksi, dan konten perlu ditinjau bidan/dokter sebelum dipakai nyata.
9. **Aset gambar adalah foto demo.** Ganti dengan aset berlisensi dan atribusi lengkap sebelum publikasi.

### Jalur migrasi Firebase

1. Proyek `nuri-5cddb` dan Android app `id.nuri.nuri` sudah terdaftar. Pastikan Auth email/password aktif, lalu aktifkan Firestore, FCM, App Check, dan Crashlytics.
2. `firebase_core` dan `firebase_auth` sudah terpasang. Tambahkan `cloud_firestore`, `firebase_messaging`, `firebase_app_check`, dan `firebase_crashlytics` untuk tahap berikutnya.
3. Ganti `AppController.login/register` agar memakai Firebase Auth, lalu petakan Firebase UID ke dokumen pengguna dan data demo.
4. Buat `FirebaseRepository implements AppRepository` (atau pecah per koleksi) dan override provider di `main.dart`.
5. Pindahkan aturan akses grant, validasi peran, dan penulisan sesi ke Cloud Functions + security rules.
6. Ganti antrean sinkron lokal dengan mekanisme offline Firestore; pertahankan bentuk state agar UI tidak berubah.
7. Tambahkan TFLite dan model makanan saat dataset tersedia (OQ-5), lalu buka jalur foto.

---

## Sumber data & lisensi

- **WHO Child Growth Standards** — Height-for-Age, tabel LMS harian 0–1856 hari, laki-laki dan perempuan. Tabel diambil dari dataset publik `SunnySeedApp/who-growth-standards`.
- **TKPI 2017** — subset 58 bahan pangan, nilai per 100 g, bersumber dari panganku.org melalui dataset publik `intanypurbasari/food-nutrition`.
- **AKG Kemenkes 2019** — konstanta target energi dan zat gizi pada `nutrition_calculator.dart`.
- **Font** — Nunito dan Inter, SIL Open Font License.
- **Ikon** — Material Icons.
- Konten edukasi meringkas materi publik Kemenkes RI; sumber dicantumkan pada tiap artikel.

Data WHO/TKPI dibundel untuk demo akademik. Untuk penggunaan komersial, tinjau ulang ketentuan lisensi masing-masing sumber.
