import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/nutrient.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../domain/models/child.dart';
import '../../domain/models/food_log.dart';
import '../../domain/models/nutrient.dart';
import '../../domain/models/nutrition_summary.dart';
import '../../state/app_state.dart';

/// Hasil analisis gizi piring makan.
class MealResultScreen extends StatelessWidget {
  const MealResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    if (child == null) {
      return const _ResultEmpty(
        message:
            'Pilih atau tambahkan data anak terlebih dahulu untuk melihat '
            'hasil analisis gizi piring.',
      );
    }

    final DateTime today = state.today;
    final List<FoodLogItem> items = state.foodItemsFor(
      childId: child.id,
      date: today,
    );
    if (items.isEmpty) {
      return const _ResultEmpty(
        message:
            'Belum ada makanan yang tercatat hari ini. Pindai piring makan '
            'Si Kecil untuk melihat ringkasan gizinya.',
      );
    }

    final NutritionSummary summary = state.nutritionSummaryFor(
      child: child,
      date: today,
    );
    final FoodLogItem last = items.last;
    final List<FoodLogItem> mealItems = items
        .where((FoodLogItem item) => item.meal == last.meal)
        .toList();

    final double energyTarget = summary.energy.target;
    final double energyPercent = energyTarget <= 0
        ? 0
        : (last.energy / energyTarget).clamp(0.0, 1.0);

    final NutrientIntake proteinIntake = summary.intakeFor(Nutrient.protein);
    final double proteinValue = last.nutrient(Nutrient.protein);
    final double proteinPercent = proteinIntake.target <= 0
        ? 0
        : (proteinValue / proteinIntake.target).clamp(0.0, 1.0);

    final NutrientIntake ironIntake = summary.intakeFor(Nutrient.iron);
    final double ironValue = last.nutrient(Nutrient.iron);
    final double ironPercent = ironIntake.target <= 0
        ? 0
        : (ironValue / ironIntake.target).clamp(0.0, 1.0);

