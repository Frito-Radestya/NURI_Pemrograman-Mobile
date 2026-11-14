# Dokumentasi Lengkap Laman & Komponen UI Aplikasi NURI

Dokumen ini berisi spesifikasi seluruh laman (*screen*), sub-laman, dialog, dan lembar interaksi (*bottom sheet*) pada aplikasi NURI beserta daftar komponen penyusunnya.

---

## 1. Alur Masuk & Autentikasi (Auth & Onboarding)

### 1.1. Splash Screen
* **File:** `lib/app.dart` (`SplashScreen`)
* **Tujuan:** Layar pembuka transisi awal saat inisialisasi aplikasi (durasi 500ms atau ketuk layar).
* **Daftar Komponen UI:**
  * Kontainer logo berlatar warna mint dengan ikon `Icons.spa_rounded`.
  * Teks judul aplikasi `NURI` (tipografi Nunito, tebal, huruf kapital).
  * Teks sub-judul `Sahabat Ibu & Balita`.
  * Indikator muat berputar (`CircularProgressIndicator` warna hijau daun).
  * Teks penafian (*disclaimer*) pada bagian bawah: *"Skrining awal, bukan diagnosis."*

---

### 1.2. Landing Screen
* **File:** `lib/features/landing/landing_screen.dart` (`LandingScreen`)
* **Tujuan:** Pengenalan nilai aplikasi bagi pengguna baru dan pemilihan peran awal.
* **Daftar Komponen UI:**
  * **Top Bar:** Komponen logo ringkas `NuriLogo` dan tombol teks *"Lewati"*.
  * **Hero Carousel (`PageView` interaktif + timer otomatis 4,5 detik):**
    * Slide 1: Gambar keluarga, tag *"Ibu & Balita"*, *caption* *"Tumbuh kembang terpantau, hati lebih tenang."*
    * Slide 2: Gambar bayi, tag *"1000 Hari Pertama"*, *caption* *"Setiap sentimeter berarti. Pantau dari hari pertama."*
    * Slide 3: Gambar piring makan, tag *"Gizi Harian"*, *caption* *"Catat makan anak dengan porsi yang lebih tepat."*
    * Indikator titik slide animasi aktif/non-aktif.
  * **Teks Proposisi Nilai:** Teks tajuk *"Ibu Sehat, Awal Generasi Cemerlang"*.
  * **Lencana Kredensial (`_CredentialItem`):** Tiga lencana kredibilitas: *"Standar WHO"*, *"AKG 2019"*, dan *"Siap Offline"*.
  * **Kartu Pemilihan Peran (`_RoleCard`):**
    * Kartu *"Saya Ibu / Keluarga"* dengan ikon hati dan deskripsi fitur ibu.
    * Kartu *"Saya Kader Posyandu"* dengan ikon grup dan deskripsi fitur kader.
  * **Tautan Masuk:** Tombol teks *"Sudah punya akun? Masuk"*.
  * **Penafian Medis (`NuriDisclaimer`):** Kotak informasi batas klinis NURI.

---

### 1.3. Layar Masuk (Login Screen)
* **File:** `lib/features/auth/onboarding_screens.dart` (`LoginScreen`, `AuthScreen`)
* **Tujuan:** Masuk ke akun yang telah terdaftar dengan email/password atau Google Sign-In.
* **Daftar Komponen UI:**
  * **Header:** Tombol kembali bundar (`RoundIconButton`) dan logo ringkas (`NuriLogo`).
  * **Tajuk Laman:** Teks judul *"Selamat datang kembali"* dan deskripsi singkat.
  * **Pemilih Peran (`NuriSegmentedControl`):** Sakelar peran *Ibu / Keluarga* vs *Kader Posyandu*.
  * **Kartu Formulir Masuk (`AppCard`):**
    * Input Email (`NuriTextField`): Teks panduan dinamis sesuai peran, tipe keyboard email.
    * Input Kata Sandi (`NuriTextField`): Teks tersembunyi dengan tombol sakelar ikon visibilitas mata.
    * Kotak pesan peringatan galat (*error banner*) jika autentikasi gagal.
    * Tautan teks *"Lupa Password?"* (membuka dialog reset email `_ResetPasswordDialog`).
    * Tombol submit utama *"Masuk"* (`NuriButton`) dengan indikator proses loading.
  * **Pemisah Teks:** Garis pemisah dengan tulisan *"atau masuk dengan"*.
  * **Tombol Masuk Pihak Ketiga (`_GoogleSignInButton`):** Tombol dengan lukisan vektor logo Google kustom (`_GoogleLogoPainter`).
  * **Tautan Pendaftaran:** Tombol teks *"Belum punya akun? Daftar"*.

---

### 1.4. Layar Pendaftaran (Signup Screen)
* **File:** `lib/features/auth/onboarding_screens.dart` (`SignupScreen`)
* **Tujuan:** Pendaftaran akun baru untuk peran Ibu atau Kader.
* **Daftar Komponen UI:**
  * **Header:** Tombol navigasi kembali dan logo aplikasi.
  * **Pemilih Peran Pengguna:** Tab pilihan peran Ibu atau Kader.
  * **Formulir Input Data Diri:**
    * Input Nama Lengkap.
    * Input Email valid.
    * Input Kata Sandi dan Konfirmasi Kata Sandi.
    * Bidang Khusus Kader: Input Nama Posyandu, Desa/Kelurahan, dan Kecamatan.
  * **Persetujuan Ketentuan:** Checkbox persetujuan syarat dan kebijakan privasi kesehatan.
  * **Tombol Aksi:** Tombol *"Daftar Sekarang"* dan tautan kembali ke login.

