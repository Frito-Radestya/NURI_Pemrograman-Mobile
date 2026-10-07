import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_logo.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/step_dots.dart';
import '../../core/widgets/tiles.dart';

/// Orientasi 3 langkah sebelum memilih peran.
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_index < 2) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go('/role');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(index: _index, onSkip: () => context.go('/role')),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: const [
                  _PageOne(),
                  _PageTwo(),
                  _PageThree(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 18),
              child: Column(
                children: [
                  StepDots(count: 3, index: _index),
                  const SizedBox(height: 18),
                  if (_index == 0)
                    NuriPrimaryButton(
                      label: 'Lanjut',
                      trailingArrow: true,
                      onPressed: _next,
                    )
                  else if (_index == 1)
                    Row(
                      children: [
                        NuriSoftButton(
                          icon: Icons.arrow_back_rounded,
                          size: 56,
                          background: AppColors.surface,
                          onPressed: () => _controller.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: NuriPrimaryButton(
                            label: 'Lanjut',
                            trailingArrow: true,
                            onPressed: _next,
                          ),
                        ),
                      ],
                    )
                  else ...[
                    NuriPrimaryButton(
                      label: 'Mulai Sekarang',
                      trailingArrow: true,
                      onPressed: _next,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Langkah berikutnya: Pilih peran Anda',
                      style: AppText.caption.copyWith(color: AppColors.inkFaint),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------

class _TopBar extends StatelessWidget {
  const _TopBar({required this.index, required this.onSkip});

  final int index;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: SizedBox(
        height: 44,
        child: Row(
          children: [
            if (index == 0)
              const NuriBrand(markSize: 34, fontSize: 21)
            else
              NuriSoftButton(
                icon: Icons.arrow_back_rounded,
                background: AppColors.surface,
                onPressed: onSkip,
              ),
            const Spacer(),
            if (index == 2)
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.surfaceSoft,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  '3 / 3',
                  style: AppText.bodyStrong.copyWith(
                    color: AppColors.inkSoft,
                    fontSize: 13,
                  ),
                ),
              )
            else
              NuriTextAction(label: 'Lewati', onTap: onSkip),
          ],
        ),
      ),
    );
  }
}

class _PageScaffold extends StatelessWidget {
  const _PageScaffold({
    required this.photo,
    required this.photoOverlay,
    required this.child,
  });

  final String photo;
  final Widget photoOverlay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final photoHeight = MediaQuery.of(context).size.width * 1.08;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NuriPhoto(
            url: photo,
            height: photoHeight,
            radius: AppDimens.radiusXl,
            overlay: photoOverlay,
          ),
          const SizedBox(height: 22),
          child,
        ],
      ),
    );
  }
}

class _PageOne extends StatelessWidget {
  const _PageOne();

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      photo: DemoImages.heroFood,
      photoOverlay: Stack(
        children: const [
          Positioned(
            left: 16,
            top: 16,
            child: PhotoTag(label: 'MPASI & Gizi Seimbang', icon: Icons.eco_rounded),
          ),
          Positioned(
            right: 16,
            bottom: 16,
            child: _DotTag(label: '1000 Hari Pertama'),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PillLabel(text: 'Langkah 01'),
          SizedBox(height: 14),
          Text(
            'Pahami nutrisi esensial di setiap fase tumbuh kembang.',
            style: AppText.h1,
          ),
          SizedBox(height: 14),
          Text(
            'Panduan pola makan bergizi kaya protein hewani dan zat besi mikro '
            'untuk optimalkan 1000 Hari Pertama Kehidupan buah hati.',
            style: AppText.body,
          ),
          SizedBox(height: 18),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SoftChip(label: 'Standar WHO', icon: Icons.workspace_premium_outlined),
              SoftChip(label: 'Cegah Stunting', icon: Icons.shield_outlined),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageTwo extends StatelessWidget {
  const _PageTwo();

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      photo: DemoImages.measuredChild,
      photoOverlay: Stack(
        children: const [
          Positioned(
            left: 16,
            top: 16,
            child: PhotoTag(
              label: 'Kurva WHO & Kemenkes',
              icon: Icons.monitor_heart_outlined,
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _GrowthStatusCard(),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pantau pertumbuhan dengan presisi standar WHO.', style: AppText.h1),
          SizedBox(height: 14),
          Text(
            'Catat tinggi dan berat badan secara berkala untuk melihat kurva '
            'kenaikan bobot yang ideal tanpa rasa cemas berlebih.',
            style: AppText.body,
          ),
        ],
      ),
    );
  }
}

class _GrowthStatusCard extends StatelessWidget {
  const _GrowthStatusCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.pastelGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_circle_outline_rounded,
                color: AppColors.brand, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('STATUS PERTUMBUHAN',
                    style: AppText.label.copyWith(
                        color: AppColors.inkFaint, fontSize: 10.5)),
                const SizedBox(height: 3),
                Text('Tinggi Optimal (+0.6 SD)', style: AppText.h3),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.pastelGreen,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              'Zona\nHijau',
              textAlign: TextAlign.center,
              style: AppText.caption.copyWith(
                color: AppColors.brandText,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageThree extends StatelessWidget {
  const _PageThree();

  @override
  Widget build(BuildContext context) {
    return _PageScaffold(
      photo: DemoImages.cameraKid,
      photoOverlay: Stack(
        children: const [
          Positioned(
            left: 16,
            top: 16,
            child: PhotoTag(
              label: 'Deteksi Dini Stunting & Gizi',
              icon: Icons.verified_user_outlined,
            ),
          ),
          Positioned(
            right: 16,
            top: 16,
            child: _LeafButton(),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: 16,
            child: _AnalysisCard(),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Deteksi potensi risiko stunting lebih awal.', style: AppText.h1),
          SizedBox(height: 14),
          Text(
            'Dukungan kecerdasan buatan NURI mendeteksi perlambatan tumbuh '
            'kembang lebih dini secara santun, sebelum berdampak permanen pada '
            'masa depan si kecil.',
            style: AppText.body,
          ),
          SizedBox(height: 18),
          NoteBox(
            icon: Icons.groups_2_outlined,
            child: Text(
              'Mulai perjalanan mendampingi si kecil sebagai Orang Tua atau '
              'Kader Posyandu.',
              style: AppText.bodyStrong,
            ),
          ),
        ],
      ),
    );
  }
}

/// Label foto dengan titik aksen (mis. "1000 Hari Pertama").
class _DotTag extends StatelessWidget {
  const _DotTag({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: const BoxDecoration(
              color: Color(0xFFB5543C),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: AppText.bodySm.copyWith(
              color: AppColors.ink,
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LeafButton extends StatelessWidget {
  const _LeafButton();
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.eco_rounded, color: AppColors.brand, size: 22),
    );
  }
}

class _AnalysisCard extends StatelessWidget {
  const _AnalysisCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBadge(
            icon: Icons.insights_rounded,
            color: AppColors.pastelPeach,
            iconColor: Color(0xFFD9743A),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Analisis Akurat', style: AppText.h3),
                const SizedBox(height: 2),
                Text(
                  'Rekomendasi pangan spesifik berba…',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.bodySm.copyWith(fontSize: 12.5),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(
                      color: AppColors.brand,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text('Standar WHO &\nKemenkes',
                      style: AppText.caption.copyWith(height: 1.2)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
