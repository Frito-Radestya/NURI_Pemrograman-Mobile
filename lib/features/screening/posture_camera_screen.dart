import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/section.dart';

/// Kamera pemandu pengukuran postur (UI gelap penuh).
class PostureCameraScreen extends StatefulWidget {
  const PostureCameraScreen({super.key});

  @override
  State<PostureCameraScreen> createState() => _PostureCameraScreenState();
}

class _PostureCameraScreenState extends State<PostureCameraScreen> {
  /// 0 = anak berdiri, 1 = berbaring (<2 thn).
  int _segment = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cameraScrim,
      body: Stack(
        children: [
          Positioned.fill(
            child: NuriPhoto(
              url: DemoImages.measuredChild,
              radius: 0,
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Column(
                children: [
                  _TopRow(
                    onClose: () => context.canPop()
                        ? context.pop()
                        : context.go('/screening'),
                  ),
                  const SizedBox(height: 14),
                  _SegmentControl(
                    segment: _segment,
                    onChanged: (i) => setState(() => _segment = i),
                  ),
                  const SizedBox(height: 14),
                  const _StatusPill(),
                  const SizedBox(height: 22),
                  const _PostureGuide(),
                  const SizedBox(height: 18),
                  const _InfoBar(),
                  const SizedBox(height: 12),
                  const _TipsPanel(),
                  const SizedBox(height: 16),
                  const NoteRow(
                    icon: Icons.shield_outlined,
                    color: Colors.white70,
                    text:
                        'Foto hanya diproses untuk proporsi tubuh & tidak '
                        'disimpan',
                  ),
                  const SizedBox(height: 18),
                  _BottomBar(
                    onShutter: () => context.go('/screening-result'),
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

// ---------------------------------------------------------------------------

class _TopRow extends StatelessWidget {
  const _TopRow({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NuriSoftButton(
          icon: Icons.close_rounded,
          background: Colors.white.withValues(alpha: 0.24),
          color: Colors.white,
          onPressed: onClose,
        ),
        Expanded(
          child: Text(
            'KAMERA PENGUKURAN POSTUR',
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppText.label.copyWith(
              color: Colors.white,
              letterSpacing: 1,
              fontSize: 11,
            ),
          ),
        ),
        const SizedBox(width: 44),
        const Icon(Icons.flash_on_rounded, color: Colors.white),
      ],
    );
  }
}

class _SegmentControl extends StatelessWidget {
  const _SegmentControl({required this.segment, required this.onChanged});

  final int segment;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: [
          _segmentItem(
            index: 0,
            label: 'Anak Berdiri',
            icon: Icons.accessibility_new_rounded,
          ),
          _segmentItem(
            index: 1,
            label: 'Berbaring (<2 Thn)',
            icon: Icons.airline_seat_flat_rounded,
          ),
        ],
      ),
    );
  }

  Widget _segmentItem({
    required int index,
    required String label,
    required IconData icon,
  }) {
    final active = segment == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.brand : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: Colors.white),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySm.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
        decoration: BoxDecoration(
          color: AppColors.brand,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              'Posisi Sudah Pas & Stabil',
              style: AppText.bodyStrong.copyWith(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PostureGuide extends StatelessWidget {
  const _PostureGuide();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 440,
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: const _DashedRing()),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Text(
              'GARIS TUMIT RATA',
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                color: Colors.white,
                letterSpacing: 2,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBar extends StatelessWidget {
  const _InfoBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        'Pastikan kepala hingga tumit ada di dalam garis',
        textAlign: TextAlign.center,
        style: AppText.bodySm.copyWith(color: Colors.white),
      ),
    );
  }
}

class _TipsPanel extends StatelessWidget {
  const _TipsPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _TipColumn(
            icon: Icons.wb_sunny_outlined,
            title: 'Cahaya Merata',
            caption: 'Tanpa bayangan pekat',
          ),
          _TipColumn(
            icon: Icons.checkroom,
            title: 'Baju Pas Badan',
            caption: 'Postur kaki terlihat',
          ),
          _TipColumn(
            icon: Icons.straighten,
            title: 'Jarak ±1.5 – 2 m',
            caption: 'Sejajar dada balita',
          ),
        ],
      ),
    );
  }
}

class _TipColumn extends StatelessWidget {
  const _TipColumn({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          const SizedBox(height: 9),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppText.bodyStrong.copyWith(
              color: Colors.white,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            textAlign: TextAlign.center,
            style: AppText.caption.copyWith(
              color: Colors.white70,
              fontSize: 10.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  const _BottomBar({required this.onShutter});

  final VoidCallback onShutter;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        NuriSoftButton(
          icon: Icons.photo_library_outlined,
          size: 52,
          background: Colors.white.withValues(alpha: 0.15),
          color: Colors.white,
          onPressed: () {},
        ),
        GestureDetector(
          onTap: onShutter,
          child: Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColors.brand,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Colors.white, size: 26),
              ),
            ),
          ),
        ),
        NuriSoftButton(
          icon: Icons.cameraswitch_outlined,
          size: 52,
          background: Colors.white.withValues(alpha: 0.15),
          color: Colors.white,
          onPressed: () {},
        ),
      ],
    );
  }
}