---

### 1.5. Layar Persetujuan Privasi (Consent Screen)
* **File:** `lib/features/auth/onboarding_screens.dart` (`ConsentScreen`)
* **Tujuan:** Permintaan persetujuan penanganan data medis (*informed consent*) sesuai prinsip privasi.
* **Daftar Komponen UI:**
  * Kontainer ikon tameng keamanan data (`Icons.privacy_tip_rounded`).
  * Teks judul *"Persetujuan Privasi Data Kesehatan"*.
  * 4 Butir ringkasan transparansi data:
    1. Penyimpanan lokal utama (*offline-first*).
    2. Enkripsi sinkronisasi cloud.
    3. Kontrol penuh pembagian data ke Posyandu (dapat dicabut sewaktu-waktu).
    4. Kepatuhan perundang-undangan perlindungan data pribadi.
  * Tombol teks *"Baca Kebijakan Lengkap"* (membuka *bottom sheet* `_PolicySheet` & `_PolicySection`).
  * Kotak centang (*checkbox*) persetujuan pengguna.
  * Tombol aksi *"Setuju & Lanjutkan"*.

---

### 1.6. Penyiapan Peran Awal (Role Setup Screen)
* **File:** `lib/features/auth/onboarding_screens.dart` (`RoleSetupScreen`)
* **Tujuan:** Melengkapi profil awal sesaat setelah registrasi pertama kali.
* **Daftar Komponen UI:**
  * **Opsi Mode Ibu:**
    * Pilihan kondisi: *"Sedang Hamil"* atau *"Sudah Memiliki Anak"*.
    * Formulir Hamil: Input Hari Pertama Haid Terakhir (HPHT) atau Hari Perkiraan Lahir (HPL).
    * Formulir Anak: Input Nama Panggilan, Tanggal Lahir, Jenis Kelamin, Berat Lahir, Panjang Lahir.
  * **Opsi Mode Kader:**
    * Konfirmasi nama Posyandu, RT/RW wilayah binaan, dan estimasi sasaran balita.
  * Tombol aksi simpan dan masuk ke beranda.

---

## 2. Rangka Navigasi Aplikasi (`AppShell`)
* **File:** `lib/features/shell/app_shell.dart` (`AppShell`)
* **Tujuan:** Mengelola *state* navigasi halaman utama menggunakan `IndexedStack` dan bilah navigasi bawah (`NuriBottomNav`).

### Pembagian Bilah Navigasi:
1. **Navigasi Mode Ibu (5 Tab):**
   * Tab 0: **Beranda** (`MotherHomeScreen`)
   * Tab 1: **Tumbuh** (`GrowthDetailScreen`)
   * Tab 2: **Catat** (Tombol bulat menonjol di tengah; memicu aksi pintas membuka `FoodCameraScreen`)
   * Tab 3: **Edukasi** (`EducationScreen`)
   * Tab 4: **Profil** (`ProfileScreen`)
2. **Navigasi Mode Kader (5 Tab):**
   * Tab 0: **Sesi** (`KaderHomeScreen`)
   * Tab 1: **Sasaran** (`RosterScreen`)
   * Tab 2: **Rekap** (`RecapScreen`)
   * Tab 3: **Tindak** (`FollowUpScreen`)
   * Tab 4: **Profil** (`ProfileScreen`)

---

## 3. Laman-Laman Fitur Ibu & Keluarga

### 3.1. Beranda Ibu (Mother Home Screen)
* **File:** `lib/features/mother/mother_home.dart` (`MotherHomeScreen`)
* **Tujuan:** Dasbor utama pemantauan kehamilan, pertumbuhan anak, dan asupan nutrisi harian.
* **Daftar Komponen UI:**
  * **Header:** Ucapan salam waktu (*pagi/siang/sore/malam*), nama pengguna, tanggal lengkap, tombol lonceng notifikasi/pengingat (`_showNotifications` *sheet*), dan avatar profil pengguna dengan lencana sinkronisasi.
  * **Pengalih Konteks Kehamilan vs Anak:** Sakelar `NuriSegmentedControl` jika ibu memiliki data kehamilan aktif sekaligus profil anak.
  * **Hero Kehamilan (`_PregnancyHero`):**
    * Kartu trimester aktif dan hitung mundur usia minggu + hari ke HPL.
    * Kotak metrik: Perkiraan BB ibu, LiLA, dan status risiko KEK.
    * Tombol akses cepat: *"Kelola ANC"* dan *"Log TTD"*.
  * **Hero Balita (`_ChildHero`):**
    * Nama anak dan usia dalam format bulan.
    * Lencana status gizi balita standar WHO (`GrowthStatusBadge`).
    * Kotak metrik fisik (`_HeroMetric`): Berat Badan (BB), Tinggi/Panjang Badan (TB/PB), Lingkar Kepala (LK), dan selisih dibanding bulan lalu.
  * **Kartu Rutinitas Hamil (`_PregnancyTodayCard`):**
    * Checklist minum Tablet Tambah Darah (TTD) hari ini dengan tombol interaktif penanda minum.
    * Status jadwal kunjungan ANC terdekat.
    * Rekap periksa fisik kehamilan terakhir.
  * **Kartu Nutrisi Harian (`_NutritionCard`):**
    * Cincin visual persentase kalori harian (`_CalorieRing`).
    * Batang pencapaian makronutrien (`_MacroBar`): Karbohidrat, Protein, dan Lemak.
    * Nilai capaian mikronutrien (`_MicroValue`): Zat Besi, Kalsium, Asam Folat / Seng.
    * Tombol aksi: *"Buka Buku Makan"* (`DiaryScreen`), *"Foto Piring"* (`FoodCameraScreen`), dan *"Catat Ukur"* (`MeasurementInputScreen`).
  * **Pengingat Jadwal Posyandu (`_PosyanduReminder`):** Tanggal sesi terdekat, nama posyandu, dan dialog rincian lokasi posyandu.
  * **Spanduk Konsultasi:** Tombol pintas navigasi ke layanan nakes `ConsultationScreen`.
  * **Bagian Untuk Ibu (`_ForYouCard`):**
    * Kartu artikel edukasi rekomendasi harian.
    * Tombol ide menu/resep harian bergizi (`RecommendationScreen`).
  * **Penafian Medis:** Komponen `NuriDisclaimer`.

