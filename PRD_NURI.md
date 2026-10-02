# PRD — NURI (Nutrisi & Resiko Stunting di Indonesia)

| Item | Isi |
|---|---|
| Versi | 0.1 (draft) |
| Tim | Kelompok Free Fire — Frito Radestya S. (241401030), Akief Maulana Aulia (241401072) |
| Konteks | Tugas kuliah, target akhir: APK Android yang berjalan di perangkat uji |
| Sumber | Mini SRS Kelompok Free Fire + jawaban klarifikasi |
| Konvensi | Item bertanda **[OQ-n]** merujuk ke Bagian 10 (Open Questions). Tidak ada asumsi yang ditulis sebagai fakta. |

**Keputusan yang sudah dikunci**

| # | Keputusan |
|---|---|
| K1 | Primary user MVP: **ibu balita + kader Posyandu**. Ibu hamil ditunda ke v2. |
| K2 | Deteksi stunting: **z-score WHO (TB/U atau PB/U) dari input manual sebagai penentu utama; foto anak sebagai indikator tambahan** yang ditampilkan berdampingan. |
| K3 | Platform **Android saja**. |
| K4 | Stack: Groq API (chatbot) + Supabase (auth & database) + TensorFlow Lite. Batas Groq free tier adalah rate limit (bukan storage 500 MB seperti tertulis di SRS); angka pastinya diverifikasi saat implementasi. |
| K5 | Dataset makanan dan foto anak **belum tersedia**. |
| K6 | Definisi selesai: APK berjalan end-to-end di perangkat uji untuk demo/penilaian dosen. |

---

## 1. Problem Statement

**Siapa yang dirugikan**

| Pihak | Kerugian |
|---|---|
| Balita 0–5 tahun | Stunting (21,6% menurut SSGI; target pemerintah 14%) menyebabkan gagal tumbuh kronis dengan dampak permanen pada perkembangan kognitif dan kesehatan. |
| Ibu balita | Tidak punya cara mudah menilai apakah asupan makanan anak memenuhi kebutuhan gizi dan apakah pertumbuhan anak menyimpang. |
| Kader Posyandu | Skrining dilakukan manual; pencatatan dan pelaporan memakan waktu; keterbatasan alat di lapangan. |

**Kenapa terjadi (menurut SRS)**
1. Keterbatasan alat deteksi di lapangan.
2. Kesadaran gizi rendah.
3. Deteksi terlambat, sehingga intervensi terlambat.

**Pernyataan masalah:** Keluarga dan kader tidak punya alat yang cepat dan murah untuk (a) mengetahui kecukupan gizi makanan harian dan (b) mengetahui posisi pertumbuhan anak terhadap standar WHO sedini mungkin, sehingga tindak lanjut sering terlambat.

---

## 2. Target User dan Persona

| Segmen | Deskripsi | Status |
|---|---|---|
| Ibu balita | Perempuan 20–40 th, anak 0–5 th | MVP |
| Kader Posyandu | Relawan terlatih pemantau kesehatan balita desa | MVP |
| Ibu hamil | Perempuan 17–40 th, trimester 1–3 | v2 |

Persona di bawah adalah **hipotesis tim**, belum berdasar riset pengguna.

### Persona 1 — Sari, ibu balita

| Atribut | Isi |
|---|---|
| Usia / peran | 28 th, ibu rumah tangga, anak perempuan 14 bulan |
| Perangkat | Android RAM 3 GB, kuota data terbatas |
| Perilaku | Memberi MPASI dari resep turun-temurun; ke Posyandu tiap bulan; tidak hafal kebutuhan gizi anak |
| Kebutuhan | Tahu apakah menu hari ini cukup; tahu apakah tinggi anak sesuai umur |
| Frustrasi | Tidak paham istilah gizi; tidak tahu harus berbuat apa jika anak "kurang" |
| Sukses bagi Sari | Scan makanan dan lihat hasilnya dalam hitungan detik; mendapat menu saran yang bisa langsung dimasak |

### Persona 2 — Bu Ratna, kader Posyandu

| Atribut | Isi |
|---|---|
| Usia / peran | 45 th, kader Posyandu sekitar 8 tahun |
| Perangkat | Android milik pribadi, sinyal tidak stabil di lokasi Posyandu |
| Perilaku | Mengukur dan menimbang 30–50 balita per sesi, mencatat di kertas, merekap manual |
| Kebutuhan | Input cepat banyak anak, hasil klasifikasi otomatis, rekap yang bisa dilaporkan |
| Frustrasi | Menghitung status gizi manual; rekap lama; salah catat |
| Sukses bagi Bu Ratna | Satu sesi Posyandu selesai tercatat dan terklasifikasi tanpa hitung manual |

