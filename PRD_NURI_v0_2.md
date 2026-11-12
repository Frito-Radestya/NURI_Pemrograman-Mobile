# PRD — NURI v0.2 (Nutrisi & Risiko Stunting di Indonesia)

## 0. Informasi dokumen

| Item | Isi |
|---|---|
| Versi | 0.2 (draft untuk ditinjau tim) |
| Tanggal | 9 November 2026 |
| Menggantikan | PRD v0.1 (`PRD_NURI.md`); perubahan dirinci di §0.2 |
| Tim | Kelompok Free Fire — Frito Radestya S. (241401030), Akief Maulana Aulia (241401072) |
| Konteks | Tugas kuliah. Target akhir: APK Android yang berjalan end-to-end di perangkat uji |
| Platform dan stack | Flutter (Android), Firebase (Authentication, Cloud Firestore, Cloud Functions, Cloud Messaging, App Check, Crashlytics), TensorFlow Lite on-device |
| Dokumen terkait | `NURI_Product_Specification_for_AI_Coding_Agent.md`, Mini SRS Kelompok Free Fire, daftar sumber riset (§20-D) |

### 0.1 Konvensi

| Penanda | Arti |
|---|---|
| **M / S / C** | Prioritas: **M** wajib MVP, **S** sebaiknya masuk bila waktu cukup, **C** ditunda |
| **[Frito]** | Keputusan yang Anda nyatakan langsung |
| **[Usulan]** | Default yang saya usulkan. Boleh diubah, dan menunggu konfirmasi |
| **[Verifikasi]** | Klaim atau angka yang harus dicek ke sumber resmi saat implementasi |
| **[OQ-n]** | Merujuk ke §19 (Open Questions) |
| Aturan penulisan | Tidak ada asumsi yang ditulis sebagai fakta. Angka contoh selalu diberi label "Contoh" |

### 0.2 Perubahan dari v0.1

| Area | v0.1 | v0.2 | Alasan |
|---|---|---|---|
| Peran | Ibu balita + kader; ibu hamil ditunda ke v2 | Tiga peran: ibu hamil (versi ringan), ibu balita, kader | Permintaan Anda. Pencegahan paling efektif dimulai dari kehamilan (1000 HPK) |
| Backend | Supabase | Firebase | Keputusan Anda |
| Penghubung antar peran | Tidak ada | Model keluarga, kode penghubung, dan akses atas persetujuan (§5) | Flow v0.1 belum menjelaskan data mana yang berpindah antar peran |
| Struktur alur | Daftar fitur | Perjalanan per peran dan 7 alur lintas peran (§6) | Flow sebelumnya terasa belum jelas |
| Foto anak sebagai indikator stunting | Masuk MVP (K2) | Dikeluarkan dari MVP | Tidak ada dasar ilmiah di PRD (OQ-15), dataset belum ada, dan spesifikasi agent menyatakan out of scope. **Perlu konfirmasi Anda karena K2 v0.1 sudah dikunci** |
| Offline | OQ-2 terbuka | Offline-first untuk alur kader dan pencatatan | Sinyal di lokasi Posyandu tidak stabil; Firestore menyediakan cache offline di Android |
| Chatbot Groq | OQ-1 terbuka | Ditunda ke v2 | Kunci API tidak boleh ada di aplikasi; butuh proxy server dan batas pemakaian |
| Lokasi Posyandu terdekat | OQ-1 terbuka | C | Bukan kebutuhan inti alur |
| Landing | Tidak ada | Hero carousel foto bayi yang bergeser otomatis (F-01) | Permintaan Anda |
| Scan makanan | 80 kelas (SRS) | Jalur manual TKPI wajib lebih dulu; model 20–30 kelas bila data tersedia | Dataset belum ada (OQ-5) |
| Data referensi | Tidak ditentukan | Tabel WHO LMS, TKPI, dan AKG dibundel di aplikasi | Hemat biaya baca, bisa offline, dan versinya terkunci |

---

## 1. Ringkasan dan masalah

### 1.1 Deskripsi produk

NURI adalah aplikasi Android yang membantu keluarga dan kader Posyandu memantau gizi dan pertumbuhan sejak kehamilan sampai anak berusia 59 bulan. Tiga peran memakai satu data keluarga yang terhubung atas persetujuan pemilik data. NURI mendukung deteksi dini dan pencegahan risiko stunting lewat pemantauan, pencatatan, dan edukasi. NURI **bukan** alat diagnosis maupun pengobatan.

### 1.2 Prinsip produk

| # | Prinsip | Konsekuensi desain |
|---|---|---|
| P1 | Skrining awal, bukan diagnosis | Disclaimer di setiap hasil; status selalu disertai saran ke fasilitas kesehatan |
| P2 | AI mengidentifikasi, pengguna memverifikasi, data tepercaya menghitung | Hasil deteksi makanan tidak pernah dianggap benar sebelum dikonfirmasi; gizi dihitung dari tabel TKPI, bukan oleh model bahasa |
| P3 | Satu data keluarga, banyak peran | Akses antar peran selalu melalui persetujuan yang bisa dicabut |
| P4 | Kader bekerja offline dulu | Semua alur sesi Posyandu berjalan tanpa sinyal |
| P5 | Jujur soal ketidakpastian | Tidak ada angka karangan; data kosong tidak diperlakukan sebagai nol |

### 1.3 Masalah dan bukti

| Pihak | Masalah | Bukti dan catatan |
|---|---|---|
| Ibu hamil | Kepatuhan tablet tambah darah (TTD) rendah, anemia tinggi, pemeriksaan kehamilan kurang memadai | Riskesdas 2018: 6,7% ibu hamil mengonsumsi TTD sesuai standar 90 tablet; anemia ibu hamil 48,9%. Kajian Kemenkes: sekitar 40% ibu hamil tidak mendapat pemeriksaan kehamilan yang memadai. Angka Riskesdas berasal dari 2018, **[Verifikasi]** ke rilis terbaru |
| Ibu balita | Sulit memahami grafik pertumbuhan dan istilah gizi; tidak selalu bisa hadir ke Posyandu | Laporan pengabdian masyarakat E-GIZI (Kediri) dan kajian kualitatif peran kader. Berskala lokal, tidak digeneralisasi |
| Kader | Pencatatan manual, hitung status gizi manual, dan kualitas pengukuran tinggi badan | Studi IPB (Toraja Utara): data e-PPGBM menghasilkan prevalensi 30,9% dibanding 39,9% pada gold standard, sensitivitas 70,7%. Studi UNRAM menyebut ketidaktepatan pengukuran dapat mencapai 10–20%. Keduanya studi lokal |
| Sistem | Data lapangan tidak tersambung ke keluarga | Tinjauan literatur: koordinasi kader–tenaga kesehatan dan integrasi data masih terbatas |
| Prioritas intervensi | Pencegahan paling efektif sebelum dan saat kehamilan | Pernyataan Menkes (Desember 2022): prioritas tertinggi adalah ibu hamil dan calon ibu; stunting yang sudah terjadi hanya sekitar 6% yang dapat pulih |

Angka stunting nasional dan target pemerintah di PRD v0.1 (21,6% dan 14%) tetap dipakai sebagai konteks. **[Verifikasi]** terhadap rilis SSGI terbaru sebelum dikutip di laporan kuliah.

### 1.4 Posisi terhadap aplikasi yang sudah ada

| Celah di aplikasi existing | Bukti | Respons NURI |
|---|---|---|
| Rekomendasi makanan bergizi tidak tersedia | Tabel perbandingan fitur (Telkom University) menunjukkan fitur ini kosong pada Simpati, MyBidan, Elsimil, STUNTECH, dan estuntad | Scan makanan, hitung gizi, dan perbandingan AKG |
| Sangat bergantung pada internet | Stunting Care, e-PPGBM, e-HDW, dan Elsimil dicatat sangat bergantung jaringan | Offline-first untuk kader |
| Data kader dan keluarga terpisah | Tinjauan literatur Gosting dan Posyandu mobile | Model keluarga dan akses atas persetujuan (§5) |
| Notifikasi untuk balita yang tidak hadir | Saran dari studi e-PPGBM Tangerang Selatan | Daftar tindak lanjut kader (F-10.8) |
| Kesinambungan hamil ke balita | Banyak aplikasi hanya melayani salah satunya | Konversi kehamilan menjadi profil anak (Alur 6) |

---

## 2. Keputusan produk

| # | Keputusan | Status | Catatan |
|---|---|---|---|
| K1 | Platform Android saja, dibangun dengan Flutter | [Frito] | Melanjutkan K3 v0.1 |
| K2 | Backend Firebase: Authentication, Cloud Firestore, Cloud Functions, Cloud Messaging, App Check, Crashlytics | [Frito] | Menggantikan Supabase |
| K3 | Tiga peran pengguna: ibu hamil, ibu balita, kader Posyandu. Admin konten dikelola terpisah di back-office | [Frito] untuk tiga peran; [Usulan] untuk admin terpisah | "Kader (admin)" dipisah menjadi kader (operator lapangan) dan admin (pengelola konten) |
| K4 | Status pertumbuhan hanya dari z-score WHO (TB/U atau PB/U) berdasarkan input manual. Foto anak dikeluarkan dari MVP | [Usulan] | Mengubah K2 v0.1. Perlu konfirmasi |
| K5 | Ibu hamil masuk MVP versi ringan: pemeriksaan, TTD, ANC, diary gizi, edukasi | [Usulan] | Mengubah jadwal v2 v0.1 |
| K6 | Satu akun ibu dapat memiliki kehamilan dan anak sekaligus. Mode tampilan ditentukan data, bukan akun terpisah | [Usulan] | Menjawab OQ-3 |
| K7 | Kader hanya melihat data keluarga ber-akun setelah ibu memberi akses (grant) yang dapat dicabut | [Usulan] | Menjawab sebagian OQ-9 |
| K8 | Offline-first untuk alur kader dan pencatatan harian memakai cache offline Firestore | [Usulan] | Android mengaktifkan persistence secara default |
| K9 | Tabel WHO LMS, TKPI, dan AKG dibundel di aplikasi sebagai aset berversi | [Usulan] | Tidak disimpan di Firestore |
| K10 | Chatbot Groq tidak masuk MVP (v2) | [Usulan] | Butuh proxy Cloud Functions |
| K11 | Foto makanan tidak diunggah ke server di MVP; disimpan sementara di perangkat lalu dihapus | [Usulan] | Menjawab OQ-8; menghindari Cloud Storage |
| K12 | Jalur input manual (pencarian TKPI) wajib lengkap lebih dulu; deteksi foto adalah peningkatan bila model tersedia | [Usulan] | Menurunkan risiko dataset (OQ-5) |
| K13 | Definisi selesai: APK berjalan end-to-end di perangkat uji untuk demo dan penilaian dosen | [Frito] | Melanjutkan K6 v0.1 |
| K14 | Lokasi database Firestore: `asia-southeast2` (Jakarta), dipilih sejak awal | [Usulan] | Lokasi tidak dapat diubah setelah database dibuat |

---

## 3. Goals, non-goals, dan metrik

### 3.1 Goals (MVP)

| ID | Goal |
|---|---|
| G1 | Ibu hamil memantau pemeriksaan, TTD, kunjungan ANC, dan gizi harian |
| G2 | Ibu balita mengetahui status pertumbuhan anak (z-score WHO) dan memahami artinya |
| G3 | Ibu mencatat makanan dan melihat pemenuhan gizi terhadap AKG |
| G4 | Kader menyelesaikan satu sesi Posyandu (input, klasifikasi, rekap, tindak lanjut) tanpa hitung manual dan tanpa sinyal |
| G5 | Data terhubung antar peran atas persetujuan, dengan akses yang bisa dicabut |
| G6 | Pengguna mendapat rekomendasi tindak lanjut sesuai status |
| G7 | Data ibu dan anak terlindungi sesuai UU PDP |
| G8 | APK stabil dan berjalan end-to-end |

### 3.2 Non-goals

| ID | Non-goal |
|---|---|
| NG1 | Diagnosis medis, atau klaim mencegah/mengobati penyakit |
| NG2 | Telemedicine dan konsultasi dokter langsung |
| NG3 | Deteksi stunting dari foto anak |
| NG4 | Chatbot berbasis LLM di MVP |
| NG5 | Platform iOS |
| NG6 | Rilis Play Store dan validasi klinis penuh |
| NG7 | Integrasi otomatis ke e-PPGBM atau sistem Puskesmas |
| NG8 | Estimasi berat makanan dari foto |
| NG9 | Penjualan produk atau suplemen |
| NG10 | Menggantikan e-PPGBM sebagai sistem pelaporan resmi |

### 3.3 Metrik keberhasilan

Konteks tugas kuliah, tanpa pengguna produksi. Metrik diukur di perangkat uji dan uji terbatas.

| ID | Metrik | Target | Cara ukur |
|---|---|---|---|
| M-01 | Skenario end-to-end MVP lulus tanpa crash | 100% | Checklist §16 |
| M-02 | Selisih z-score aplikasi vs kalkulator WHO resmi | Di dalam toleransi [OQ-14], minimal 30 kasus lintas umur dan jenis kelamin | Uji perbandingan |
| M-03 | Kategori status sama dengan referensi WHO | 100% pada kasus uji | Uji perbandingan |
| M-04 | Satu sesi simulasi 20 anak dalam mode pesawat, lalu tersinkron | 0 data hilang | Uji offline |
| M-05 | Waktu input per anak oleh kader | Dilaporkan apa adanya. Tidak ada target angka sampai ada baseline pencatatan manual [OQ-12] | Uji dengan kader atau peran pengganti |
| M-06 | Pengguna awam menyelesaikan scan pertama | ≤ 3 menit tanpa tutorial, minimal 5 pengguna | Uji usabilitas |
| M-07 | Latensi scan makanan | ≤ 2 detik pada perangkat RAM 3 GB | Uji perangkat |
| M-08 | Ukuran APK terpasang | ≤ 150 MB | Ukur di perangkat |
| M-09 | Uji aturan keamanan Firestore | 0 pelanggaran pada seluruh kasus uji (§16.2) | Emulator Firebase |
| M-10 | Tidak ada foto yang diunggah ke server | 0 file | Audit jaringan dan penyimpanan |
| M-11 | Top-1 accuracy model makanan | Ditetapkan setelah dataset dan jumlah kelas final [OQ-5] | Evaluasi pada set uji terpisah |

---

## 4. Peran, persona, dan hak akses

### 4.1 Peran

