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

/// Layar kegagalan analisis piring — ajakan foto ulang.
class MealFailScreen extends StatelessWidget {
  const MealFailScreen({super.key});

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
              'NURI',
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
            const SizedBox(height: 4),
            Row(
              children: [
                Tag(
                  text: child == null
                      ? 'Belum ada data anak'
                      : '${child.nickname} • ${child.ageLabelAt(state.today)}',
                ),
                const Spacer(),
                Text('Makan Siang', style: AppText.caption),
              ],
            ),
            const SizedBox(height: 14),

            // ---- Kartu peringatan -------------------------------------------
            NuriCard(
              color: AppColors.pastelPink,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const StatusChip(
                    text: 'Perlu Foto Ulang',
                    color: Colors.white,
                    onColor: Color(0xFFB5543C),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Piring makan belum dapat dianalisis',
                    style: AppText.h2,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pencahayaan tampak agak redup atau sudut piring kurang '
                    'pas, sehingga komposisi nutrisi dan protein hewani '
                    '${child?.nickname ?? 'Si Kecil'} belum terdeteksi secara '
                    'optimal.',
                    style: AppText.body.copyWith(fontSize: 13.5),
                  ),
                  const SizedBox(height: 14),
                  NuriPhoto(
                    url: DemoImages.plateMeal,
                    height: 170,
                    overlay: Stack(
                      children: [
                        const Positioned(
                          top: 12,
                          right: 12,
                          child: Tag(text: 'Akurasi 42%'),
                        ),
                        Positioned(
                          left: 12,
                          bottom: 12,
                          child: _DarkPillText(
                            text:
                                'Foto sebelumnya: sudut piring & bayangan kurang fokus',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ---- Langkah foto ulang -----------------------------------------
            NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      IconBadge(
                        icon: Icons.lightbulb_outline,
                        color: AppColors.pastelGreen,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          '3 Langkah Mudah Foto Ulang',
                          style: AppText.h3,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 18),
                  _StepRow(
                    icon: Icons.light_mode_outlined,
                    title: 'Pencahayaan Cukup Terang',
                    body:
                        'Dekatkan piring ke arah cahaya alami atau nyalakan lampu '
                        'meja makan agar warna lauk jelas.',
                  ),
                  SizedBox(height: 18),
                  _StepRow(
                    icon: Icons.center_focus_strong_outlined,
                    title: 'Arahkan Kamera Tegak Lurus',
                    body:
                        'Ambil sudut tepat dari atas (top-down view) agar proporsi '
                        'dan potongan lauk terbaca utuh.',
                  ),
                  SizedBox(height: 18),
                  _StepRow(
                    icon: Icons.restaurant_outlined,
                    title: 'Pastikan Lauk Terbuka Bersih',
                    body:
                        'Hindari lauk tertutup sendok, tisu, atau tangan si Kecil '
                        'yang sedang meraih makanan.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            NuriPrimaryButton(
              label: 'Coba Foto Ulang',
              icon: Icons.camera_alt_outlined,
              onPressed: () => context.go('/camera-plate'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Pilih Galeri',
                    icon: Icons.photo_library_outlined,
                    filled: true,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Catat Manual',
                    icon: Icons.edit_note_rounded,
                    filled: true,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            NoteBox(
              background: AppColors.pastelGreenSoft,
              icon: Icons.favorite_border,
              child: Text(
                'Jangan khawatir Bunda, pencatatan nutrisi mandiri di NURI '
                'dirancang fleksibel untuk memudahkan hari-hari Bunda mendampingi '
                'tumbuh kembang Al-Fatih.',
                style: AppText.bodySm,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _DarkPillText extends StatelessWidget {
  const _DarkPillText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 220),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.caption.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(
          icon: icon,
          color: AppColors.pastelGreenSoft,
          size: 42,
          radius: 14,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.title.copyWith(fontSize: 14.5)),
              const SizedBox(height: 4),
              Text(body, style: AppText.bodySm),
            ],
          ),
        ),
      ],
    );
  }
}