*Angka pada persona (jumlah balita per sesi, dll.) adalah asumsi ilustratif dan perlu divalidasi [OQ-12].*

---

## 3. Goals dan Non-Goals

### Goals (MVP)

| ID | Goal |
|---|---|
| G1 | Ibu dapat mengetahui perkiraan kandungan gizi makanan dari foto dan membandingkannya dengan AKG harian. |
| G2 | Ibu/kader dapat menghitung status pertumbuhan anak (z-score TB/U atau PB/U menurut WHO) dari data ukur manual. |
| G3 | Foto anak memberi indikator tambahan yang ditampilkan berdampingan dengan z-score, dengan label jelas bahwa itu eksperimental. |
| G4 | Pengguna mendapat rekomendasi tindak lanjut sesuai hasil. |
| G5 | Kader dapat menskrining banyak anak dan melihat rekap. |
| G6 | APK stabil dan berjalan end-to-end di perangkat uji. |

### Non-Goals

| ID | Non-goal |
|---|---|
| NG1 | Diagnosis medis klinis. Aplikasi hanya alat skrining awal. |
| NG2 | Telemedicine / konsultasi dokter langsung. |
| NG3 | Fitur khusus ibu hamil (AKG hamil, monitoring kehamilan) di MVP. |
| NG4 | Platform iOS. |
| NG5 | Rilis Play Store dan validasi klinis penuh. |
| NG6 | Foto anak sebagai penentu tunggal status stunting. |

---

## 4. User Stories

| ID | Persona | User story |
|---|---|---|
| US-01 | Ibu balita | Sebagai ibu balita, saya ingin mendaftar dan masuk ke aplikasi, supaya data anak dan riwayat makan saya tersimpan. |
| US-02 | Ibu balita | Sebagai ibu balita, saya ingin memotret makanan, supaya saya tahu jenis makanan dan kandungan gizinya tanpa mencari manual. |
| US-03 | Ibu balita | Sebagai ibu balita, saya ingin mengoreksi hasil deteksi makanan, supaya catatan gizi tetap benar bila AI salah. |
| US-04 | Ibu balita | Sebagai ibu balita, saya ingin melihat pemenuhan AKG anak hari ini dengan warna lebih/cukup/kurang, supaya saya tahu apa yang harus ditambah. |
| US-05 | Ibu balita | Sebagai ibu balita, saya ingin mencatat makanan per sesi (pagi/siang/malam/snack), supaya saya bisa melihat total gizi harian. |
| US-06 | Ibu balita | Sebagai ibu balita, saya ingin memasukkan data anak (tanggal lahir, jenis kelamin, berat, tinggi/panjang), supaya saya tahu status pertumbuhannya. |
| US-07 | Ibu balita | Sebagai ibu balita, saya ingin memotret anak dari ujung kepala sampai kaki, supaya saya mendapat indikator tambahan selain angka ukur. |
| US-08 | Ibu balita | Sebagai ibu balita, saya ingin rekomendasi yang jelas setelah hasil keluar, supaya saya tahu langkah berikutnya (menu, kunjungan Puskesmas). |
| US-09 | Ibu balita | Sebagai ibu balita, saya ingin melihat kurva pertumbuhan anak dari waktu ke waktu, supaya saya bisa melihat tren. |
| US-10 | Kader | Sebagai kader, saya ingin mendaftarkan dan menskrining banyak anak dalam satu sesi, supaya pekerjaan Posyandu lebih cepat. |
| US-11 | Kader | Sebagai kader, saya ingin klasifikasi status otomatis dari data ukur, supaya saya tidak menghitung manual. |
| US-12 | Kader | Sebagai kader, saya ingin rekap hasil skrining per sesi, supaya saya bisa melapor ke puskesmas/desa. |
| US-13 | Semua | Sebagai pengguna, saya ingin melihat pernyataan bahwa hasil hanya skrining awal, supaya saya tidak salah mengartikan sebagai diagnosis. |
| US-14 | Semua | Sebagai pengguna, saya ingin foto anak tidak disimpan, supaya privasi anak terjaga. |

---

## 5. Daftar Fitur

Kolom **Status** adalah hasil kroscek implementasi saat ini (kode HEAD bersih):
**Sudah** = berfungsi, **Parsial** = ada sebagian, **Belum** = belum ada kode.