| Peran | Deskripsi | Penyimpanan peran | MVP | Cara bergabung |
|---|---|---|---|---|
| Ibu | Pengguna keluarga. Mode hamil aktif bila ada kehamilan aktif; mode balita aktif bila ada anak; keduanya bisa aktif bersamaan | `users/{uid}.role = "ibu"` | M | Daftar sendiri. Pilihan "Ibu Hamil" atau "Ibu Balita" saat daftar hanya menentukan onboarding awal |
| Kader | Operator lapangan Posyandu | `users/{uid}.role = "kader"` | M | Daftar, lalu memasukkan Kode Posyandu yang diterbitkan admin [OQ-17] |
| Admin | Pengelola konten, Posyandu, dan kode (back-office) | Custom claim `admin` | S | Dibuat manual oleh tim |
| Bidan / tenaga kesehatan | Verifikator hasil dan konten | — | C | Ditinjau untuk v2 [OQ-22] |

### 4.2 Persona (hipotesis tim, belum berdasar riset pengguna)

| Atribut | Ibu hamil — "Dewi" | Ibu balita — "Sari" | Kader — "Bu Ratna" |
|---|---|---|---|
| Profil | 26 th, kehamilan pertama, trimester 2 | 28 th, anak perempuan 14 bulan | 45 th, kader sekitar 8 tahun |
| Perangkat | Android RAM 3 GB, kuota terbatas | Android RAM 3 GB, kuota terbatas | Android pribadi, sinyal tidak stabil di lokasi |
| Kebutuhan | Pengingat TTD dan ANC; tahu cukup tidaknya makan | Tahu posisi tinggi anak; tahu menu yang cocok | Input cepat, hitung otomatis, rekap, bisa offline |
| Frustrasi | Lupa minum TTD; bingung istilah | Tidak paham grafik; bingung menu | Hitung dan catat dua kali; salah ukur |
| Sukses | TTD dan ANC terpantau; hasil pemeriksaan tercatat | Melihat status anak dalam bahasa awam dan tahu langkah berikutnya | Satu sesi selesai tercatat dan terklasifikasi tanpa hitung manual |

Angka dan atribut persona adalah asumsi ilustratif dan perlu divalidasi [OQ-12].

### 4.3 Matriks hak akses

| Sumber daya | Ibu (pemilik) | Kader dengan grant aktif | Kader untuk anak tanpa akun buatannya | Admin |
|---|---|---|---|---|
| Profil sendiri | R/U | R/U (milik sendiri) | — | R/U (milik sendiri) |
| Data anak | C/R/U/arsip | R (sesuai cakupan) | C/R/U | Tidak ada akses |
| Pengukuran anak | C/R/U (entri sendiri) | C/R | C/R/U | Tidak ada akses |
| Food log anak | C/R/U/D | R, hanya bila cakupan "makan" diberikan | — | Tidak ada akses |
| Kehamilan | C/R/U | R (sesuai cakupan) | — | Tidak ada akses |
| Pemeriksaan ibu hamil | C/R/U (entri mandiri) | C/R | — | Tidak ada akses |
| Posyandu, sesi, entri | — | C/R/U bila anggota Posyandu | C/R/U | Kelola Posyandu |
| Grant | C (lewat kode), R, cabut | R | — | Tidak ada akses |
| Konten edukasi dan rekomendasi | R | R | R | C/R/U/D |
| Log audit | R milik sendiri (S) | — | — | R |

Prinsip: admin tidak memiliki akses ke data kesehatan pribadi (hak akses minimum). C = buat, R = baca, U = ubah, D = hapus.

---

## 5. Model keluarga dan keterhubungan antar peran

Bagian ini menjawab kebingungan utama pada flow v0.1: **bagaimana tiga peran saling terhubung**.

### 5.1 Relasi konseptual

```
User (ibu) 1 ──── N Kehamilan ──── 0..1 ──► Anak   (saat melahirkan)
User (ibu) 1 ──── N Anak          (guardianUids)
Anak       1 ──── N Pengukuran    (riwayat, tidak ditimpa)
Anak       1 ──── N FoodLog
Kehamilan  1 ──── N PemeriksaanHamil, CatatanTTD, KunjunganANC
Posyandu   1 ──── N Sesi ──── N Entri (merujuk ke Pengukuran / PemeriksaanHamil)
AccessGrant: ibu ──(izin, cakupan, masa berlaku)──► kader / Posyandu ──► Anak atau Kehamilan
```

### 5.2 Empat mekanisme penghubung

| # | Mekanisme | Tujuan | Langkah ringkas | Aturan keamanan |
|---|---|---|---|---|
| M1 | Kode Posyandu | Menghubungkan kader ke Posyandu | Admin menerbitkan kode, kader memasukkan di S-10 | Diverifikasi Cloud Function; membuat keanggotaan Posyandu |
| M2 | Kode Keluarga / QR | Ibu memberi akses ke kader | Ibu memilih anak/kehamilan dan cakupan, membuat kode (B-14); kader memindai (K-09) | Kode acak, disimpan ter-hash, berlaku 24 jam [Usulan], satu kader per kode, ditukar lewat Cloud Function, dibatasi percobaan |
| M3 | Anak tanpa akun + Kode Klaim | Kader mencatat anak yang ibunya belum punya akun, lalu diserahkan ke ibu | Kader membuat anak (K-03); saat ibu mendaftar kader membuat Kode Klaim (K-10); ibu memasukkan di B-15 | Sekali pakai, berlaku 7 hari [Usulan], ditukar lewat Cloud Function |
| M4 | Konversi kelahiran | Kehamilan menjadi profil anak | Ibu menekan "Saya sudah melahirkan" (H-06) | Satu `WriteBatch`: membuat anak dan menutup kehamilan |

Kode bukan satu-satunya pengaman: akses data tetap ditegakkan oleh aturan keamanan Firestore (§10.4), bukan oleh aplikasi.

### 5.3 Tujuh aliran data

| # | Aliran | Pemicu | Mekanisme | Perilaku offline | Persetujuan |
|---|---|---|---|---|---|
| 1 | Kehamilan → anak | Ibu melahirkan | M4: `WriteBatch` membuat anak dan menutup kehamilan | Berjalan offline, tersinkron kemudian | Ibu sendiri |
| 2 | Hasil ukur Posyandu → ibu | Kader menyimpan pengukuran | Kader menulis di `children/{id}/measurements`; ibu mendengarkan perubahan; notifikasi push lewat Cloud Function (S) | Kader menulis offline; ibu melihat setelah kader tersinkron | Grant M2 atau anak tanpa akun yang sudah diklaim |
| 3 | Jadwal Posyandu → ibu | Kader/admin mengubah jadwal | Ibu memasukkan Kode Posyandu (publik, tidak sensitif) untuk mengikuti jadwal | Jadwal tersimpan di cache | Tidak perlu (data non-pribadi) |
| 4 | Catatan makan ibu → kader | Ibu memberi cakupan "makan" | Grant dengan cakupan tambahan, dibaca kader | Dibaca dari cache bila pernah dimuat | Opt-in terpisah |
| 5 | Status pertumbuhan → daftar tindak lanjut kader | Pengukuran berstatus pendek/sangat pendek, atau tidak hadir berturut-turut | Roster ter-denormalisasi memuat kategori terakhir; daftar dihitung di perangkat kader | Berjalan offline | Mengikuti grant |
| 6 | Pemeriksaan ibu hamil → pendampingan | Kader/bidan mencatat pemeriksaan | Flag "perlu konsultasi" dihitung di perangkat dari ambang (§8.9) | Berjalan offline | Mengikuti grant |
| 7 | Persetujuan akses | Ibu membuat atau mencabut grant | Cloud Function membuat grant; pencabutan berlaku seketika pada aturan Firestore | Pembuatan butuh internet; pencabutan butuh internet | Ibu sendiri |

### 5.4 Siklus status

| Objek | Status |
|---|---|
| Kehamilan | `aktif` → `lahir` (anak terbentuk) atau `berakhir` (tanpa kelahiran, ditangani sensitif; E-18) |
| Grant | `aktif` → `dicabut` atau `kedaluwarsa` |
| Sesi Posyandu | `berlangsung` → `selesai` |
| Anak | `aktif` → `diarsipkan` → dihapus (aturan retensi [OQ-20]) |
| Kode (keluarga/klaim) | `aktif` → `terpakai` atau `kedaluwarsa` |

---

## 6. Peta perjalanan dan flow

### 6.0 Flow global

```
[Buka app] ─► S-01 Splash ─► pertama kali? ─ya─► S-02 Landing ─► S-03 Pilih Peran ─► S-04 Daftar ─► S-07 Consent
                                  │ tidak                                                                │
                                  ▼                                                                      ▼
                          sudah login? ─tidak─► S-05 Masuk                           Onboarding: S-08 Hamil | S-09 Balita | S-10 Kader
                                  │ ya                                                                   │
                                  ▼                                                                      ▼
                  Beranda sesuai peran:  H-01 (hamil)  |  B-01 (balita)  |  K-01 (kader)  ◄──────────────┘

 Lintas peran:  Ibu ──(Kode Keluarga/QR)──► Kader        Kader ──(Kode Klaim)──► Ibu
                Hamil ──(melahirkan)──► Anak             Kader ──(hasil ukur, jadwal)──► Ibu
```

Kode layar (S-, H-, B-, K-, A-) didefinisikan di §11.

### 6.1 Alur 1 — Pengguna baru

| # | Aktor | Aksi dan respons sistem | Layar | Catatan |
|---|---|---|---|---|
| 1.1 | Pengguna | Membuka aplikasi. Sistem memeriksa sesi login dan penanda pertama kali | S-01 | Splash ≤ 2 dtk |
| 1.2 | Pengguna | Pertama kali: melihat hero carousel. Autoplay 4,5 dtk, bisa digeser | S-02 | F-01.2 |
| 1.3 | Pengguna | Menekan "Mulai" atau "Lewati" → pilih peran. "Saya sudah punya akun" → masuk | S-02 → S-03 / S-05 | |
| 1.4 | Pengguna | Memilih Ibu Hamil, Ibu Balita, atau Kader | S-03 | Disimpan sementara di perangkat |
| 1.5 | Pengguna | Mengisi nama, email, password. Sistem memvalidasi dan membuat akun Firebase Auth dan dokumen `users/{uid}` | S-04 | Email terpakai, offline pertama kali → E-31 |
| 1.6 | Pengguna | Membaca dan menyetujui persetujuan data dan disclaimer skrining. Tanpa persetujuan tidak bisa lanjut. Versi dan waktu persetujuan dicatat | S-07 | F-02.4 |
| 1.7a | Ibu Hamil | Mengisi HPHT atau HPL. Sistem menghitung usia kehamilan dan membuat kehamilan aktif | S-08 → H-01 | §8.8 |
| 1.7b | Ibu Balita | Menambah anak pertama (nama panggilan, tanggal lahir, jenis kelamin). Usia di luar 0–59 bulan ditolak. Boleh dilewati | S-09 → B-01 | E-06 |
| 1.7c | Kader | Memasukkan Kode Posyandu. Cloud Function memverifikasi dan membuat keanggotaan | S-10 → K-01 | E-16 |
| 1.8 | Pengguna | Login berikutnya langsung ke beranda. Bila ada versi persetujuan baru, diminta menyetujui ulang | S-05 | E-32 |

### 6.2 Alur 2 — Ibu hamil

| # | Frekuensi | Aktor | Aksi dan respons sistem | Layar |
|---|---|---|---|---|
| 2.1 | Harian | Sistem | Notifikasi lokal pengingat TTD (berjalan offline) | S-15 |
| 2.2 | Harian | Ibu | Mencentang "sudah minum TTD". Progres terhadap target 90 tablet diperbarui | H-03 |
| 2.3 | Harian | Ibu | Mencatat makan lewat pencarian TKPI atau foto. Melihat ringkasan gizi | H-05 |
| 2.4 | Berkala | Ibu atau kader | Mencatat pemeriksaan (tanggal, berat badan, LiLA, Hb bila ada). Kader mencatatnya dalam sesi (K-06); ibu bisa mencatat hasil sendiri | H-02, K-06 |
| 2.5 | Berkala | Sistem | Bila nilai melewati ambang [OQ-18], menampilkan pesan "disarankan konsultasi ke Puskesmas". Tidak ada kata diagnosis | H-01, H-02 |
| 2.6 | Berkala | Ibu | Mencatat kunjungan ANC. Progres terhadap target minimal 6 kunjungan | H-04 |
| 2.7 | Berkala | Ibu | Membaca edukasi 1000 HPK sesuai trimester | S-13, S-14 |
| 2.8 | Sekali | Ibu | "Saya sudah melahirkan" → Alur 6. Atau "Kehamilan berakhir" → E-18 | H-06, H-07 |

### 6.3 Alur 3 — Ibu balita

| # | Aktor | Aksi dan respons sistem | Layar | Edge |
|---|---|---|---|---|
| 3.1 | Ibu | Membuka beranda: anak aktif, status terakhir, tombol "Foto Makanan", ringkasan gizi hari ini, kartu "Hasil terbaru dari Posyandu" bila ada | B-01 | |
| 3.2 | Ibu | Memilih atau menambah anak; mengganti anak aktif | B-02 | E-06 |
| 3.3 | Ibu | Mengisi tanggal ukur, berat, tinggi/panjang, metode ukur. Sistem memvalidasi | B-03 | E-05, E-08, E-29 |
| 3.4 | Sistem | Menghitung z-score TB/U (PB/U) lokal, mengklasifikasi, menyimpan sebagai entri baru | B-03 → B-04 | E-26 |
| 3.5 | Ibu | Membaca hasil: status, nilai z, umur saat ukur, saran, disclaimer. Melihat kurva dan riwayat | B-04, B-05, B-06 | |
| 3.6 | Ibu | Melihat entri dari Posyandu dengan label "Diukur di Posyandu … pada …" | B-06 | Hanya bila anak terhubung (Alur 5) |
| 3.7 | Ibu | Mencatat makan: foto (B-07) atau cari manual (B-09) → koreksi (B-08) → porsi gram (B-10) → ringkasan dan simpan (B-11) | B-07 … B-11 | E-01–E-04, E-11–E-13 |
| 3.8 | Ibu | Melihat diary harian dan progres gizi terhadap AKG dengan teks label | B-12 | |
| 3.9 | Ibu | Membaca rekomendasi sesuai status dan usia | B-13 | §8.11 |
| 3.10 | Ibu | Membagikan data ke kader → Alur 5 | B-14 | |

### 6.4 Alur 4 — Kader (sebelum, saat, setelah sesi)

