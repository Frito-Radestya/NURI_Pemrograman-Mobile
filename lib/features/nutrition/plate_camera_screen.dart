import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/section.dart';
import '../../domain/models/child.dart';
import '../../state/app_state.dart';

/// Layar kamera pengukuran piring makan (UI kamera gelap penuh).
class PlateCameraScreen extends StatefulWidget {
  const PlateCameraScreen({super.key});

  @override
  State<PlateCameraScreen> createState() => _PlateCameraScreenState();
}

class _PlateCameraScreenState extends State<PlateCameraScreen> {
  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    return Scaffold(
      backgroundColor: AppColors.cameraScrim,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimens.screenPadding,
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),

              // ---- Baris atas -------------------------------------------------
              Row(
                children: [
                  NuriSoftButton(
                    icon: Icons.close_rounded,
                    background: Colors.white.withValues(alpha: 0.24),
                    color: Colors.white,
                    onPressed: () =>
                        context.canPop() ? context.pop() : context.go('/home'),
                  ),
                  const Spacer(),
                  Text(
                    'KAMERA PENGUKURAN POSTUR',
                    style: AppText.label.copyWith(
                      color: Colors.white,
                      letterSpacing: 1,
                    ),
                  ),
                  const Spacer(),
                  const Icon(Icons.flash_on_rounded, color: Colors.white),
                ],
              ),

              const SizedBox(height: 14),

              // ---- Pil hijau pemilih piring -----------------------------------
              _BrandPill(
                label:
                    'Piring Makan ${child?.nickname ?? 'Si Kecil'} • Makan Siang',
                onTap: () {},
              ),

              const SizedBox(height: 14),

              // ---- Pratinjau kamera -------------------------------------------
              Expanded(
                child: NuriPhoto(
                  url: DemoImages.plateMeal,
                  radius: AppDimens.radiusXl,
                  overlay: Stack(
                    children: [
                      Center(
                        child: FractionallySizedBox(
                          widthFactor: 0.72,
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CustomPaint(
                              painter: _DashedCirclePainter(
                                color: Colors.white.withValues(alpha: 0.9),
                                dashLength: 14,
                                gapLength: 10,
                                strokeWidth: 2.4,
                              ),
                              child: const SizedBox.expand(),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _GuidePill(
                            label: 'Sudut Tegak Lurus & Cahaya Pas',
                          ),
                        ),
                      ),
                      const Positioned(
                        bottom: 16,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: _DarkPill(
                            label:
                                'Posisikan seluruh mangkuk di dalam lingkaran',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ---- Kapsul aksi cepat ------------------------------------------
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _Capsule(
                      label: 'Analisis Gizi',
                      color: Colors.white.withValues(alpha: 0.14),
                      onTap: () => context.go('/meal-review'),
                    ),
                    const SizedBox(width: 8),
                    _Capsule(
                      label: 'Riwayat Makan',
                      color: Colors.white.withValues(alpha: 0.10),
                      onTap: () => context.go('/meal-history'),
                    ),
                    const SizedBox(width: 8),
                    _Capsule(
                      label: '90° Tegak',
                      icon: Icons.rotate_90_degrees_ccw_rounded,
                      color: Colors.white.withValues(alpha: 0.14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // ---- Panel tips -------------------------------------------------
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.cameraSheet,
                  borderRadius: BorderRadius.circular(AppDimens.radiusLg),
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Tip(
                      icon: Icons.vertical_align_bottom_rounded,
                      label: 'Foto Tegak\ndari Atas',
                    ),
                    _Tip(
                      icon: Icons.restaurant_rounded,
                      label: 'Lauk Jangan\nTertutup',
                    ),
                    _Tip(
                      icon: Icons.wb_sunny_outlined,
                      label: 'Cahaya\nCukup Terang',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              const NoteRow(
                icon: Icons.auto_awesome,
                text:
                    'AI NURI menghitung protein hewani ganda, zat besi, & kalori dalam 3 detik.',
                color: Colors.white70,
              ),

              const SizedBox(height: 14),

              // ---- Kontrol bawah ----------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _RoundButton(
                    icon: Icons.photo_library_outlined,
                    onTap: () => context.go('/meal-review'),
                  ),
                  _ShutterButton(
                    onTap: () => context.go('/meal-review'),
                  ),
                  _RoundButton(
                    icon: Icons.help_outline_rounded,
                    onTap: () => context.go('/meal-review'),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.lock_outline_rounded,
                    size: 14,
                    color: Colors.white70,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Privasi terlindungi • Foto hanya digunakan untuk kalkulasi asupan Si Kecil',
                      textAlign: TextAlign.center,
                      style: AppText.caption.copyWith(color: Colors.white70),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Bagian lokal
// ---------------------------------------------------------------------------

class _BrandPill extends StatelessWidget {
  const _BrandPill({required this.label, this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.brand,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 9),
                Text(
                  label,
                  style: AppText.bodyStrong.copyWith(
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Colors.white,
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GuidePill extends StatelessWidget {
  const _GuidePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.brand.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppText.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkPill extends StatelessWidget {
  const _DarkPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.center,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.center_focus_strong_rounded,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 7),
            Text(
              label,
              style: AppText.bodySm.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Capsule extends StatelessWidget {
  const _Capsule({
    required this.label,
    required this.color,
    this.icon,
    this.onTap,
  });

  final String label;
  final Color color;
  final IconData? icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: Colors.white),
                const SizedBox(width: 7),
              ],
              Text(
                label,
                style: AppText.bodySm.copyWith(
                  color: Colors.white,
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

class _Tip extends StatelessWidget {
  const _Tip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(height: 8),
          Text(
            label,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(color: Colors.white, height: 1.3),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  const _RoundButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 52,
          height: 52,
          child: Icon(icon, color: Colors.white, size: 24),
        ),
      ),
    );
  }
}

class _ShutterButton extends StatelessWidget {
  const _ShutterButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 78,
        height: 78,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.5),
            width: 4,
          ),
        ),
        child: Center(
          child: Container(
            width: 58,
            height: 58,
            decoration: const BoxDecoration(
              color: AppColors.brand,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.camera_alt_rounded,
              color: Colors.white,
              size: 26,
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  _DashedCirclePainter({
    required this.color,
    this.dashLength = 14,
    this.gapLength = 10,
    this.strokeWidth = 2.4,
  });

  final Color color;
  final double dashLength;
  final double gapLength;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final inset = strokeWidth / 2 + 2;
    final rect = Rect.fromLTWH(
      inset,
      inset,
      size.width - inset * 2,
      size.height - inset * 2,
    );
    final path = Path()..addOval(rect);

    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final next =
            (distance + dashLength).clamp(0.0, metric.length).toDouble();
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance = next + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedCirclePainter old) =>
      old.color != color ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength ||
      old.strokeWidth != strokeWidth;
}