| Fitur | MVP | v2 | Nanti | Status |
|---|---|---|---|---|
| Registrasi/login + peran (ibu / kader) | ✔ | | | Parsial — UI peran + login demo in-memory ada (`lib/services/auth_service.dart`, `lib/screens/login_screen.dart`); Supabase Auth + bcrypt belum ada |
| Scan makanan + deteksi multi-objek | ✔ | | | Belum — tanpa kamera/galeri, tanpa model TFLite, tanpa layar scan |
| Koreksi manual hasil deteksi + input makanan manual | ✔ | | | Parsial — input manual + search 25 item ada (`lib/data/food_database.dart`); koreksi hasil AI belum ada karena scan belum ada |
| Kalkulasi nilai gizi (TKPI) | ✔ | | | Parsial — hitung `gram/100` untuk 4 nutrien ada; baru 25 item, bukan 80 kelas |
| Perbandingan AKG harian (traffic light) | ✔ | | | Parsial — logika traffic light + label teks ada (`lib/models/food_entry.dart`); AKG masih hardcode dewasa, bukan AKG anak otomatis |
| Food diary + progress ring nutrisi | ✔ | | | Parsial — CRUD 4 sesi + ring harian ada (`lib/services/food_diary_service.dart`); penyimpanan masih in-memory, bukan cloud |
| Data anak + pengukuran (BB, TB/PB) | ✔ | | | Parsial — CRUD data anak ada (`lib/services/child_service.dart`); tanpa aturan PB/TB, koreksi ±0,7 cm, validasi 0–59 bulan, dan riwayat pengukuran |
| Skrining stunting z-score WHO | ✔ | | | Belum — tanpa tabel WHO LMS, tanpa hitung z-score, status masih dropdown manual |
| Indikator tambahan dari foto anak | ✔ | | | Belum — tanpa input foto, tanpa model, tanpa label eksperimental |
| Rekomendasi lanjutan | ✔ | | | Belum — tanpa rekomendasi otomatis per status; yang ada hanya artikel statis |
| Kurva pertumbuhan anak | ✔ | | | Belum — tanpa grafik; toggle kurva di profil tidak terhubung ke tampilan |
| Mode kader: skrining banyak anak + rekap sesi | ✔ | | | Parsial — role kader + 20 data seed ada; tanpa sesi skrining dan tanpa rekap |
| Disclaimer skrining + consent data | ✔ | | | Parsial — checkbox syarat di register ada; layar disclaimer wajib + consent orang tua belum ada |
| Mode ibu hamil (AKG hamil, monitoring) | | ✔ | | Parsial di luar MVP — role ibu hamil sudah ada di kode padahal PRD v2 (NG3); konten AKG hamil belum ada |
| Ekspor laporan PDF | Belum diputuskan [OQ-1] | | | Belum |
| Chatbot gizi (Groq) | Belum diputuskan [OQ-1] | | | Belum |
| Reminder notifikasi (Posyandu, makan) | Belum diputuskan [OQ-1] | | | Belum — hanya toggle in-memory di profil |
| Lokasi Posyandu terdekat | Belum diputuskan [OQ-1] | | | Belum — hanya field nama Posyandu teks |
| Mode offline penuh + sinkronisasi | Belum diputuskan [OQ-2] | | | Belum — semua data in-memory, tanpa persistensi/sync |
| Pembaruan model over-the-air | | | ✔ | Belum |
| iOS | | | ✔ | Belum (Android saja, K3) |
| Integrasi sistem pelaporan resmi (mis. e-PPGBM) | | | ✔ | Belum |
| Validasi klinis dan rilis publik | | | ✔ | Belum |

---

## 6. Functional Requirements — Fitur MVP

Prioritas: **M** = wajib, MVP.

### F-01 Autentikasi, Peran, Disclaimer dan Consent (baru; mendukung NFR-02)

| ID | Requirement | Prio |
|---|---|---|
| F-01.1 | Registrasi dan login via Supabase Auth. Metode login (email / nomor HP) — lihat [OQ-3]. | M |
| F-01.2 | Password disimpan dengan hash (bcrypt) sesuai SRS NFR-02. | M |
| F-01.3 | Saat registrasi pengguna memilih peran: Ibu atau Kader. Satu akun satu peran (perubahan peran — [OQ-3]). | M |
| F-01.4 | Layar disclaimer wajib disetujui sebelum fitur skrining: "Hasil adalah skrining awal, bukan diagnosis." Disclaimer juga tampil di setiap layar hasil skrining. | M |
| F-01.5 | Persetujuan pengolahan data pribadi ditampilkan saat registrasi. Untuk kader yang memasukkan data anak orang lain: mekanisme persetujuan orang tua — [OQ-9]. | M |
| F-01.6 | Semua komunikasi jaringan memakai HTTPS (TLS 1.3 sesuai SRS). | M |

