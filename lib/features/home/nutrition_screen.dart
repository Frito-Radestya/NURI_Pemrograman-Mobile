import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_tabs.dart';
import '../../core/widgets/nuri_top_bar.dart' show NuriAvatar;
import '../../core/widgets/nutrient.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../domain/models/child.dart';
import '../../domain/models/nutrient.dart';
import '../../domain/models/nutrition_summary.dart';
import '../../state/app_state.dart';

/// Layar gizi harian — target asupan, pilar gizi, dan rekomendasi menu.
class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    final DateTime today = state.today;
    final NutritionSummary? summary = child == null
        ? null
        : state.nutritionSummaryFor(child: child, date: today);

    return NuriScaffold(
      bottomNavigationBar: const MomTabBar(active: '/nutrition'),
      topBar: _NutritionTopBar(child: child, today: today),
      body: ListView(
        padding: const EdgeInsets.only(top: 4, bottom: 16),
        children: [
          PillLabel(text: _formatDate(today)),
          const SizedBox(height: 10),
          Row(
            children: [
              const _StatusDot(color: AppColors.brand),
              const SizedBox(width: 7),
              Text(
                child == null
                    ? 'Fase MP-ASI • Belum ada data anak'
                    : 'Fase MP-ASI • ${child.ageLabelAt(today)}',
                style: AppText.caption,
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text('Kesadaran Nutrisi Si Kecil', style: AppText.h1),
          const SizedBox(height: 10),
          Text(
            child == null
                ? 'Tambahkan data anak untuk mulai memantau kecukupan gizi '
                      'hariannya.'
                : 'Kebutuhan asupan harian untuk mendukung tumbuh kembang '
                      '${child.nickname} di usia ${child.ageLabelAt(today)}.',
            style: AppText.body,
          ),
          const SizedBox(height: 20),

          // Target harian.
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Target Harian Si Kecil',
                        style: AppText.h3,
                      ),
                    ),
                    Tag(text: summary?.group.label ?? 'Tanpa data'),
                  ],
                ),
                const SizedBox(height: 16),
                if (child == null)
                  const _EmptyChildNote()
                else ...[
                  for (int i = 0; i < Nutrient.primary.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    Builder(
                      builder: (BuildContext context) {
                        final Nutrient nutrient = Nutrient.primary[i];
                        final NutrientIntake intake = summary!.intakeFor(
                          nutrient,
                        );
                        return _NutrientProgress(
                          title: nutrient.label,
                          caption: _intakeCaption(intake, nutrient),
                          value: (intake.percent / 100).clamp(0.0, 1.0),
                          color: _nutrientColor(nutrient),
                          status: intake.light.label,
                          statusColor: _lightColor(intake.light),
                        );
                      },
                    ),
                  ],
                ],
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Kartu analisis piring.
          NuriCard(
            gradient: AppColors.brandGradient,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NURI SMART VISION • ANALISIS PIRING',
                  style: AppText.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 10.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text('Analisis Piring Si Kecil', style: AppText.h2),
                const SizedBox(height: 4),
                Text(
                  'MP-ASI (6–23 Bulan)',
                  style: AppText.caption.copyWith(
                    color: Colors.white.withValues(alpha: 0.75),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Cukup dekatkan piring makan saat sebelum sesi untuk '
                  'menganalisis — AI NURI mendeteksi profil hewani ganda, '
                  'kecukupan zat besi, dan takaran mini serat sehat.',
                  style: AppText.body.copyWith(
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 16),
                const Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _GlassChip(label: 'Deteksi Hewani & Omega-3'),
                    _GlassChip(label: 'Komposisi Piring Standar Kemenkes'),
                  ],
                ),
                const SizedBox(height: 16),
                _WhitePillButton(
                  icon: Icons.photo_camera_outlined,
                  label: 'Pindai Piring Makan Sekarang',
                  onPressed: () => context.go('/camera-plate'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          SectionHeader(
            title: 'Pilar Gizi Hari Ini',
            subtitle: child == null
                ? 'Kondisi terkini kebutuhan tumbuh'
                : 'Kondisi terkini kebutuhan tumbuh ${child.nickname}',
          ),
          const SizedBox(height: 12),
          NuriCard(
            child: Column(
              children: [
                const _PillarRow(
                  title: 'Protein Hewani Ganda',
                  caption: 'Terpenuhi sebagian',
                  value: 0.6,
                  color: AppColors.protein,
                ),
                const SizedBox(height: 16),
                const _PillarRow(
                  title: 'Mikronutrien Pencegahan Stunting',
                  caption: 'Zat besi, zinc & kalsium',
                  value: 0.85,
                  color: AppColors.brand,
                ),
                const SizedBox(height: 16),
                const _PillarRow(
                  title: 'Tekstur & Ragam Makanan',
                  caption: 'Sesuai anjuran usia 18 bulan',
                  value: 0.9,
                  color: AppColors.fat,
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          const SectionHeader(
            title: 'Rekomendasi Menu Ekstra Tumbuh',
            subtitle: 'Panduan porsi lengkap dari makanan dan gizi tinggi',
            actionLabel: 'Lihat Semua',
          ),
          const SizedBox(height: 12),
          NuriCard(
            padding: EdgeInsets.zero,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppDimens.radiusXl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const NuriPhoto(
                    url: DemoImages.riceFish,
                    height: 170,
                    radius: 0,
                    overlay: Stack(
                      children: [
                        Positioned(
                          left: 16,
                          top: 16,
                          child: PhotoTag(label: 'Tinggi Zat Besi'),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Nasi Tim Gurih Ikan Kembung & Wortel Manis',
                          style: AppText.h3,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Ikan kembung lokal kaya DHA & EPA serta salmon, '
                          'disandingkan dengan labu kuning dan telur ayam '
                          'sebagai booster tumbuh tinggi badan.',
                          style: AppText.body,
                        ),
                        const SizedBox(height: 14),
                        const Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Tag(text: 'Tinggi Zat Besi'),
                            Tag(text: 'Protein Hewani Ganda',
                                color: AppColors.pastelGreenSoft),
                            Tag(text: 'Mudah Dikunyah',
                                color: AppColors.pastelPeach),
                            Tag(text: '20 Menit Masak',
                                color: AppColors.pastelSand),
                          ],
                        ),
                        const SizedBox(height: 14),
                        const NoteBox(
                          icon: Icons.restaurant,
                          child: Text(
                            'Tips: padukan dengan buah tinggi vitamin C agar '
                            'penyerapan zat besi maksimal.',
                            style: AppText.bodySm,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          const SectionHeader(
            title: 'Riwayat Asupan 7 Hari Terakhir',
            subtitle: 'Pemantauan mingguan pola makan harian',
          ),
          const SizedBox(height: 12),
          NuriCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Expanded(child: _DayBubble(label: 'Sen', color: AppColors.brand)),
                    Expanded(child: _DayBubble(label: 'Sel', color: AppColors.brand)),
                    Expanded(child: _DayBubble(label: 'Rab', color: AppColors.fat)),
                    Expanded(child: _DayBubble(label: 'Kam', color: AppColors.brand)),
                    Expanded(child: _DayBubble(label: 'Jum', color: AppColors.protein)),
                    Expanded(child: _DayBubble(label: 'Sab', color: AppColors.brand)),
                    Expanded(child: _DayBubble(label: 'Min', color: AppColors.fat)),
                  ],
                ),
                const SizedBox(height: 18),
                const Wrap(
                  spacing: 18,
                  runSpacing: 8,
                  children: [
                    _MiniLegend(label: 'Baik', color: AppColors.brand),
                    _MiniLegend(label: 'Kurang', color: AppColors.protein),
                    _MiniLegend(label: 'Cukup', color: AppColors.fat),
                  ],
                ),
                const SizedBox(height: 16),
                NuriSecondaryButton(
                  label: 'Buka Buku Riwayat Menu & Catatan Makan (MP-ASI)',
                  icon: Icons.menu_book_outlined,
                  filled: true,
                  onPressed: () => context.go('/meal-history'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          const NoteBox(
            background: AppColors.pastelGreenSoft,
            icon: Icons.verified_outlined,
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'SENTUHAN NUTRISI DARI HATI\n',
                    style: AppText.bodyStrong,
                  ),
                  TextSpan(
                    text: 'Tidak perlu mahal. Ikan kembung, telur, tempe, dan '
                        'sayur lokal sudah sangat cukup untuk tumbuh kembang '
                        'optimal si kecil.',
                    style: AppText.bodySm,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

const List<String> _dayNames = <String>[
  'Senin',
  'Selasa',
  'Rabu',
  'Kamis',
  'Jumat',
  'Sabtu',
  'Minggu',
];

const List<String> _monthNames = <String>[
  'Januari',
  'Februari',
  'Maret',
  'April',
  'Mei',
  'Juni',
  'Juli',
  'Agustus',
  'September',
  'Oktober',
  'November',
  'Desember',
];

String _formatDate(DateTime date) =>
    '${_dayNames[date.weekday - 1]}, ${date.day} '
    '${_monthNames[date.month - 1]} ${date.year}';

String _formatNumber(double value) {
  if (value == value.roundToDouble()) return value.round().toString();
  return value.toStringAsFixed(1);
}

String _intakeCaption(NutrientIntake intake, Nutrient nutrient) =>
    '${_formatNumber(intake.value)} / ${_formatNumber(intake.target)} '
    '${nutrient.unit}';

Color _nutrientColor(Nutrient nutrient) {
  switch (nutrient) {
    case Nutrient.energy:
      return AppColors.energy;
    case Nutrient.protein:
      return AppColors.protein;
    case Nutrient.fat:
      return AppColors.fat;
    case Nutrient.carb:
      return AppColors.carb;
    case Nutrient.iron:
      return AppColors.iron;
    case Nutrient.zinc:
      return AppColors.zinc;
    case Nutrient.calcium:
      return AppColors.calcium;
    case Nutrient.vitaminA:
      return AppColors.vitaminA;
  }
}

Color _lightColor(TrafficLight light) {
  switch (light) {
    case TrafficLight.kurang:
      return AppColors.pastelYellow;
    case TrafficLight.cukup:
      return AppColors.pastelGreen;
    case TrafficLight.lebih:
      return AppColors.pastelPeach;
  }
}

/// Catatan saat belum ada anak terpilih.
class _EmptyChildNote extends StatelessWidget {
  const _EmptyChildNote();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const NoteRow(
          icon: Icons.child_care_rounded,
          text:
              'Belum ada data anak terpilih. Tambahkan data Si Kecil untuk '
              'menghitung target AKG harian dan asupan gizi.',
        ),
        const SizedBox(height: 14),
        NuriSecondaryButton(
          label: 'Tambah Data Anak',
          icon: Icons.add_rounded,
          filled: true,
          onPressed: () => context.go('/child-data'),
        ),
      ],
    );
  }
}

class _NutritionTopBar extends StatelessWidget {
  const _NutritionTopBar({required this.child, required this.today});

  final Child? child;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final Child? selected = child;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            const NuriAvatar(imageUrl: DemoImages.avatarChild),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                selected == null
                    ? 'Belum ada anak'
                    : '${selected.nickname} • '
                          '${selected.ageLabelAt(today)}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppText.h3,
              ),
            ),
            const SizedBox(width: 10),
            NuriSoftButton(
              icon: Icons.calendar_today_outlined,
              onPressed: () => context.go('/notifications'),
            ),
            const SizedBox(width: 8),
            const NuriAvatar(imageUrl: DemoImages.avatarMother),
          ],
        ),
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.color});

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

class _NutrientProgress extends StatelessWidget {
  const _NutrientProgress({
    required this.title,
    required this.caption,
    required this.value,
    required this.color,
    required this.status,
    required this.statusColor,
  });

  final String title;
  final String caption;
  final double value;
  final Color color;
  final String status;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.title),
                  const SizedBox(height: 2),
                  Text(caption, style: AppText.caption),
                ],
              ),
            ),
            const SizedBox(width: 10),
            StatusChip(text: status, color: statusColor),
          ],
        ),
        const SizedBox(height: 10),
        NutrientBar(value: value, color: color),
      ],
    );
  }
}

class _PillarRow extends StatelessWidget {
  const _PillarRow({
    required this.title,
    required this.caption,
    required this.value,
    required this.color,
  });

  final String title;
  final String caption;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppText.title)),
            Text('${(value * 100).round()}%',
                style: AppText.bodyStrong.copyWith(color: color)),
          ],
        ),
        const SizedBox(height: 2),
        Text(caption, style: AppText.caption),
        const SizedBox(height: 10),
        NutrientBar(value: value, color: color),
      ],
    );
  }
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppText.bodySm.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
          fontSize: 12.5,
        ),
      ),
    );
  }
}

class _WhitePillButton extends StatelessWidget {
  const _WhitePillButton({
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onPressed,
        child: Container(
          height: AppDimens.buttonHeight,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.brand, size: 20),
                const SizedBox(width: 10),
              ],
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.button.copyWith(color: AppColors.brand),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DayBubble extends StatelessWidget {
  const _DayBubble({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.85),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(height: 6),
        Text(label, style: AppText.caption.copyWith(fontSize: 10.5)),
      ],
    );
  }
}

class _MiniLegend extends StatelessWidget {
  const _MiniLegend({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 7),
        Text(label, style: AppText.caption),
      ],
    );
  }
}
