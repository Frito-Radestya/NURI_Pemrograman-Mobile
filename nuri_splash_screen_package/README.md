# NURI — Paket Kloning 1:1 & Animasi Splash Screen Per-Komponen

Paket ini berisi hasil kloning presisi tinggi (1:1) dari logo & splash screen **NURI (Nutrisi & Risiko Stunting di Indonesia — Tumbuh Sehat, Keluarga Kuat.)** yang telah dipisahkan ke dalam **8 komponen anatomis independen** siap animasi.

## Struktur Folder

- `web_standalone/`
  - `index.html` & `css/nuri_splash.css` — Halaman splash screen web mandiri (4 preset koreografi animasi).
  - `nuri_splash_studio.html` — Aplikasi studio interaktif lengkap (Timeline Scrubber, Solo Component Inspector, Komparasi 1:1 Asli vs Clone, dan Generator Kode).
- `assets/svg_layers/` — File vektor SVG per komponen (viewBox `0 0 1024 1024` yang presisi saat ditumpuk):
  - `comp_01_base.svg` — Lingkaran Dasar & Lengkung Pelindung (`#1F5F2E`)
  - `comp_02_mother.svg` — Siluet Ibu, Wajah & Bahu (`#191D19`, `#1F5F2E`, `#F4F8F2`)
  - `comp_03_crown_leaves.svg` — Daun Mahkota Rambut (`#4C9D55`)
  - `comp_04_sprout_leaves.svg` — Tunas Pertumbuhan Luar (`#1F5F2E`, `#4C9D55`, `#191D19`)
  - `comp_05_baby_cradle.svg` — Siluet Bayi Ceria & Lengan Pelukan Ibu
  - `comp_06_medical_plus.svg` — Lencana Medis Plus `+`
  - `comp_07_wordmark.svg` & `comp_07_letter_[N,U,R,I].svg` — Huruf `N`, `U`, `R`, `I` terpisah untuk *staggered animation*
  - `comp_08_tagline.svg`, `comp_08_subtitle.svg`, `comp_08_motto.svg` — Sub-judul & Tagline
  - `nuri_logo_full_layered.svg` — File SVG gabungan lengkap dengan grup `<g id="comp-...">`
- `assets/png_layers/` — Layer PNG transparan (`1024x1024` RGBA) per komponen (dapat langsung dipakai di Flutter dengan `Image.asset` tanpa perlu paket tambahan).
- `flutter/lib/features/splash/`
  - `nuri_splash_screen_svg.dart` — Widget Flutter menggunakan `flutter_svg`.
  - `nuri_splash_screen_png.dart` — Widget Flutter menggunakan `Image.asset` bawaan (tanpa dependensi eksternal).

## Cara Pakai di Proyek Flutter NURI

1. Salin folder `assets/svg_layers/` atau `assets/png_layers/` ke dalam folder `assets/` proyek Flutter Anda.
2. Daftarkan di `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/svg_layers/
       - assets/png_layers/
   ```
3. Salin `flutter/lib/features/splash/nuri_splash_screen_png.dart` (atau versi SVG) ke `lib/features/splash/` dan panggil pada halaman awal aplikasi:
   ```dart
   NuriSplashScreenPng(
     onFinished: () {
       // Navigasi ke AppShell / MotherHome
     },
   )
   ```