---

### 3.2. Detail Pertumbuhan Balita (Growth Detail Screen)
* **File:** `lib/features/mother/growth_screens.dart` (`GrowthDetailScreen`)
* **Tujuan:** Visualisasi data antropometri anak dan grafik pertumbuhan standar WHO.
* **Daftar Komponen UI:**
  * **Header Laman:** Pilihan nama anak (jika anak > 1) dan tombol aksi riwayat lengkap.
  * **Ringkasan Indikator Pertumbuhan (`_GrowthSummary` & `_SummaryStat`):**
    * Kartu status BB/U (Berat Badan menurut Umur).
    * Kartu status TB/U atau PB/U (Tinggi/Panjang Badan menurut Umur / Status Stunting).
    * Kartu status BB/TB (Berat Badan menurut Tinggi Badan / Status Wasting).
    * Kartu status IMT/U dan LK/U (Lingkar Kepala).
  * **Grafik Interaktif WHO (`_WhoChartCard`):**
    * Tombol sakelar kurva (BB/U, TB/U, BB/TB, LK).
    * Garis-garis deviasi standar WHO (-3 SD, -2 SD, 0 SD Median, +2 SD, +3 SD).
    * Titik plot penimbangan anak dari waktu ke waktu.
  * **Catatan Interpretasi Status:** Teks penjelasan kondisi anak saat ini dan saran stimulasi gizi.
  * **Pratinjau Riwayat Terakhir (`_HistoryPreview`):** Daftar 3 penimbangan terakhir.
  * **Tombol Aksi Mengambang (FAB):** Tombol *"Tambah Ukur"* membuka `MeasurementInputScreen`.

---

### 3.3. Formulir Catat Ukur (Measurement Input Screen)
* **File:** `lib/features/mother/growth_screens.dart` (`MeasurementInputScreen`)
* **Tujuan:** Penginputan data penimbangan berat badan, tinggi badan, dan lingkar kepala balita.
* **Daftar Komponen UI:**
  * **Field Tanggal:** Pemilih tanggal penimbangan.
  * **Input Berat Badan:** Kolom input angka (kg) hingga 2 desimal.
  * **Input Tinggi / Panjang Badan:** Kolom input angka (cm) hingga 1 desimal.
  * **Pilihan Cara Pengukuran:** Tombol pilihan Terlentang (biasanya usia < 24 bulan) atau Berdiri (usia ≥ 24 bulan).
  * **Input Lingkar Kepala & LiLA:** Kolom input angka opsional (cm).
  * **Kartu Pratinjau Langsung Z-Score (`_PreviewCard`):**
    * Perhitungan otomatis Z-score WHO saat angka diketik.
    * Pratinjau kategori hasil (misal: *Gizi Baik*, *Normal*, *Pendek*, *Gizi Kurang*).
  * Peringatan angka ekstrim tidak lazim (*implausible*) dengan dialog validasi konfirmasi.
  * Tombol submit *"Simpan Pengukuran"*.

---

### 3.4. Riwayat Pertumbuhan Lengkap (Growth History Screen)
* **File:** `lib/features/mother/growth_screens.dart` (`GrowthHistoryScreen`)
* **Tujuan:** Menampilkan seluruh log historis pengukuran anak.
* **Daftar Komponen UI:**
  * Daftar entri pengukuran kronologis (`_HistoryTile`).
  * Informasi rincian entri: Tanggal ukur, usia anak (bulan & hari), BB (kg), TB (cm), LK (cm), lencana status gizi, dan keterangan pihak pencatat (Mandiri / Posyandu).
  * Tombol opsi hapus entri (disertai dialog konfirmasi).

---

### 3.5. Alur Pencatatan Makanan (Food Flow)

#### A. Kamera Piring Makan (`FoodCameraScreen`)
* **File:** `lib/features/mother/food_flow.dart` (`FoodCameraScreen`)
* **Tujuan:** Mengambil foto makanan atau memilih gambar dari galeri.
* **Komponen:**
  * Jendela bidik kamera (*viewfinder*) dengan panduan kontur piring (`_ViewfinderPainter`).
  * Tombol flash, tombol pembalik kamera, dan tombol akses galeri.
  * Pemilih waktu makan (`_MealSelector`): Sarapan, Makan Siang, Selingan, Makan Malam.
  * Tombol rana (*shutter*) untuk mengambil foto.
  * Tombol navigasi *"Input Manual"* menuju pencarian katalog pangan.