### F-02 Scan dan Identifikasi Makanan (SRS FR-01)

| ID | Requirement | Prio |
|---|---|---|
| F-02.1 | Input foto dari kamera atau galeri. | M |
| F-02.2 | Model klasifikasi mendeteksi jenis makanan; mendukung multi-objek (beberapa makanan dalam satu piring). | M |
| F-02.3 | Hasil menampilkan daftar makanan terdeteksi dengan skor kepercayaan. Bila kepercayaan di bawah ambang, sistem meminta pengguna memilih manual dari kandidat teratas. Nilai ambang — [OQ-6]. | M |
| F-02.4 | Pengguna dapat mengubah, menghapus, atau menambah item hasil deteksi sebelum menyimpan. | M |
| F-02.5 | Pencarian dan input makanan manual dari daftar TKPI tersedia sebagai jalur alternatif. | M |
| F-02.6 | Cakupan kelas makanan: 80 kelas makanan Indonesia (SRS). Karena dataset belum ada, daftar 80 kelas dan sumber data — [OQ-5]. | M |
| F-02.7 | Inferensi ≤ 2 detik pada perangkat RAM 3 GB (target SRS NFR-01). | M |
| F-02.8 | Foto makanan disimpan lokal sementara; penghapusan otomatis setelah disimpan ke diary — aturan retensi [OQ-8]. | M |

### F-03 Kalkulasi Nilai Gizi dan Perbandingan AKG (SRS FR-02, FR-03)

| ID | Requirement | Prio |
|---|---|---|
| F-03.1 | Nilai gizi per item dihitung dari database TKPI Kemenkes (lokal) dikali porsi. | M |
| F-03.2 | Metode estimasi porsi: **belum ditetapkan** [OQ-4]. | M |
| F-03.3 | Nutrien minimum yang ditampilkan: [OQ-7] (SRS hanya menyebut "kandungan gizi"). | M |
| F-03.4 | AKG dipilih otomatis berdasar usia dan jenis kelamin anak. Sumber dan versi tabel AKG — [OQ-7]. | M |
| F-03.5 | Persentase pemenuhan AKG ditampilkan dengan indikator traffic light: lebih / cukup / kurang. Ambang persen per warna — [OQ-7]. | M |
| F-03.6 | Warna tidak menjadi satu-satunya penanda; sertakan teks label (aksesibilitas, NFR-04). | M |

### F-04 Data Anak dan Pengukuran (SRS FR-04)

| ID | Requirement | Prio |
|---|---|---|
| F-04.1 | Profil anak: nama, tanggal lahir, jenis kelamin. Ibu dapat memiliki lebih dari satu anak (batas jumlah — [OQ-3]). | M |
| F-04.2 | Pengukuran: tanggal ukur, berat badan (kg), panjang/tinggi badan (cm). | M |
| F-04.3 | Aturan pengukuran WHO: anak < 24 bulan diukur **berbaring (PB)**, ≥ 24 bulan **berdiri (TB)**. Aplikasi menampilkan jenis ukuran sesuai umur dan menerapkan koreksi WHO bila metode ukur tidak sesuai umur (PB→TB: −0,7 cm; TB→PB: +0,7 cm). | M |
| F-04.4 | Rentang usia valid: 0–59 bulan. Di luar rentang, sistem menolak skrining dengan pesan jelas. | M |
| F-04.5 | Validasi rentang nilai (nilai mustahil ditolak, nilai ekstrem meminta konfirmasi). Batas nilai — [OQ-6]. | M |
| F-04.6 | Setiap pengukuran disimpan sebagai riwayat (bukan menimpa) untuk kurva pertumbuhan. | M |
| F-04.7 | Data antropometri disimpan di cloud (Supabase); foto tidak (lihat F-05.6). | M |

### F-05 Skrining Stunting (SRS FR-05; keputusan K2)