| # | Tahap | Aktor | Aksi dan respons sistem | Layar | Edge |
|---|---|---|---|---|---|
| 4.1 | Sebelum (online) | Kader | Membuka aplikasi dengan sinyal: roster, jadwal, dan konten tersinkron ke perangkat | K-01, K-12 | E-09 |
| 4.2 | Sebelum | Kader | Membuat sesi: nama Posyandu terisi otomatis, tanggal hari ini | K-04 | |
| 4.3 | Saat (offline OK) | Kader | Mencari sasaran di roster (anak, ibu hamil). Tidak ada → tambah sasaran | K-02, K-03 | E-27 |
| 4.4 | Saat | Kader | Anak: mengisi berat dan tinggi/panjang. Metode ukur default mengikuti umur. Hasil kategori dan z muncul seketika | K-05 | E-05, E-08, E-26 |
| 4.5 | Saat | Kader | Menekan "Simpan dan berikutnya". Entri tercatat dengan indikator status sinkron | K-05 | E-10, E-30 |
| 4.6 | Saat | Kader | Ibu hamil: mengisi berat badan, LiLA, Hb bila ada | K-06 | |
| 4.7 | Saat | Kader | Anak ber-akun yang belum memberi akses tidak muncul. Meminta ibu membuat Kode Keluarga → Alur 5 | K-09 | E-14 |
| 4.8 | Setelah | Kader | Menekan "Selesaikan sesi" → rekap: jumlah anak, jumlah per kategori, daftar tindak lanjut | K-07 | |
| 4.9 | Setelah | Kader | Memastikan semua entri tersinkron. Mengekspor rekap (S) | K-12 | E-24 |
| 4.10 | Antar sesi | Kader | Membuka daftar tindak lanjut: anak berstatus pendek/sangat pendek, tidak hadir berturut-turut, ibu hamil dengan flag | K-08 | |
| 4.11 | Antar sesi | Kader | Mengubah jadwal Posyandu agar terlihat oleh ibu (S) | K-11 | |

### 6.5 Alur 5 — Penghubungan

| # | Skenario | Aktor | Aksi dan respons sistem | Layar | Edge |
|---|---|---|---|---|---|
| 5A.1 | Ibu ber-akun ↔ kader | Ibu | Memilih anak dan/atau kehamilan, menentukan cakupan (ukur wajib; catatan makan opsional), menekan "Buat Kode". Kode dan QR tampil, berlaku 24 jam | B-14 | |
| 5A.2 | | Kader | Memindai QR atau mengetik kode. Cloud Function memverifikasi, membuat grant aktif dan entri roster | K-09 | E-14 |
| 5A.3 | | Ibu | Melihat daftar akses aktif dan mencabut kapan saja | S-12 | E-15 |
| 5B.1 | Anak tanpa akun → ibu | Kader | Menambah anak dengan nama wali (tanpa NIK) dan mengukur | K-03, K-05 | [OQ-23] |
| 5B.2 | | Kader | Saat ibu mendaftar: membuat Kode Klaim (sekali pakai, 7 hari) | K-10 | |
| 5B.3 | | Ibu | Memasukkan kode klaim. Cloud Function memindahkan kepemilikan, riwayat ikut, dan membuat grant ke Posyandu asal (dapat dicabut) | B-15 | E-17 |
| 5C | Ibu mengikuti Posyandu | Ibu | Memasukkan Kode Posyandu untuk melihat jadwal | S-11 | |

### 6.6 Alur 6 — Kelahiran (hamil → anak)

| # | Aktor | Aksi dan respons sistem | Layar | Edge |
|---|---|---|---|---|
| 6.1 | Ibu | Dari beranda hamil memilih "Saya sudah melahirkan". Mengisi tanggal lahir, jenis kelamin, berat dan panjang lahir (opsional). Usia kehamilan saat lahir dihitung dari HPHT dan dapat diubah | H-01 → H-06 | E-07, E-19 |
| 6.2 | Sistem | `WriteBatch` (berfungsi offline): membuat anak, mengisi data lahir, menutup kehamilan (`lahir`, `childId`) | — | |
| 6.3 | Sistem | Menghentikan pengingat TTD/ANC dan menjadwalkan pengingat balita | — | E-23 |
| 6.4 | Sistem | Bila kehamilan pernah dibagikan ke kader, bertanya apakah data anak ikut dibagikan. Tidak otomatis | — | |
| 6.5 | Sistem | Membuka beranda balita. Mode hamil menjadi arsip hanya-baca | B-01 | |

### 6.7 Alur 7 — Tindak lanjut status pendek / sangat pendek

| # | Aktor | Aksi dan respons sistem | Layar |
|---|---|---|---|
| 7.1 | Sistem | Hasil ukur berkategori pendek atau sangat pendek (dari ibu maupun kader) menampilkan kartu rujukan dan rekomendasi (§8.11). Tidak ada diagnosis | B-04, K-05 |
| 7.2 | Sistem | Menandai anak "perlu tindak lanjut" pada roster Posyandu | K-08 |
| 7.3 | Kader | Menghubungi atau mengunjungi keluarga, mencatat tindak lanjut: "Diarahkan ke Puskesmas", "Sudah ke Puskesmas", atau "Tidak dapat ditemui" | K-08 |
| 7.4 | Sistem | Pengukuran berikutnya memperbarui status dan tren. Anak tetap di daftar sampai kader menutup dengan alasan | K-08, B-05 |

### 6.8 Penegasan batas peran

- NURI menyajikan hasil ukur dan saran rujukan. Penetapan diagnosis dan terapi tetap oleh tenaga kesehatan.
- Kader mencatat dan mengarahkan. Kader tidak memberikan diagnosis lewat NURI.
- Ibu mengendalikan data keluarganya, termasuk memutuskan siapa yang boleh melihatnya.

---

## 7. Kebutuhan fungsional

Kolom **Kriteria** berisi syarat lulus yang bisa diuji. Kode layar dijelaskan di §11, aturan perhitungan di §8, dan kasus tepi di §15.

### F-01 Landing dan onboarding

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-01.1 | Splash singkat lalu landing hanya pada peluncuran pertama (penanda lokal). Pengguna lama langsung ke S-05 atau beranda | M | Peluncuran kedua tidak menampilkan landing |
| F-01.2 | Hero carousel layar penuh, 5 slide foto bayi/balita. Autoplay tiap 4,5 detik, berputar tanpa henti, bisa digeser, berhenti saat disentuh, lanjut saat dilepas. Titik indikator dengan progres pada titik aktif | M | Slide berganti otomatis 4,5 ± 0,5 dtk; berhenti saat disentuh |
| F-01.3 | Transisi crossfade dengan zoom halus. Bila pengaturan aksesibilitas "kurangi animasi" aktif, autoplay dan zoom dimatikan | M | Dengan animasi dimatikan, tidak ada pergantian otomatis |
| F-01.4 | Seluruh isi slide (gambar, headline, subteks, teks alternatif) dari satu berkas data. Gambar berlisensi [OQ-25] | M | Mengganti slide cukup mengubah satu berkas |
| F-01.5 | Overlay gradient agar teks terbaca; kontras teks memenuhi WCAG AA; gambar dimuat lebih dulu untuk slide berikutnya | M | Teks terbaca di semua slide |
| F-01.6 | Di bawah hero: "Cara kerja" 3 langkah dan 3 kartu fitur. Tanpa testimoni atau angka pengguna karangan. Footer disclaimer skrining | M | Tidak ada klaim tanpa sumber |
| F-01.7 | Tombol "Mulai", "Lewati", "Saya sudah punya akun" | M | Ketiganya berfungsi sesuai §6.1 |
| F-01.8 | Pilih peran (S-03) dan onboarding per peran (S-08, S-09, S-10) | M | Sesuai Alur 1 |

### F-02 Autentikasi, peran, dan persetujuan

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-02.1 | Daftar dan masuk dengan email dan password (Firebase Authentication). Validasi bahasa Indonesia yang jelas. Masuk dengan nomor HP ditunda [OQ-3] | M | Email tidak valid, password lemah, dan email terpakai menampilkan pesan spesifik |
| F-02.2 | Sesi login bertahan antar peluncuran. Keluar menghapus data sesi lokal sensitif. Reset password lewat email | M | Setelah keluar, data keluarga tidak tampil |
| F-02.3 | Peran disimpan saat pendaftaran dan **tidak dapat diubah oleh klien** setelah dibuat | M | Uji aturan: klien gagal mengubah `role` |
| F-02.4 | Layar persetujuan wajib: pengolahan data pribadi dan data anak, serta disclaimer skrining. Versi dan waktu persetujuan dicatat. Persetujuan ulang bila versi baru terbit | M | Tanpa centang, tombol lanjut nonaktif; `consent.version` tersimpan |
| F-02.5 | Peran kader memerlukan Kode Posyandu yang valid sebelum fitur kader terbuka | M | Kode salah menampilkan pesan; fitur kader terkunci |
| F-02.6 | Hapus akun dan seluruh data pribadi (Cloud Function). Perilaku untuk data yang dibagikan ke kader: [OQ-20] | M | Setelah hapus, dokumen milik pengguna tidak dapat dibaca |
| F-02.7 | Firebase App Check (Play Integrity) diaktifkan. Enforcement dinyalakan setelah masa pemantauan | S | Permintaan tanpa token ditolak setelah enforcement |

### F-03 Profil keluarga

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-03.1 | Profil ibu: nama; tanggal lahir opsional | M | |
| F-03.2 | Tambah anak: nama panggilan, tanggal lahir, jenis kelamin. Usia valid 0–59 bulan. Satu ibu dapat memiliki lebih dari satu anak (batas jumlah [OQ-3], default usulan 5) | M | Usia di luar rentang ditolak dengan pesan |
| F-03.3 | Ubah data anak dan arsipkan anak (bukan hapus langsung) | M | Anak yang diarsipkan tidak tampil di beranda |
| F-03.4 | Pemilih anak aktif di beranda dan layar terkait | M | Mengganti anak mengganti semua data tampilan |
| F-03.5 | Data lahir opsional: berat lahir, panjang lahir, usia kehamilan saat lahir | S | Usia kehamilan < 37 minggu memicu catatan prematur (E-07) |
| F-03.6 | Tidak ada foto profil anak. Avatar berupa ilustrasi | M | Tidak ada unggah foto anak |

### F-04 Mode ibu hamil

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-04.1 | Membuat kehamilan dari HPHT atau HPL. Menghitung usia kehamilan (minggu+hari) dan trimester (§8.8) | M | Hasil sesuai kasus uji hitung manual |
| F-04.2 | Beranda hamil: usia kehamilan, trimester, pengingat hari ini, hasil pemeriksaan terakhir beserta tanggal dan sumbernya | M | |
| F-04.3 | Catatan pemeriksaan: tanggal, berat badan, LiLA, Hb (opsional), sumber (mandiri/kader/bidan), pencatat | M | Entri tidak menimpa entri lain |
| F-04.4 | Pesan "disarankan konsultasi ke Puskesmas" bila nilai melewati ambang (§8.9). Tidak menyebut diagnosis | M | Pesan muncul pada nilai uji di bawah/di atas ambang |
| F-04.5 | Pelacak TTD: centang harian, total tablet, dan progres terhadap target 90 tablet | M | Total sama dengan jumlah centang |
| F-04.6 | Pelacak ANC: catat kunjungan, progres terhadap target minimal 6 kunjungan. Pembagian per trimester [OQ-21] | M | |
| F-04.7 | Diary makan dan gizi untuk ibu hamil memakai alur F-06 dan F-07. Kebutuhan AKG ibu hamil [OQ-7] | S | |
| F-04.8 | Edukasi 1000 HPK per trimester | S | |
| F-04.9 | "Saya sudah melahirkan" → Alur 6 | M | Anak terbentuk dan kehamilan berstatus `lahir` dalam satu batch |
| F-04.10 | "Kehamilan berakhir" dengan bahasa netral, tanpa menanyakan sebab. Menghentikan pengingat. Pengguna dapat menghapus data kehamilan | M | E-18 |

### F-05 Pengukuran dan skrining pertumbuhan balita

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-05.1 | Input ukur: tanggal ukur, berat (kg), tinggi/panjang (cm), metode ukur (berbaring/berdiri) dengan default sesuai umur | M | |
| F-05.2 | Aturan metode ukur dan koreksi ±0,7 cm (§8.2) | M | Kasus uji koreksi lulus |
| F-05.3 | Hitung z-score TB/U atau PB/U memakai metode LMS dari tabel WHO yang dibundel (§8.3) | M | Selisih terhadap kalkulator WHO di dalam toleransi [OQ-14] |
| F-05.4 | Klasifikasi: sangat pendek, pendek, normal, tinggi (§8.4) | M | 100% sama dengan referensi pada kasus uji |
| F-05.5 | Validasi nilai: batas mustahil ditolak; nilai ekstrem meminta konfirmasi; z-score di luar ±6 ditandai tidak masuk akal (§8.5) | M | E-05, E-26 |
| F-05.6 | Peringatan bila ada pengukuran pada tanggal yang sama; pengguna memilih menyimpan sebagai entri baru atau membatalkan | M | E-08 |
| F-05.7 | Riwayat pengukuran bersifat tambah-saja. Koreksi dibuat sebagai revisi dengan jejak | M | Entri lama tetap terlihat di riwayat |
| F-05.8 | Layar hasil: status, nilai z, umur saat ukur, jenis ukuran, saran, disclaimer "Skrining awal, bukan diagnosis" | M | Semua elemen tampil |
| F-05.9 | Kurva TB/U (PB/U) dengan garis referensi −3, −2, median, +2, +3 SD dan titik pengukuran anak. Diperbarui setiap ada pengukuran baru | M | Titik sama dengan data riwayat |
| F-05.10 | Rekomendasi sesuai status dan usia (§8.11) dan Alur 7 | M | |
| F-05.11 | Kurva BB/U dan status BB/TB | C | [OQ-7] |
| F-05.12 | Penanda penurunan posisi z antar kunjungan | C | Aturan klinis [OQ-11] |

