# StuntingCare (NURI)

Aplikasi mobile Flutter untuk pencegahan stunting — **Kelompok Free Fire**.

Berdasarkan Mini SRS: **NURI** (Nutrisi & Resiko Stunting di Indonesia).  
UI mengikuti desain mockup **StuntingCare** yang disediakan.

## Fitur UI (saat ini)

1. Splash / branding screen  
2. Login (Welcome back)  
3. Home — info stunting, kategori, berita  
4. Menu MPASI  
5. Daftar Resep MPASI  
6. Detail resep (bahan + langkah)

## Cara menjalankan

Pastikan Flutter SDK terpasang, lalu:

```bash
flutter pub get
flutter run
```

Jika `flutter` belum ada di PATH (Windows), gunakan:

```bash
C:\flutter\bin\flutter.bat pub get
C:\flutter\bin\flutter.bat run
```

## Alur navigasi

Splash → Login → Home → (tap **MPASI**) → Menu MPASI → (tap **Resep MPASI**) → List Resep → Detail Resep

## Catatan

Gambar makanan/profil memakai URL Unsplash (butuh internet saat pertama load).  
Fitur AI scan makanan, deteksi stunting, chatbot (FR-01–FR-08) belum diintegrasikan — UI siap dikembangkan sesuai SRS.
