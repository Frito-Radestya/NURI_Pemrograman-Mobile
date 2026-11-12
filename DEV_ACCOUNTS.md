# Kredensial & Data Akun Pengujian (Khusus Developer)

> **DOKUMEN INI RAHASIA UNTUK PENGEMBANG**  
> Jangan cantumkan informasi akun ini di tampilan UI publik aplikasi atau materi rilis pengguna akhir.

---

## 1. Daftar Akun Bawaan (Pre-seeded Accounts)

| Peran | Nama | Email | Password | Konteks Utama |
|---|---|---|---|---|
| **Ibu Hamil & Balita** | Siti Rahma | `ibu@nuri.id` | `nuri123` | Balita Rafi (18 bln, riwayat grafik WHO lengkap) + Kehamilan Trimester 2 (24 minggu, HPL 1 Mar 2027) |
| **Kader Posyandu** | Nur Aisyah | `kader@nuri.id` | `nuri123` | Posyandu Melati II, Kelurahan Sukamaju (52 sasaran, 38 hadir, 7 tindak lanjut) |
| **Ibu Balita (Alt)** | Sinta | `sinta@nuri.id` | `nuri123` | Balita Maya Clarissa (22 bulan) |

---

## 2. Struktur Data Bawaan di Firebase Firestore

Setiap akun di atas memiliki data lengkap yang disinkronkan ke Cloud Firestore proyek `nuri-5cddb`:

### A. Koleksi `users`
- `u_ibu`: Siti Rahma (`ibu@nuri.id`), role: `mother`.
- `u_kader`: Nur Aisyah (`kader@nuri.id`), role: `cadre`, posyandu: `p_melati`.
- `u_maya`: Sinta (`sinta@nuri.id`), role: `mother`, posyandu: `p_melati`.

### B. Koleksi `children`
- `c_rafi`: Rafi Rahmatullah, Laki-laki, lahir 15 September 2024.
  - Memiliki riwayat pengukuran lengkap dari 0 bulan hingga 18 bulan beserta kalkulasi z-score WHO LMS dan status gizi.
- `c_kenzo`: Kenzo Alfarizi, sasaran Posyandu Melati II.
- `c_maya`: Maya Clarissa, anak dari Sinta.

### C. Koleksi `pregnancies`
- `preg_siti_2026`: Kehamilan Siti Rahma.
  - HPHT: 24 Mei 2026, HPL: 1 Maret 2027.
  - Checklist konsumsi TTD (Tablet Tambah Darah) dan riwayat kunjungan ANC (Antenatal Care).

### D. Koleksi `food_logs`
- Catatan makan harian balita dengan rincian gram, kalori (kkal), protein hewani, dan zat gizi mikro dari tabel TKPI Kemenkes (total energi sarapan & makan siang: 685 kkal).

### E. Koleksi `roster` & `sessions`
- 52 sasaran Posyandu Melati II (38 balita dan 14 ibu hamil).
- Sesi penimbangan bulan berjalan dengan 38 sasaran terukur dan status kehadiran.

### F. Koleksi `contents`
- 8 artikel edukasi 1000 HPK, stunting, gizi MPASI, dan kesehatan ibu hamil bersumber Kemenkes RI.

---

## 3. Prosedur Pengujian untuk Developer

1. **Masuk ke Aplikasi:**
   - Pilih tab **Ibu / Keluarga**, masukkan `ibu@nuri.id` dan `nuri123`.
   - Atau pilih tab **Kader Posyandu**, masukkan `kader@nuri.id` dan `nuri123`.
2. **Verifikasi Firebase Authentication:**
   - Buka Firebase Console → **Authentication** → **Users**.
   - Pastikan akun `ibu@nuri.id` dan `kader@nuri.id` telah terdaftar.
3. **Verifikasi Database Firestore:**
   - Buka Firebase Console → **Firestore Database** → **Data**.
   - Koleksi `users`, `children`, `pregnancies`, `food_logs`, `roster`, `sessions`, dan `contents` akan terisi otomatis.
4. **Reset Akun Pengembang:**
   - Di tab **Profil** aplikasi paling bawah, klik tombol **Reset akun**.
   - Konfirmasi pada pop-up untuk mengembalikan semua data akun ke kondisi awal.