#### B. Hasil Deteksi Piring (`DetectionResultScreen`)
* **File:** `lib/features/mother/food_flow.dart` (`DetectionResultScreen`)
* **Tujuan:** Konfirmasi dan revisi makanan hasil pindaian foto.
* **Komponen:**
  * Foto pratinjau piring yang diambil.
  * Daftar makanan terdeteksi (nama menu, porsi dasar, persentase keyakinan).
  * Tombol hapus makanan yang keliru.
  * Tombol *"Tambah Makanan Lain"* (membuka modal cari manual).
  * Tombol *"Lanjut ke Porsi"*.

#### C. Pencarian Makanan Manual (`ManualFoodSearchScreen`)
* **File:** `lib/features/mother/food_flow.dart` (`ManualFoodSearchScreen`)
* **Tujuan:** Mencari dan memilih bahan pangan dari katalog lokal AKG/DKBM.
* **Komponen:**
  * Kolom pencarian teks nama makanan.
  * Filter kategori: Makanan Pokok, Lauk Hewani, Lauk Nabati, Sayur, Buah, Camilan.
  * Daftar hasil pencarian dengan info kalori per porsi standar.
  * Tombol pilih menu.

#### D. Penyesuaian Porsi & Nilai Gizi (`PortionScreen`)
* **File:** `lib/features/mother/food_flow.dart` (`PortionScreen`)
* **Tujuan:** Menentukan ukuran porsi makanan yang dikonsumsi dan melihat rincian gizinya.
* **Komponen:**
  * Daftar makanan terpilih.
  * Pengatur porsi interaktif (tombol pengurang/penambah kelipatan porsi atau gramasi).
  * Kartu kalkulasi nutrisi seketika: Energi (kkal), Karbohidrat, Protein, Lemak, Zat Besi, Kalsium.
  * Kolom catatan tambahan opsional.
  * Tombol aksi *"Catat ke Buku Makan"*.

#### E. Layar Konfirmasi Berhasil Simpan (`FoodSuccessScreen`)
* **File:** `lib/features/mother/food_flow.dart` (`FoodSuccessScreen`)
* **Tujuan:** Umpan balik sukses setelah menyimpan catatan makan.
* **Komponen:**
  * Ilustrasi centang keberhasilan.
  * Ringkasan zat gizi yang berhasil dicatat (`_SuccessMetric`).
  * Teks persentase pemenuhan terhadap target AKG harian.
  * Tombol navigasi: *"Lihat Diary Makan"* atau *"Kembali ke Beranda"*.

---

### 3.6. Buku Catatan Makan / Diary Nutrisi (Diary Screen)
* **File:** `lib/features/mother/diary_screen.dart` (`DiaryScreen`)
* **Tujuan:** Rekapitulasi konsumsi makan harian dan pembanding target AKG.
* **Daftar Komponen UI:**
  * **Navigasi Tanggal (`_DateNavigator`):** Tombol hari sebelumnya, kalender tanggal, tombol hari berikutnya, dan tombol cepat *"Hari Ini"*.
  * **Ringkasan Asupan (`_DiarySummary`):** Total kalori harian, persentase target AKG, bilah capaian makronutrien (`_NutrientBar`: Karbo, Protein, Lemak) dan mikronutrien (Zat Besi, Kalsium, Asam Folat/Seng).
  * **Kartu Waktu Makan (`_MealCard`):** Kelompok kartu Sarapan, Makan Siang, Selingan, dan Makan Malam berisi rincian item makanan, foto hidangan, jumlah porsi, dan tombol hapus item.
  * **Tombol Aksi:** Tombol mengambang untuk mencatat makanan baru pada tanggal terpilih.

---

### 3.7. Fitur Kehamilan Lanjutan

#### A. Pelacak Tablet Tambah Darah (`TtdScreen`)
* **File:** `lib/features/mother/pregnancy_screens.dart` (`TtdScreen`)
* **Tujuan:** Memantau kepatuhan minum 90 tablet tambah darah selama masa kehamilan.
* **Komponen:**
  * Bilah progres target 90 tablet standar Kemenkes.
  * Tombol utama *"Minum TTD Hari Ini"* (otomatis berubah warna jika sudah dicatat).
  * Kalender interaktif bulanan dengan penanda centang hijau pada tanggal konsumsi.
  * Kartu statistik: Total tablet diminum, sisa target, dan rekor berturut-turut (*streak*).
  * Tips konsumsi TTD (anjuran minum bersama air putih/jeruk, larangan minum bersama teh/kopi).

#### B. Pemeriksaan Kehamilan ANC (`AncScreen`)
* **File:** `lib/features/mother/pregnancy_screens.dart` (`AncScreen`)
* **Tujuan:** Manajemen jadwal dan riwayat 6 kali kunjungan Antenatal Care (ANC).
* **Komponen:**
  * Kartu progres kepatuhan kunjungan ANC.
  * Daftar riwayat & jadwal 6 kunjungan ANC (`_AncTile`): Status jadwal/selesai, tanggal, lokasi periksa (Puskesmas/Bidan/Dokter SpOG), catatan medis.
  * Kartu jadwal USG wajib trimester 1 dan trimester 3 (`_UsgScheduleCard` & `_UsgMilestoneTile`).
  * Lembar formulir input/update kunjungan ANC (`_AncFormSheet` *bottom sheet*).