### F-06 Scan makanan dan hitung gizi

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-06.1 | Input dari kamera atau galeri. Layar penjelasan sebelum meminta izin kamera | M | E-11 |
| F-06.2 | Pencarian dan input makanan manual dari tabel TKPI. Ini jalur utama yang selalu tersedia | M | Dapat menyelesaikan pencatatan tanpa model |
| F-06.3 | Deteksi jenis makanan memakai TensorFlow Lite on-device bila model tersedia. Cakupan kelas mengikuti dataset final [OQ-5]. Satu makanan per foto di MVP; multi-objek S | S | Tanpa model, tombol foto mengarah ke pencarian manual |
| F-06.4 | Hasil deteksi menampilkan label dan skor kepercayaan. Di bawah ambang [OQ-6] sistem meminta pengguna memilih dari kandidat teratas atau mencari manual | M | E-01, E-02 |
| F-06.5 | Pengguna dapat mengubah, menambah, atau menghapus item sebelum menyimpan | M | E-03 |
| F-06.6 | Porsi dalam gram (wajib). Ukuran rumah tangga (kecil/sedang/besar) → gram: S [OQ-4] | M | Porsi harus > 0 |
| F-06.7 | Nilai gizi = gram ÷ 100 × nilai per 100 g (§8.6). Nutrien MVP: energi, protein, lemak, karbohidrat. Nutrien lain [OQ-7] | M | Kasus uji hitung lulus |
| F-06.8 | Nilai gizi yang tidak tersedia ditampilkan sebagai "tidak tersedia", tidak dihitung sebagai nol | M | E-04 |
| F-06.9 | Foto makanan disimpan sementara di perangkat dan dihapus setelah entri tersimpan. Tidak diunggah | M | Tidak ada permintaan unggah foto (M-10) |
| F-06.10 | Latensi inferensi ≤ 2 dtk pada RAM 3 GB, dengan indikator proses bila lebih lama | M | M-07, E-13 |

### F-07 Food diary dan AKG

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-07.1 | Pencatatan per sesi makan: pagi, siang, malam, snack | M | |
| F-07.2 | Entri diary terkait ke satu anak (atau kehamilan) terpilih | M | |
| F-07.3 | Ringkasan harian: progress ring per nutrien terhadap AKG yang dipilih otomatis dari usia dan jenis kelamin. Sumber dan versi tabel AKG [OQ-7] | M | AKG berganti saat usia anak melewati batas kelompok |
| F-07.4 | Indikator kurang / cukup / lebih dengan **warna, teks, dan ikon** (ambang §8.7) | M | Warna bukan satu-satunya penanda |
| F-07.5 | Ubah dan hapus entri. Lihat riwayat per tanggal | M | |
| F-07.6 | Setiap item menyimpan salinan nilai gizi saat dicatat, versi TKPI, dan sumber (scan/manual) | M | Perubahan tabel tidak mengubah riwayat |
| F-07.7 | Label "hanya yang tercatat; bukan seluruh asupan" pada ringkasan | M | |

### F-08 Rekomendasi dan edukasi

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-08.1 | Rekomendasi sesuai status dan usia dari bank konten di Firestore, tersimpan di cache | M | Tampil offline setelah pernah dimuat |
| F-08.2 | Konten hanya tampil bila berstatus `published` dan memiliki peninjau (`reviewedBy`) | M | Konten draft tidak tampil |
| F-08.3 | Edukasi per kategori (hamil, balita, MPASI, umum) dengan sumber, peninjau, dan tanggal | M | Semua metadata tampil |
| F-08.4 | Saran menu berbasis aturan dari TKPI dan usia | S | |
| F-08.5 | Jadwal Posyandu yang diisi kader tampil di beranda ibu | S | Alur 5C |

### F-09 Pengingat dan notifikasi

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-09.1 | Pengingat lokal terjadwal (TTD harian, ANC, ukur bulanan, jadwal Posyandu). Berfungsi tanpa internet | M | Notifikasi muncul dalam mode pesawat |
| F-09.2 | Penjadwalan ulang setelah perangkat dinyalakan ulang | M | E-23 |
| F-09.3 | Permintaan izin notifikasi (Android 13+) dengan penjelasan. Pengaturan hidup/mati per jenis | M | E-22 |
| F-09.4 | Isi notifikasi tidak memuat nama anak atau status pertumbuhan | M | Tampilan layar kunci tidak membocorkan data |
| F-09.5 | Notifikasi push (FCM) dari sistem: hasil ukur baru, perubahan jadwal | S | |
| F-09.6 | Kader menerima daftar tindak lanjut sebagai pengingat sebelum sesi | S | |

### F-10 Mode kader

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-10.1 | Bergabung ke Posyandu dengan Kode Posyandu | M | |
| F-10.2 | Membuat dan menyelesaikan sesi Posyandu (nama, tanggal) | M | Sesi selesai mengunci rekap |
| F-10.3 | Roster: daftar anak dan ibu hamil sasaran Posyandu, dapat dicari nama | M | Pencarian bekerja offline |
| F-10.4 | Menambah sasaran baru tanpa akun: anak (nama, tanggal lahir, jenis kelamin, nama wali) dan ibu hamil. Tidak mengumpulkan NIK [OQ-23] | M | |
| F-10.5 | Input cepat pengukuran anak dalam satu layar: berat, tinggi/panjang, hasil seketika, "Simpan dan berikutnya" | M | Alur 4.4–4.5 |
| F-10.6 | Peringatan salah ukur: nilai ekstrem, ketidaksesuaian metode ukur dan umur, duplikat | M | E-05, E-08 |
| F-10.7 | Input pemeriksaan ibu hamil dalam sesi: berat badan, LiLA, Hb bila ada | M | |
| F-10.8 | Rekap sesi: jumlah anak, jumlah per kategori status, daftar tindak lanjut | M | Angka sama dengan jumlah entri |
| F-10.9 | Daftar tindak lanjut: anak pendek/sangat pendek, tidak hadir berturut-turut (default 2 sesi [Usulan]), ibu hamil dengan flag. Kader dapat mencatat hasil tindak lanjut | M | Alur 7 |
| F-10.10 | Semua F-10.x berjalan offline. Setiap entri menampilkan status sinkron (tertunda/tersinkron) | M | M-04 |
| F-10.11 | Data keluarga ber-akun hanya dapat dilihat bila ada grant aktif | M | Uji aturan §16.2 |
| F-10.12 | Ekspor rekap sesi ke CSV dengan kolom yang mudah disalin ke e-PPGBM [OQ-13] | S | |
| F-10.13 | Setelah sesi selesai, perubahan entri hanya oleh pembuatnya dengan alasan tercatat | S | |

### F-11 Penghubungan dan persetujuan

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-11.1 | Ibu membuat Kode Keluarga dan QR (berlaku 24 jam [Usulan]) untuk anak dan/atau kehamilan terpilih | M | Kode kedaluwarsa ditolak (E-14) |
| F-11.2 | Cakupan akses dipilih ibu: **ukur** (wajib), **catatan makan** (opsional terpisah) | M | Tanpa cakupan makan, kader tidak bisa membaca food log |
| F-11.3 | Kader memindai atau mengetik kode; sistem membuat grant dan entri roster | M | |
| F-11.4 | Ibu melihat daftar akses aktif dan mencabut kapan saja. Pencabutan berlaku segera pada aturan Firestore | M | Setelah dicabut, pembacaan kader ditolak |
| F-11.5 | Kader membuat Kode Klaim untuk anak tanpa akun; ibu memasukkan kode; kepemilikan berpindah dan riwayat ikut | M | E-17 |
| F-11.6 | Masa berlaku grant [OQ-20] dan pengingat tinjau akses berkala | S | |
| F-11.7 | Log audit akses kader ke data keluarga, terlihat oleh ibu | S | |

### F-12 Admin konten (back-office)

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-12.1 | Mengelola artikel dan rekomendasi: draft → ditinjau → terbit. Bentuk antarmuka (Firebase Console atau halaman web sederhana) [OQ-19] | S | |
| F-12.2 | Mengelola Posyandu, kode Posyandu, dan jadwal | S | |
| F-12.3 | Hak admin lewat custom claim, bukan field yang dapat diubah klien | M (bila F-12 ada) | |

### F-13 Offline dan sinkronisasi

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-13.1 | Cache offline Firestore aktif (default Android) dengan batas ukuran cache yang ditetapkan | M | |
| F-13.2 | Indikator koneksi dan jumlah tulisan tertunda (dari metadata snapshot) | M | |
| F-13.3 | Pengukuran dan entri sesi adalah dokumen baru per entri (tambah-saja). Ini menghindari tertimpanya tulisan dari dua perangkat, karena konflik pada satu dokumen diselesaikan dengan "tulisan terakhir menang" | M | E-10 |
| F-13.4 | Operasi yang butuh koneksi (kode keluarga, klaim, pencabutan, hapus akun) menampilkan status offline yang jelas | M | E-09 |
| F-13.5 | Login pertama kali butuh internet. Setelah itu sesi bertahan offline | M | E-31 |
| F-13.6 | Data referensi (WHO, TKPI, AKG) tersedia tanpa jaringan | M | |

### F-14 Pengaturan dan kepatuhan

| ID | Requirement | Prio | Kriteria |
|---|---|---|---|
| F-14.1 | Halaman profil, pengaturan pengingat, Privasi dan Akses Data (S-12), dan Tentang | M | |
| F-14.2 | Disclaimer skrining dapat dibaca ulang kapan saja | M | |
| F-14.3 | Ekspor data pribadi pengguna | S | |
| F-14.4 | Bahasa antarmuka Indonesia sederhana (setara SMP) | M | Dinilai pada uji usabilitas |

---

## 8. Aturan bisnis dan perhitungan

### 8.1 Umur

| Aturan | Isi |
|---|---|
| Umur dalam hari | `tanggalUkur − tanggalLahir` |
| Umur dalam bulan | `floor(hari / 30,4375)` |
| Rentang valid | Umur 0 sampai 59 bulan penuh. Tanggal lahir di masa depan atau umur ≥ 60 bulan ditolak (E-06) |
| Zona waktu | Tanggal ukur diambil dari perangkat dan dapat diubah pengguna; selisih besar dari waktu server ditandai (E-29) |

### 8.2 Metode ukur dan koreksi

| Kondisi | Tindakan |
|---|---|
| Umur < 24 bulan | Diukur **berbaring** (panjang badan, PB) |
| Umur ≥ 24 bulan | Diukur **berdiri** (tinggi badan, TB) |
| Umur < 24 bulan tetapi diukur berdiri | PB = TB + 0,7 cm |
| Umur ≥ 24 bulan tetapi diukur berbaring | TB = PB − 0,7 cm |
| Penyimpanan | Nilai asli dan nilai terkoreksi disimpan keduanya |

### 8.3 Z-score tinggi/panjang menurut umur

Gunakan tabel WHO Child Growth Standards panjang/tinggi menurut umur (L, M, S per jenis kelamin dan umur). Untuk indikator ini L = 1, sehingga:

```
z = ((y / M)^L − 1) / (L × S)  →  z = (y/M − 1) / S     (dengan L = 1)
```

`y` adalah panjang/tinggi terkoreksi (cm). Tabel per hari lebih akurat daripada per bulan; pilihan dan interpolasi [OQ-6]. Hasil disimpan dengan versi tabel (`refVersion`). Klasifikasi memakai nilai tanpa pembulatan, tampilan dibulatkan 2 desimal. **[Verifikasi]** perilaku pada batas klasifikasi terhadap kalkulator WHO.

### 8.4 Klasifikasi status

| Kondisi z-score | Kategori |
|---|---|
| z < −3 | Sangat pendek (severely stunted) |
| −3 ≤ z < −2 | Pendek (stunted) |
| −2 ≤ z ≤ +3 | Normal |
| z > +3 | Tinggi |

Klasifikasi hanya dari z-score. Tidak ada masukan lain yang mengubah kategori.

### 8.5 Validasi nilai (usulan awal, ditetapkan di OQ-6)

| Jenis | Aturan default [Usulan] |
|---|---|
| Batas mustahil (ditolak) | Panjang/tinggi di luar 35–130 cm; berat di luar 1,5–30 kg |
| Nilai ekstrem (minta konfirmasi) | Di luar sekitar tiga simpangan dari median umur, atau perubahan sangat besar dari entri sebelumnya |
| Tidak masuk akal secara biologis | z-score tinggi/umur < −6 atau > +6 ditandai dan tidak disimpan tanpa konfirmasi ulang. **[Verifikasi]** ambang terhadap panduan WHO |
| Duplikat | Pengukuran pada tanggal yang sama memicu peringatan (E-08) |

### 8.6 Perhitungan gizi

```
nilai_nutrien = (porsi_gram / 100) × nilai_per_100g
```

| Aturan | Isi |
|---|---|
| Nilai kosong | Tetap `null`. Tidak diubah menjadi 0 |
| Agregasi | Menjumlahkan hanya nilai yang ada; bila ada yang kosong, total diberi label "tidak lengkap" |
| Porsi | Harus > 0; dinyatakan sebagai porsi yang dimakan (bagian yang dapat dimakan) |
| Snapshot | Setiap item menyimpan nilai terhitung, versi TKPI, dan sumber |
| Mesin hitung | Deterministik di aplikasi. Model bahasa tidak dipakai untuk menghitung gizi |

### 8.7 AKG dan indikator pemenuhan

| Aturan | Isi |
|---|---|
| Pemilihan AKG | Otomatis dari kelompok umur dan jenis kelamin anak. Ibu hamil: berdasarkan trimester [OQ-7] |
| Ambang indikator | Contoh awal: kurang < 80%, cukup 80–110%, lebih > 110%. **Hanya contoh**, harus ditetapkan dan ditinjau ahli gizi [OQ-7] |
| Tampilan | Warna + teks + ikon |

### 8.8 Kehamilan

| Aturan | Isi |
|---|---|
| HPL | HPHT + 280 hari. Bila pengguna memasukkan HPL, HPHT diperkirakan = HPL − 280 hari |
| Usia kehamilan | `hari ini − HPHT`, ditampilkan minggu+hari |
| Trimester | T1: sampai 13 minggu 6 hari; T2: 14 minggu 0 hari sampai 27 minggu 6 hari; T3: mulai 28 minggu |
| Rentang valid | 0–42 minggu. Di atas 42 minggu: peringatan konfirmasi tanggal |

Definisi standar di atas **[Verifikasi]** terhadap buku KIA atau pedoman Kemenkes yang dipakai tim.

### 8.9 Ambang tanda "disarankan konsultasi" untuk ibu hamil

| Parameter | Ambang awal | Pesan |
|---|---|---|
| LiLA | < 23,5 cm | "Ukuran lingkar lengan atas di bawah batas. Disarankan konsultasi ke Puskesmas" |
| Hb | < 11 g/dL | "Kadar Hb di bawah batas. Disarankan konsultasi ke Puskesmas" |

Ambang adalah **[Verifikasi]** ke pedoman Kemenkes dan WHO [OQ-18]. Pesan tidak menyebut KEK atau anemia sebagai diagnosis.

