import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
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

/// Riwayat analisis gizi piring makan Si Kecil.
class MealHistoryScreen extends StatefulWidget {
  const MealHistoryScreen({super.key});

  @override
  State<MealHistoryScreen> createState() => _MealHistoryScreenState();
}

class _MealHistoryScreenState extends State<MealHistoryScreen> {
  MealType? _filter;

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    final DateTime today = state.today;

    final List<FoodLogItem> items = child == null
        ? const <FoodLogItem>[]
        : state.foodItemsFor(childId: child.id, date: today);
    final NutritionSummary? summary = child == null
        ? null
        : state.nutritionSummaryFor(child: child, date: today);

    return NuriScaffold(
      background: AppColors.canvas,
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NURI',
              style: AppText.caption.copyWith(letterSpacing: 1.2),
            ),
            Text(
              'Riwayat Analisis Gizi',
              style: AppText.h3.copyWith(fontSize: 17),
            ),
          ],
        ),
        actions: const [
          NuriSoftButton(icon: Icons.calendar_today_outlined, size: 40),
          SizedBox(width: 8),
          NuriSoftButton(icon: Icons.tune_rounded, size: 40),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 4),

            // ---- Profil anak ------------------------------------------------
            NuriCard(
              child: Row(
                children: [
                  NuriAvatar(
                    initials: child?.initial ?? 'A',
                    size: 48,
                    background: AppColors.brand,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child == null
                              ? 'Belum ada anak'
                              : '${child.nickname} '
                                    '(${child.ageLabelAt(today)})',
                          style: AppText.title,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          child == null
                              ? 'Tambahkan data anak untuk memantau gizi'
                              : '• MP-ASI • ${child.posyanduName ?? 'Posyandu'}',
                          style: AppText.caption,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  if (child != null) const Tag(text: 'Aktif Terpantau'),
                ],
              ),
            ),
            const SizedBox(height: 14),

            if (child == null)
              _EmptyHistory(
                icon: Icons.child_care_rounded,
                title: 'Belum Ada Data Anak',
                message:
                    'Tambahkan data anak terlebih dahulu untuk mulai mencatat '
                    'dan memantau asupan gizi harian.',
                buttonLabel: 'Tambah Data Anak',
                buttonIcon: Icons.add_rounded,
                onPressed: () => context.go('/child-data'),
              )
            else ...[
              // ---- Ringkasan hari ini ---------------------------------------
              if (summary != null)
                _SummaryCard(summary: summary, today: today),
              const SizedBox(height: 16),

              // ---- Filter chips ---------------------------------------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Semua Sesi',
                      active: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final MealType meal in MealType.values) ...[
                      const SizedBox(width: 8),
                      _FilterChip(
                        label: meal.label,
                        icon: null,
                        leadingEmoji: meal.emoji,
                        active: _filter == meal,
                        onTap: () => setState(() => _filter = meal),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // ---- Daftar per sesi makan ------------------------------------
              if (items.isEmpty)
                _EmptyHistory(
                  icon: Icons.restaurant_menu_rounded,
                  title: 'Belum Ada Catatan Makan',
                  message:
                      'Pindai piring makan Si Kecil atau catat manual untuk '
                      'mulai membangun riwayat gizi harian.',
                  buttonLabel: 'Pindai Piring Makan',
                  buttonIcon: Icons.camera_alt_outlined,
                  onPressed: () => context.go('/camera-plate'),
                )
              else
                for (final MealType meal in MealType.values)
                  _MealGroup(
                    meal: meal,
                    items: items
                        .where(
                          (FoodLogItem item) =>
                              item.meal == meal &&
                              (_filter == null || _filter == meal),
                        )
                        .toList(),
                  ),
            ],
            const SizedBox(height: 22),
            NuriPrimaryButton(
              label: 'Pindai Piring Baru',
              icon: Icons.camera_alt_outlined,
              onPressed: () => context.go('/camera-plate'),
            ),
            const SizedBox(height: 22),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.summary, required this.today});

  final NutritionSummary summary;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final NutrientIntake protein = summary.intakeFor(Nutrient.protein);
    final NutrientIntake energy = summary.energy;
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('Ringkasan Hari Ini', style: AppText.h3),
              ),
              Tag(text: _formatDate(today)),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _SummaryMetric(
                  title: 'Asupan Energi',
                  value: '${energy.value.toStringAsFixed(0)} kkal',
                  bar: (energy.percent / 100).clamp(0.0, 1.0),
                  caption:
                      'Target: ${energy.target.toStringAsFixed(0)} kkal',
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 18),
              Expanded(
                child: _SummaryMetric(
                  title: 'Protein',
                  value: '${protein.value.toStringAsFixed(1)} g',
                  bar: (protein.percent / 100).clamp(0.0, 1.0),
                  caption: 'Target: ${protein.target.toStringAsFixed(0)} g',
                  color: AppColors.brand,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          NoteBox(
            background: AppColors.pastelGreenSoft,
            icon: Icons.eco_rounded,
            child: RichText(
              text: TextSpan(
                style: AppText.bodySm,
                children: [
                  TextSpan(
                    text: '${summary.loggedItems} item tercatat. ',
                    style: AppText.bodyStrong.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'Pola makan bergizi seimbang mendukung tumbuh kembang '
                        'dan pencegahan stunting sesuai pedoman Kemenkes RI.',
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

class _MealGroup extends StatelessWidget {
  const _MealGroup({required this.meal, required this.items});

  final MealType meal;
  final List<FoodLogItem> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(
            title: '${meal.label} — ${_formatDate(items.first.logDate)}',
            count: '${items.length} Hidangan',
          ),
          const SizedBox(height: 12),
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            _MealItemCard(item: items[i]),
          ],
        ],
      ),
    );
  }
}

class _MealItemCard extends StatelessWidget {
  const _MealItemCard({required this.item});

  final FoodLogItem item;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.surfaceSoft,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(item.emoji, style: const TextStyle(fontSize: 28)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${item.meal.emoji} ${item.meal.label}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppText.caption,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Tag(
                      text: item.source.label,
                      color: item.confidence == null
                          ? AppColors.pastelSand
                          : AppColors.pastelGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.foodName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.title.copyWith(fontSize: 14.5),
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.portionLabel} • '
                  '${item.grams.toStringAsFixed(0)} g',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${item.energy.toStringAsFixed(1)} kkal',
                style: AppText.bodyStrong.copyWith(fontSize: 13.5),
              ),
              const SizedBox(height: 4),
              Text(
                '${item.nutrient(Nutrient.protein).toStringAsFixed(1)} g P',
                style: AppText.caption,
              ),
              const SizedBox(height: 2),
              Text(
                '${item.nutrient(Nutrient.iron).toStringAsFixed(1)} mg Fe',
                style: AppText.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory({
    required this.icon,
    required this.title,
    required this.message,
    required this.buttonLabel,
    required this.buttonIcon,
    required this.onPressed,
  });

  final IconData icon;
  final String title;
  final String message;
  final String buttonLabel;
  final IconData buttonIcon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        children: [
          IconBadge(
            icon: icon,
            color: AppColors.pastelGreenSoft,
            size: 56,
            radius: 18,
          ),
          const SizedBox(height: 14),
          Text(
            title,
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
          NuriSecondaryButton(
            label: buttonLabel,
            icon: buttonIcon,
            filled: true,
            onPressed: onPressed,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _SummaryMetric extends StatelessWidget {
  const _SummaryMetric({
    required this.title,
    required this.value,
    required this.bar,
    required this.caption,
    required this.color,
  });

  final String title;
  final String value;
  final double bar;
  final String caption;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppText.caption),
        const SizedBox(height: 6),
        Text(value, style: AppText.h3.copyWith(fontSize: 16)),
        const SizedBox(height: 8),
        NutrientBar(value: bar, color: color),
        const SizedBox(height: 6),
        Text(caption, style: AppText.caption),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    this.icon,
    this.leadingEmoji,
    this.active = false,
    this.onTap,
  });

  final String label;
  final IconData? icon;
  final String? leadingEmoji;
  final bool active;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? AppColors.brand : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: active ? null : Border.all(color: AppColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (leadingEmoji != null) ...[
                Text(leadingEmoji!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 7),
              ] else if (icon != null) ...[
                Icon(
                  icon,
                  size: 16,
                  color: active ? Colors.white : AppColors.inkSoft,
                ),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: AppText.bodySm.copyWith(
                  color: active ? Colors.white : AppColors.ink,
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.count});

  final String title;
  final String count;

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
        Expanded(
          child: Text(title, style: AppText.bodyStrong),
        ),
        const SizedBox(width: 8),
        Tag(text: count),
      ],
    );
  }
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