#### C. Riwayat Pemeriksaan Fisik Bumil (`PregnancyCheckupScreen`)
* **File:** `lib/features/mother/pregnancy_screens.dart` (`PregnancyCheckupScreen`)
* **Tujuan:** Log pemeriksaan fisik klinis ibu hamil.
* **Komponen:**
  * Daftar riwayat pemeriksaan (`_CheckupTile`): Berat Badan, Tekanan Darah (tensi), LiLA, TFU, DJJ, dan kadar Hb (`_CheckupValue`).
  * Indikator status risiko Kurang Energi Kronis (KEK).
  * Tombol aksi *"Tambah Pemeriksaan"* membuka `CheckupFormScreen`.

#### D. Formulir Pemeriksaan Fisik Bumil (`CheckupFormScreen`)
* **File:** `lib/features/mother/pregnancy_screens.dart` (`CheckupFormScreen`)
* **Tujuan:** Formulir pengisian parameter klinis ibu hamil.
* **Komponen:**
  * Input tanggal periksa.
  * Input Berat Badan (kg), Tekanan Darah (Sistolik & Diastolik mmHg), LiLA (cm).
  * Input Tinggi Fundus Uteri (cm), Detak Jantung Janin (bpm), dan Hemoglobin (g/dL).
  * Input lokasi pemeriksaan dan catatan keluhan.
  * Tombol submit simpan data.

#### E. Pencatatan Persalinan (`GiveBirthScreen`)
* **File:** `lib/features/mother/pregnancy_screens.dart` (`GiveBirthScreen`)
* **Tujuan:** Menutup masa kehamilan dan mengalihkan profil menjadi bayi/anak.
* **Komponen:**
  * Input tanggal persalinan.
  * Input nama lengkap dan nama panggilan bayi.
  * Pilihan jenis kelamin bayi (Laki-laki / Perempuan).
  * Input Berat Badan lahir (gram/kg), Panjang Badan lahir (cm), Lingkar Kepala lahir (cm).
  * Pilihan metode persalinan (Normal / Caesar) dan tempat bersalin.
  * Tombol konfirmasi *"Simpan & Buat Profil Bayi"*.

---

### 3.8. Rekomendasi Menu & Resep MPASI (Recommendation Screen)
* **File:** `lib/features/mother/recommendation_screen.dart` (`RecommendationScreen`)
* **Tujuan:** Inspirasi menu makanan bergizi seimbang berbasis pangan lokal terjangkau.
* **Daftar Komponen UI:**
  * **Spanduk Menu Utama (`_HeroBanner`):** Menu rekomendasi hari ini yang padat gizi mikro (misal: menu pencegah stunting).
  * **Panduan Kebutuhan:** Panduan kebutuhan trimester (`_TrimesterGuideCard`) atau panduan tekstur & frekuensi MPASI sesuai usia bulan anak.
  * **Pilihan Kategori Resep:** Tab filter kelompok MPASI 6-8 bulan, 9-11 bulan, 12-24 bulan, atau Ibu Hamil.
  * **Kartu Resep Makanan (`_MenuCard`):** Foto hidangan, metrik nilai gizi (`_RecipeMetric`), panduan takaran porsi (`_PortionGuide`), grid 4 Bintang MPASI (`_FourStarGrid`: Karbo, Prohe, Prona, Sayur/Buah), dan langkah pembuatan praktis (`_StepsCard`).

---

## 4. Laman-Laman Fitur Kader Posyandu

### 4.1. Beranda Kader / Sesi Posyandu (Kader Home Screen)
* **File:** `lib/features/kader/kader_home.dart` (`KaderHomeScreen`)
* **Tujuan:** Pusat komando operasional hari buka posyandu.
* **Daftar Komponen UI:**
  * **Header:** Avatar kader, identitas nama kader, nama Posyandu, dan tombol status sinkronisasi (`_SyncButton`) dengan indikator jumlah data lokal tertunda (*pending writes*).
  * **Kartu Sesi Posyandu (`_SessionCard`):**
    * Status sesi aktif atau selesai, tanggal pelaksanaan.
    * Metrik kehadiran sesi: Jumlah Hadir (D) vs Target Sasaran (S) beserta persentase cakupan D/S (`_SessionStat`).
    * Jumlah kasus yang membutuhkan tindak lanjut segera.
    * Tombol aksi utama *"Mulai Ukur / Scan"* menuju `ScanScreen`.
    * Tombol *"Selesaikan Sesi"* (dengan dialog konfirmasi penguncian rekap) atau *"Mulai Sesi Baru"*.
  * **Snapshot Status Gizi Sesi (`_NutritionSnapshot` & `_SnapshotCount`):**
    * Rekapitulasi status balita terukur pada sesi: Normal, Stunting (*Pendek*), Severely Stunting (*Sangat Pendek*), dan Wasting (*Gizi Kurang/Buruk*).
  * **Daftar Perhatian & Tindak Lanjut (`_FollowUpList` & `_FollowUpPreview`):** Daftar balita yang perlu rujukan faskes atau tidak hadir 2 sesi berturut-turut.

---