### 8.10 Ketidakhadiran

Saat sesi diselesaikan, setiap anak di roster tanpa entri pada sesi itu bertambah hitungan tidak hadir; entri mengatur ulang hitungan. Pembaruan bersifat idempoten (disimpan `lastAbsentSessionId`). Ambang tindak lanjut default 2 sesi berturut-turut [Usulan].

### 8.11 Tabel rekomendasi

Konten hanya ditampilkan bila `published` dan telah ditinjau (F-08.2). Isi konten ditetapkan di [OQ-11].

| Status | Usia | Isi yang ditampilkan |
|---|---|---|
| Normal | < 6 bulan | Edukasi ASI. **Tidak ada** menu makanan pendamping (sesuai spesifikasi agent §2.2) |
| Normal | 6–23 bulan | Tips MPASI sesuai usia |
| Normal | 24–59 bulan | Gizi seimbang anak |
| Pendek | < 6 bulan | Saran konsultasi tenaga kesehatan. Tanpa menu |
| Pendek | 6–23 bulan | Menu MPASI tinggi protein (setelah ditinjau) + saran ke Puskesmas |
| Pendek | 24–59 bulan | Menu tinggi protein (setelah ditinjau) + saran ke Puskesmas |
| Sangat pendek | Semua usia | **Kartu rujukan di posisi teratas**: periksakan ke Puskesmas/dokter. Konten menu hanya bila sudah ditinjau |
| Tinggi | Semua usia | Informasi umum dan saran konsultasi bila ada kekhawatiran |

### 8.12 Sumber dan kepemilikan entri

| Aturan | Isi |
|---|---|
| Field sumber | `mandiri` atau `kader` |
| Entri kader | Tidak dapat dihapus oleh ibu; ibu dapat mencabut akses kader |
| Koreksi | Dibuat sebagai revisi dengan jejak (siapa, kapan, alasan) |

---

## 9. Arsitektur Firebase

### 9.1 Komponen

| Komponen | Fungsi di NURI | Catatan |
|---|---|---|
| Firebase Authentication | Daftar dan masuk dengan email/password | Nomor HP ditunda [OQ-3] |
| Cloud Firestore (Native) | Data utama dan cache offline | Lokasi `asia-southeast2` (Jakarta) tersedia. Lokasi tidak dapat diubah setelah database dibuat |
| Cloud Functions | Operasi yang butuh validasi server: tukar kode, klaim anak, hapus akun, notifikasi push | Kebutuhan paket Blaze untuk Functions **[Verifikasi]** [OQ-19] |
| Cloud Messaging (FCM) | Notifikasi push dari sistem (S) | Pengingat rutin memakai notifikasi lokal, bukan FCM |
| App Check (Play Integrity) | Memastikan permintaan berasal dari aplikasi asli | Perlu sidik jari SHA dari Play App Signing agar berfungsi di produksi. Mulai dari mode pantau sebelum enforcement |
| Crashlytics | Laporan crash tanpa data pribadi | Tidak mengirim nama, email, atau nilai ukur |
| Cloud Storage | **Tidak dipakai di MVP** (K11) | Bila dipakai kelak, Cloud Storage for Firebase mensyaratkan paket Blaze |
| Firebase Analytics | Dimatikan di MVP [Usulan] | Bila diaktifkan, tanpa data kesehatan atau anak pada event |

Paket Flutter yang diusulkan, **[Verifikasi]** kompatibilitas versi dan status pemeliharaan sebelum ditambahkan: `firebase_core`, `firebase_auth`, `cloud_firestore`, `cloud_functions`, `firebase_messaging`, `firebase_app_check`, `firebase_crashlytics`, `flutter_local_notifications`, `tflite_flutter`, `image_picker`, `fl_chart`, `go_router`, `flutter_riverpod`, `google_fonts`, `mobile_scanner` dan `qr_flutter` (QR).

### 9.2 Diagram arsitektur

```
┌──────────────────────── Aplikasi Flutter (Android) ────────────────────────┐
│  UI (screens)  →  State (Riverpod)  →  Use case (domain murni: z-score,    │
│                                         gizi, AKG, kehamilan)              │
│                         │                                                  │
│                  Repository (interface)                                    │
│        ┌────────────────┼───────────────────────┐                          │
│  Firestore SDK     Cloud Functions SDK     Aset lokal (WHO LMS, TKPI, AKG) │
│  (+ cache offline)                         TFLite (model makanan, opsional)│
│  Notifikasi lokal  Kamera/Galeri                                           │
└────────┬──────────────────┬───────────────────────────────────────────────┘
         │ HTTPS            │ HTTPS (callable)
         ▼                  ▼
 Cloud Firestore      Cloud Functions ──► FCM (push)
 (Aturan Keamanan)    (validasi kode, klaim, hapus akun)
         ▲                  ▲
   Firebase Auth      App Check (Play Integrity)
```

### 9.3 Lapisan kode dan migrasi dari kode saat ini

| Lapisan | Isi | Aturan |
|---|---|---|
| `core/` | Tema, router, inisialisasi Firebase, penanda offline | Tanpa logika bisnis |
| `domain/` | Model, serta fungsi murni: umur, koreksi ukur, z-score, klasifikasi, gizi, AKG, usia kehamilan | Dart murni, tanpa dependensi Firebase. Unit test wajib |
| `data/` | Repository (antarmuka) dan implementasi Firestore/Functions | UI tidak memanggil Firestore langsung |
| `features/` | `auth`, `landing`, `pregnancy`, `child`, `growth`, `nutrition`, `posyandu`, `linking`, `content`, `reminders` | Satu folder per modul fungsional |
| `assets/data/` | `who_hfa_boys.json`, `who_hfa_girls.json`, `tkpi_vN.json`, `akg_vN.json` | Berversi, bersumber resmi, dibuat dengan skrip impor yang diverifikasi. Tidak ada baris karangan |

Migrasi: layanan in-memory yang ada (mis. `auth_service.dart`, `food_diary_service.dart`, `child_service.dart`) dipertahankan sebagai implementasi sementara di balik antarmuka repository, lalu diganti implementasi Firebase tanpa mengubah UI.

### 9.4 Cloud Functions

| Nama | Tipe | Fungsi | Validasi |
|---|---|---|---|
| `verifyPosyanduCode` | Callable | Menukar Kode Posyandu menjadi keanggotaan kader | Auth; role kader; pembatasan percobaan |
| `createLinkCode` | Callable | Membuat Kode Keluarga untuk subjek milik pemanggil | Pemanggil adalah wali/pemilik subjek |
| `redeemLinkCode` | Callable | Menukar kode menjadi grant dan entri roster | Kode aktif, belum kedaluwarsa, belum terpakai; pemanggil kader anggota Posyandu |
| `createClaimCode` | Callable | Kader membuat Kode Klaim anak tanpa akun | Kader anggota Posyandu pembuat anak |
| `claimChild` | Callable | Memindahkan kepemilikan anak ke ibu | Kode aktif; mencegah klaim ganda |
| `joinPosyandu` | Callable | Ibu mengikuti jadwal Posyandu | Kode valid |
| `deleteAccount` | Callable | Menghapus data pribadi pengguna | Hanya pemilik akun |
| `onMeasurementCreated` | Trigger (S) | Mengirim push "hasil ukur baru" ke ibu | Tanpa nilai atau status pada isi pesan |
| `setAdminClaim` | Skrip admin (bukan endpoint publik) | Memberi hak admin | Dijalankan tim secara manual |

Kedaluwarsa kode dan grant diperiksa memakai waktu server pada aturan keamanan dan Functions, sehingga tidak diperlukan penjadwal khusus.

### 9.5 Strategi offline

| Topik | Keputusan |
|---|---|
| Cache | Persistence Firestore aktif (default Android). Batas ukuran cache ditetapkan eksplisit |
| Pramuat | Cache hanya berisi dokumen yang pernah dimuat. Karena itu kader **wajib memuat roster, jadwal, dan konten saat online** sebelum sesi (Alur 4.1). Aplikasi menampilkan status "siap offline" |
| Penulisan | Pengukuran dan entri sesi adalah dokumen baru dengan ID acak, sehingga dua perangkat tidak saling menimpa |
| Konflik | Perubahan beberapa kali pada satu dokumen diselesaikan "tulisan terakhir menang". Dokumen bersama (roster) hanya memuat field yang diperbarui terpisah dan idempoten |
| Operasi atomik offline | Gunakan `WriteBatch`. Transaksi membutuhkan koneksi **[Verifikasi]** |
| Indikator | Status koneksi dan jumlah tulisan tertunda tampil di K-12 dan bilah atas |
| Keluar akun | Bila ada tulisan tertunda, aplikasi meminta sinkron dulu. Setelah itu cache dibersihkan agar data keluarga tidak tertinggal di perangkat |

### 9.6 Lingkungan dan biaya

| Item | Keputusan |
|---|---|
| Proyek | Dua proyek Firebase: `dev` dan `prod`. Emulator Firebase untuk menguji aturan dan Functions |
| Paket | Cloud Storage dan kemungkinan Cloud Functions membutuhkan Blaze (bayar sesuai pemakaian, dengan kuota gratis). Perlu akun penagihan dan peringatan anggaran [OQ-19] |
| Kuota | Kuota gratis harian Firestore **[Verifikasi]** saat implementasi. Desain menekan pembacaan: roster ter-denormalisasi, referensi dibundel, listener dibatasi per sesi |

---

## 10. Model data Firestore

### 10.1 Pohon koleksi

```
users/{uid}
  devices/{deviceId}
pregnancies/{pregId}
  checkups/{id}
  ttdLogs/{yyyyMMdd}
  ancVisits/{id}
  foodLogs/{id}
children/{childId}
  measurements/{id}
  foodLogs/{id}
posyandus/{posyanduId}
  members/{uid}
  sessions/{sessionId}
    entries/{entryId}
  roster/{rosterId}
accessGrants/{granteeUid_subjectId}
linkCodes/{codeHash}
contents/{contentId}
auditLogs/{id}                (S)
config/app
```

### 10.2 Dokumen dan field utama

| Koleksi | Field utama |
|---|---|
| `users/{uid}` | `role` (ibu/kader), `displayName`, `email`, `consent{version, acceptedAt}`, `posyanduIds[]`, `settings.reminders{ttd, anc, ukur, posyandu}`, `createdAt` |
| `users/{uid}/devices/{id}` | `fcmToken`, `updatedAt` |
| `pregnancies/{id}` | `ownerUid`, `method` (hpht/hpl), `hphtDate`, `hplDate`, `status` (aktif/lahir/berakhir), `childId?`, `endedAt?`, `createdAt` |
| `…/checkups/{id}` | `date`, `weightKg`, `lilaCm`, `hbGdl?`, `source` (mandiri/kader/bidan), `recordedByUid`, `sessionId?`, `createdAt` |
| `…/ttdLogs/{yyyyMMdd}` | `taken`, `loggedAt` |
| `…/ancVisits/{id}` | `date`, `facility?`, `note?`, `createdAt` |
| `children/{id}` | `nickname`, `dob`, `sex`, `guardianUids[]`, `guardianName?` (anak tanpa akun), `createdByUid`, `createdByRole`, `posyanduId?`, `status` (aktif/diarsipkan), `birth{weightG?, lengthCm?, gestationWeeks?}`, `createdAt` |
| `…/measurements/{id}` | `date`, `ageDays`, `ageMonths`, `weightKg`, `measuredCm`, `method`, `correctedCm`, `zHfa`, `category`, `refVersion`, `source` (mandiri/kader), `recordedByUid`, `sessionId?`, `flags[]`, `revisionOf?`, `createdAt` |
| `…/foodLogs/{id}` | `date`, `meal`, `items[{foodId, name, grams, kcal, proteinG, fatG, carbG, source, confidence?}]` (nilai gizi boleh `null`), `totals{…, incomplete}`, `tkpiVersion`, `akgVersion`, `createdAt` |
| `posyandus/{id}` | `name`, `area`, `schedule{nextDate, note}`, `codeHash`, `createdAt` |
| `…/members/{uid}` | `role`, `joinedAt` |
| `…/sessions/{id}` | `date`, `status` (berlangsung/selesai), `createdByUid`, `startedAt`, `endedAt?` |
| `…/entries/{id}` | `type` (anak/bumil), `subjectId`, `measurementId` atau `checkupId`, `categorySnapshot?`, `recordedByUid`, `createdAt` |
| `…/roster/{id}` | `type`, `subjectPath`, `displayName`, `dobOrHpl`, `lastCategory`, `lastMeasuredAt`, `absentCount`, `lastAbsentSessionId`, `followUp{needed, status, note, updatedAt}` |
| `accessGrants/{granteeUid_subjectId}` | `subjectType`, `subjectId`, `ownerUid`, `granteeUid`, `posyanduId`, `scopes[]` (ukur/makan), `status`, `createdAt`, `expiresAt`, `revokedAt?` |
| `linkCodes/{codeHash}` | `type` (keluarga/klaim), `issuerUid`, `subjectId`, `scopes[]`, `expiresAt`, `usedAt?`, `usedByUid?` |
| `contents/{id}` | `type`, `category`, `title`, `body`, `targetStatus?`, `ageMinMonths?`, `ageMaxMonths?`, `source`, `reviewedByName`, `status` (draft/published), `version`, `publishedAt` |
| `config/app` | `minAppVersion`, `consentVersion`, `refVersions` |

Contoh dokumen pengukuran (**Contoh**, bukan data nyata):

```json
{
  "date": "2026-11-09",
  "ageDays": 427, "ageMonths": 14,
  "weightKg": 9.4, "measuredCm": 75.0, "method": "berbaring", "correctedCm": 75.0,
  "zHfa": -1.2, "category": "normal", "refVersion": "who-hfa-2006",
  "source": "kader", "recordedByUid": "uid-kader", "sessionId": "sesi-001",
  "flags": [], "createdAt": "<server timestamp>"
}
```

### 10.3 Prinsip desain data

| Prinsip | Alasan |
|---|---|
| Pengukuran dan entri sesi tambah-saja | Menghindari konflik tulis antar perangkat; menjaga riwayat |
| ID grant deterministik `granteeUid_subjectId` | Aturan keamanan dapat memeriksa grant lewat jalur dokumen, tanpa kueri |
| Roster ter-denormalisasi | Daftar sasaran dan tindak lanjut cepat dan murah dibaca, dan bisa offline |
| Snapshot nilai gizi di food log | Riwayat tidak berubah saat tabel referensi diperbarui |
| Tanpa NIK, alamat lengkap, atau foto anak | Minimisasi data |
| Tabel referensi di aset, bukan Firestore | Offline, tanpa biaya baca, versi terkunci |