| ID | Requirement | Prio |
|---|---|---|
| F-05.1 | Sistem menghitung z-score **TB/U (≥ 24 bln) atau PB/U (< 24 bln)** dengan metode LMS dari tabel WHO Child Growth Standards (lokal/offline). | M |
| F-05.2 | Klasifikasi status berdasar z-score: < −3 SD sangat pendek (severely stunted); −3 s.d. < −2 SD pendek (stunted); −2 s.d. +3 SD normal; > +3 SD tinggi. | M |
| F-05.3 | Klasifikasi z-score adalah **penentu utama** dan tidak diubah oleh hasil foto. | M |
| F-05.4 | Foto anak (tampak penuh badan) diproses model on-device untuk menghasilkan **indikator tambahan**. Format keluaran (kelas / skor) — [OQ-10]. | M |
| F-05.5 | Indikator foto ditampilkan di kartu terpisah, berlabel "Indikator tambahan (eksperimental)". Aturan bila hasil z-score dan foto bertentangan — [OQ-10]. | M |
| F-05.6 | Foto anak tidak disimpan di server. Apakah vektor fitur disimpan di mana pun — [OQ-8]. | M |
| F-05.7 | Pemeriksaan kualitas foto sebelum inferensi: satu orang, seluruh badan terlihat, tidak buram, pencahayaan memadai. Gagal → pengguna diminta memotret ulang, dengan petunjuk. | M |
| F-05.8 | Inferensi foto ≤ 3 detik pada perangkat RAM 3 GB (SRS NFR-01). Perhitungan z-score dianggap instan. | M |
| F-05.9 | Layar hasil menampilkan: status z-score, nilai z-score, umur saat ukur, indikator foto, disclaimer. | M |
| F-05.10 | Target sensitivitas model foto ≥ 80% (SRS NFR-05) — tidak dapat diverifikasi sampai ada dataset berlabel [OQ-5]. | M |

### F-06 Rekomendasi Lanjutan (SRS FR-06)

| ID | Requirement | Prio |
|---|---|---|
| F-06.1 | Status normal: tips gizi sesuai usia. | M |
| F-06.2 | Status pendek: menu MPASI tinggi protein + saran jadwal ke Puskesmas. | M |
| F-06.3 | Status sangat pendek: konten rekomendasi belum didefinisikan di SRS [OQ-11]. | M |
| F-06.4 | Anak ≥ 24 bulan (di luar konteks MPASI): konten rekomendasi belum didefinisikan [OQ-11]. | M |
| F-06.5 | Konten rekomendasi bersifat statis (bank konten lokal); sumber dan reviewer konten — [OQ-11]. | M |
| F-06.6 | "Jadwal Puskesmas": sumber data jadwal belum ditetapkan [OQ-11]. | M |

### F-07 Food Diary dan Tracking Harian (SRS FR-07)

| ID | Requirement | Prio |
|---|---|---|
| F-07.1 | Pengguna mencatat makanan per sesi: pagi / siang / malam / snack. | M |
| F-07.2 | Sumber entri: hasil scan (F-02) atau input manual. | M |
| F-07.3 | Ringkasan harian: total gizi ditampilkan sebagai progress ring per nutrien terhadap AKG. | M |
| F-07.4 | Pengguna dapat mengedit dan menghapus entri. | M |
| F-07.5 | Log disimpan ke cloud; pengguna dapat memilih tanggal untuk melihat riwayat. | M |
| F-07.6 | Diary terkait ke satu anak terpilih; bila punya lebih dari satu anak, pengguna memilih anak aktif. Diary untuk ibu sendiri — tidak termasuk MVP (ibu hamil v2). | M |

### F-08 Mode Kader: Skrining Banyak Anak dan Rekap (peran kader)

SRS hanya menyebut "skrining massal, laporan komunitas". Detail berikut adalah **turunan minimum** dari K1; format laporan tetap [OQ-13].

| ID | Requirement | Prio |
|---|---|---|
| F-08.1 | Kader dapat membuat **sesi skrining** (nama/tanggal Posyandu). | M |
| F-08.2 | Dalam sesi, kader menambah anak dan pengukurannya (alur F-04, F-05) secara berurutan dan cepat. | M |
| F-08.3 | Rekap sesi: jumlah anak, jumlah per kategori status (sangat pendek / pendek / normal / tinggi), daftar anak yang perlu tindak lanjut. | M |
| F-08.4 | Anak yang sudah pernah diskrining dapat dipilih ulang dari daftar (tanpa input ulang identitas). | M |
| F-08.5 | Format, tujuan, dan penerima laporan komunitas — [OQ-13]. | M |
| F-08.6 | Fitur lokasi Posyandu terdekat: menunggu keputusan [OQ-1]. | — |

### F-09 Kurva Pertumbuhan (SRS ruang lingkup: pemantauan tumbuh kembang dengan kurva)