### 4.2. Pemindai QR & Kode Sasaran (Scan Screen)
* **File:** `lib/features/kader/scan_screen.dart` (`ScanScreen`)
* **Tujuan:** Identifikasi sasaran posyandu secara cepat melalui kode QR atau token token keluarga.
* **Daftar Komponen UI:**
  * Bingkai kamera pemindai dengan sudut bingkai visual (`_ScannerCorners`, `_Corner`) dan animasi garis laser bergerak.
  * Teks panduan pemindaian QR aplikasi NURI Ibu.
  * Tombol *"Masukkan Kode Keluarga"* (membuka *bottom sheet* input manual kode token `NR-XXXX-XXXX`).
  * Tombol pemindaian simulasi untuk pengujian lingkungan offline/demo.
  * **Lembar Hasil Temuan Sasaran (`_showFound`):**
    * Nama anak, umur, jenis kelamin, serta status cakupan izin data (*Ukur* / *Makan*).
    * Tombol langsung *"Mulai Ukur Sekarang"* (membuka formulir ukur mode kader).
    * Tombol *"Buka Profil Sasaran"*.

---

### 4.3. Roster Sasaran Posyandu (Roster Screen)
* **File:** `lib/features/kader/roster_screen.dart` (`RosterScreen`)
* **Tujuan:** Manajemen daftar seluruh sasaran balita dan ibu hamil di wilayah posyandu.
* **Daftar Komponen UI:**
  * **Pencarian Sasaran:** Kolom pencarian teks nama anak atau nama orang tua.
  * **Filter Chip Kategori (`_FilterChip`):** *Semua, Balita, Ibu Hamil, Butuh Tindak Lanjut, Hadir, Belum Hadir*.
  * **Daftar Kartu Sasaran (`_RosterTile`):**
    * Avatar, nama sasaran, umur / usia kehamilan, nama wali/suami.
    * Status kehadiran sesi (Hadir / Belum Hadir).
    * Lencana kategori gizi atau risiko KEK.
    * Indikator status akun tertaut (`linked: true/false`).
  * **Lembar Detail Sasaran (`_RosterDetailSheet`):**
    * Profil lengkap anak / ibu hamil dan catatan riwayat terakhir.
    * Tombol *"Catat Pengukuran"* (membuka formulir ukur balita atau pemeriksaan bumil `_PregnancyCheckupSheet`).
    * Tombol *"Buat Kode Klaim untuk Ibu (7 hari)"* (`createChildClaimCode` KL-XXXX-XXXX) untuk anak yang belum terhubung dengan akun aplikasi ibu.
    * Tombol *"Tandai Tindak Lanjut"* (`_QuickFollowUpSheet`) untuk mencatat rujukan puskesmas atau kunjungan rumah.
  * **Tombol Mengambang (FAB):** Tombol *"Tambah Sasaran"* menuju `AddTargetScreen`.

---

### 4.4. Tambah Sasaran Posyandu (Add Target Screen)
* **File:** `lib/features/kader/add_target_screen.dart` (`AddTargetScreen`)
* **Tujuan:** Menambahkan sasaran balita atau ibu hamil baru ke dalam basis data posyandu tanpa mewajibkan akun pengguna ibu.
* **Daftar Komponen UI:**
  * Pilihan tipe sasaran: Balita (`RosterType.child`) vs Ibu Hamil (`RosterType.pregnant`).
  * **Formulir Input Balita:**
    * Nama lengkap anak.
    * Pilihan jenis kelamin (Laki-laki / Perempuan).
    * Tanggal lahir (pemilih kalender).
    * Nama orang tua/wali.
    * Berat badan lahir (kg) dan panjang badan lahir (cm) opsional.
  * **Formulir Input Ibu Hamil:**
    * Nama lengkap ibu hamil.
    * Usia kehamilan (minggu).
    * Nama suami/pendamping.
    * Ukuran LiLA (cm) dan kadar Hemoglobin (g/dL) opsional.
  * Tombol submit *"Simpan Sasaran Baru"*.

---

### 4.5. Rekapitulasi Sesi & Laporan SKDN (Recap Screen)
* **File:** `lib/features/kader/recap_screen.dart` (`RecapScreen`)
* **Tujuan:** Rekap data hasil sesi penimbangan posyandu dan pelaporan SKDN standar Puskesmas.
* **Daftar Komponen UI:**
  * **Header:** Pemilih tanggal sesi posyandu dan tombol *"Ekspor Laporan"* (`_ExportButton`: salin teks laporan terformat untuk WhatsApp atau laporan tertulis).
  * **Kartu Ringkasan Sesi (`_SessionSummaryCard`):** Tanggal pelaksanaan, posyandu, nama kader penanggung jawab, status penguncian sesi.
  * **Blok Kartu Indikator SKDN (`_StatCard`, `_AttendanceCard`, `_AttendanceStat`):**
    * **S (Sasaran):** Jumlah total balita yang ada di wilayah posyandu.
    * **K (KMS):** Jumlah balita yang memiliki Buku KIA/KMS.
    * **D (Ditimbang):** Jumlah balita yang hadir dan ditimbang pada sesi ini.
    * **N (Naik):** Jumlah balita yang berat badannya naik dibanding bulan lalu.
    * Rasio keberhasilan program: D/S (tingkat partisipasi masyarakat) dan N/D (efektivitas tumbuh kembang).
  * **Rincian Distribusi Status Gizi WHO (`_DistributionDetail` & `_DistributionRow`):**
    * Distribusi BB/U: Gizi Baik, Gizi Kurang, Gizi Buruk.
    * Distribusi TB/U: Normal, Pendek (*Stunted*), Sangat Pendek (*Severely Stunted*).
    * Distribusi BB/TB: Normal, Kurus (*Wasted*), Obesitas.
  * **Rekapitulasi Sasaran Ibu Hamil:** Jumlah diperiksa, jumlah terindikasi KEK (LiLA < 23,5 cm), kasus anemia.
  * **Daftar Kasus Rujukan Sesi (`_FollowUpRow`):** Daftar anak yang direkomendasikan rujuk ke Puskesmas.