/// Pemandu postur: tanda kurung sudut, siluet kepala/badan/kaki bergaris
/// putus-putus, dan garis tumit.
class _DashedRing extends CustomPainter {
  const _DashedRing();

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;

    final guide = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..color = Colors.white.withValues(alpha: 0.8);

    final solid = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..color = Colors.white;

    // Tanda kurung sudut.
    const b = 24.0;
    final corners = <List<Offset>>[
      [Offset(0, b), Offset(0, 0), Offset(b, 0)],
      [Offset(w - b, 0), Offset(w, 0), Offset(w, b)],
      [Offset(0, h - b), Offset(0, h), Offset(b, h)],
      [Offset(w - b, h), Offset(w, h), Offset(w, h - b)],
    ];
    for (final c in corners) {
      final p = Path()
        ..moveTo(c[0].dx, c[0].dy)
        ..lineTo(c[1].dx, c[1].dy)
        ..lineTo(c[2].dx, c[2].dy);
      canvas.drawPath(p, solid);
    }

    // Kepala (oval).
    _dashPath(
      canvas,
      guide,
      Path()
        ..addOval(
          Rect.fromCenter(
            center: Offset(cx, h * 0.13),
            width: w * 0.2,
            height: h * 0.17,
          ),
        ),
    );

    // Badan (rounded rect).
    _dashPath(
      canvas,
      guide,
      Path()
        ..addRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTRB(cx - w * 0.18, h * 0.25, cx + w * 0.18, h * 0.6),
            Radius.circular(w * 0.1),
          ),
        ),
    );

    // Lengan.
    _dashPath(
      canvas,
      guide,
      Path()
        ..moveTo(cx - w * 0.18, h * 0.28)
        ..lineTo(cx - w * 0.28, h * 0.5),
    );
    _dashPath(
      canvas,
      guide,
      Path()
        ..moveTo(cx + w * 0.18, h * 0.28)
        ..lineTo(cx + w * 0.28, h * 0.5),
    );

    // Kaki.
    _dashPath(
      canvas,
      guide,
      Path()
        ..moveTo(cx - w * 0.1, h * 0.6)
        ..lineTo(cx - w * 0.12, h * 0.9),
    );
    _dashPath(
      canvas,
      guide,
      Path()
        ..moveTo(cx + w * 0.1, h * 0.6)
        ..lineTo(cx + w * 0.12, h * 0.9),
    );

    // Garis tumit.
    _dashPath(
      canvas,
      guide,
      Path()
        ..moveTo(w * 0.08, h * 0.9)
        ..lineTo(w * 0.92, h * 0.9),
      dash: 12,
      gap: 8,
    );
  }

  void _dashPath(
    Canvas canvas,
    Paint paint,
    Path path, {
    double dash = 9,
    double gap = 7,
  }) {
    for (final metric in path.computeMetrics()) {
      double dist = 0;
      while (dist < metric.length) {
        final next = (dist + dash).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(dist, next), paint);
        dist = next + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRing oldDelegate) => false;
}
