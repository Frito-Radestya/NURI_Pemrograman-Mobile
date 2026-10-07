import 'dart:async';

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
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';
import '../../domain/models/child.dart';
import '../../state/app_state.dart';

/// Layar proses analisis gizi piring makan.
class MealAnalyzingScreen extends StatefulWidget {
  const MealAnalyzingScreen({super.key});

  @override
  State<MealAnalyzingScreen> createState() => _MealAnalyzingScreenState();
}

class _MealAnalyzingScreenState extends State<MealAnalyzingScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 3), () {
      if (mounted) context.go('/meal-result');
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final NuriAppState state = NuriScope.of(context);
    final Child? child = state.selectedChild;
    return NuriScaffold(
      background: AppColors.canvas,
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/home'),
        titleWidget: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'NURI CARE',
              style: AppText.caption.copyWith(letterSpacing: 1.2),
            ),
            Text('Analisis Piring Makan', style: AppText.h3.copyWith(fontSize: 17)),
          ],
        ),
        actions: const [
          NuriSoftButton(icon: Icons.info_outline_rounded, size: 40),
          SizedBox(width: 8),
          NuriAvatar(initials: 'B', size: 40),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 6),
            NuriCard(
              child: Row(
                children: [
                  NuriAvatar(initials: child?.initial ?? 'A', size: 46),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          child?.nickname ?? 'Si Kecil',
                          style: AppText.title.copyWith(fontSize: 15),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          child == null
                              ? 'Data anak belum tersedia'
                              : '${child.ageLabelAt(state.today)} • Makan Siang',
                          style: AppText.caption,
                        ),
                      ],
                    ),
                  ),
                  Tag(text: child?.posyanduName ?? 'Posyandu Standar'),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // ---- Komposisi melingkar ----------------------------------------
            Center(
              child: SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipOval(
                      child: NuriPhoto(
                        url: DemoImages.plateMeal,
                        width: 198,
                        height: 198,
                        radius: 99,
                      ),
                    ),
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _DashedRingPainter(
                          color: AppColors.brand,
                          dashLength: 13,
                          gapLength: 9,
                          strokeWidth: 2.6,
                        ),
                        child: const SizedBox.expand(),
                      ),
                    ),
                    const Positioned(
                      top: 4,
                      right: 0,
                      child: PhotoTag(
                        label: 'Protein Hewani',
                        trailing: _Dot(color: Color(0xFFD9743A)),
                      ),
                    ),
                    const Positioned(
                      bottom: 4,
                      left: 0,
                      child: PhotoTag(
                        label: 'Zat Besi Alami',
                        trailing: _Dot(color: AppColors.brand),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 22),
            const Center(
              child: PillLabel(text: 'Analisis Cerdas NURI', leadingDot: true),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sedang mengenali kandungan gizi Fatih…',
              textAlign: TextAlign.center,
              style: AppText.h1,
            ),
            const SizedBox(height: 10),
            const Text(
              'Menyelaraskan komposisi protein hewani ganda, takaran zat besi, '
              'dan standar Isi Piringku balita 18 bulan.',
              textAlign: TextAlign.center,
              style: AppText.body,
            ),
            const SizedBox(height: 22),

            // ---- Daftar periksa ---------------------------------------------
            NuriCard(
              child: Column(
                children: const [
                  _CheckRow(
                    leading: Icon(
                      Icons.check_circle_rounded,
                      color: AppColors.statusNormal,
                      size: 24,
                    ),
                    title: 'Komponen bahan piring',
                    subtitle:
                        'Nasi pulen, ikan kembung suwir, telur, wortel, br…',
                    trailing: StatusChip(
                      text: 'Terdeteksi',
                      color: AppColors.pastelGreen,
                      onColor: AppColors.brandText,
                    ),
                  ),
                  _RowDivider(),
                  _CheckRow(
                    leading: IconBadge(
                      icon: Icons.egg_alt_outlined,
                      color: AppColors.pastelPeach,
                      iconColor: Color(0xFFD9743A),
                      size: 40,
                      radius: 12,
                    ),
                    title: 'Estimasi protein ganda',
                    subtitle: 'Kombinasi ikan laut segar & telur ayam utuh',
                    trailing: _StatusText(
                      text: '● Menghitung…',
                      color: Color(0xFFD9743A),
                    ),
                  ),
                  _RowDivider(),
                  _CheckRow(
                    leading: IconBadge(
                      icon: Icons.show_chart_rounded,
                      color: AppColors.surfaceSoft,
                      iconColor: AppColors.inkSoft,
                      size: 40,
                      radius: 12,
                    ),
                    title: 'Densitas energi & mikronutrien',
                    subtitle: 'Penilaian kecukupan kalori harian Al–Fatih',
                    trailing: _StatusText(
                      text: 'Menunggu',
                      color: AppColors.inkFaint,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            NoteBox(
              background: AppColors.surfaceSand,
              icon: Icons.lightbulb_outline,
              child: RichText(
                text: TextSpan(
                  style: AppText.bodySm,
                  children: [
                    TextSpan(
                      text: 'TAHUAKAH BUNDA?\n',
                      style: AppText.bodyStrong.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'Satu porsi ikan kembung lokal menyediakan asam lemak '
                          'Omega–3 dan DHA setara dengan ikan salmon impor, sangat '
                          'efektif mendukung akselerasi kecerdasan dan mencegah '
                          'risiko stunting balita.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: TextButton.icon(
                onPressed: () => context.go('/meal-review'),
                icon: const Icon(
                  Icons.close_rounded,
                  size: 18,
                  color: AppColors.inkSoft,
                ),
                label: Text(
                  'Batalkan Analisis',
                  style: AppText.bodyStrong.copyWith(color: AppColors.inkSoft),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _CheckRow extends StatelessWidget {
  const _CheckRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.title.copyWith(fontSize: 14)),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          trailing,
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, color: AppColors.lineSoft);
  }
}

class _StatusText extends StatelessWidget {
  const _StatusText({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppText.caption.copyWith(
        color: color,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _DashedRingPainter extends CustomPainter {
  _DashedRingPainter({
    required this.color,
    this.dashLength = 13,
    this.gapLength = 9,
    this.strokeWidth = 2.6,
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
  bool shouldRepaint(covariant _DashedRingPainter old) =>
      old.color != color ||
      old.dashLength != dashLength ||
      old.gapLength != gapLength ||
      old.strokeWidth != strokeWidth;
}