### 10.4 Aturan keamanan (sketsa, harus diuji di emulator)

| Sumber daya | Baca | Tulis |
|---|---|---|
| `users/{uid}` | Pemilik | Pemilik; `role` tidak dapat berubah |
| `children/{id}` | Wali (`guardianUids`) atau kader dengan grant `ukur` aktif, atau kader anggota Posyandu untuk anak tanpa akun buatannya | Wali; kader hanya untuk anak tanpa akun yang ia atau Posyandunya miliki |
| `…/measurements` | Sama dengan induk | Wali, atau kader dengan grant; entri kader tidak dapat dihapus wali |
| `…/foodLogs` | Wali, atau kader dengan grant `makan` | Wali |
| `pregnancies/**` | Pemilik, atau kader dengan grant | Pemilik; kader hanya `checkups` dengan grant |
| `posyandus/**` | Anggota Posyandu (kader), jadwal oleh pengikut | Anggota; admin |
| `accessGrants` | Pemilik dan grantee | Hanya lewat Functions; pemilik boleh mengubah status menjadi `dicabut` |
| `linkCodes` | Tidak ada | Hanya Functions |
| `contents` | Semua pengguna login, hanya `published` | Admin |

```
function hasGrant(subjectId, scope) {
  let g = get(/databases/$(db)/documents/accessGrants/$(request.auth.uid + '_' + subjectId)).data;
  return g.status == 'aktif' && scope in g.scopes && g.expiresAt > request.time;
}
```

Jumlah pemanggilan `get()`/`exists()` per permintaan dibatasi oleh Firestore **[Verifikasi]**; aturan dirancang agar jumlahnya kecil.

### 10.5 Indeks komposit (awal)

| Koleksi | Indeks | Untuk |
|---|---|---|
| `children` | `guardianUids` (array-contains) + `status` | Daftar anak ibu |
| `…/measurements` | `date` menurun | Riwayat dan kurva |
| `…/foodLogs` | `date` + `meal` | Diary per tanggal |
| `…/roster` | `followUp.needed` + `lastCategory` | Daftar tindak lanjut |
| `accessGrants` | `ownerUid` + `status`; `granteeUid` + `status` | Daftar akses ibu dan kader |

---

## 11. Layar dan navigasi

### 11.1 Navigasi bawah per peran

| Peran | Item navigasi |
|---|---|
| Ibu (hanya hamil) | Beranda, Catat Makan, Kehamilan (TTD, ANC), Edukasi, Profil |
| Ibu (hanya balita) | Beranda, Foto Makanan, Pertumbuhan, Edukasi, Profil |
| Ibu (hamil dan balita) | Pemilih konteks "Kehamilan / Anak" di bilah atas; navigasi mengikuti konteks terpilih |
| Kader | Sesi, Sasaran, Rekap, Tindak Lanjut, Profil |

### 11.2 Inventaris layar

| ID | Layar | Peran | FR utama |
|---|---|---|---|
| S-01 | Splash | Semua | F-01.1 |
| S-02 | Landing (hero carousel) | Semua | F-01.2–F-01.7 |
| S-03 | Pilih peran | Semua | F-01.8 |
| S-04 | Daftar | Semua | F-02.1 |
| S-05 | Masuk | Semua | F-02.1, F-02.2 |
| S-06 | Lupa password | Semua | F-02.2 |
| S-07 | Persetujuan dan disclaimer | Semua | F-02.4 |
| S-08 | Onboarding ibu hamil | Ibu | F-04.1 |
| S-09 | Onboarding ibu balita | Ibu | F-03.2 |
| S-10 | Onboarding kader (Kode Posyandu) | Kader | F-02.5, F-10.1 |
| S-11 | Profil dan pengaturan | Semua | F-14.1 |
| S-12 | Privasi dan akses data | Ibu | F-11.4 |
| S-13 | Daftar edukasi | Semua | F-08.3 |
| S-14 | Detail edukasi | Semua | F-08.3 |
| S-15 | Pengingat | Ibu | F-09.1, F-09.3 |
| H-01 | Beranda hamil | Ibu | F-04.2 |
| H-02 | Catatan pemeriksaan | Ibu | F-04.3, F-04.4 |
| H-03 | Pelacak TTD | Ibu | F-04.5 |
| H-04 | Pelacak ANC | Ibu | F-04.6 |
| H-05 | Diary makan hamil | Ibu | F-04.7 |
| H-06 | Melahirkan | Ibu | F-04.9 |
| H-07 | Akhiri kehamilan | Ibu | F-04.10 |
| B-01 | Beranda balita | Ibu | F-03.4, F-05.8 |
| B-02 | Pilih / tambah / ubah anak | Ibu | F-03.2–F-03.4 |
| B-03 | Input ukur | Ibu | F-05.1, F-05.2 |
| B-04 | Hasil skrining | Ibu | F-05.3–F-05.10 |
| B-05 | Kurva pertumbuhan | Ibu | F-05.9 |
| B-06 | Riwayat ukur | Ibu | F-05.7 |
| B-07 | Foto makanan | Ibu | F-06.1, F-06.3 |
| B-08 | Hasil deteksi dan koreksi | Ibu | F-06.4, F-06.5 |
| B-09 | Cari makanan manual | Ibu | F-06.2 |
| B-10 | Input porsi | Ibu | F-06.6 |
| B-11 | Ringkasan gizi dan simpan | Ibu | F-06.7, F-06.8 |
| B-12 | Diary dan ringkasan harian | Ibu | F-07 |
| B-13 | Rekomendasi | Ibu | F-08.1 |
| B-14 | Kode Keluarga / QR | Ibu | F-11.1, F-11.2 |
| B-15 | Masukkan Kode Klaim | Ibu | F-11.5 |
| K-01 | Beranda kader | Kader | F-10.2 |
| K-02 | Sasaran (roster) | Kader | F-10.3 |
| K-03 | Tambah sasaran | Kader | F-10.4 |
| K-04 | Mulai / kelola sesi | Kader | F-10.2 |
| K-05 | Input cepat anak | Kader | F-10.5, F-10.6 |
| K-06 | Input cepat ibu hamil | Kader | F-10.7 |
| K-07 | Rekap sesi | Kader | F-10.8 |
| K-08 | Tindak lanjut | Kader | F-10.9 |
| K-09 | Pindai / masukkan Kode Keluarga | Kader | F-11.3 |
| K-10 | Buat Kode Klaim | Kader | F-11.5 |
| K-11 | Jadwal Posyandu | Kader | F-08.5 |
| K-12 | Status sinkronisasi dan siap offline | Kader | F-10.10, F-13.2 |
| A-01 | Kelola konten (back-office) | Admin | F-12.1 |
| A-02 | Kelola Posyandu dan kode (back-office) | Admin | F-12.2 |

### 11.3 Arah visual

Detail visual diatur di dokumen desain terpisah. PRD hanya menetapkan perilaku dan aturan aksesibilitas berikut.

| Aspek | Aturan |
|---|---|
| Komponen | Material 3 untuk Android (NavigationBar, TopAppBar, dialog izin) |
| Warna awal | Teal `#2E9C85`, aksen peach `#FFB99A`, latar krem `#FFF8F1`, teks `#1F2D2A` (usulan; dapat diganti di dokumen desain) |
| Huruf | Nunito untuk judul, Inter untuk isi (usulan) |
| Status pertumbuhan | Selalu warna + teks + ikon |
| Sentuhan | Target minimal 48 dp |
| Nada bahasa | Hangat, tidak menakut-nakuti. Hasil "pendek" tidak memakai kata yang menyalahkan orang tua |
| Landing | Gambar bayi/balita berlisensi. Tidak memakai foto anak nyata tanpa izin tertulis orang tua |

---

## 12. Notifikasi dan pengingat

| ID | Pemicu | Penerima | Jenis | Contoh isi (tanpa data sensitif) | Prio |
|---|---|---|---|---|---|
| N-01 | TTD harian (jam dapat diatur) | Ibu hamil | Lokal | "Waktunya minum tablet tambah darah." | M |
| N-02 | Jadwal ANC | Ibu hamil | Lokal | "Ada jadwal pemeriksaan kehamilan besok." | M |
| N-03 | Pemantauan ukur bulanan | Ibu balita | Lokal | "Saatnya memantau tinggi dan berat si kecil." | M |
| N-04 | Jadwal Posyandu | Ibu | Lokal dari jadwal; push saat berubah (S) | "Posyandu besok pukul …" | M |
| N-05 | Hasil ukur baru | Ibu | Push (S) | "Ada hasil pengukuran baru. Buka NURI untuk melihat." | S |
| N-06 | Catat makan | Ibu | Lokal, default mati | "Jangan lupa catat makan hari ini." | S |
| N-07 | Daftar tindak lanjut sebelum sesi | Kader | Lokal | "Ada anak yang perlu ditindaklanjuti." | S |
| N-08 | Akses diberikan atau dicabut | Kader / Ibu | Push | "Status akses data berubah." | S |

Aturan: isi tidak memuat nama anak atau status pertumbuhan; ada pengaturan hidup/mati per jenis; izin notifikasi Android 13+ diminta dengan penjelasan; kanal notifikasi dipisah per jenis.

---

## 13. Kebutuhan non-fungsional

| ID | Area | Requirement | Target / verifikasi |
|---|---|---|---|
| NFR-01 | Performa | Layar utama termuat dalam waktu wajar pada jaringan normal; hitung z-score dan gizi lokal | Layar utama < 3 dtk; hitung lokal ≤ 200 ms [Usulan] |
| NFR-02 | Performa | Scan makanan | ≤ 2 dtk pada RAM 3 GB (M-07) |
| NFR-03 | Offline | Seluruh alur kader dan pencatatan harian berjalan tanpa internet | M-04 |
| NFR-04 | Keamanan | Semua komunikasi lewat HTTPS; akses data lewat aturan Firestore dengan hak minimum; App Check; peran tidak dapat diubah klien | M-09 |
| NFR-05 | Keamanan | Konfigurasi Firebase di aplikasi bukan rahasia; keamanan bergantung pada aturan dan App Check. Tidak ada kunci layanan atau kunci pihak ketiga di aplikasi | Tinjauan kode |
| NFR-06 | Privasi | Minimisasi data; foto tidak diunggah; admin tanpa akses data kesehatan | §14 |
| NFR-07 | Aksesibilitas | Kontras teks WCAG AA; target sentuh ≥ 48 dp; label semantik untuk pembaca layar; mendukung ukuran huruf sistem yang diperbesar | Uji manual |
| NFR-08 | Usabilitas | Bahasa Indonesia sederhana; scan pertama ≤ 3 menit tanpa tutorial | M-06 |
| NFR-09 | Kompatibilitas | Versi Android minimum dan perangkat uji ditetapkan [OQ-26]; uji pada minimal dua perangkat termasuk RAM 3 GB | Uji instalasi |
| NFR-10 | Ukuran | APK ≤ 150 MB | M-08 |
| NFR-11 | Keandalan | Tulisan tertunda tetap ada setelah aplikasi ditutup dan tersinkron kemudian; data tersimpan tidak hilang | Uji offline |
| NFR-12 | Observabilitas | Crashlytics tanpa data pribadi; log tidak memuat nilai ukur atau nama | Tinjauan log |
| NFR-13 | Pemeliharaan | Domain murni terpisah dari UI dan Firebase; unit test untuk perhitungan | Cakupan tes §16 |

---

## 14. Privasi dan kepatuhan

### 14.1 Klasifikasi data

| Data | Kategori | Perlakuan |
|---|---|---|
| Nama, email | Data pribadi | Disimpan di Authentication dan `users` |
| Nama panggilan anak, tanggal lahir, jenis kelamin, hasil ukur | Data anak dan data kesehatan | Diperlakukan sebagai data pribadi yang bersifat spesifik. **[Verifikasi hukum]** terhadap UU PDP No. 27/2022 |
| Kehamilan dan pemeriksaan | Data kesehatan | Sama dengan di atas |
| Catatan makan | Data pribadi non-medis | Hanya dibagikan bila ibu memberi cakupan "makan" |
| Foto makanan | Sementara | Di perangkat, dihapus setelah simpan; tidak diunggah |
| Konten edukasi | Publik | Dapat dibaca semua pengguna login |

Tidak dikumpulkan: NIK, alamat lengkap, foto anak, lokasi presisi.

### 14.2 Isi minimum persetujuan (S-07)

| Butir | Isi |
|---|---|
| Tujuan | Memantau gizi dan pertumbuhan; bukan diagnosis |
| Data | Jenis data yang dikumpulkan (§14.1) |
| Pihak yang melihat | Hanya orang yang diizinkan ibu; admin tidak melihat data kesehatan |
| Hak pengguna | Mengakses, memperbaiki, menghapus data, dan mencabut akses kapan saja |
| Penyimpanan | Basis data di Firebase, lokasi Jakarta (`asia-southeast2`) |
| Disclaimer | Hasil adalah skrining awal; keputusan medis oleh tenaga kesehatan |
| Kader | Menggunakan data hanya untuk kegiatan Posyandu. Pihak yang bertanggung jawab atas data [OQ-9] |

### 14.3 Hak subjek data

| Hak | Cara | Prio |
|---|---|---|
| Akses dan ekspor | F-14.3 | S |
| Koreksi | Mengubah data, atau revisi pengukuran | M |
| Hapus | F-02.6 (Cloud Function) | M |
| Cabut akses pihak lain | S-12 | M |
| Cabut persetujuan | Hapus akun | M |

### 14.4 Retensi (usulan, ditetapkan di OQ-20)

| Objek | Default [Usulan] |
|---|---|
| Grant akses | Berlaku 12 bulan, dapat diperpanjang oleh ibu |
| Anak tanpa akun yang tidak diklaim | Diarsipkan setelah 12 bulan sejak pengukuran terakhir |
| Akun yang dihapus | Data pribadi dihapus dari Firestore saat penghapusan selesai. Tidak ada cadangan di MVP |
| Foto makanan | Dihapus dari perangkat setelah entri tersimpan |

### 14.5 Praktik teknis

| Topik | Aturan |
|---|---|
| Analytics dan crash | Analytics mati; Crashlytics tanpa nama, email, atau nilai ukur |
| Perangkat bersama | Saat keluar akun, cache data keluarga dibersihkan setelah tulisan tertunda tersinkron (E-28) |
| Notifikasi | Tanpa data sensitif pada layar kunci |
| Admin | Tidak memiliki akses baca ke data kesehatan |