    return NuriScaffold(
      background: AppColors.canvas,
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hasil Analisis Gizi',
              style: AppText.caption.copyWith(letterSpacing: 0.6),
            ),
            Text(
              '${last.meal.label} • Makan',
              style: AppText.h3.copyWith(fontSize: 17),
            ),
          ],
        ),
        actions: const [
          NuriAvatar(initials: 'B', size: 40),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),

            // ---- Kartu waktu & foto -----------------------------------------
            NuriCard(
              color: AppColors.surfaceSoft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const IconBadge(
                        icon: Icons.schedule_rounded,
                        color: AppColors.canvasGreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Waktu Makan: ${last.meal.label}',
                              style: AppText.title,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              last.confidence == null
                                  ? 'Dicatat manual • ${last.source.label}'
                                  : 'Akurasi AI '
                                        '${(last.confidence! * 100).round()}% • '
                                        '${last.source.label}',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  NuriPhoto(
                    url: DemoImages.plateMeal,
                    height: 160,
                    overlay: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Align(
                        alignment: Alignment.bottomLeft,
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final FoodLogItem item
                                in mealItems.take(4))
                              _DetectionChip(
                                text:
                                    '${item.foodName} '
                                    '(${item.grams.toStringAsFixed(0)}g)',
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            Center(
              child: PillLabel(
                text:
                    'Piring Sehat Balita • ${summary.group.label} • TKPI 2019',
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                _formatDate(today),
                textAlign: TextAlign.center,
                style: AppText.caption,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              last.foodName,
              textAlign: TextAlign.center,
              style: AppText.h2,
            ),
            const SizedBox(height: 16),

            // ---- Ringkasan hari ini -----------------------------------------
            NuriCard(
              color: AppColors.canvasGreen,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      IconBadge(
                        icon: Icons.shield_rounded,
                        color: AppColors.brand,
                        iconColor: Colors.white,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Tag(text: 'RINGKASAN HARI INI'),
                            SizedBox(height: 8),
                            Text('Status Asupan Harian', style: AppText.h3),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    _summaryMessage(summary, child.nickname),
                    style: AppText.body.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Text(
                        '${summary.loggedItems} item tercatat',
                        style: AppText.caption,
                      ),
                      const Spacer(),
                      Text(
                        '${summary.energy.value.toStringAsFixed(0)} / '
                        '${summary.energy.target.toStringAsFixed(0)} kkal',
                        style: AppText.caption.copyWith(
                          color: AppColors.brandText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            SectionHeader(
              title: 'Kandungan Gizi Piring',
              actionLabel: 'Target ${summary.group.label}',
            ),
            const SizedBox(height: 14),

            // ---- Energi ------------------------------------------------------
            Row(
              children: [
                NutrientRing(value: energyPercent, trackLabel: 'Energi'),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('TOTAL ENERGI TERHITUNG', style: AppText.label),
                      const SizedBox(height: 4),
                      Text(
                        '${last.energy.toStringAsFixed(1)} kkal',
                        style: AppText.h2,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${(energyPercent * 100).round()}% dari kebutuhan '
                        'harian ${child.nickname} '
                        '(${energyTarget.toStringAsFixed(0)} kkal)',
                        style: AppText.caption,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ---- Protein -----------------------------------------------------
            NuriCard(
              color: AppColors.pastelPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'PROTEIN',
                              style: AppText.label,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${proteinValue.toStringAsFixed(1)} gram',
                              style: AppText.h2,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kebutuhan harian '
                              '${proteinIntake.target.toStringAsFixed(0)} g',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Tag(
                        text: '${(proteinPercent * 100).round()}% Target Harian',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  NutrientBar(value: proteinPercent, color: AppColors.protein),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // ---- Lemak & karbohidrat ----------------------------------------
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: MetricBox(
                    label: 'LEMAK',
                    value: last.nutrient(Nutrient.fat).toStringAsFixed(1),
                    unit: Nutrient.fat.unit,
                    icon: Icons.opacity_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: MetricBox(
                    label: 'KARBOHIDRAT',
                    value: last.nutrient(Nutrient.carb).toStringAsFixed(1),
                    unit: Nutrient.carb.unit,
                    icon: Icons.rice_bowl_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // ---- Zat besi ----------------------------------------------------
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ZAT BESI (FE)', style: AppText.label),
                  const SizedBox(height: 4),
                  Text('${ironValue.toStringAsFixed(1)} mg', style: AppText.h2),
                  const SizedBox(height: 4),
                  Text(
                    '${(ironPercent * 100).round()}% Kebutuhan Harian '
                    '(${ironIntake.target.toStringAsFixed(1)} mg)',
                    style: AppText.caption,
                  ),
                  const SizedBox(height: 12),
                  NutrientBar(value: ironPercent, color: AppColors.iron),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ---- Rincian komponen --------------------------------------------
            const SectionHeader(
              title: 'Rincian Komponen Pangan',
              actionLabel: 'Takaran Matang',
            ),
            const SizedBox(height: 14),
            NuriCard(
              child: Column(
                children: [
                  for (int i = 0; i < mealItems.length; i++) ...[
                    if (i > 0)
                      const Divider(height: 1, color: AppColors.lineSoft),
                    _DetailRow(
                      emoji: mealItems[i].emoji,
                      title: mealItems[i].foodName,
                      subtitle:
                          'Porsi ${mealItems[i].grams.toStringAsFixed(0)}g '
                          '(${mealItems[i].portionLabel})',
                      energy:
                          '${mealItems[i].energy.toStringAsFixed(1)} kkal',
                      macros:
                          '${mealItems[i].nutrient(Nutrient.protein).toStringAsFixed(1)} g P • '
                          '${mealItems[i].nutrient(Nutrient.carb).toStringAsFixed(1)} g K',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 14),
            const NoteRow(
              icon: Icons.verified_outlined,
              text:
                  'Sumber Data Terverifikasi: Tabel Komposisi Pangan Indonesia '
                  '(TKPI 2019) & Pedoman Gizi Seimbang Kementerian Kesehatan '
                  'Republik Indonesia (Kemenkes RI).',
            ),
            const SizedBox(height: 22),
            NuriPrimaryButton(
              label: 'Simpan ke Buku Jurnal Makan ${child.nickname}',
              icon: Icons.bookmark_border_rounded,
              onPressed: () => context.go('/meal-history'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Pindai Lagi',
                    icon: Icons.camera_alt_outlined,
                    filled: true,
                    onPressed: () => context.go('/camera-plate'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Riwayat Makan',
                    icon: Icons.menu_book_outlined,
                    filled: true,
                    onPressed: () => context.go('/meal-history'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

String _summaryMessage(NutritionSummary summary, String nickname) {
  final double energyPercent = summary.energy.percent;
  if (summary.isEmpty) {
    return 'Belum ada asupan tercatat hari ini untuk $nickname.';
  }
  if (energyPercent < 80) {
    return 'Asupan $nickname hari ini masih di bawah target. Lengkapi '
        'makanan bergizi seimbang pada sesi berikutnya ya, Bunda.';
  }
  if (energyPercent <= 120) {
    return 'Asupan $nickname hari ini sudah mendekati target harian. '
        'Pertahankan pola makan bergizi seimbang.';
  }
  return 'Asupan $nickname hari ini melebihi target harian. Cukup atur '
      'takaran pada sesi makan berikutnya.';
}

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

/// Layar hasil saat data anak/riwayat belum tersedia.
class _ResultEmpty extends StatelessWidget {
  const _ResultEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      background: AppColors.canvas,
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Hasil Analisis Gizi',
              style: AppText.caption.copyWith(letterSpacing: 0.6),
            ),
            Text('Ringkasan Piring', style: AppText.h3.copyWith(fontSize: 17)),
          ],
        ),
        actions: const [NuriAvatar(initials: 'B', size: 40)],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            NuriCard(
              child: Column(
                children: [
                  const IconBadge(
                    icon: Icons.restaurant_menu_rounded,
                    color: AppColors.pastelGreenSoft,
                    size: 56,
                    radius: 18,
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Belum Ada Hasil',
                    textAlign: TextAlign.center,
                    style: AppText.h3,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: AppText.bodySm,
                  ),
                  const SizedBox(height: 18),
                  NuriPrimaryButton(
                    label: 'Pindai Piring Makan',
                    icon: Icons.camera_alt_outlined,
                    onPressed: () => context.go('/camera-plate'),
                  ),
                  const SizedBox(height: 10),
                  NuriSecondaryButton(
                    label: 'Riwayat Makan',
                    icon: Icons.menu_book_outlined,
                    filled: true,
                    onPressed: () => context.go('/meal-history'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetectionChip extends StatelessWidget {
  const _DetectionChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        style: AppText.caption.copyWith(
          color: AppColors.ink,
          fontWeight: FontWeight.w600,
          fontSize: 10.5,
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.energy,
    required this.macros,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final String energy;
  final String macros;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(emoji, style: const TextStyle(fontSize: 20)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title.copyWith(fontSize: 14)),
                const SizedBox(height: 2),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(energy, style: AppText.bodyStrong),
              const SizedBox(height: 2),
              Text(
                macros,
                textAlign: TextAlign.right,
                style: AppText.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
