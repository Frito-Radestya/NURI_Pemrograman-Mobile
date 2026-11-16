import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/food_catalog.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'food_manual_search_screen.dart';
import 'food_models.dart';
import 'food_portion_screen.dart';
import 'food_widgets.dart';

class DetectionResultScreen extends StatefulWidget {
  const DetectionResultScreen({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
    required this.meal,
    required this.initialItems,
    this.capturedImagePath,
  });

  final String subjectId;
  final String subjectLabel;
  final MealType meal;
  final List<DetectedFood> initialItems;
  final String? capturedImagePath;

  @override
  State<DetectionResultScreen> createState() => _DetectionResultScreenState();
}

class _DetectionResultScreenState extends State<DetectionResultScreen> {
  late List<DetectedFood> _items;
  late MealType _meal;

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.initialItems);
    _meal = widget.meal;
  }

  void _update(int index, DetectedFood value) {
    setState(() => _items[index] = value);
  }

  Future<void> _addManual() async {
    final items = await Navigator.of(context).push<List<FoodLogItem>>(
      MaterialPageRoute(builder: (_) => const ManualFoodSearchScreen()),
    );
    if (!mounted || items == null || items.isEmpty) return;
    setState(() {
      for (final item in items) {
        _items.add(
          DetectedFood(
            food: FoodCatalogItem(
              id: item.foodId,
              name: item.name,
              originalName: item.name,
              category: 'Manual',
              source: 'TKPI 2017',
              energyKcal: item.kcalPer100,
              proteinG: item.proteinPer100,
              fatG: item.fatPer100,
              carbG: item.carbPer100,
              ironMg: item.ironPer100,
              zincMg: item.zincPer100,
            ),
            displayName: item.name,
            grams: item.grams,
            confidence: 1,
          ),
        );
      }
    });
  }

  void _next() {
    final selected = _items.where((item) => item.selected).toList();
    if (selected.isEmpty) {
      showNuriSnack(context, 'Pilih minimal satu makanan.', error: true);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PortionScreen(
          subjectId: widget.subjectId,
          subjectLabel: widget.subjectLabel,
          meal: _meal,
          initialItems: selected.map((item) => item.toLogItem()).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            NuriStepHeader(
              step: 1,
              total: 3,
              title: 'Hasil deteksi',
              subtitle:
                  'Periksa makanan yang terdeteksi, lalu sesuaikan porsinya.',
              onClose: () =>
                  Navigator.of(context).popUntil((route) => route.isFirst),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Stack(
                        children: [
                          if (widget.capturedImagePath != null &&
                              File(widget.capturedImagePath!).existsSync())
                            Image.file(
                              File(widget.capturedImagePath!),
                              height: 190,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          else
                            Image.asset(
                              'assets/images/food_plate.jpg',
                              height: 190,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          Positioned.fill(
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.2),
                                    Colors.black.withValues(alpha: 0.55),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Retake button
                          Positioned(
                            top: 12,
                            right: 12,
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.65),
                                  borderRadius: BorderRadius.circular(
                                    AppRadius.pill,
                                  ),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.cached_rounded,
                                      size: 14,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Foto Ulang',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Smart Detection Pin 1 (Nasi Putih)
                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 9,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.92),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x30000000),
                                    blurRadius: 8,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 6,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Nasi Tim Lembek (75g)',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          // Smart Detection Pin 2 (Protein Hewani Highlight)
                          Positioned(
                            top: 55,
                            right: 14,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                gradient: AppGradients.button,
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                                border: Border.all(
                                  color: AppColors.secondaryFixed,
                                  width: 1.5,
                                ),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x400D631B),
                                    blurRadius: 10,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.stars_rounded,
                                    size: 14,
                                    color: AppColors.secondaryFixed,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    '★ Ikan & Telur (Prohe Unggulan)',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.pill,
                                ),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    'Piring Terdeteksi Sempurna (98.4%)',
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    const InfoBanner(
                      title: 'Deteksi adalah perkiraan',
                      body: 'Periksa nama makanan dan porsi. Nilai gizi mengacu pada data TKPI 2017.',
                      icon: Icons.info_outline_rounded,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Makanan terdeteksi',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    ...List.generate(_items.length, (index) {
                      final item = _items[index];
                      final confidenceColor = item.confidence >= 0.9
                          ? AppColors.primary
                          : item.confidence >= 0.8
                          ? AppColors.amber
                          : AppColors.red;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: AppCard(
                          padding: const EdgeInsets.all(12),
                          color: item.selected
                              ? AppColors.surface
                              : AppColors.background,
                          child: Row(
                            children: [
                              InkWell(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  _update(
                                    index,
                                    item.copyWith(selected: !item.selected),
                                  );
                                },
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.all(4),
                                  child: Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: item.selected
                                          ? AppColors.primary
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: item.selected
                                            ? AppColors.primary
                                            : AppColors.muted,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: item.selected
                                        ? const Icon(
                                            Icons.check_rounded,
                                            size: 15,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      item.displayName,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Row(
                                      children: [
                                        Container(
                                          width: 6,
                                          height: 6,
                                          decoration: BoxDecoration(
                                            color: confidenceColor,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${(item.confidence * 100).round()}%',
                                          style: TextStyle(
                                            fontSize: 11.5,
                                            fontWeight: FontWeight.w600,
                                            color: confidenceColor,
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Flexible(
                                          child: Text(
                                            '${item.food.energyKcal?.round() ?? '—'} kkal/100g',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 11.5,
                                              color: AppColors.muted,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 6),
                              NuriNumberStepper(
                                value: item.grams,
                                min: 5,
                                max: 300,
                                step: 5,
                                suffix: 'g',
                                onChanged: (value) =>
                                    _update(index, item.copyWith(grams: value)),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const SizedBox(height: 4),
                    NuriButton(
                      label: 'Tambah makanan manual',
                      icon: Icons.add_rounded,
                      variant: NuriButtonVariant.outlined,
                      height: 46,
                      onPressed: _addManual,
                    ),
                    const SizedBox(height: 14),
                    const NuriFormLabel(text: 'Waktu makan'),
                    FoodMealSelector(
                      value: _meal,
                      onChanged: (value) => setState(() => _meal = value),
                    ),
                    const SizedBox(height: 16),
                    NuriButton(
                      label: 'Atur porsi & simpan',
                      icon: Icons.arrow_forward_rounded,
                      onPressed: _next,
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