---

## 15. Kasus tepi dan kondisi gagal

| ID | Skenario | Perilaku yang diharapkan | Ref |
|---|---|---|---|
| E-01 | Foto makanan buram, gelap, atau tanpa makanan | Pesan "makanan tidak terdeteksi"; tawarkan foto ulang atau pencarian manual | F-06.4 |
| E-02 | Makanan di luar kelas model | Tampilkan "tidak dikenali" dan arahkan ke pencarian manual. Tebakan berkepercayaan rendah tidak ditampilkan sebagai hasil pasti | F-06.4 |
| E-03 | Sebagian item hasil deteksi salah | Pengguna mengubah, menghapus, atau menambah per item | F-06.5 |
| E-04 | Makanan tidak ada di TKPI atau nilai gizi kosong | Tampilkan "data gizi tidak tersedia"; tidak dihitung sebagai nol; total diberi label "tidak lengkap" | F-06.8 |
| E-05 | Nilai berat/tinggi mustahil atau ekstrem (salah ketik) | Mustahil: ditolak. Ekstrem: minta konfirmasi ulang | F-05.5 |
| E-06 | Umur di luar 0–59 bulan atau tanggal lahir di masa depan | Ditolak dengan pesan rentang usia | F-03.2 |
| E-07 | Anak prematur | Menampilkan catatan bahwa penilaian memakai umur kronologis. Koreksi umur belum tercakup [OQ-6] | F-03.5 |
| E-08 | Pengukuran pada tanggal yang sama dimasukkan dua kali | Peringatan duplikat; pengguna memilih menyimpan sebagai entri baru atau membatalkan | F-05.6 |
| E-09 | Tidak ada koneksi | Fitur lokal tetap berjalan. Operasi yang butuh internet menampilkan status offline yang jelas | F-13.4 |
| E-10 | Dua perangkat menulis pada waktu berdekatan | Entri baru bersifat tambah-saja. Dokumen bersama memakai "tulisan terakhir menang" pada field terpisah | F-13.3 |
| E-11 | Izin kamera ditolak | Layar penjelasan dan tombol menuju pengaturan; input manual tetap tersedia | F-06.1 |
| E-12 | Model TFLite gagal dimuat atau RAM kurang | Error terkontrol, tidak crash; jalur manual tetap tersedia | F-06.3 |
| E-13 | Inferensi melebihi target waktu | Indikator proses; tidak dibatalkan otomatis. Batas waktu [OQ-14] | F-06.10 |
| E-14 | Kode keluarga/klaim salah, kedaluwarsa, atau sudah terpakai | Pesan spesifik; percobaan dibatasi; pengguna dapat meminta kode baru | F-11.1 |
| E-15 | Grant dicabut saat kader offline dengan tulisan tertunda | Saat sinkron, tulisan ditolak aturan. Entri ditandai "gagal: akses dicabut" di K-12. Tidak ditulis ke data keluarga | F-11.4 |
| E-16 | Kader tanpa Kode Posyandu yang valid | Fitur kader terkunci; pesan jelas | F-02.5 |
| E-17 | Kode klaim dipakai dua ibu, atau anak sudah diklaim | Hanya pemakai pertama berhasil; yang lain ditolak | F-11.5 |
| E-18 | Kehamilan berakhir tanpa kelahiran | Bahasa netral dan tanpa menanyakan sebab. Pengingat berhenti. Tidak menawarkan pembuatan profil anak. Pengguna dapat menghapus data kehamilan [OQ-24] | F-04.10 |
| E-19 | Kelahiran dicatat padahal anak serupa sudah ada | Peringatan kemungkinan duplikat (nama dan tanggal lahir); pengguna memilih lanjut atau batal | Alur 6 |
| E-20 | Ibu menghapus akun yang datanya dibagikan ke kader | Grant dan data anak dihapus. Entri sesi kader hanya menyisakan agregat tanpa identitas [OQ-20] | F-02.6 |
| E-21 | Anak pindah Posyandu | Kader baru memperoleh grant baru; riwayat tetap pada anak; roster lama ditandai nonaktif | F-11 |
| E-22 | Izin notifikasi ditolak (Android 13+) | Banner penjelasan; pengaturan pengingat tetap tersimpan; tombol menuju pengaturan | F-09.3 |
| E-23 | Perangkat dinyalakan ulang atau zona waktu berubah | Pengingat dijadwalkan ulang saat boot atau saat aplikasi dibuka | F-09.2 |
| E-24 | Kuota atau anggaran Firebase tercapai | Penulisan gagal dengan pesan jelas; tulisan tertunda tidak hilang; peringatan anggaran ke tim [OQ-19] | NFR-11 |
| E-25 | Aplikasi versi lama dengan skema data baru | `minAppVersion` memaksa pembaruan; field tak dikenal diabaikan | §10 |
| E-26 | z-score di luar ±6 | Ditandai kemungkinan salah input; diminta periksa ulang; disimpan hanya setelah konfirmasi | F-05.5 |
| E-27 | Kader menambah anak yang sudah punya akun (duplikat) | Peringatan berdasarkan nama dan tanggal lahir; menyarankan Kode Keluarga | F-10.4 |
| E-28 | Satu perangkat dipakai dua pengguna | Saat keluar, cache data keluarga dibersihkan setelah tulisan tertunda tersinkron. Bila ada tulisan tertunda, pengguna diminta sinkron atau mengonfirmasi pembuangan | §9.5 |
| E-29 | Jam perangkat salah | Tanggal ukur dapat diubah; tanggal di masa depan ditolak; selisih besar dengan waktu server saat sinkron ditandai pada `flags` | §8.1 |
| E-30 | Aplikasi tertutup paksa atau baterai habis saat sesi | Entri yang sudah disimpan tetap ada; sesi dapat dilanjutkan. Isian yang belum disimpan hilang (draft lokal S) | F-10.10 |
| E-31 | Login pertama kali tanpa internet | Pesan bahwa login pertama butuh internet | F-13.5 |
| E-32 | Versi persetujuan baru terbit | Diminta menyetujui ulang; bila menolak, fitur dibatasi dan opsi hapus akun tersedia | F-02.4 |

---

## 16. Strategi pengujian

### 16.1 Uji unit (domain murni)

| Area | Kasus minimum |
|---|---|
| Umur | Batas bulan, tahun kabisat, tanggal lahir = tanggal ukur, masa depan |
| Koreksi ukur | PB↔TB pada umur < 24 dan ≥ 24 bulan |
| Z-score | Minimal 30 kasus dibandingkan dengan kalkulator WHO resmi: laki-laki dan perempuan, umur < 24 dan ≥ 24 bulan, nilai dekat batas klasifikasi |
| Klasifikasi | Nilai tepat pada −3, −2, +3 dan di sekitarnya |
| Gizi | Porsi 0 atau negatif ditolak; nilai `null` tidak menjadi 0; total tidak lengkap |
| AKG | Pergantian kelompok umur |
| Kehamilan | HPHT ↔ HPL, minggu+hari, batas trimester |
| Tidak hadir | Penambahan hitungan idempoten |

### 16.2 Uji aturan keamanan (emulator Firebase)

| ID | Kasus | Hasil |
|---|---|---|
| T-S01 | Ibu A membaca anak ibu B | Ditolak |
| T-S02 | Kader tanpa grant membaca anak ber-akun | Ditolak |
| T-S03 | Kader dengan grant `ukur` membaca pengukuran | Diizinkan |
| T-S04 | Kader dengan grant `ukur` membaca food log | Ditolak |
| T-S05 | Kader dengan grant `makan` membaca food log | Diizinkan |
| T-S06 | Grant dicabut, kader membaca | Ditolak |
| T-S07 | Grant kedaluwarsa, kader membaca | Ditolak |
| T-S08 | Klien mengubah `role` miliknya | Ditolak |
| T-S09 | Klien membuat `accessGrants` atau `linkCodes` langsung | Ditolak |
| T-S10 | Pengguna biasa menulis `contents` | Ditolak |
| T-S11 | Admin membaca `children` | Ditolak |
| T-S12 | Konten `draft` dibaca non-admin | Ditolak |
| T-S13 | Kader non-anggota membaca roster Posyandu lain | Ditolak |
| T-S14 | Wali menghapus pengukuran yang dibuat kader | Ditolak |
| T-S15 | Kader menulis pengukuran ke anak tanpa grant | Ditolak |

### 16.3 Uji integrasi

| ID | Skenario |
|---|---|
| T-I01 | Sesi 20 anak dalam mode pesawat, lalu sambung internet: semua entri tersinkron, tidak ada yang hilang (M-04) |
| T-I02 | Kehamilan → kelahiran dalam satu batch, termasuk saat offline |
| T-I03 | Kode keluarga: berhasil, kedaluwarsa, salah, terpakai |
| T-I04 | Klaim anak oleh dua ibu bersamaan |
| T-I05 | Pencabutan akses saat kader memiliki tulisan tertunda (E-15) |
| T-I06 | Hapus akun: dokumen pribadi tidak lagi terbaca |
| T-I07 | Pengingat tetap muncul setelah perangkat dinyalakan ulang |
| T-I08 | Keluar akun dengan tulisan tertunda (E-28) |

### 16.4 Uji model makanan (bila model ada)

Presisi, recall, dan F1 per kelas; confusion matrix; gambar di luar kelas dan gambar berkualitas rendah; makanan yang mirip; latensi pada RAM 3 GB. Set uji terpisah dan tidak dipakai saat memilih model. Dataset dan labelnya dicatat asal dan lisensinya [OQ-5].

### 16.5 Uji penerimaan pengguna

| ID | Skenario | Lulus bila |
|---|---|---|
| UAT-01 | Ibu hamil: daftar → kehamilan → catat TTD → catat pemeriksaan → catat ANC | Selesai tanpa bantuan dan memahami pesan konsultasi |
| UAT-02 | Ibu balita: daftar → tambah anak → input ukur → baca hasil → catat makan | Memahami status dan langkah berikutnya |
| UAT-03 | Kader: gabung Posyandu → sesi offline → rekap → sinkron | M-04 terpenuhi |
| UAT-04 | Penghubungan: ibu membuat kode → kader memindai → kader mengukur → ibu melihat hasil → ibu mencabut | Seluruh langkah berfungsi dan pencabutan efektif |
| UAT-05 | Kelahiran: hamil → melahirkan → profil anak | Riwayat lahir tampil di anak |
| UAT-06 | Aksesibilitas singkat dengan pembaca layar dan huruf diperbesar | Layar inti dapat dipakai |

Pengguna uji: minimal 5 pengguna awam untuk M-06 dan, bila tersedia, kader dan ibu nyata [OQ-12]. Perangkat uji ditetapkan di [OQ-26].

---

## 17. Roadmap dan potongan MVP

Urutan mengikuti ketergantungan teknis. Tidak ada tanggal karena kapasitas tim belum diukur; estimasi durasi ditetapkan tim setelah P0.

### 17.1 Fase

| Fase | Isi | Cakupan | Kriteria selesai |
|---|---|---|---|
| P0 Fondasi | Repo dan struktur lapisan, proyek Firebase `dev`, Firestore Jakarta, kerangka aturan keamanan, emulator, CI (analyze dan test), tema. Gerbang keputusan OQ-19 dan OQ-26 | §9 | Aplikasi kosong berjalan, terhubung ke `dev`, emulator berjalan |
| P1 Domain dan data referensi | Fungsi murni (umur, koreksi, z-score, klasifikasi, gizi, AKG, kehamilan). Impor tabel WHO, TKPI, AKG dengan skrip terverifikasi | §8, F-05.3–F-05.4, F-06.7 | 30 kasus z-score lulus (M-02, M-03) |
| P2 Akun dan onboarding | Landing, pilih peran, auth, persetujuan, onboarding, profil anak | F-01, F-02, F-03 | Alur 1 lulus |
| P3 Pertumbuhan balita | Input ukur, hasil, kurva, riwayat, rekomendasi dasar | F-05, F-08.1–F-08.2 | Alur 3.2–3.5 dan 3.9 lulus |
| P4 Makanan dan diary | Pencarian TKPI, porsi, hitung gizi, diary, AKG | F-06.2, F-06.5–F-06.9, F-07 | Alur 3.7–3.8 lulus tanpa model |
| P5 Ibu hamil dan pengingat | Kehamilan, pemeriksaan, TTD, ANC, pengingat lokal | F-04, F-09.1–F-09.4 | Alur 2 lulus |
| P6 Mode kader | Posyandu, roster, sesi, input cepat, rekap, tindak lanjut, offline | F-10, F-13 | Alur 4 lulus; M-04 |
| P7 Penghubungan | Cloud Functions, grant, klaim, kelahiran, pengerasan aturan keamanan | F-11, Alur 5–7 | Seluruh T-S dan T-I03–T-I05 lulus |
| P8 Scan makanan (kondisional) | Model TFLite, deteksi, ambang | F-06.3, F-06.10 | Hanya bila dataset tersedia (OQ-5) |
| P9 Pengerasan | Uji aturan, uji offline, UAT, performa, ukuran APK, App Check enforcement, data demo sintetis berlabel, dokumentasi | §16 | M-01–M-10 terpenuhi |

Jalur paralel: P0 bagian Firebase dan P1 (domain murni) dapat dikerjakan bersamaan oleh dua orang karena tidak saling bergantung.

### 17.2 Garis potong MVP

| Kelompok | Isi |
|---|---|
| **Wajib (M)** | P0–P7 dan P9. Alur lintas peran (P7) adalah inti flow dan tidak dipotong |
| **Sebaiknya (S)** | Push FCM, ekspor CSV, diary dan edukasi untuk ibu hamil, log audit, draft lokal, kurva tambahan |
| **Kondisional** | P8 (scan TFLite) |

Urutan pemangkasan bila waktu kurang: (1) P8, (2) push FCM dan ekspor CSV, (3) diary dan edukasi ibu hamil, (4) log audit dan draft lokal, (5) admin back-office (konten diisi lewat Firebase Console).

---

## 18. Risiko dan mitigasi

