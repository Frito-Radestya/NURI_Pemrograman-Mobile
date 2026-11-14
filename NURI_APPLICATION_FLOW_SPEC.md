# NURI — Spesifikasi Alur Aplikasi, Keamanan & Family–Cadre Linking

## 1. Arsitektur Penyimpanan & Sinkronisasi

NURI menerapkan arsitektur **Offline-First Hybrid**:
- **Lapisan Lokal (`AppRepository`):**
  - Android: `SqliteRepository` (`nuri.db`, schema v2 dengan `onUpgrade` otomatis) menyimpan tabel terpisah: `users`, `pregnancies`, `children`, `food_logs`, `roster`, `sessions`, `contents`, `access_grants`, `link_codes`, dan `meta`.
  - Web: `LocalRepository` berbasis `SharedPreferences`.
- **Lapisan Cloud (`DatabaseService` / `FirestoreService`):**
  - Menyinkronkan perubahan lokal (`syncChanges` & `syncAll`) ke Cloud Firestore.
  - Penarikan data (`pullUserDataset`) **dibatasi berdasarkan ruang lingkup pengguna** (scoped query):
    - **Ibu:** Hanya mengambil `children` dengan `guardianUid == user.id`, `pregnancies` dengan `ownerUid == user.id`, `access_grants` dengan `ownerUid == user.id`, dan `food_logs` milik subjek tersebut.
    - **Kader:** Hanya mengambil `roster` dan `children` pada `posyanduId == user.posyanduId`, `sessions` pada `createdByUid == user.id`, serta `access_grants` pada `posyanduId == user.posyanduId`.
  - Kegagalan sinkronisasi (`syncAll` / `syncChanges`) mengembalikan `bool` (`false` saat gagal), sehingga `syncNow()` mempertahankan `pendingWrites` jika jaringan bermasalah.

---

## 2. Family–Cadre Linking (Penghubung Keluarga & Posyandu)

### Flow A — Ibu Sudah Memiliki Akun NURI (`type: 'keluarga'`)
1. **Ibu Membuat Kode Keluarga (`createFamilyLinkCode`):**
   - Ibu membuka **Profil → Koneksi Keluarga & Posyandu → Buat QR**.
   - Ibu memilih cakupan izin:
     - **Data pertumbuhan (`ukur`)** — Wajib.
     - **Catatan makan (`makan`)** — Opsional (toggle).
   - Sistem menghasilkan token acak kriptografis (`NR-XXXX-XXXX` via `Random.secure()`), berlaku **24 jam**, sekali pakai (`usedAt == null`), dan menyimpannya ke koleksi `link_codes`.
2. **Kader Memindai / Menukar Kode (`redeemFamilyLinkCode`):**
   - Kader membuka **Mulai Ukur / Scan → Masukkan Kode Keluarga**.
   - Sistem memeriksa validitas token (`!isExpired && !isUsed && type == 'keluarga'`).
   - Sistem menandai token sudah digunakan (`usedAt`, `usedByUid`), membuat dokumen `AccessGrant` aktif (`granteeUid`, `subjectId`, `posyanduId`, `scopes`), dan menambahkan anak ke `roster` Posyandu kader.
3. **Pencabutan Izin (`revokeGrant`):**
   - Ibu dapat menekan **Cabut akses** kapan saja di halaman Profil.
   - Status grant diubah menjadi `'dicabut'` beserta `revokedAt`, disinkronkan ke Firestore, dan akses kader terhadap anak/catatan makan langsung dihentikan (`hasActiveGrantForSubject` mengembalikan `false`).

### Flow B — Anak Dicatat Kader Lebih Dulu, Ibu Belum Punya Akun (`type: 'klaim'`)
1. **Kader Membuat Kode Klaim (`createChildClaimCode`):**
   - Kader menambahkan sasaran anak baru di Posyandu (`linked: false`).
   - Pada detail sasaran di tab **Sasaran**, kader menekan **Buat Kode Klaim untuk Ibu (7 hari)**.
   - Sistem menghasilkan token klaim sekali pakai (`KL-XXXX-XXXX`), berlaku **7 hari**.
2. **Ibu Mengklaim Profil Anak (`redeemChildClaimCode`):**
   - Ibu mengunduh NURI, mendaftar akun Ibu, lalu membuka **Profil → Punya kode klaim anak dari Kader Posyandu?**.
   - Ibu memasukkan kode `KL-XXXX-XXXX`.
   - Sistem memverifikasi kode, memindahkan kepemilikan anak (`guardianUid = mother.id`, `linked = true`) beserta seluruh riwayat pengukurannya ke akun Ibu, dan membuat `AccessGrant` ukur aktif untuk Posyandu asal.

---

## 3. Aturan Keamanan Firestore (`firestore.rules`)

| Koleksi | Baca (`read`) | Tulis (`create` / `update` / `delete`) |
|---|---|---|
| `users/{userId}` | Pemilik UID | Hanya pemilik; field `role` dikunci (tidak dapat diubah sepihak setelah dibuat) |
| `children/{childId}` | Ibu pemilik (`guardianUid`) atau kader Posyandu terkait | Ibu pemilik atau kader Posyandu; hapus (`delete`) hanya ibu pemilik |
| `pregnancies/{id}` | Ibu pemilik (`ownerUid`) | Hanya ibu pemilik (`ownerUid`) |
| `food_logs/{id}` | Pemilik atau kader dengan izin `makan` | Pemilik subjek |
| `access_grants/{id}` | Ibu pemilik (`ownerUid`) atau kader penerima (`granteeUid`) | Buat saat penukaran kode; `update`/`delete` (cabut akses) hanya Ibu pemilik (`ownerUid`) |
| `link_codes/{code}` | Pengguna terautentikasi untuk verifikasi kode | Buat oleh `issuerUid` (`usedAt == null`); `update` hanya satu kali (`resource.data.usedAt == null -> request.resource.data.usedAt != null`) |

---

## 4. Matriks Skenario Uji Keamanan & Integrasi

| ID | Skenario | Status Pengujian |
|---|---|---|
| **SEC-01** | Ibu A tidak dapat melihat anak milik Ibu B | Teruji di `test/domain_test.dart` |
| **SEC-03** | Kader dengan grant `ukur` dapat mengakses profil & pengukuran anak | Teruji di `test/domain_test.dart` |
| **SEC-04** | Kader dengan grant `ukur` (tanpa `makan`) ditolak saat membaca `foodLogsFor` | Teruji di `test/domain_test.dart` |
| **SEC-05** | Ibu mencabut grant → akses kader di `myChildren` & `myRoster` langsung hilang & tersinkron ke Firestore | Teruji di `test/domain_test.dart` |
| **SYNC-03** | Sinkronisasi gagal mempertahankan `pendingWrites` dan mengembalikan status gagal | Teruji di `test/domain_test.dart` |
| **FLOW-LINK-A** | Ibu membuat kode `NR-XXXX-XXXX` → Kader menukar kode → Grant aktif → Pakai ulang kode ditolak | Teruji di `test/domain_test.dart` |
| **FLOW-LINK-B** | Kader membuat kode `KL-XXXX-XXXX` → Ibu menukar kode → Kepemilikan anak berpindah ke Ibu | Teruji di `test/domain_test.dart` |
