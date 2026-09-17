**MINI SRS**

Nama Kelompok 	: Free Fire  
Anggota		: \- 241401030 Frito Radestya. S   
			  \- 241401072 Akief Maulana Aulia

1\. Nama Aplikasi NURI (Nutrisi & Resiko Stunting di Indonesia)  
NURI adalah aplikasi mobile berbasis kecerdasan buatan yang membantu keluarga dan kader Posyandu mencegah stunting. Hanya melalui foto, NURI dapat menganalisis kandungan gizi makanan secara instan berdasarkan basis data Kemenkes RI, sekaligus mendeteksi risiko stunting pada balita secara non-invasif lewat estimasi proporsi tubuh berstandar WHO.

2\. Latar Belakang Masalah  
Indonesia menghadapi krisis gizi ganda yang serius. Berdasarkan data Survei Status Gizi Indonesia (SSGI), 21,6% balita Indonesia mengalami stunting kondisi gagal tumbuh akibat kekurangan gizi kronis yang berdampak permanen pada kecerdasan dan kesehatan anak. Pemerintah menargetkan angka ini turun ke 14%, namun upaya deteksi dini masih terkendala oleh keterbatasan alat dilapangan, rendahnya kesadaran gizi, keterlambatan detekesi.

3\. Tujuan Aplikasi

- Membantu ibu balita mengidentifikasi kandungan gizi makanan secara instan melalui kamera smartphone.  
- Membantu kader Posyandu dan ibu mendeteksi risiko stunting anak secara dini melalui analisis foto.  
- Memberikan rekomendasi gizi dan tindak lanjut berbasis hasil AI secara personal.

4\. Target Pengguna 

| Pengguna | Deskripsi | Aksi  |
| :---: | :---: | :---: |
| Ibu Balita  | Perempuan 20–40 tahun, memiliki anak usia 0–5 tahun  | Scan makanan, cek stunting anak, tracking gizi  |
| Ibu Hamil | Perempuan 17–40 tahun, kehamilan trimester 1–3  | Scan makanan, monitoring asupan gizi harian  |
| Kader Posyandu | Relawan terlatih bertugas memantau kesehatan balita desa  | Skrining stunting masal, laporan komunitas |

5\. Ruang Lingkup Aplikasi

- Identifikasi jenis makanan dan kalkulasi nilai gizi dari foto  
- Estimasi risiko stunting balita berdasarkan foto dan data anak  
- Pencatatan asupan makanan harian (food diary)  
- Pemantauan tumbuh kembang anak dengan kurva  
- Chatbot AI seputar gizi dan stunting    
- Diagnosis medis klinis (hanya alat skrining awal)  
- Konsultasi dokter secara langsung (telemedicine) 

6\. Functional Requirements 