| ID | Risiko | Dampak | Mitigasi |
|---|---|---|---|
| R-01 | Dataset makanan tidak tersedia | Scan tidak dapat dibuat atau diuji | K12: jalur manual wajib lebih dulu; kurangi jumlah kelas; P8 kondisional |
| R-02 | Paket Blaze atau penagihan tidak tersedia | Functions dan Storage tidak dapat dipakai, sehingga penghubungan aman tidak bisa dibangun | Putuskan di P0 (OQ-19). Jangan melonggarkan aturan keamanan sebagai pengganti Functions |
| R-03 | Aturan keamanan keliru | Kebocoran data anak dan ibu | Uji emulator (T-S01–T-S15), tinjauan sejawat, hak akses minimum |
| R-04 | Z-score atau klasifikasi salah | Hasil menyesatkan | Uji 30 kasus terhadap kalkulator WHO, versi tabel tersimpan |
| R-05 | Konten rekomendasi tanpa peninjau | Saran tidak aman | Konten terkunci hingga ada peninjau (F-08.2); sumber Kemenkes (OQ-11) |
| R-06 | Biaya baca Firestore tak terduga | Kuota atau anggaran habis | Roster ter-denormalisasi, referensi dibundel, listener berlingkup, peringatan anggaran |
| R-07 | Kader lupa memuat data sebelum offline | Roster kosong di lapangan | Indikator "siap offline" di K-12; pramuat otomatis saat online |
| R-08 | Lingkup terlalu besar untuk dua orang | Tidak selesai | Garis potong §17.2 |
| R-09 | Kepatuhan UU PDP untuk data anak | Risiko hukum | Persetujuan, minimisasi, tinjauan hukum (OQ-9) |
| R-10 | Hasil dianggap diagnosis | Kesalahan tindakan | Disclaimer, bahasa, rujukan ke fasilitas kesehatan |
| R-11 | Kader tak terverifikasi mengakses data | Penyalahgunaan | Akses hanya lewat grant ibu; Kode Posyandu dari admin (OQ-17); log audit |
| R-12 | App Check gagal di build rilis | Aplikasi tidak bisa mengakses data | Mulai dari mode pantau; daftarkan SHA dari Play App Signing; uji build rilis |
| R-13 | Skema Firestore berubah saat pengembangan | Data lama tidak cocok | Field `schemaVersion`, `minAppVersion`, migrasi sederhana |
| R-14 | Lisensi foto landing | Pelanggaran hak cipta | Foto stok berlisensi atau ilustrasi (OQ-25) |

---

## 19. Open Questions

Status: **Terjawab** (ada default yang diterapkan di dokumen ini), **Terbuka**, atau **Gugur**.

| # | Pertanyaan | Status | Default / catatan | Dampak |
|---|---|---|---|---|
| OQ-1 | Fitur belum diputuskan di v0.1: chatbot, PDF, reminder, lokasi Posyandu | Terjawab | Chatbot v2; ekspor CSV (S); reminder lokal (M); lokasi Posyandu C | Lingkup |
| OQ-2 | Fitur wajib offline dan model sinkronisasi | Terjawab | Offline-first untuk kader dan pencatatan; cache Firestore; append-only | Arsitektur |
| OQ-3 | Login email atau HP; satu akun lintas status; batas anak | Terjawab (konfirmasi) | Email; ya; 5 anak per akun | F-02, F-03 |
| OQ-4 | Estimasi porsi makanan | Terbuka | Gram wajib; ukuran rumah tangga (S) | F-06 |
| OQ-5 | Dataset makanan: kelas, sumber, lisensi, pelabel | Terbuka (risiko utama) | Jalur manual lebih dulu; P8 kondisional | R-01, M-11 |
| OQ-6 | Ambang kepercayaan deteksi; batas nilai ukur; koreksi prematur; tabel WHO per hari atau bulan | Terbuka | Default §8.5; per hari disarankan | §8, F-05, F-06 |
| OQ-7 | Nutrien ditampilkan; sumber dan versi AKG (anak dan ibu hamil); ambang indikator; BB/U dan BB/TB | Terbuka | Empat nutrien; ambang contoh §8.7 | F-06, F-07 |
| OQ-8 | Penyimpanan foto | Terjawab | Foto makanan lokal sementara lalu dihapus; foto anak tidak ada | K11 |
| OQ-9 | UU PDP untuk data anak: persetujuan bila kader menginput, penghapusan, pengendali data | Terbuka sebagian | Grant, klaim, dan hapus akun sudah dirancang; perlu tinjauan hukum | §14 |
| OQ-10 | Format indikator foto anak | Gugur | Fitur dikeluarkan (K4) | — |
| OQ-11 | Konten rekomendasi: penyusun dan peninjau; konten sangat pendek dan ≥ 24 bulan; sumber jadwal Puskesmas | Terbuka (kritis untuk keamanan) | Konten terkunci sampai ada peninjau | F-08, R-05 |
| OQ-12 | Akses ke ibu dan kader nyata untuk uji; validasi persona | Terbuka | Pengguna awam sebagai pengganti | M-05, M-06 |
| OQ-13 | Format laporan kader | Terjawab | Rekap di aplikasi; CSV (S) | F-10 |
| OQ-14 | Toleransi selisih z-score; batas waktu inferensi; perangkat uji | Terbuka | Ditetapkan sebelum P1 selesai | M-02, M-07 |
| OQ-15 | Dasar ilmiah foto sebagai indikator stunting | Gugur | Fitur dikeluarkan | — |
| OQ-16 | Framework aplikasi | Terjawab | Flutter [Frito] | — |
| OQ-17 | Siapa menerbitkan Kode Posyandu dan memverifikasi kader | Terbuka | Admin (tim) menerbitkan kode per Posyandu | F-02.5, R-11 |
| OQ-18 | Ambang LiLA dan Hb serta sumbernya | Terbuka | Default §8.9, wajib diverifikasi | F-04.4 |
| OQ-19 | Paket Blaze, penagihan, anggaran; kebutuhan Blaze untuk Functions; bentuk antarmuka admin | Terbuka (gerbang P0) | Verifikasi di Firebase Console sebelum P0 selesai | R-02, F-12 |
| OQ-20 | Retensi data, masa berlaku grant, nasib data setelah hapus akun | Terbuka | Default §14.4 | §14 |
| OQ-21 | Jadwal ANC per trimester | Terbuka | Hanya target total 6 kunjungan di MVP | F-04.6 |
| OQ-22 | Peran bidan/tenaga kesehatan sebagai verifikator | Terbuka | Ditinjau untuk v2 | §4.1 |
| OQ-23 | Identitas minimum anak tanpa akun | Terjawab (konfirmasi) | Nama panggilan, nama wali, tanggal lahir; tanpa NIK | F-10.4 |
| OQ-24 | Penanganan kehamilan yang berakhir tanpa kelahiran | Terbuka | Bahasa netral, tanpa pertanyaan, opsi hapus data. Tinjau dengan dosen atau tenaga kesehatan | E-18 |
| OQ-25 | Sumber dan lisensi foto landing | Terbuka | Foto stok berlisensi atau ilustrasi | F-01.4, R-14 |
| OQ-26 | Versi Android minimum; kompatibilitas Firebase dan TFLite; perangkat uji | Terbuka | Ditetapkan di P0 | NFR-09 |

---

## 20. Lampiran

### A. Glosarium

| Istilah | Arti |
|---|---|
| AKG | Angka Kecukupan Gizi |
| ANC | Antenatal care, pemeriksaan kehamilan |
| e-PPGBM | Elektronik Pencatatan dan Pelaporan Gizi Berbasis Masyarakat |
| HPHT / HPL | Hari pertama haid terakhir / hari perkiraan lahir |
| HPK | Hari Pertama Kehidupan (1000 HPK: sejak kehamilan sampai anak berusia 2 tahun) |
| Hb | Hemoglobin |
| KEK | Kurang Energi Kronis |
| KIA | Kesehatan Ibu dan Anak (buku KIA) |
| LiLA | Lingkar lengan atas |
| LMS | Metode (L, M, S) yang dipakai WHO untuk menghitung z-score |
| MPASI | Makanan pendamping ASI |
| PB / TB | Panjang badan (berbaring) / tinggi badan (berdiri) |
| Posyandu | Pos pelayanan terpadu |
| TKPI | Tabel Komposisi Pangan Indonesia |
| TTD | Tablet tambah darah |
| z-score | Jarak nilai terhadap median referensi, dalam satuan simpangan baku |
| Grant | Izin akses yang diberikan ibu kepada kader, dengan cakupan dan masa berlaku |
| Roster | Daftar sasaran (anak dan ibu hamil) suatu Posyandu |

### B. Pemetaan dari PRD v0.1

| v0.1 | v0.2 | Catatan |
|---|---|---|
| F-01 Autentikasi | F-02 | Supabase diganti Firebase; ditambah Kode Posyandu |
| F-02 Scan makanan | F-06.1–F-06.6, F-06.9–F-06.10 | Jalur manual wajib; model kondisional |
| F-03 Gizi dan AKG | F-06.7, F-07 | |
| F-04 Data anak dan pengukuran | F-03, F-05.1–F-05.2 | Ditambah riwayat tambah-saja |
| F-05 Skrining stunting | F-05.3–F-05.10 | Foto anak dikeluarkan |
| F-06 Rekomendasi | F-08, §8.11 | |
| F-07 Food diary | F-07 | |
| F-08 Mode kader | F-10, F-11 | Ditambah grant dan klaim |
| F-09 Kurva pertumbuhan | F-05.9 | |
| — | F-01, F-04, F-09, F-12, F-13, F-14 | Baru |

### C. Status kode saat ini → tugas di v0.2

Status kode berasal dari kroscek di PRD v0.1 dan perlu dicek ulang terhadap repo terbaru.

| Fitur | Status kode (v0.1) | Tugas di v0.2 |
|---|---|---|
| Registrasi dan login | Login demo in-memory | Ganti ke Firebase Auth; peran ibu/kader; Kode Posyandu; persetujuan (F-02) |
| Database makanan | 25 item | Impor TKPI lengkap dengan skrip terverifikasi (F-06.2) |
| Hitung gizi | `gram/100` untuk 4 nutrien | Pertahankan; tambah penanganan `null`, snapshot, versi TKPI (F-06.7) |
| AKG | Hardcode dewasa | AKG otomatis dari umur dan jenis kelamin (F-07.3) |
| Food diary | In-memory | Repository Firestore (F-07) |
| Data anak | CRUD tanpa validasi umur | Validasi 0–59 bulan, riwayat ukur (F-03, F-05) |
| Skrining stunting | Status dropdown manual | Z-score WHO dan klasifikasi (F-05.3–F-05.4) |
| Foto anak | Belum ada | Dikeluarkan dari lingkup |
| Rekomendasi | Artikel statis | Bank konten Firestore dan tabel §8.11 (F-08) |
| Kurva | Toggle tidak terhubung | Kurva dengan garis WHO (F-05.9) |
| Mode kader | Peran dan 20 data seed | Sesi, roster, rekap, tindak lanjut (F-10). Seed menjadi data sintetis berlabel |
| Disclaimer dan persetujuan | Checkbox syarat | Layar persetujuan wajib dengan versi (F-02.4) |
| Role ibu hamil | Ada di kode, tanpa konten | Dipakai sebagai mode hamil dari role `ibu` (F-04) |
| Reminder | Toggle in-memory | Notifikasi lokal terjadwal (F-09) |
| Penyimpanan | In-memory | Firestore dengan cache offline (§9.5) |

### D. Sumber riset

Sebagian sumber adalah skripsi dan laporan pengabdian masyarakat. Sumber tersebut dipakai untuk memetakan fitur dan kendala, bukan sebagai bukti bahwa suatu fitur menurunkan stunting. Studi lokal tidak digeneralisasi ke tingkat nasional.

| Topik | Sumber |
|---|---|
| Gosting | https://ejurnalmalahayati.ac.id/index.php/kreativitas/article/download/27648/Download%20Artikel |
| Stunting Care dan daftar aplikasi | https://journals2.ums.ac.id/warta/article/download/4388/1829/24157 |
| Kualitas data e-PPGBM (Toraja Utara) | https://repository.ipb.ac.id/handle/123456789/172888 |
| Akurasi antropometri dan alat IoT | https://abdiinsani.unram.ac.id/index.php/jurnal/article/download/3228/2100/30808 |
| Faktor risiko berbasis e-PPGBM (Tangerang Selatan) | https://journal.stikesbanten.ac.id/index.php/Kesehatan/article/download/205/177 |
| E-GIZI | https://proceeding.unpkediri.ac.id/index.php/ncce/article/download/9540/6259/36047 |
| Perbandingan fitur aplikasi (Telkom University) | https://openlibrary.telkomuniversity.ac.id/pustaka/files/218031/bab1/pengembangan-fitur-tracking-dan-rekomendasi-gizi-ibu-pada-aplikasi-mobile-genting-guna-mencegah-stunting-menggunakan-vision-transformer-studi-kasus-pkk-kota-bandung-dalam-bentuk-buku-karya-ilmiah.pdf |
| Si Bunda | https://www.its.ac.id/news/its-kembangkan-si-bunda-solusi-stunting-untuk-indonesia/ |
| CETING | https://www.ejurnalmalahayati.ac.id/index.php/manuju/article/download/18103/Download%20Artikel |
| E-STARE | https://repository.unair.ac.id/117268/1/E-STARE_Rafaleony%20Berlian%20Putri%20W_Universitas%20Airlangga.pdf |
| Aplikasi empat peran (Polije) | https://sipora.polije.ac.id/56709/2/Bab%201%20Pendahuluan.pdf |
| Tinjauan mHealth stunting | https://www.pms.lifescienceglobal.com/index.php/ijchn/article/view/10416 |
| Kemenkes: intervensi sebelum dan saat kehamilan | https://kemkes.go.id/id/intervensi-pencegahan-stunting-dimulai-sebelum-dan-saat-kehamilan |
| Kajian prioritas intervensi (Badan Kebijakan Kemenkes) | https://repository.badankebijakan.kemkes.go.id/id/eprint/5952/1/18%20Menentukan%20Prioritas%20Intervensi.pdf |
| Data Riskesdas 2018 (TTD dan anemia) | https://repository.unhas.ac.id/55879/2/K013211036-1-2.pdf |
| Firebase: paket harga | https://firebase.google.com/docs/projects/billing/firebase-pricing-plans |
| Firebase: Cloud Storage dan paket Blaze | https://firebase.google.com/docs/storage/faqs-storage-changes-announced-sept-2024 |
| Firestore: data offline | https://firebase.google.com/docs/firestore/manage-data/enable-offline |
| Firestore: lokasi | https://firebase.google.com/docs/firestore/locations |
| App Check untuk Flutter | https://firebase.google.com/docs/app-check/flutter/default-providers |
| Standar pertumbuhan | WHO Child Growth Standards (tabel resmi panjang/tinggi menurut umur) — **[Verifikasi]** saat impor |