| ID | Requirement | Prio |
|---|---|---|
| F-09.1 | Kurva TB/U (PB/U) anak dengan garis referensi WHO (−3, −2, median, +2, +3 SD) dan titik pengukuran anak. | M |
| F-09.2 | Kurva diperbarui setiap ada pengukuran baru. | M |
| F-09.3 | Kurva BB/U dan status gizi lain (BB/TB) — [OQ-7]. | — |

### Kebutuhan non-fungsional (referensi SRS, dikonfirmasi sebagai target)

| Kode | Target | Catatan |
|---|---|---|
| NFR-01 | Scan ≤ 2 dtk, foto anak ≤ 3 dtk, chatbot ≤ 5 dtk (bila chatbot masuk), APK ≤ 150 MB | Uji pada perangkat RAM 3 GB [OQ-14] |
| NFR-02 | TLS 1.3, bcrypt, UU PDP No. 27/2022, foto anak tidak disimpan | Lihat [OQ-8], [OQ-9] |
| NFR-03 | Offline dengan TFLite | Ruang lingkup offline [OQ-2] |
| NFR-04 | Bahasa Indonesia sederhana (setara SMP); scan pertama ≤ 3 menit tanpa tutorial | Uji dengan pengguna awam |
| NFR-05 | Top-1 ≥ 83% (80 kelas); sensitivitas foto ≥ 80% | Tidak dapat diverifikasi tanpa dataset [OQ-5] |

---

## 7. Sketsa Data Model

| Entitas | Field kunci | Penyimpanan | Catatan |
|---|---|---|---|
| **User** | id, email/phone, password_hash, role (ibu/kader), nama, consent_at, created_at | Cloud | Auth via Supabase |
| **Child** | id, owner_user_id, nama, tgl_lahir, jenis_kelamin, created_at | Cloud | Kader dapat memiliki anak dari banyak keluarga [OQ-9] |
| **Measurement** | id, child_id, tgl_ukur, umur_bulan, bb_kg, tb_pb_cm, metode_ukur (berbaring/berdiri), tb_terkoreksi_cm | Cloud | Riwayat, tidak ditimpa |
| **ScreeningResult** | id, measurement_id, zscore_tbu, kategori (sangat pendek/pendek/normal/tinggi), foto_indikator_hasil, foto_indikator_skor, versi_model, created_at | Cloud | Foto tidak disimpan |
| **FoodItem** (TKPI) | tkpi_id, nama, energi, protein, lemak, karbohidrat, serat, mineral/vitamin [OQ-7] | Lokal | Read-only |
| **AKGReference** | kelompok_umur, jenis_kelamin, nutrien, nilai | Lokal | Versi tabel [OQ-7] |
| **WHOGrowthRef** | indikator, jenis_kelamin, umur_bulan, L, M, S | Lokal | Untuk z-score LMS |
| **FoodLog** | id, child_id, tanggal, sesi (pagi/siang/malam/snack) | Cloud | |
| **FoodLogItem** | id, food_log_id, tkpi_id, porsi, sumber (scan/manual), skor_kepercayaan, nilai_gizi_terhitung | Cloud | |
| **Recommendation** | id, kategori_status, rentang_umur, konten | Lokal | Bank konten statis [OQ-11] |
| **ScreeningSession** (kader) | id, kader_user_id, nama_posyandu, tanggal | Cloud | |
| **SessionEntry** | id, session_id, measurement_id | Cloud | Menghubungkan sesi dengan pengukuran |
| **ChatMessage** | id, user_id, role, isi, created_at | Cloud | Hanya bila chatbot masuk [OQ-1] |

Relasi utama: User 1—N Child; Child 1—N Measurement; Measurement 1—1 ScreeningResult; Child 1—N FoodLog; FoodLog 1—N FoodLogItem; ScreeningSession 1—N SessionEntry.

---

## 8. Edge Case dan Failure State