| Kode  | Nama  | Deskripsi |
| ----- | ----- | ----- |
| FR-01 | Scan & Identifiksi Makanan | Sistem menganalisis foto makanan menggunakan model ai untuk mendeteksi jenis makanan. Mendukung deteksi multi-objek (beberapa makanan dalam satu piring).  |
| FR-02 | Kalkulasi Nilai Gizi | Sistem menghitung kandungan gizi berdasarkan jenis dan estimasi porsi makanan. |
| FR-03 | Perbandingan AKG harian | Sistem menampilkan persentase pemenuhan Angka Kecukupan Gizi (AKG) harian dalam bentuk indikator traffic light ( lebih / cukup /  kurang) sesuai profil usia dan kondisi pengguna.  |
| FR-04 | Input data dan foto anak | Pengguna mengisi data anak (nama, tanggal lahir, jenis kelamin, berat badan) dan mengambil foto anak tampak penuh sebagai input deteksi stunting.  |
| FR-05 | Deteksi resiko stunting | Sistem menganalisis proporsi tubuh anak dari foto untuk mengestimasi dan mengklasifikasikan risiko.  |
| FR-06 | Rekomendasi lanjutan | Sistem memberikan rekomendasi berbeda berdasarkan hasil deteksi: tips gizi (normal), menu MPASI tinggi protein \+ jadwal Puskesmas (stunted.  |
| FR-07 | Food diary & Tracking harian | Pengguna dapat mencatat semua makanan yang dikonsumsi per sesi (pagi/siang/malam/snack) dan melihat ringkasan total gizi harian dalam bentuk progress ring nutrisi.  |
| FR-08 | ChatBot Gizi | Sistem menyediakan asisten AI yang dapat menjawab pertanyaan bebas seputar gizi, MPASI, stunting, dan resep sehat dalam Bahasa Indonesia, dengan kemampuan mendeteksi kondisi darurat medis untuk memberikan arahan segera.  |

7\. Non-Functional Requirements 

| Kode | Kategori | Deskripsi |
| ----- | ----- | ----- |
| NFR-01 | Performa | Waktu inferensi model AI scan makanan ≤ 2 detik dan deteksi stunting ≤ 3 detik pada perangkat dengan RAM 3 GB. Respons chatbot ≤ 5 detik. Ukuran aplikasi terinstal ≤ 150 MB  |
| NFR-02 | Keamanan & Privasi | Semua komunikasi data menggunakan HTTPS (TLS 1.3). Foto anak tidak disimpan di server (hanya fitur vektor yang diekstrak). Data pribadi pengguna dilindungi sesuai UU Perlindungan Data Pribadi (UU PDP No. 27 Tahun 2022). Password disimpan dengan hash bcrypt.  |
| NFR-03 | Ketersediaan Offline | Fitur scan makanan dan deteksi stunting tetap berfungsi tanpa koneksi internet menggunakan model TFLite yang tersimpan di perangkat (on-device inference). Sinkronisasi data dilakukan saat koneksi tersedia.  |
| NFR-04 | Usabilitas | Antarmuka menggunakan Bahasa Indonesia sederhana (setara tingkat baca SMP). Pengguna baru dapat menyelesaikan scan makanan pertama dalam ≤ 3 menit tanpa tutorial tambahan.  |
| NFR-05 | Akurasi Model  | Model klasifikasi makanan mencapai akurasi Top-1 ≥ 83% pada 80 kelas makanan Indonesia. Model deteksi stunting mencapai sensitivitas ≥ 80% untuk mendeteksi kasus stunting positif.  |

8\. Data Utama yang dikelola

| Data | Sumber | Penyimpanan |
| :---- | :---- | :---- |
| Foto Makanan | Kamera/ galeri | lokal sementara |
| Nilai Gizi Makanan | Database TKPI Kemenkes | lokal |
| Foto anak | Kamera pengguna | tidak disimpan |
| Data antropometri anak | Input pengguna | Cloud |
| Log makanan harian | Input via scan/manual | Cloud |
| Tabel pertumbuhan WHO | WHO Child Growth Standards | lokal |
| Histori chat | Percakapan dengan ai | Cloud |

9\. Permission perangkat yang diperlukan

| Permission | Alasan |
| :---- | :---- |
| CAMERA | Mengambil foto makanan dan foto anak untuk analisis AI  |
| READ\_EXTERNAL\_STORAGE  | Memilih foto dari galeri perangkat  |
| WRITE\_EXTERNAL\_STORAGE  | Menyimpan laporan PDF hasil cek stunting  |
| INTERNET  | Sinkronisasi data cloud, chatbot AI, pembaruan model  |
| ACCESS\_FINE\_LOCATION  | Fitur mode kader: lokasi Posyandu terdekat  |
| POST\_NOTIFICATIONS  | Notifikasi reminder jadwal Posyandu dan makan  |
| RECEIVE\_BOOT\_COMPLETED  | Menjaga scheduled notification setelah HP restart  |

10\. Batasan API Eksternal

| API / Layanan  | Fungsi  | Batasan |
| :---- | :---- | :---- |
| Groq API | Chatbot | Limit: 500 MB storage (Free tier)  |
| Supabase | Autentifikasi dan penyimpanan database | Limit: 500 MB storage (Free tier)  |
| TKPI Kemenkes | Database nutrisi | Open data, digunakan lokal offline  |
| WHO GROWTH Standard | Tabel pertumbuhan anak | Open data, digunakan lokal offline  |
| Tensorflow | Inferensi model si | Kompatibilitas: ARM64, ARMv7  |

