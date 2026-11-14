# NURI

**Nutrisi & Risiko Stunting di Indonesia** — aplikasi pendamping tumbuh kembang ibu dan balita untuk demo mata kuliah.

NURI adalah aplikasi Flutter Android (juga dapat dipreview di web) dengan tiga peran:

| Peran | Fokus |
| --- | --- |
| Ibu hamil | Kehamilan, TTD, 6 jadwal ANC, skrining USG Kemenkes, gizi per trimester, konsultasi nakes |
| Ibu balita | Tumbuh kembang anak, grafik ramah awam (rentang normal WHO), diary makan TKPI, kode QR Posyandu |
| Kader Posyandu | Roster sasaran posyandu, sesi ukur offline, rekap CSV, scan QR keluarga, tindak lanjut stunting |

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
- SDK Flutter: `firebase_core`, `firebase_auth`, `cloud_firestore`, dan `google_sign_in`
- Firebase diinisialisasi di `main.dart`; bila konfigurasi gagal, aplikasi tetap berjalan dengan penyimpanan lokal.
- Database: Cloud Firestore dengan offline persistence; aturan keamanan tersedia di `firestore.rules`.
- Autentikasi: Email/Password dan Google Sign-In aktif.
- Kredensial akun pengujian awal khusus developer didokumentasikan di `DEV_ACCOUNTS.md` (tidak diekspos di UI publik).
- Akun kader baru memulai dari kondisi bersih (0 sasaran & 0 sesi posyandu).
- Di web preview, Firebase belum diinisialisasi sehingga login/registrasi memakai penyimpanan lokal.

### Design System 2.0 (Fresh Natural Green)

NURI mengusung identitas visual modern **Fresh Natural Green**:
- **Deep Forest (`#145C45`)**: Warna utama tombol primer, judul aksen, dan hero card.
- **Fresh Green (`#239B70`)**: Aksen sekunder, tombol sekunder, dan indikator aktif.
- **Leaf Green (`#72C99A`)**: Highlight, progress bar, dan status aktif.
- **Soft Mint (`#D9F0DF`)**: Section soft, container card, dan badge background.
- **Natural White (`#F4FAF4`)**: Background utama aplikasi.
- **Dark Green (`#263B32`)**: Teks utama dan heading.
- **Secondary Text (`#66766E`)**: Teks sekunder dan caption pendukung.
- **Pure White (`#FFFFFF`)**: Card surface dan modal dialog.
- **Warna Semantik Kesehatan Tetap Terjaga**: Normal (hijau `#239B70`), perhatian (amber `#D97706`), dan bahaya/rujukan (merah `#DC2626`).

---

## Fitur yang dapat dicoba

### Ibu

- **Beranda** — ringkasan status anak/kehamilan, akses cepat pencatatan, edukasi, dan pintasan konsultasi nakes.
- **Pertumbuhan** — grafik pertumbuhan ramah keluarga (area hijau rentang tumbuh normal WHO tanpa istilah teknis statistik membingungkan); titik pengukuran anak; kartu penjelasan informatif saat data masih kosong; kalkulasi z-score akurat dari WHO LMS harian.
- **Makan & Diary** — pencarian manual 58 bahan pangan TKPI 2017, porsi gram, simpan diary harian, ringkasan energi/protein/lemak/karbohidrat terhadap AKG 2019.
- **Rekomendasi Menu Trimester** — menu gizi spesifik untuk Trimester 1 (anti mual & asam folat), Trimester 2 (+300 kkal & kalsium), dan Trimester 3 (DHA & zat besi), serta panduan MPASI anak.
- **Kehamilan & Skrining USG** — checklist TTD harian, 6 jadwal kunjungan ANC sesuai standar Kemenkes, kartu edukasi skrining USG dokter (Trimester 1 konfirmasi janin/HPL & Trimester 3 taksiran berat lahir cegah stunting), dan konversi kelahiran ("sudah melahirkan") menjadi profil anak.
- **Konsultasi Bidan & Nakes** — daftar nakes resmi wilayah (bidan desa, perawat gizi), status siap konsultasi, tombol langsung chat WhatsApp dan telepon, serta panduan rujukan Puskesmas.
- **Profil & Privasi** — ubah nama, tambah anak/kehamilan, tampilkan Kode QR Keluarga untuk kader Posyandu, kelola/cabut akses kader, pengingat lokal, dan tombol **Reset akun** dengan konfirmasi dialog.

### Kader

