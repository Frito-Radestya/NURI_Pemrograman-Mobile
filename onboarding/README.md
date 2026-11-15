# NURI — Paket Lengkap Splash Screen Per-Komponen & Alur Onboarding (Slide 1–4)

Paket ini berisi aset vektor SVG, layer PNG transparan, aplikasi web interaktif, serta kode implementasi **Flutter (Dart)** untuk alur pengguna baru **NURI (Nutrisi & Risiko Stunting di Indonesia)**:

1. **00 — Splash Screen NURI**: Kloning 1:1 dengan 8 komponen terpisah yang beranimasi secara bertahap.
2. **01 — Kenali NURI (Slide 1)**: *"Setiap Anak Berhak Tumbuh Sehat"* — Ilustrasi ibu & anak muncul bertahap beserta dedaunan tumbuh.
3. **02 — Pantau Pertumbuhan (Slide 2)**: *"Pantau Setiap Tahap Pertumbuhannya"* — Indikator tinggi badan bergerak & kurva standar WHO.
4. **03 — Penuhi Nutrisi (Slide 3)**: *"Nutrisi Tepat, Tumbuh Lebih Optimal"* — Buah & sayuran muncul satu per satu, tombol berubah menjadi **Mulai Sekarang**.
5. **04 — Pilih Peran (Halaman Akhir)**: *"Mulai Perjalanan Bersama NURI"* — Pilihan peran **Saya Ibu / Keluarga** atau **Saya Kader Posyandu** sebelum menuju halaman Login/Registrasi (tanpa formulir data pribadi di dalam onboarding).

## Struktur Folder

- `web_standalone/`
  - `nuri_splash_studio.html` — Studio interaktif lengkap (Alur Onboarding Slide 1–4, Simulator Splash Screen, Komparasi 1:1, dan Generator Kode).
  - `onboarding.html` & `css/nuri_onboarding.css` — Halaman web mandiri khusus alur Onboarding NURI.
  - `index.html` & `css/nuri_splash.css` — Halaman web mandiri khusus animasi Splash Screen NURI.
- `flutter/lib/features/`
  - `splash/nuri_splash_screen_svg.dart` — Widget Splash Screen Flutter berbasis `flutter_svg`.
  - `splash/nuri_splash_screen_png.dart` — Widget Splash Screen Flutter berbasis `Image.asset` (tanpa paket eksternal).
  - `onboarding/nuri_onboarding_screen.dart` — Widget Onboarding 3 Slide + Halaman Pemilihan Peran.
  - `onboarding/nuri_app_entry_flow.dart` — Widget penggabung alur otomatis dari `Splash Screen → Onboarding → Pilih Peran → Login/Daftar`.
- `assets/svg_layers/` — 8 komponen SVG Splash Screen (`0 0 1024 1024`).
- `assets/svg_onboarding/` — Ilustrasi SVG untuk Slide 1, Slide 2, Slide 3, dan logo kecil header NURI.
- `assets/png_layers/` — Layer PNG transparan (`1024x1024`) untuk Splash Screen.
