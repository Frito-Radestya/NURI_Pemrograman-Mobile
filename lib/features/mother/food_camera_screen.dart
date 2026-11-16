import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/food_catalog.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'food_detection_screen.dart';
import 'food_manual_search_screen.dart';
import 'food_models.dart';
import 'food_portion_screen.dart';
import 'food_camera_widgets.dart';
import 'food_widgets.dart';

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
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _pickImage(ImageSource source) async {
    if (_capturing) return;
    setState(() => _capturing = true);
    try {
      final photo = await _picker.pickImage(
        source: source,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 85,
      );
      if (!mounted) return;
      if (photo != null) {
        final items = _demoDetectedFoods();
        setState(() => _capturing = false);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => DetectionResultScreen(
              subjectId: widget.subjectId,
              subjectLabel: widget.subjectLabel,
              meal: _meal,
              initialItems: items,
              capturedImagePath: photo.path,
            ),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('ImagePicker error: $e');
    }
    if (!mounted) return;
    setState(() => _capturing = false);
  }

  Future<void> _captureSimulation() async {
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
                        CameraIconButton(
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
                        CameraIconButton(
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
                        GestureDetector(
                          onTap: _captureSimulation,
                          child: Pill(
                            label: 'Kamera Aktif • Tap Demo',
                            icon: Icons.camera_alt_rounded,
                            background: AppColors.secondaryContainer,
                            foreground: AppColors.onSecondaryContainer,
                            fontSize: 11.5,
                          ),
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
                                    painter: ViewfinderPainter(
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
                        FoodMealSelector(
                          value: _meal,
                          onChanged: (value) => setState(() => _meal = value),
                          dark: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CameraIconButton(
                              icon: Icons.photo_library_outlined,
                              onTap: () => _pickImage(ImageSource.gallery),
                            ),
                            const Spacer(),
                            NuriTapScale(
                              onTap: () {
                                HapticFeedback.lightImpact();
                                _pickImage(ImageSource.camera);
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
                            CameraIconButton(
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
