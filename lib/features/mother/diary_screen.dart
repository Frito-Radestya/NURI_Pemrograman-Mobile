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
import 'diary_date_navigator.dart';
import 'diary_meal_card.dart';
import 'diary_summary.dart';
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
                    DiaryDateNavigator(
                      selected: _selectedDate,
                      onChanged: (value) {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedDate = value);
                      },
                    ),
                    const SizedBox(height: 14),
                    DiarySummary(
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
                        child: DiaryMealCard(
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