| # | Skenario | Perilaku yang diharapkan |
|---|---|---|
| E-01 | Foto makanan buram / gelap / tanpa makanan | Pesan "makanan tidak terdeteksi", tawarkan foto ulang atau input manual. |
| E-02 | Makanan di luar 80 kelas | Tampilkan "tidak dikenali", arahkan ke pencarian manual TKPI. Jangan menampilkan tebakan berkepercayaan rendah sebagai hasil pasti. |
| E-03 | Multi-objek dengan sebagian item salah | Pengguna dapat koreksi per item (F-02.4). |
| E-04 | Makanan tidak ada di TKPI | Sistem menyatakan data gizi tidak tersedia; item tidak dihitung diam-diam sebagai nol. |
| E-05 | Foto anak: bukan seluruh badan, lebih dari satu orang, buram, anak memakai pakaian tebal | Tolak inferensi, beri petunjuk pemotretan (F-05.7). Dampak pakaian terhadap akurasi — [OQ-10]. |
| E-06 | Hasil z-score dan indikator foto bertentangan | Tampilkan keduanya; z-score menjadi penentu utama; aturan pesan peringatan — [OQ-10]. |
| E-07 | Tinggi/berat tidak masuk akal (mis. salah ketik) | Validasi dan konfirmasi ulang (F-04.5). |
| E-08 | Anak di bawah 0 atau di atas 59 bulan, atau tanggal lahir di masa depan | Skrining ditolak dengan pesan rentang usia. |
| E-09 | Anak prematur | Koreksi umur tidak tercakup SRS — [OQ-6]. |
| E-10 | Pengukuran hari yang sama diinput dua kali | Peringatan duplikat; pengguna memilih menimpa atau menyimpan sebagai entri baru. |
| E-11 | Tidak ada koneksi | Fitur yang tergantung internet (login awal, sinkronisasi, chatbot bila ada) menampilkan status offline yang jelas. Fitur lokal tetap berjalan sesuai keputusan [OQ-2]. |
| E-12 | Konflik sinkronisasi (dua perangkat, satu akun) | Aturan resolusi belum ditentukan [OQ-2]. |
| E-13 | Izin kamera/galeri ditolak | Layar penjelasan + tombol menuju pengaturan; input manual tetap tersedia untuk makanan. |
| E-14 | Model TFLite gagal dimuat / RAM kurang | Tampilkan error terkontrol, jangan crash; fitur manual tetap bisa. |
| E-15 | Waktu inferensi melebihi target | Tampilkan indikator proses; tidak membatalkan otomatis. Batas timeout — [OQ-14]. |
| E-16 | Limit Groq API tercapai (bila chatbot masuk) | Pesan "layanan sedang penuh, coba lagi"; tidak mengulang otomatis tanpa batas. |
| E-17 | Chatbot mendeteksi kondisi darurat medis (bila chatbot masuk) | Arahkan segera ke fasilitas kesehatan/layanan darurat; daftar kondisi darurat — [OQ-1]. |
| E-18 | Kader menskrining anak tanpa persetujuan orang tua | Alur consent belum ditetapkan [OQ-9]. |
| E-19 | Batas storage Supabase free tier (500 MB) tercapai | Penulisan gagal dengan pesan jelas; data lokal tidak hilang. |
| E-20 | Pengguna menghapus akun | Alur penghapusan data (hak subjek data UU PDP) — [OQ-9]. |

---

## 9. Success Metrics

Konteks: tugas kuliah, tanpa pengguna produksi. Metrik diukur pada perangkat uji dan uji terbatas.

| Kategori | Metrik | Target | Cara ukur |
|---|---|---|---|
| Kelengkapan | Alur end-to-end MVP berjalan tanpa crash (registrasi → scan → diary → input anak → skrining → rekomendasi → rekap kader) | 100% skenario uji lulus | Checklist skenario uji |
| Kebenaran z-score | Selisih z-score aplikasi vs kalkulator WHO resmi | Toleransi disepakati [OQ-14], pada minimal 30 kasus uji lintas umur dan jenis kelamin | Uji perbandingan |
| Klasifikasi status | Kategori aplikasi = kategori referensi WHO | 100% pada kasus uji | Uji perbandingan |
| Model makanan | Top-1 accuracy | ≥ 83% pada 80 kelas (target SRS), pada set uji terpisah | Evaluasi model — bergantung pada dataset [OQ-5] |
| Model foto anak | Sensitivitas | ≥ 80% (target SRS) — dilaporkan apa adanya bersama ukuran set uji | Evaluasi model — bergantung pada dataset [OQ-5] |
| Performa | Latensi scan makanan | ≤ 2 dtk | Uji di perangkat RAM 3 GB |
| Performa | Latensi foto anak | ≤ 3 dtk | Idem |
| Ukuran | Ukuran APK terpasang | ≤ 150 MB | Ukur di perangkat |
| Usabilitas | Pengguna baru menyelesaikan scan pertama | ≤ 3 menit tanpa tutorial | Uji minimal 5 pengguna awam [OQ-12] |
| Kepatuhan | Foto anak tidak ditemukan di penyimpanan server | 0 file | Audit storage Supabase |
| Keamanan | Semua request HTTPS; tidak ada password plaintext | Lulus | Audit |
| Deliverable | APK dapat dipasang dan berjalan di perangkat uji | Ya | Uji instalasi |