---

### 4.6. Tindak Lanjut & Kunjungan Rumah (Follow Up Screen)
* **File:** `lib/features/kader/followup_screen.dart` (`FollowUpScreen`)
* **Tujuan:** Pelacakan balita bermasalah gizi dan pencatatan hasil kunjungan ke rumah (*sweeping*).
* **Daftar Komponen UI:**
  * **Kartu Ringkasan Status Tindak Lanjut (`_SummaryTile`):** Metrik total kasus, kasus butuh kunjungan rumah, rujukan faskes, dan kasus terselesaikan.
  * **Filter Chip Kategori (`_FilterChip`):** *Semua, Kunjungan Rumah, Rujukan Puskesmas, Prioritas Tinggi, Selesai*.
  * **Daftar Kartu Kasus Tindak Lanjut (`_FollowUpCard`):**
    * Nama anak/ibu hamil, alamat domisili lengkap (dusun, RT/RW).
    * Kategori masalah (contoh: *Stunting*, *BB 2x Tidak Naik (2T)*, *Bumil KEK*, *Absen 2x Posyandu*).
    * Lencana prioritas urgensi (Merah untuk mendesak, Kuning untuk peringatan).
    * Tombol aksi komunikasi instan: Tombol Telepon dan Tombol WhatsApp langsung ke nomor orang tua.
    * Tombol aksi buka formulir pencatatan kunjungan (`_RecordFollowUpSheet`).
  * **Lembar Pencatatan Kunjungan Rumah (`_RecordFollowUpSheet`):**
    * Tanggal pelaksanaan kunjungan.
    * Pilihan materi edukasi/intervensi yang diserahkan (konseling PMBA, pemberian PMT).
    * Status tindak lanjut (Dalam Pemantauan / Dirujuk ke Puskesmas / Masalah Selesai).
    * Catatan kondisi perkembangan anak.
    * Tombol simpan laporan kunjungan.

---

## 5. Fitur Bersama (Shared Features)

### 5.1. Pusat Edukasi Kesehatan (Education Screen)
* **File:** `lib/features/education/education_screen.dart` (`EducationScreen`)
* **Tujuan:** Perpustakaan artikel kesehatan ibu dan anak berbasis bukti medis.
* **Daftar Komponen UI:**
  * **Kolom Pencarian:** Pencarian artikel berdasarkan kata kunci judul atau isi.
  * **Filter Topik Kategori (`_CategoryChip`):** *Semua, Kehamilan, Nutrisi, Pertumbuhan, MPASI, Tanda Bahaya*.
  * **Artikel Utama Sorotan (`_FeaturedArticle`):** Spanduk kartu besar bergambar dengan estimasi waktu baca (menit), tag topik, dan ikon bookmark simpan artikel.
  * **Daftar Baris Artikel (`_ArticleRow`):** Gambar mini (*thumbnail*), judul artikel, cuplikan ringkasan isi, estimasi waktu baca, serta tanda bacaan telah diselesaikan.

---

### 5.2. Halaman Baca Artikel Edukasi (Article Detail Screen)
* **File:** `lib/features/education/education_screen.dart` (`ArticleDetailScreen`)
* **Tujuan:** Laman membaca konten artikel secara mendalam.
* **Daftar Komponen UI:**
  * **Header:** Tombol kembali dan tombol simpan bookmark artikel.
  * **Gambar Utama:** Foto sampul beresolusi penuh.
  * **Informasi Metadata:** Kategori artikel, tanggal rilis, dan peninjau medis (*Medical Reviewer*).
  * **Isi Artikel:** Teks terstruktur dengan sub-bab, poin penting, dan gaya tipografi bersih.
  * **Kotak Pesan Kunci:** Ringkasan inti artikel yang wajib diingat ibu/kader.
  * **Rekomendasi Artikel Terkait:** Daftar artikel serupa di bagian bawah laman.

---

### 5.3. Konsultasi Bidan & Tenaga Kesehatan (Consultation Screen)
* **File:** `lib/features/consultation/consultation_screen.dart` (`ConsultationScreen`)
* **Tujuan:** Menghubungkan pengguna dengan Bidan Desa, Perawat, atau Dokter Puskesmas terdekat.
* **Daftar Komponen UI:**
  * **Header:** Informasi pendampingan tenaga kesehatan resmi wilayah setempat.
  * **Panduan 3 Langkah Konsultasi (`_StepRow`):** Langkah memilih nakes, menyiapkan ringkasan grafik NURI, dan membuka kontak komunikasi.
  * **Daftar Kartu Tenaga Kesehatan (`_NakesCard`):**
    * Foto profil nakes.
    * Nama lengkap beserta gelar (contoh: *Bd. Siti Nurhaliza, S.Tr.Keb* / *dr. Hendra Wijaya, Sp.A*).
    * Jabatan dan instansi faskes (Bidan Desa Poskesdes, Dokter Puskesmas).
    * Jadwal operasional / status jam tugas aktif.
    * Tombol kontak instan: Tombol *"WhatsApp"* dan Tombol *"Telepon"*.
  * **Kotak Kontak Darurat:** Nomor panggilan darurat 119 dan IGD Puskesmas 24 Jam.
  * **Penafian Konsultasi:** Penjelasan bahwa kontak via NURI merupakan komunikasi pendampingan rujukan, bukan pengganti pemeriksaan fisik darurat.