- **Dashboard Posyandu** — sesi penimbangan aktif, sasaran hadir/belum/tindak lanjut, distribusi gizi (normal, pendek, sangat pendek). Akun kader baru dimulai dari 0 sasaran bersih.
- **Roster Sasaran** — tambah sasaran baru (anak tanpa akun atau ibu hamil), cari dan filter status.
- **Alur Ukur Cepat** — input TB/PB, berat, posisi ukur (terkoreksi otomatis sesuai umur <24 bln atau ≥24 bln); hasil z-score dan kategori tampil instan.
- **Rekap & Tindak Lanjut** — ringkasan sesi siap salin ke format e-PPGBM dan daftar tindak lanjut prioritas.
- **Penghubung Data Keluarga** — kader dapat memindai QR Kode Keluarga ibu untuk menghubungkan data anak ke roster Posyandu.
- **Scan QR** — hasil scan kamera dan kode manual keluarga.

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
  domain_test.dart              57 uji domain, auth, firestore CRUD, otorisasi grant, dan family linking
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
flutter test      # 58 test lulus
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
- Auth: pemetaan akun demo ke Firebase UID, pengguna Firebase baru, pesan error, fallback demo, registrasi, dan reset password.
- Firestore CRUD, Keamanan & Family–Cadre Linking: seeding dataset per akun demo, query terbatas per pemilik/Posyandu, kode keluarga sekali pakai (`NR-XXXX-XXXX`), kode klaim anak Posyandu (`KL-XXXX-XXXX`), penegakan cakupan grant (`ukur` vs `makan`), pencabutan grant seketika (`revokeGrant`), dan penanganan kegagalan sinkronisasi (`SYNC-03`).
- Smoke test landing page setelah splash.

---

## Batasan demo

Ini adalah demo lokal untuk mata kuliah, bukan produk produksi:

1. **Firebase Auth & Firestore aktif.** Login, registrasi, logout, reset password, dan sinkronisasi data (anak, pengukuran, kehamilan, catatan makan, sasaran roster, sesi) terhubung ke Firestore dengan persistensi lokal SQLite. Cloud Functions, FCM, App Check, dan Crashlytics belum aktif.
2. **Sinkronisasi dua arah ke Firestore.** Tombol "Sinkronkan" mengirim dan menarik data dari Firestore; integrasi e-PPGBM eksternal belum diimplementasikan.
3. **Deteksi makanan disimulasikan.** Tidak ada model TFLite/dataset (PRD OQ-5). Jalur manual TKPI tetap lengkap.
4. **Scan QR disimulasikan.** Kode keluarga/Posyandu dibuat aplikasi; pemindaian kamera dan verifikasi grant server belum ada.
5. **Rekap CSV berupa pratinjau + salin.** Berbagi/menyimpan berkas dan integrasi e-PPGBM belum diimplementasikan.
6. **Edukasi statis.** Artikel dibundel; belum ada CMS/alur draft–tinjau–terbit.
7. **Web hanya untuk preview.** Target utama Android; di web data berada di `localStorage`.
8. **Belum ada verifikasi klinis.** Ambang, koreksi, dan konten perlu ditinjau bidan/dokter sebelum dipakai nyata.
9. **Aset gambar adalah foto demo.** Ganti dengan aset berlisensi dan atribusi lengkap sebelum publikasi.

### Jalur migrasi Firebase

1. Proyek `nuri-5cddb` dan Android app `id.nuri.nuri` sudah terdaftar. Auth email/password dan Cloud Firestore sudah terintegrasi; security rules tersedia di `firestore.rules`.
2. `firebase_core`, `firebase_auth`, dan `cloud_firestore` sudah terpasang. Tambahkan `firebase_messaging`, `firebase_app_check`, dan `firebase_crashlytics` untuk tahap rilis produksi.
3. Aturan akses peran sudah didefinisikan di `firestore.rules` (Spark plan); Cloud Functions baru diperlukan bila beralih ke paket Blaze.
4. Mekanisme offline Firestore dan SQLite berjalan bersamaan agar UI tetap instan dan tahan tanpa koneksi.
5. Tambahkan TFLite dan model makanan saat dataset tersedia (OQ-5), lalu buka jalur foto.

---

## Sumber data & lisensi

- **WHO Child Growth Standards** — Height-for-Age, tabel LMS harian 0–1856 hari, laki-laki dan perempuan. Tabel diambil dari dataset publik `SunnySeedApp/who-growth-standards`.
- **TKPI 2017** — subset 58 bahan pangan, nilai per 100 g, bersumber dari panganku.org melalui dataset publik `intanypurbasari/food-nutrition`.
- **AKG Kemenkes 2019** — konstanta target energi dan zat gizi pada `nutrition_calculator.dart`.
- **Font** — Nunito dan Inter, SIL Open Font License.
- **Ikon** — Material Icons.
- Konten edukasi meringkas materi publik Kemenkes RI; sumber dicantumkan pada tiap artikel.

Data WHO/TKPI dibundel untuk demo akademik. Untuk penggunaan komersial, tinjau ulang ketentuan lisensi masing-masing sumber.
