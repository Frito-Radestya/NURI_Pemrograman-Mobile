import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/nutrition_calculator.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'food_flow.dart';
import 'recommendation_screen.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key, this.subjectId, this.subjectLabel});

  final String? subjectId;
  final String? subjectLabel;

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  DateTime _selectedDate = dateOnly(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final pregnancy = state.activePregnancy;
    final child = state.activeChild;

    String? subjectId = widget.subjectId;
    String subjectLabel = widget.subjectLabel ?? '';
    if (subjectId == null) {
      if (state.pregnancyContext && pregnancy != null) {
        subjectId = pregnancy.id;
        subjectLabel = 'Kehamilan';
      } else if (child != null) {
        subjectId = child.id;
        subjectLabel = child.nickname;
      } else if (pregnancy != null) {
        subjectId = pregnancy.id;
        subjectLabel = 'Kehamilan';
      }
    }

    Pregnancy? subjectPregnancy;
    Child? subjectChild;
    if (subjectId != null) {
      for (final item in state.pregnancies) {
        if (item.id == subjectId) subjectPregnancy = item;
      }
      for (final item in state.children) {
        if (item.id == subjectId) subjectChild = item;
      }
    }

    if (subjectId == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            children: [
              ScreenHeader(
                title: 'Catatan gizi',
                onBack: () => Navigator.of(context).pop(),
              ),
              const Expanded(
                child: EmptyState(
                  title: 'Belum ada data',
                  body: 'Tambahkan data kehamilan atau anak untuk mulai mencatat makan.',
                  icon: Icons.restaurant_menu_rounded,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final activeSubjectId = subjectId;
    final totals = state.totalsFor(activeSubjectId, _selectedDate);
    final logs = state.foodLogsFor(activeSubjectId, _selectedDate);

    late final AkgTarget target;
    late final String targetLabel;
    if (subjectPregnancy != null) {
      final progress = PregnancyCalculator.progress(
        hpht: subjectPregnancy.hpht,
        hpl: subjectPregnancy.hpl,
        today: _selectedDate,
      );
      target = const AkgReference().forPregnancy(progress.trimester);
      targetLabel =
          '${PregnancyCalculator.trimesterLabel(progress.trimester)} • ${target.label}';
      subjectLabel = 'Kehamilan';
    } else if (subjectChild != null) {
      target = const AkgReference().forChild(
        subjectChild.ageMonthsAt(_selectedDate),
        subjectChild.sex,
      );
      targetLabel = '${subjectChild.ageLabel(_selectedDate)} • ${target.label}';
      subjectLabel = subjectChild.nickname;
    } else {
      target = const AkgReference().forChild(18, Sex.male);
      targetLabel = target.label;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Catatan gizi',
              subtitle: subjectLabel,
              onBack: () => Navigator.of(context).pop(),
              action: RoundIconButton(
                icon: Icons.restaurant_menu_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => RecommendationScreen(
                      subjectLabel: subjectLabel,
                      pregnancyMode: subjectPregnancy != null,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DateNavigator(
                      selected: _selectedDate,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDate = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    _DiarySummary(
                      totals: totals,
                      target: target,
                      targetLabel: targetLabel,
                      onAdd: () => _openCamera(activeSubjectId, subjectLabel),
                    ),
                    if (totals.incomplete) ...[
                      const SizedBox(height: 10),
                      InfoBanner(
                        title: 'Sebagian nilai gizi belum lengkap',
                        body:
                            'Data ${totals.incompleteNutrients.join(', ')} belum tersedia untuk semua makanan. Angka ini adalah perkiraan minimum.',
                        icon: Icons.info_outline_rounded,
                        background: AppColors.amberSoft,
                        foreground: AppColors.amber,
                      ),
                    ],
                    const SizedBox(height: 22),
                    const SectionHeader(
                      title: 'Makan hari ini',
                      subtitle: 'Ketuk catatan untuk melihat rincian.',
                    ),
                    const SizedBox(height: 10),
                    ...MealType.values.map((meal) {
                      final mealLogs = logs
                          .where((log) => log.meal == meal)
                          .toList();
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _MealCard(
                          meal: meal,
                          logs: mealLogs,
                          onAdd: () => _openCamera(
                            activeSubjectId,
                            subjectLabel,
                            meal: meal,
                          ),
                          onDelete: (log) => _deleteLog(log),
                          onOpen: (log) => _showLogSheet(log),
                        ),
                      );
                    }),
                    const SizedBox(height: 6),
                    NuriButton(
                      label: 'Tambah catatan makan',
                      icon: Icons.add_a_photo_outlined,
                      onPressed: () =>
                          _openCamera(activeSubjectId, subjectLabel),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Perhitungan gizi mengacu pada TKPI 2017 Kemenkes RI.',
                      style: TextStyle(fontSize: 12, color: AppColors.muted),
                    ),
                    const NuriDisclaimer(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openCamera(String subjectId, String subjectLabel, {MealType? meal}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FoodCameraScreen(
          subjectId: subjectId,
          subjectLabel: subjectLabel,
          initialMeal: meal ?? _mealForNow(),
        ),
      ),
    );
  }

  MealType _mealForNow() {
    final hour = DateTime.now().hour;
    if (hour < 11) return MealType.breakfast;
    if (hour < 15) return MealType.lunch;
    if (hour < 18) return MealType.snack;
    return MealType.dinner;
  }

  Future<void> _deleteLog(FoodLog log) async {
    final confirmed = await showNuriConfirm(
      context: context,
      title: 'Hapus catatan?',
      message:
          'Catatan ${log.meal.label} beserta rincian makanannya akan dihapus.',
      confirmLabel: 'Hapus',
      danger: true,
    );
    if (!confirmed || !mounted) return;
    ref.read(appControllerProvider.notifier).deleteFoodLog(log.id);
    showNuriSnack(context, 'Catatan makan dihapus.');
  }

  void _showLogSheet(FoodLog log) {
    showNuriSheet(
      context: context,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${log.meal.label} • ${formatDateId(log.date, withYear: false)}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _deleteLog(log);
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.red,
                    size: 21,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ...log.items.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSubtle,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.restaurant_rounded,
                        size: 17,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${gramsLabel(item.grams)} • ${item.source.label}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      item.kcal == null ? '—' : '${item.kcal!.round()} kkal',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (log.note != null) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  log.note!,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                    height: 1.4,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Text(
                    log.totals.kcal == null
                        ? 'Total —'
                        : 'Total ${log.totals.kcal!.round()} kkal',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Pill(
                  label: log.tkpiVersion,
                  background: AppColors.surfaceSubtle,
                  foreground: AppColors.muted,
                  fontSize: 11,
                ),
              ],
            ),
            const SizedBox(height: 14),
            NuriButton(
              label: 'Tutup',
              variant: NuriButtonVariant.outlined,
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateNavigator extends StatelessWidget {
  const _DateNavigator({required this.selected, required this.onChanged});

  final DateTime selected;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final today = dateOnly(DateTime.now());
    final days = List.generate(
      7,
      (index) => today.subtract(Duration(days: 6 - index)),
    );
    return Column(
      children: [
        Row(
          children: [
            _ArrowButton(
              icon: Icons.chevron_left_rounded,
              onTap: () =>
                  onChanged(selected.subtract(const Duration(days: 1))),
            ),
            Expanded(
              child: Column(
                children: [
                  Text(
                    relativeDayLabel(selected),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    formatDateId(selected),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
            _ArrowButton(
              icon: Icons.chevron_right_rounded,
              onTap: selected.isBefore(today)
                  ? () => onChanged(selected.add(const Duration(days: 1)))
                  : null,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: days.map((date) {
            final active = dateOnly(date) == dateOnly(selected);
            final isToday = dateOnly(date) == today;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2.5),
                child: InkWell(
                  onTap: () => onChanged(date),
                  borderRadius: BorderRadius.circular(13),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    decoration: BoxDecoration(
                      color: active ? AppColors.primary : AppColors.surface,
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: active ? AppColors.primary : AppColors.line,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          formatDayShort(date),
                          style: TextStyle(
                            fontSize: 11,
                            color: active ? Colors.white70 : AppColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date.day.toString(),
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            fontFeatures: const [FontFeature.tabularFigures()],
                            color: active ? Colors.white : AppColors.text,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: isToday
                                ? (active ? AppColors.peach : AppColors.coral)
                                : Colors.transparent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(36),
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
        ),
        child: Icon(
          icon,
          size: 20,
          color: onTap == null ? AppColors.line : AppColors.text,
        ),
      ),
    );
  }
}

class _DiarySummary extends StatelessWidget {
  const _DiarySummary({
    required this.totals,
    required this.target,
    required this.targetLabel,
    required this.onAdd,
  });

  final NutritionTotals totals;
  final AkgTarget target;
  final String targetLabel;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final percent =
        (NutritionCalculator.percent(totals.kcal, target.energyKcal) ?? 0) /
        100;
    final status = NutritionCalculator.status(totals.kcal, target.energyKcal);
    final color = switch (status) {
      NutrientStatus.low => AppColors.amber,
      NutrientStatus.high => AppColors.coral,
      _ => AppColors.primary,
    };
    final label = switch (status) {
      NutrientStatus.low => 'Perlu dilengkapi',
      NutrientStatus.high => 'Melebihi anjuran',
      _ => 'Sesuai anjuran',
    };

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 78,
                height: 78,
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: percent.clamp(0.0, 1.0)),
                  duration: const Duration(milliseconds: 750),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) => Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 78,
                        height: 78,
                        child: CircularProgressIndicator(
                          value: value,
                          strokeWidth: 7.5,
                          backgroundColor: AppColors.surfaceSubtle,
                          valueColor: AlwaysStoppedAnimation(color),
                          strokeCap: StrokeCap.round,
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${(percent * 100).round()}%',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                          ),
                          const Text(
                            'AKG',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: totals.kcal == null
                                ? '—'
                                : totals.kcal!.round().toString(),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                              fontFeatures: [FontFeature.tabularFigures()],
                              color: AppColors.text,
                              height: 1,
                            ),
                          ),
                          TextSpan(
                            text: ' / ${target.energyKcal.round()} kkal',
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: color,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      targetLabel,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _NutrientBar(
                  label: 'Protein',
                  value: totals.proteinG,
                  target: target.proteinG,
                  color: AppColors.coral,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientBar(
                  label: 'Lemak',
                  value: totals.fatG,
                  target: target.fatG,
                  color: AppColors.amber,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientBar(
                  label: 'Karbo',
                  value: totals.carbG,
                  target: target.carbG,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _NutrientBar(
                  label: 'Besi',
                  value: totals.ironMg,
                  target: target.ironMg,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah makan'),
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 44)),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutrientBar extends StatelessWidget {
  const _NutrientBar({
    required this.label,
    required this.value,
    required this.target,
    required this.color,
  });

  final String label;
  final double? value;
  final double target;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ratio = ((value ?? 0) / target).clamp(0.0, 1.0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
        const SizedBox(height: 3),
        Text(
          value == null ? '—' : value!.toStringAsFixed(value! < 10 ? 1 : 0),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14.5,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 5,
            backgroundColor: AppColors.surfaceSubtle,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
        const SizedBox(height: 3),
        Text(
          '/ ${target.toStringAsFixed(target < 10 ? 1 : 0)}',
          style: const TextStyle(fontSize: 11, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _MealCard extends StatelessWidget {
  const _MealCard({
    required this.meal,
    required this.logs,
    required this.onAdd,
    required this.onDelete,
    required this.onOpen,
  });

  final MealType meal;
  final List<FoodLog> logs;
  final VoidCallback onAdd;
  final ValueChanged<FoodLog> onDelete;
  final ValueChanged<FoodLog> onOpen;

  IconData get _icon => switch (meal) {
    MealType.breakfast => Icons.free_breakfast_rounded,
    MealType.lunch => Icons.lunch_dining_rounded,
    MealType.dinner => Icons.dinner_dining_rounded,
    MealType.snack => Icons.cookie_rounded,
  };

  Color get _color => switch (meal) {
    MealType.breakfast => AppColors.amber,
    MealType.lunch => AppColors.primary,
    MealType.dinner => AppColors.blue,
    MealType.snack => AppColors.coral,
  };

  Color get _background => switch (meal) {
    MealType.breakfast => AppColors.amberSoft,
    MealType.lunch => AppColors.mint,
    MealType.dinner => AppColors.blueSoft,
    MealType.snack => AppColors.peachSoft,
  };

  @override
  Widget build(BuildContext context) {
    final kcal = logs.fold<double>(
      0,
      (sum, log) => sum + (log.totals.kcal ?? 0),
    );
    final hasKcal = logs.any((log) => log.totals.kcal != null);
    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: _background,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(_icon, size: 19, color: _color),
              ),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.label,
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      logs.isEmpty
                          ? 'Belum dicatat'
                          : '${logs.length} catatan • ${hasKcal ? '${kcal.round()} kkal' : '— kkal'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              if (logs.isEmpty)
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_rounded, size: 17),
                  label: const Text('Catat'),
                  style: TextButton.styleFrom(minimumSize: const Size(0, 38)),
                )
              else
                IconButton(
                  onPressed: onAdd,
                  icon: const Icon(
                    Icons.add_circle_outline_rounded,
                    size: 22,
                    color: AppColors.primary,
                  ),
                  tooltip: 'Tambah',
                ),
            ],
          ),
          if (logs.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 4),
              child: Divider(height: 1),
            ),
            ...logs.map(
              (log) => InkWell(
                onTap: () => onOpen(log),
                borderRadius: BorderRadius.circular(10),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.items.map((e) => e.name).join(', '),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.text,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (log.note != null)
                              Text(
                                log.note!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.muted,
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (log.totals.kcal != null)
                        Text(
                          '${log.totals.kcal!.round()} kkal',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.muted,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        iconSize: 18,
                        icon: const Icon(
                          Icons.more_vert_rounded,
                          color: AppColors.muted,
                        ),
                        onSelected: (value) {
                          if (value == 'delete') onDelete(log);
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(
                                  Icons.delete_outline_rounded,
                                  size: 18,
                                  color: AppColors.red,
                                ),
                                SizedBox(width: 8),
                                Text('Hapus catatan'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