---

### 5.4. Profil Pengguna, Keluarga & Sinkronisasi (Profile Screen)
* **File:** `lib/features/profile/profile_screen.dart` (`ProfileScreen`)
* **Tujuan:** Pengaturan akun, manajemen subjek keluarga, integrasi Posyandu, dan kontrol sinkronisasi data.
* **Daftar Komponen UI:**
  * **Kartu Identitas Pengguna (`_ProfileCard`):** Avatar, nama lengkap, lencana peran (Ibu / Kader), alamat email, nomor telepon, dan nama Posyandu terdaftar.
  * **Bagian Pengaturan Mode Ibu:**
    * **Daftar Profil Anak (`_ChildRow`):** Nama anak, usia, status gizi terakhir, tombol edit/kelola, dan tombol *"Tambah Data Anak"* (`_AddChildSheet`).
    * **Kartu Kehamilan Aktif (`_PregnancyCard`):** Usia kehamilan berjalan, tanggal HPL, status TTD & ANC (`_PregnancyStat`), tombol menuju persalinan (`_PregnancyAction` -> `GiveBirthScreen`), dan tombol *"Tambah Kehamilan"* (`_AddPregnancySheet`).
    * **Koneksi Keluarga & Posyandu (`_FamilyCodeCard`):**
      * Tombol *"Buat QR / Kode Keluarga"* (`_FamilyCodeGeneratorSheet`): Menghasilkan token acak 24 jam `NR-XXXX-XXXX` dengan toggle izin data ukur dan catatan makan.
      * Tautan *"Klaim Profil Anak dari Kader"*: Input token klaim 7 hari `KL-XXXX-XXXX` untuk mengambil alih data anak dari kader.
      * Daftar izin akses kader posyandu yang sedang aktif beserta tombol *"Cabut Akses"*.
  * **Bagian Pengaturan Mode Kader:**
    * **Kartu Identitas Posyandu (`_PosyanduCard`):** Nama Posyandu, Dusun/RT/RW, Desa/Kelurahan, Kecamatan, Kabupaten/Kota, dan ID Posyandu.
  * **Kartu Sinkronisasi Data (`_SyncCard`):**
    * Status mesin penyimpanan: SQLite (Android) / SharedPreferences (Web) dan Cloud Firestore.
    * Jumlah data lokal yang belum diunggah (*pending writes*).
    * Waktu sinkronisasi terakhir.
    * Tombol aksi manual *"Sinkronkan Sekarang"*.
  * **Kartu Privasi & Keamanan (`_PrivacyCard`):** Tautan membaca kebijakan privasi dan dokumen perlindungan data anak.
  * **Tombol Keluar:** Tombol aksi logout dengan konfirmasi keamanan.

---

## 6. Komponen Bersama & Desain Sistem (Design System & Shared Widgets)

### 6.1. Shared UI (`lib/shared/ui.dart`)
* `NuriPage`: Pembungkus halaman terstandar dengan penanganan `SafeArea` dan warna latar cream.
* `NuriTapScale`: Animasi mikro penekanan tombol (*spring bounce effect* saat disentuh).
* `NuriTextField`: Kolom input teks terstandar dengan label, ikon awalan, ikon akhiran, dan penanganan status galat.
* `NuriDateField`: Kolom pemilih tanggal interaktif dengan modal kalender terintegrasi.
* `NuriSegmentedControl<T>`: Sakelar pemilih opsi berbentuk tab pil geser.
* `NuriButton`: Tombol aksi utama, sekunder, atau outline dengan dukungan status memuat (*loading state*).
* `NuriNumberStepper`: Komponen pengubah angka bertahap (+/-) untuk porsi makanan.
* `NuriDisclaimer`: Spanduk informasi batas medis klinis aplikasi NURI.

### 6.2. Shared Widgets (`lib/shared/widgets.dart`)
* `NuriLogo`: Komponen logo resmi NURI dengan pilihan mode penuh atau ringkas (*compact*).
* `AppCard`: Kontainer kartu dengan radius melengkung halus, border tipis, dan elevasi bayangan konsisten.
* `SectionHeader`: Header judul bagian yang dilengkapi tombol aksi teks opsional (*Lihat Semua*).
* `Pill`: Lencana status berwarna dengan teks kecil padat.
* `AppAvatar`: Avatar inisial atau foto pengguna dengan opsi cincin indikator lencana.
* `GrowthStatusBadge`: Lencana klasifikasi status gizi WHO dengan warna indikator standar (Hijau: Normal, Kuning: Waspada, Merah: Rujukan).
* `SyncBadge`: Indikator status koneksi offline/online dan sinkronisasi data.
* `MetricBox`: Kartu vertikal penampil angka metrik antropometri (nilai, satuan, label).
* `NuriBottomNav`: Bilah navigasi bawah 5 tab dengan tombol aksi tengah yang menonjol.
* `ScreenHeader`: Header atas standar dengan judul laman, subjudul, dan tombol kembali bundar.
* `EmptyState`: Tampilan ilustrasi dan teks jika data daftar masih kosong.
