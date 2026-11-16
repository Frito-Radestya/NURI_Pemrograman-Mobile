import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'food_success_screen.dart';
import 'food_widgets.dart';

class PortionScreen extends ConsumerStatefulWidget {
  const PortionScreen({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
    required this.meal,
    required this.initialItems,
  });

  final String subjectId;
  final String subjectLabel;
  final MealType meal;
  final List<FoodLogItem> initialItems;

  @override
  ConsumerState<PortionScreen> createState() => _PortionScreenState();
}

class _PortionScreenState extends ConsumerState<PortionScreen> {
  late List<FoodLogItem> _items;
  late MealType _meal;
  final _note = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.initialItems);
    _meal = widget.meal;
  }

  @override
  void dispose() {
    _note.dispose();
    super.dispose();
  }

  void _updateGrams(int index, double grams) {
    setState(() => _items[index] = _items[index].copyWith(grams: grams));
  }

  void _save() {
    if (_items.isEmpty) {
      showNuriSnack(context, 'Belum ada makanan yang dipilih.', error: true);
      return;
    }
    setState(() => _saving = true);
    final log = ref
        .read(appControllerProvider.notifier)
        .addFoodLog(
          subjectId: widget.subjectId,
          meal: _meal,
          items: _items,
          note: _note.text.trim().isEmpty ? null : _note.text.trim(),
        );
    setState(() => _saving = false);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            FoodSuccessScreen(log: log, subjectLabel: widget.subjectLabel),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totals = NutritionTotals.fromItems(_items);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            NuriStepHeader(
              step: 2,
              total: 3,
              title: 'Atur porsi',
              subtitle: 'Perkirakan porsi yang benar-benar dimakan. Tidak perlu sempurna.',
              onClose: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Pill(
                          label: 'Untuk',
                          background: AppColors.mint,
                          foreground: AppColors.primaryDark,
                          fontSize: 11.5,
                        ),
                        const SizedBox(width: 7),
                        Text(
                          widget.subjectLabel,
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${_items.length} makanan',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_items.length, (index) {
                      final item = _items[index];
                      final kcal = item.kcal;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          '${item.kcalPer100?.round() ?? '—'} kkal/100 g • ${item.source.label}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.muted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  NuriNumberStepper(
                                    value: item.grams,
                                    min: 5,
                                    max: 500,
                                    step: 5,
                                    suffix: 'g',
                                    onChanged: (value) =>
                                        _updateGrams(index, value),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: (item.grams / 250).clamp(
                                          0.0,
                                          1.0,
                                        ),
                                        minHeight: 5,
                                        backgroundColor:
                                            AppColors.surfaceSubtle,
                                        valueColor:
                                            const AlwaysStoppedAnimation(
                                              AppColors.primary,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    kcal == null
                                        ? '— kkal'
                                        : '${kcal.round()} kkal',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFeatures: [
                                        FontFeature.tabularFigures(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    AppCard(
                      padding: const EdgeInsets.all(14),
                      color: AppColors.mint,
                      borderColor: AppColors.mintStrong,
                      child: Row(
                        children: [
                          const Icon(
                            Icons.local_fire_department_rounded,
                            color: AppColors.coral,
                            size: 22,
                          ),
                          const SizedBox(width: 9),
                          const Expanded(
                            child: Text(
                              'Total perkiraan',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            totals.kcal == null
                                ? '— kkal'
                                : '${totals.kcal!.round()} kkal',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const NuriFormLabel(text: 'Waktu makan'),
                    FoodMealSelector(
                      value: _meal,
                      onChanged: (value) => setState(() => _meal = value),
                    ),
                    const SizedBox(height: 14),
                    NuriTextField(
                      label: 'Catatan (opsional)',
                      controller: _note,
                      hint: 'Contoh: habis, ditambah sayur',
                      maxLines: 2,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 12),
                    const InfoBanner(
                      title: 'Nilai gizi adalah perkiraan',
                      body: 'Data TKPI 2017 dapat berbeda dengan masakan rumah. Gunakan sebagai panduan, bukan angka mutlak.',
                      icon: Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 14),
                    NuriButton(
                      label: 'Simpan catatan makan',
                      icon: Icons.check_rounded,
                      loading: _saving,
                      onPressed: _save,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
