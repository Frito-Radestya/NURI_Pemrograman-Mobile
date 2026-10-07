import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';

/// Pusat notifikasi NURI Care.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      background: AppColors.canvas,
      topBar: NuriTopBar(
        showBack: true,
        onBack: () =>
            context.canPop() ? context.pop() : context.go('/home'),
        titleWidget: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('NURI CARE', style: AppText.caption),
            Text('Notifikasi', style: AppText.h3),
          ],
        ),
        actions: [
          NuriSoftButton(
            icon: Icons.filter_list_rounded,
            background: AppColors.surface.withValues(alpha: 0.85),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
          NuriSoftButton(
            icon: Icons.done_all_rounded,
            background: AppColors.surface.withValues(alpha: 0.85),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        children: [
          // Ringkasan.
          Row(
            children: [
              const Expanded(child: _SummaryLabel(count: 2)),
              const SizedBox(width: 10),
              const SoftChip(
                label: 'Simulasi Kosong',
                icon: Icons.auto_awesome,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pemilih anak.
          const Row(
            children: [
              NuriAvatar(imageUrl: DemoImages.avatarChild, size: 44),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pemantauan:', style: AppText.caption),
                    Text(
                      'Muhammad Al-Fatih (14 Bln)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppText.title,
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              NuriTextAction(label: 'Tandai Semua Dibaca'),
            ],
          ),
          const SizedBox(height: 16),

          // Filter kategori.
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                SoftChip(
                  label: 'Semua (5)',
                  color: AppColors.brand,
                  textColor: Colors.white,
                  iconColor: Colors.white,
                ),
                SizedBox(width: 10),
                SoftChip(label: 'Jadwal & Imunisasi', icon: Icons.event_outlined),
                SizedBox(width: 10),
                SoftChip(label: 'Nutrisi & Gizi', icon: Icons.restaurant_outlined),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Hari ini.
          const _SectionLabel(title: 'HARI INI', tag: '2 Terbaru'),
          const SizedBox(height: 12),
          _NotifCard(
            icon: Icons.calendar_month_outlined,
            background: AppColors.pastelPink,
            iconBackground: AppColors.surface,
            iconColor: AppColors.protein,
            tagColor: AppColors.surface,
            category: 'Jadwal Posyandu',
            time: '09:15 WIB',
            title: 'Jadwal Posyandu Melati RW 04 Besok Pagi',
            body: 'Penimbangan rutin dan pemberian vitamin A untuk Muhammad '
                'Al-Fatih dimulai pukul 08.30 WIB di Balai Warga RW 04.',
            footer: Row(
              children: [
                Flexible(
                  child: Text(
                    'Lihat Lokasi & Jadwal',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.bodySm.copyWith(
                      color: AppColors.brandText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const Spacer(),
                const _Dot(color: AppColors.brand),
                const SizedBox(width: 7),
                const Text('Balai RW 04', style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(height: 12),
          _NotifCard(
            icon: Icons.restaurant_outlined,
            iconBackground: AppColors.pastelPeach,
            iconColor: AppColors.accent,
            category: 'Nutrisi Harian',
            time: '07:00 WIB',
            title: 'Rekomendasi Menu MP–ASI Kaya Zat Besi',
            body: 'Berdasarkan analisis piring makan siang kemarin, Bunda '
                'disarankan melengkapi makan malam si kecil dengan variasi hati '
                'ayam atau ikan kembung segar.',
            footer: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _MiniChip(label: '+ Fe (Zat Besi)'),
                    _MiniChip(label: '+ Protein Hewani'),
                  ],
                ),
                SizedBox(height: 10),
                Text(
                  'Buka Saran Resep Menu →',
                  style: AppText.bodySm.copyWith(
                    color: AppColors.brandText,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Kemarin.
          const _SectionLabel(title: 'KEMARIN', tag: '14 Apr 2025'),
          const SizedBox(height: 12),
          _NotifCard(
            icon: Icons.show_chart_rounded,
            iconBackground: AppColors.pastelBlue,
            iconColor: AppColors.statusTinggi,
            tagColor: AppColors.pastelBlue,
            category: 'Tumbuh Kembang',
            time: '16:30 WIB',
            title: 'Data Pertumbuhan Berhasil Tersinkronisasi',
            body: 'Hasil pengukuran berat badan 10.2 kg dan tinggi badan 77.5 cm '
                'telah otomatis tercatat pada KMS Digital & Buku KIA Bunda.',
            footer: Text(
              'Lihat Kurva WHO Z-Score →',
              style: AppText.bodySm.copyWith(
                color: AppColors.brandText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const _NotifCard(
            icon: Icons.verified_user_outlined,
            iconBackground: AppColors.pastelGreenSoft,
            iconColor: AppColors.brand,
            category: 'Konseling Posyandu',
            time: '11:20 WIB',
            title: 'Catatan Bidan Desa: Pertumbuhan Prima',
            body: 'Bidan Sari telah memverifikasi kurva kenaikan BB Al-Fatih '
                'pada batas hijau prima. Pertahankan konsistensi variasi protein '
                'hewani harian dan hidrasi.',
            footer: NoteRow(
              icon: Icons.verified,
              text: 'Terverifikasi Bidan Sari, A.Md.Keb',
            ),
          ),
          const SizedBox(height: 22),

          // Minggu lalu.
          const _SectionLabel(title: 'MINGGU LALU', tag: '10 Apr 2025'),
          const SizedBox(height: 12),
          _NotifCard(
            icon: Icons.vaccines_outlined,
            iconBackground: AppColors.pastelPurple,
            iconColor: AppColors.iron,
            tagColor: AppColors.pastelPurple,
            category: 'Imunisasi',
            time: '08:00 WIB',
            title: 'Pengingat Vaksin PCV Dosis 3',
            body: 'Vaksinasi PCV Dosis 1 berikutnya dijadwalkan pada awal bulan '
                'Mei 2025 di Puskesmas Pembantu Sukamaju. Bunda dapat melihat '
                'panduan persiapan vaksinasi di aplikasi.',
            footer: Text(
              'Jadwalkan di Kalender Pribadi →',
              style: AppText.bodySm.copyWith(
                color: AppColors.brandText,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryLabel extends StatelessWidget {
  const _SummaryLabel({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: AppColors.brand,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            '$count Pemberitahuan Baru',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.bodyStrong.copyWith(fontSize: 13.5),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.tag});

  final String title;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: AppText.label),
        const Spacer(),
        Tag(text: tag),
      ],
    );
  }
}

class _NotifCard extends StatelessWidget {
  const _NotifCard({
    required this.icon,
    required this.category,
    required this.time,
    required this.title,
    required this.body,
    this.iconBackground = AppColors.pastelGreenSoft,
    this.iconColor = AppColors.brand,
    this.tagColor = AppColors.pastelGreen,
    this.background = AppColors.surface,
    this.footer,
  });

  final IconData icon;
  final String category;
  final String time;
  final String title;
  final String body;
  final Color iconBackground;
  final Color iconColor;
  final Color tagColor;
  final Color background;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      color: background,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: icon,
            color: iconBackground,
            iconColor: iconColor,
            size: 44,
            radius: 14,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(child: Tag(text: category, color: tagColor)),
                    const Spacer(),
                    Text(time, style: AppText.caption),
                  ],
                ),
                const SizedBox(height: 10),
                Text(title, style: AppText.h3),
                const SizedBox(height: 6),
                Text(body, style: AppText.bodySm),
                if (footer != null) ...[
                  const SizedBox(height: 12),
                  footer!,
                ],
              ],
            ),
          ),
          const SizedBox(width: 6),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(Icons.chevron_right_rounded,
                color: AppColors.inkFaint, size: 20),
          ),
        ],
      ),
    );
  }
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.bodySm.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 7,
      height: 7,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
