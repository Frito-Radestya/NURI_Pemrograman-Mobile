import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';

/// Katalog seluruh layar NURI — memudahkan meninjau hasil redesign.
class DesignGalleryScreen extends StatelessWidget {
  const DesignGalleryScreen({super.key});

  static const List<(String, String, String)> _groups = [
    ('Onboarding', 'Awal & orientasi', '/onboarding'),
    ('Splash', 'Pembuka aplikasi', '/'),
    ('Pilih Peran', 'Ibu Hamil / Ibu Balita / Kader', '/role'),
    ('Masuk Akun', 'Login', '/login'),
    ('Daftar', 'Buat akun NURI', '/register'),
    ('Lupa Kata Sandi', 'Pemulihan akun', '/forgot'),
    ('Cek Kotak Masuk', 'Tautan terkirim', '/forgot-sent'),
    ('Data Si Kecil', 'Profil anak', '/child-data'),
    ('Pengukuran Perdana', 'Ukuran awal', '/child-measure'),
    ('Beranda Ibu', 'Ruang ibu balita', '/home'),
    ('Tumbuh', 'Grafik & riwayat', '/growth'),
    ('Gizi', 'Nutrisi harian', '/nutrition'),
    ('Profil', 'Akun & keluarga', '/profile'),
    ('Skrining Anak', 'Data & pengukuran', '/screening'),
    ('Hasil Skrining', 'Ringkasan medis', '/screening-result'),
    ('Kamera Postur', 'Pengukuran AI', '/camera-posture'),
    ('Kamera Piring', 'Analisis makan', '/camera-plate'),
    ('Ulas Piring', 'Konfirmasi foto', '/meal-review'),
    ('Menganalisis', 'AI memproses', '/meal-analyzing'),
    ('Hasil Analisis', 'Kandungan gizi', '/meal-result'),
    ('Analisis Gagal', 'Foto ulang', '/meal-fail'),
    ('Riwayat Gizi', 'Catatan makan', '/meal-history'),
    ('Beranda Hamil', 'Ruang ibu hamil', '/pregnant'),
    ('Nutrisi Hamil', 'Gizi ibu hamil', '/pregnant-nutrition'),
    ('Pantau Hamil', 'Janin & bunda', '/pregnant-monitor'),
    ('Rekomendasi Bunda', 'Saran harian', '/pregnant-recommend'),
    ('Beranda Kader', 'Ruang kader', '/kader'),
    ('Daftar Sasaran', 'Balita terdaftar', '/kader-targets'),
    ('Detail Sasaran', 'Profil balita', '/kader-target-detail'),
    ('Input Pengukuran', 'Entri kader', '/kader-entry'),
    ('Hasil Skrining Kader', 'Diagnosis medis', '/kader-result'),
    ('Riwayat Aktivitas', 'Catatan kader', '/kader-activity'),
    ('Notifikasi', 'NURI Care', '/notifications'),
    ('Pengaturan', 'Preferensi', '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      topBar: const NuriTopBar(title: 'Katalog Layar NURI'),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 24),
        itemCount: _groups.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final (title, subtitle, route) = _groups[i];
          return NuriCard(
            padding: const EdgeInsets.all(16),
            onTap: () => context.go(route),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.pastelGreenSoft,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${i + 1}',
                    style: AppText.bodyStrong.copyWith(color: AppColors.brandText),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: AppText.title),
                      const SizedBox(height: 2),
                      Text(subtitle, style: AppText.bodySm),
                    ],
                  ),
                ),
                const PillLabel(text: 'Lihat', leadingDot: false),
              ],
            ),
          );
        },
      ),
    );
  }
}