---

## 10. Open Questions

| # | Pertanyaan | Dampak | Bagian terkait |
|---|---|---|---|
| OQ-1 | Fitur belum diputuskan: chatbot (Groq), laporan PDF, reminder notifikasi, lokasi Posyandu terdekat. Masuk MVP, v2, atau dibuang? Izin di SRS (WRITE_EXTERNAL_STORAGE, ACCESS_FINE_LOCATION, POST_NOTIFICATIONS, RECEIVE_BOOT_COMPLETED) bergantung pada jawaban ini. Bila chatbot masuk: daftar kondisi darurat medis yang harus dideteksi. | Scope, izin, E-16/E-17 | 5, 6 |
| OQ-2 | Offline: fitur mana yang wajib offline di MVP (scan makanan, z-score, diary, foto anak)? Model sinkronisasi dan resolusi konflik? | Arsitektur, E-11/E-12 | 6, 8 |
| OQ-3 | Login pakai email atau nomor HP? Apakah satu akun bisa berganti peran? Batas jumlah anak per akun? | F-01, F-04 | 6 |
| OQ-4 | Bagaimana porsi makanan diestimasi: dari foto (butuh model/rujukan ukuran), atau pilihan manual (mis. porsi kecil/sedang/besar, gram)? | Akurasi gizi, F-03 | 6 |
| OQ-5 | Dataset: dari mana 80 kelas makanan (daftar kelasnya apa) dan dataset foto anak berlabel? Siapa yang memberi label? Tanpa itu, target NFR-05 tidak dapat dipenuhi/diuji. Apakah target boleh diturunkan atau jumlah kelas dikurangi? | Risiko utama proyek | 6, 9 |
| OQ-6 | Nilai ambang: kepercayaan minimum deteksi makanan; batas nilai ekstrem tinggi/berat; koreksi umur prematur (dipakai atau tidak). | F-02, F-04 | 6, 8 |
| OQ-7 | Nutrien apa saja yang ditampilkan? Sumber dan versi tabel AKG? Ambang persentase traffic light (kurang/cukup/lebih)? Apakah kurva BB/U dan status BB/TB masuk MVP? | F-03, F-09 | 6 |
| OQ-8 | Foto anak "tidak disimpan": apakah vektor fitur disimpan (lokal/cloud) atau dibuang setelah inferensi? Retensi foto makanan lokal? | Privasi, NFR-02 | 6, 7 |
| OQ-9 | Kepatuhan UU PDP untuk data anak: bentuk persetujuan orang tua bila kader yang menginput; alur penghapusan data; pihak yang bertanggung jawab atas data. | Legal, F-01, F-08 | 6, 8 |
| OQ-10 | Indikator foto: keluaran berupa apa (kelas, skor)? Bagaimana ditampilkan bila bertentangan dengan z-score? Adakah aturan penggabungan atau hanya ditampilkan berdampingan? Bagaimana menangani variasi pakaian, pose, dan usia? | Inti fitur foto | 6, 8 |
| OQ-11 | Konten rekomendasi: siapa penyusun dan penelaah (ahli gizi/bidan)? Konten untuk status sangat pendek dan anak ≥ 24 bulan? Sumber "jadwal Puskesmas" (input manual, data statis, atau integrasi)? | Keamanan pengguna | 6 |
| OQ-12 | Validasi pengguna: apakah ada akses ke ibu balita dan kader nyata untuk uji? Persona dan angka pada Bagian 2 masih asumsi. | Metrik usabilitas | 2, 9 |
| OQ-13 | Mode kader: format, isi, dan penerima "laporan komunitas"? Apakah perlu ekspor (PDF/CSV) atau cukup tampilan di aplikasi? | F-08 | 6 |
| OQ-14 | Toleransi selisih z-score terhadap kalkulator WHO; timeout inferensi; perangkat uji spesifik (model HP) yang dipakai untuk mengukur NFR-01. | Metrik | 6, 9 |
| OQ-15 | Validitas ilmiah foto sebagai indikator stunting: adakah referensi/paper yang menjadi dasar metode "estimasi proporsi tubuh"? Untuk laporan kuliah, dasar ini perlu dikutip. | Kredibilitas | 6 |
| OQ-16 | Framework pengembangan aplikasi (SRS hanya menyebut Android/TFLite): apakah tim memakai Flutter untuk seluruh aplikasi? Versi Android minimum yang didukung? | Estimasi teknis | 6 |
