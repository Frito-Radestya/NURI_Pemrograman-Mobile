import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/food_catalog.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'diary_screen.dart';

class FoodCameraScreen extends StatefulWidget {
  const FoodCameraScreen({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
    required this.initialMeal,
  });

  final String subjectId;
  final String subjectLabel;
  final MealType initialMeal;

  @override
  State<FoodCameraScreen> createState() => _FoodCameraScreenState();
}

class _FoodCameraScreenState extends State<FoodCameraScreen>
    with SingleTickerProviderStateMixin {
  late MealType _meal;
  late final AnimationController _scanController;
  bool _flashOn = false;
  bool _capturing = false;

  @override
  void initState() {
    super.initState();
    _meal = widget.initialMeal;
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _capture() async {
    if (_capturing) return;
    setState(() => _capturing = true);
    await Future<void>.delayed(const Duration(milliseconds: 320));
    if (!mounted) return;
    final items = _demoDetectedFoods();
    setState(() => _capturing = false);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => DetectionResultScreen(
          subjectId: widget.subjectId,
          subjectLabel: widget.subjectLabel,
          meal: _meal,
          initialItems: items,
        ),
      ),
    );
  }

  List<DetectedFood> _demoDetectedFoods() {
    final catalog = FoodCatalog.instance;
    DetectedFood detected(
      String id,
      String displayName,
      double grams,
      double confidence,
    ) {
      final item = catalog.byId(id);
      return DetectedFood(
        food:
            item ??
            FoodCatalogItem(
              id: id,
              name: displayName,
              originalName: displayName,
              category: 'Lainnya',
              source: 'TKPI 2017',
              energyKcal: 100,
              proteinG: 5,
              fatG: 3,
              carbG: 12,
              ironMg: 1,
              zincMg: 0.5,
            ),
        displayName: displayName,
        grams: grams,
        confidence: confidence,
      );
    }

    return [
      detected('tkpi_0909', 'Ikan Kembung Suwir', 35, 0.94),
      detected('tkpi_1039', 'Telur Ayam Rebus', 55, 0.98),
      detected('tkpi_0023', 'Nasi Putih Tim Lembek', 75, 0.86),
      detected('composite_buncis_wortel', 'Sayur Buncis & Wortel', 30, 0.91),
    ];
  }

  void _openManual() {
    Navigator.of(context)
        .push<List<FoodLogItem>>(
          MaterialPageRoute(builder: (_) => const ManualFoodSearchScreen()),
        )
        .then((items) {
          if (!mounted || items == null || items.isEmpty) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PortionScreen(
                subjectId: widget.subjectId,
                subjectLabel: widget.subjectLabel,
                meal: _meal,
                initialItems: items,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/images/food_plate.jpg',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) =>
                  Container(color: AppColors.primaryDeep),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.black.withValues(alpha: 0.16),
                    Colors.black.withValues(alpha: 0.82),
                  ],
                  stops: const [0, 0.45, 1],
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
                    child: Row(
                      children: [
                        _CameraIconButton(
                          icon: Icons.close_rounded,
                          onTap: () => Navigator.of(context).pop(),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Catat makan',
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        _CameraIconButton(
                          icon: _flashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          onTap: () => setState(() => _flashOn = !_flashOn),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Pill(
                          label: 'Untuk ${widget.subjectLabel}',
                          icon: Icons.person_outline_rounded,
                          background: Colors.white.withValues(alpha: 0.16),
                          foreground: Colors.white,
                          fontSize: 11.5,
                        ),
                        const SizedBox(width: 8),
                        Pill(
                          label: 'Simulasi kamera',
                          icon: Icons.camera_alt_outlined,
                          background: AppColors.peach.withValues(alpha: 0.92),
                          foreground: AppColors.primaryDeep,
                          fontSize: 11.5,
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 18,
                      ),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: 0.95,
                          child: LayoutBuilder(
                            builder: (context, constraints) => Stack(
                              children: [
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(28),
                                      border: Border.all(
                                        color: Colors.white.withValues(
                                          alpha: 0.34,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned.fill(
                                  child: CustomPaint(
                                    painter: _ViewfinderPainter(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                    ),
                                  ),
                                ),
                                AnimatedBuilder(
                                  animation: _scanController,
                                  builder: (context, child) => Positioned(
                                    left: 18,
                                    right: 18,
                                    top:
                                        22 +
                                        (constraints.maxHeight - 44) *
                                            _scanController.value,
                                    child: Container(
                                      height: 1.6,
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Colors.transparent,
                                            AppColors.peach.withValues(
                                              alpha: 0.9,
                                            ),
                                            Colors.transparent,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 60,
                                        height: 60,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withValues(
                                            alpha: 0.24,
                                          ),
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: Colors.white.withValues(
                                              alpha: 0.3,
                                            ),
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.restaurant_rounded,
                                          color: Colors.white,
                                          size: 27,
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        _capturing
                                            ? 'Memotret…'
                                            : 'Arahkan ke piring',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_capturing)
                                  Positioned.fill(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(
                                          alpha: 0.32,
                                        ),
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.48),
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(28),
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _MealSelector(
                          value: _meal,
                          onChanged: (value) => setState(() => _meal = value),
                          dark: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            _CameraIconButton(
                              icon: Icons.photo_library_outlined,
                              onTap: _openManual,
                            ),
                            const Spacer(),
                            NuriTapScale(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _capture();
                              },
                              child: Container(
                                width: 72,
                                height: 72,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 3,
                                  ),
                                ),
                                padding: const EdgeInsets.all(5),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: _capturing
                                        ? AppColors.muted
                                        : Colors.white,
                                    shape: BoxShape.circle,
                                  ),
                                  child: _capturing
                                      ? const Padding(
                                          padding: EdgeInsets.all(18),
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                            ),
                            const Spacer(),
                            _CameraIconButton(
                              icon: Icons.flip_camera_ios_outlined,
                              onTap: () => showNuriSnack(
                                context,
                                'Kamera belakang digunakan untuk demo.',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _openManual,
                          icon: const Icon(
                            Icons.search_rounded,
                            size: 17,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Cari makanan manual',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                            ),
                          ),
                        ),
                        const Text(
                          'Deteksi foto disimulasikan untuk demo. Porsi tetap dapat diubah.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
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

class _CameraIconButton extends StatelessWidget {
  const _CameraIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.28),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ViewfinderPainter extends CustomPainter {
  _ViewfinderPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    const length = 28.0;
    const radius = 12.0;
    final path = Path()
      ..moveTo(0, length + radius)
      ..lineTo(0, radius)
      ..quadraticBezierTo(0, 0, radius, 0)
      ..lineTo(length + radius, 0)
      ..moveTo(size.width - length - radius, 0)
      ..lineTo(size.width - radius, 0)
      ..quadraticBezierTo(size.width, 0, size.width, radius)
      ..lineTo(size.width, length + radius)
      ..moveTo(size.width, size.height - length - radius)
      ..lineTo(size.width, size.height - radius)
      ..quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      )
      ..lineTo(size.width - length - radius, size.height)
      ..moveTo(length + radius, size.height)
      ..lineTo(radius, size.height)
      ..quadraticBezierTo(0, size.height, 0, size.height - radius)
      ..lineTo(0, size.height - length - radius);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _ViewfinderPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _MealSelector extends StatelessWidget {
  const _MealSelector({
    required this.value,
    required this.onChanged,
    this.dark = false,
  });

  final MealType value;
  final ValueChanged<MealType> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: MealType.values.map((meal) {
        final selected = meal == value;
        return GestureDetector(
          onTap: () => onChanged(meal),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? (dark ? Colors.white : AppColors.primary)
                  : (dark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.mint),
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: selected
                    ? (dark ? Colors.white : AppColors.primary)
                    : (dark
                          ? Colors.white.withValues(alpha: 0.16)
                          : AppColors.line),
              ),
            ),
            child: Text(
              meal.label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: selected
                    ? (dark ? AppColors.primaryDeep : Colors.white)
                    : (dark ? Colors.white70 : AppColors.muted),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class DetectedFood {
  DetectedFood({
    required this.food,
    required this.displayName,
    required this.grams,
    required this.confidence,
    this.selected = true,
  });

  final FoodCatalogItem food;
  final String displayName;
  final double grams;
  final double confidence;
  final bool selected;

  FoodLogItem toLogItem() => food.toLogItem(
    grams: grams,
    foodSource: FoodSource.ai,
    confidence: confidence,
  );

  DetectedFood copyWith({double? grams, bool? selected}) => DetectedFood(
    food: food,
    displayName: displayName,
    grams: grams ?? this.grams,
    confidence: confidence,
    selected: selected ?? this.selected,
  );
}

class DetectionResultScreen extends StatefulWidget {
  const DetectionResultScreen({
    super.key,
    required this.subjectId,
    required this.subjectLabel,
    required this.meal,
    required this.initialItems,
  });

  final String subjectId;
  final String subjectLabel;
  final MealType meal;
  final List<DetectedFood> initialItems;

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
                      borderRadius: BorderRadius.circular(22),
                      child: Stack(
                        children: [
                          Image.asset(
                            'assets/images/food_plate.jpg',
                            height: 160,
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
                                    Colors.transparent,
                                    Colors.black.withValues(alpha: 0.5),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            left: 12,
                            bottom: 12,
                            child: Pill(
                              label: '${_items.length} makanan terdeteksi',
                              icon: Icons.restaurant_menu_rounded,
                              background: Colors.white.withValues(alpha: 0.94),
                              foreground: AppColors.primaryDeep,
                              fontSize: 11.5,
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
                    _MealSelector(
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

class ManualFoodSearchScreen extends StatefulWidget {
  const ManualFoodSearchScreen({super.key});

  @override
  State<ManualFoodSearchScreen> createState() => _ManualFoodSearchScreenState();
}

class _ManualFoodSearchScreenState extends State<ManualFoodSearchScreen> {
  final _search = TextEditingController();
  String _category = 'Semua';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FoodCatalogItem> _results() {
    final catalog = FoodCatalog.instance;
    final query = _search.text.trim().toLowerCase();
    return catalog.foods.where((food) {
      final matchesCategory =
          _category == 'Semua' || food.category == _category;
      final matchesQuery =
          query.isEmpty ||
          food.name.toLowerCase().contains(query) ||
          food.originalName.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _pick(FoodCatalogItem food) async {
    final grams = await showNuriSheet<double>(
      context: context,
      builder: (sheetContext) {
        var value = 100.0;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                Text(
                  '${food.energyKcal?.round() ?? '—'} kkal • ${food.proteinG?.toStringAsFixed(1) ?? '—'} g protein per 100 g',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Porsi',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    NuriNumberStepper(
                      value: value,
                      min: 5,
                      max: 500,
                      step: 5,
                      suffix: 'g',
                      onChanged: (next) => setSheetState(() => value = next),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    '${((food.energyKcal ?? 0) * value / 100).round()} kkal • '
                    '${((food.proteinG ?? 0) * value / 100).toStringAsFixed(1)} g protein',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                NuriButton(
                  label: 'Tambahkan',
                  icon: Icons.add_rounded,
                  onPressed: () => Navigator.of(sheetContext).pop(value),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sumber: TKPI 2017 • Kemenkes RI',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || grams == null) return;
    Navigator.of(context)
        .pop([food.toLogItem(grams: grams, foodSource: FoodSource.manual)]);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = FoodCatalog.instance;
    final results = _results();
    final categories = ['Semua', ...catalog.categories];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Cari makanan',
              subtitle: '${catalog.foods.length} item TKPI 2017',
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NuriTextField(
                label: 'Nama makanan',
                controller: _search,
                hint: 'Cari nasi, telur, ikan…',
                prefixIcon: Icons.search_rounded,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: categories.map((category) {
                  final selected = category == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = category),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.text,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? const EmptyState(
                      title: 'Makanan tidak ditemukan',
                      body: 'Coba kata kunci lain atau pilih kategori berbeda.',
                      icon: Icons.search_off_rounded,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: results.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final food = results[index];
                        return AppCard(
                          padding: const EdgeInsets.all(12),
                          onTap: () => _pick(food),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.restaurant_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${food.energyKcal?.round() ?? '—'} kkal • ${food.proteinG?.toStringAsFixed(1) ?? '—'} g protein / 100 g',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Pill(
                                label: '100 g',
                                background: AppColors.surfaceSubtle,
                                foreground: AppColors.muted,
                                fontSize: 11.5,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.add_circle_outline_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

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
                    _MealSelector(
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

class FoodSuccessScreen extends StatelessWidget {
  const FoodSuccessScreen({
    super.key,
    required this.log,
    required this.subjectLabel,
  });

  final FoodLog log;
  final String subjectLabel;

  @override
  Widget build(BuildContext context) {
    final totals = log.totals;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            children: [
              const Spacer(),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.6, end: 1),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.mint,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.mintStrong, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 44,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Catatan makan tersimpan',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 6),
              Text(
                'Terima kasih sudah mencatat untuk $subjectLabel. Catatan kecil membantu melihat pola gizi.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12.5,
                  height: 1.5,
                  color: AppColors.muted,
                ),
              ),
              const SizedBox(height: 20),
              AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _SuccessMetric(
                            label: 'Energi',
                            value: totals.kcal == null
                                ? '—'
                                : '${totals.kcal!.round()}',
                            unit: 'kkal',
                          ),
                        ),
                        Expanded(
                          child: _SuccessMetric(
                            label: 'Protein',
                            value: totals.proteinG == null
                                ? '—'
                                : totals.proteinG!.toStringAsFixed(1),
                            unit: 'g',
                          ),
                        ),
                        Expanded(
                          child: _SuccessMetric(
                            label: 'Makanan',
                            value: '${log.items.length}',
                            unit: 'item',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(
                          Icons.restaurant_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          log.meal.label,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            log.items.map((e) => e.name).join(', '),
                            maxLines: 1,
                            textAlign: TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const InfoBanner(
                title: 'Skrining awal, bukan diagnosis',
                body: 'Nilai gizi dihitung dari data TKPI 2017. Diskusikan dengan kader atau ahli gizi bila ada kekhawatiran.',
                icon: Icons.verified_user_outlined,
              ),
              const Spacer(),
              NuriButton(
                label: 'Lihat catatan hari ini',
                icon: Icons.calendar_today_rounded,
                onPressed: () => Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) => DiaryScreen(
                      subjectId: log.subjectId,
                      subjectLabel: subjectLabel,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              NuriButton(
                label: 'Selesai',
                variant: NuriButtonVariant.outlined,
                onPressed: () =>
                    Navigator.of(context).popUntil((route) => route.isFirst),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SuccessMetric extends StatelessWidget {
  const _SuccessMetric({
    required this.label,
    required this.value,
    required this.unit,
  });

  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
        const SizedBox(height: 3),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: value,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: AppColors.text,
                ),
              ),
              TextSpan(
                text: ' $unit',
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
