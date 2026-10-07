import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/data/demo.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_dimens.dart';
import '../../core/theme/app_text.dart';
import '../../core/widgets/chips.dart';
import '../../core/widgets/nuri_button.dart';
import '../../core/widgets/nuri_card.dart';
import '../../core/widgets/nuri_photo.dart';
import '../../core/widgets/nuri_scaffold.dart';
import '../../core/widgets/nuri_tabs.dart';
import '../../core/widgets/nuri_top_bar.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';

/// Rekomendasi Bunda: prioritas medis, tindakan terarah, agenda ANC,
/// dan kenyamanan trimester 2.
class PregnantRecommendScreen extends StatelessWidget {
  const PregnantRecommendScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      bottomNavigationBar: const PregnantTabBar(active: '/pregnant-recommend'),
      topBar: NuriTopBar(
        onBack: () => context.canPop() ? context.pop() : context.go('/pregnant'),
        titleWidget: const _RecommendBarTitle(),
        actions: [
          NuriSoftButton(
            icon: Icons.notifications_none_rounded,
            onPressed: () => context.push('/notifications'),
          ),
          const SizedBox(width: 8),
          const NuriAvatar(
            initials: 'BA',
            background: AppColors.pastelGreen,
            color: AppColors.brandText,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            const _PriorityHeaderCard(),
            const SizedBox(height: 20),
            const Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: [
                PillLabel(text: 'PRIORITAS UTAMA • PEKAN INI'),
                Tag(text: 'Target Hari Ini'),
              ],
            ),
            const SizedBox(height: 14),
            const Text(
              'Cukupi Asupan Zat Besi & Omega-3 untuk Percepatan Mielinisasi '
              'Otak Janin',
              style: AppText.h2,
            ),
            const SizedBox(height: 16),
            NuriPhoto(
              url: DemoImages.plateMeal,
              height: 200,
              radius: AppDimens.radiusXl,
              overlay: const Positioned(
                left: 12,
                right: 12,
                bottom: 12,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Tag(text: 'Piring Gizi Kemenkes'),
                    Tag(text: 'Ikan Kembung + Bayam Jagung'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const NoteBox(
              icon: Icons.lightbulb_outline_rounded,
              child: _BoldBody(
                title: 'MENGAPA SANGAT KRUSIAL?',
                body:
                    'Di pekan ke-24, gelombang mielinisasi neuron dan jaringan '
                    'retina janin meningkat sangat pesat. Kekurangan zat besi '
                    'dan DHA meningkatkan risiko Berat Badan Lahir Rendah '
                    '(BBLR) serta potensi stunting jangka panjang.',
              ),
            ),
            const SizedBox(height: 18),
            _ActionCard(onScan: () => context.push('/camera-plate')),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Agenda Medis • Dalam 5 Hari',
              actionLabel: 'Wajib Trimester 2',
            ),
            const SizedBox(height: 12),
            const _AgendaCard(),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Kenyamanan & Sirkulasi'),
            const SizedBox(height: 12),
            const _ComfortCard(),
            const SizedBox(height: 18),
            const Row(
              children: [
                Text('PROGRES HARI INI', style: AppText.label),
                Spacer(),
                Text('2 dari 3 Dilakukan', style: AppText.caption),
              ],
            ),
            const SizedBox(height: 12),
            NuriPrimaryButton(
              label: 'Catat Log',
              onPressed: () => context.go('/pregnant'),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _RecommendBarTitle extends StatelessWidget {
  const _RecommendBarTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Trimester 2 • Pekan 24',
          style: AppText.caption.copyWith(
            color: AppColors.inkFaint,
            fontSize: 9.5,
            letterSpacing: 1,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text('Rekomendasi Bunda', style: AppText.h3),
      ],
    );
  }
}

class _PriorityHeaderCard extends StatelessWidget {
  const _PriorityHeaderCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              NuriPhoto(
                url: DemoImages.avatarMother,
                width: 56,
                height: 56,
                radius: AppDimens.radiusMd,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KEMENKES RI • 1.000 HPK',
                      style: AppText.label.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Kebutuhan Prioritas Bunda Arini',
                      style: AppText.h3,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Pekan ke-24 • Menu personal 112 hari lagi. Rekomendasi '
                      'medis disusun khusus berdasar asupan trimester ke-2 '
                      'Bunda.',
                      style: AppText.bodySm.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Paling Penting Sekarang',
                  filled: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Nutrisi & TTD',
                  filled: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'TINDAKAN TERARAH BUNDA',
            style: AppText.label.copyWith(fontSize: 10, letterSpacing: 0.6),
          ),
          const SizedBox(height: 12),
          const NoteBox(
            background: AppColors.pastelGreenSoft,
            icon: Icons.access_time_rounded,
            child: _BoldBody(
              title: 'Minum 1 Tablet Tambah Darah (TTD)',
              body: 'Disarankan bersama air perasan jeruk malam ini.',
            ),
          ),
          const SizedBox(height: 14),
          NuriPrimaryButton(
            label: 'Pindai Piring Makan Bunda',
            trailingArrow: true,
            onPressed: onScan,
          ),
        ],
      ),
    );
  }
}

class _AgendaCard extends StatelessWidget {
  const _AgendaCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Saatnya Pemeriksaan ANC Terpadu ke–4 di Puskesmas',
            style: AppText.h3,
          ),
          const SizedBox(height: 14),
          const _GreenInfoBox(),
          const SizedBox(height: 14),
          const NoteRow(
            icon: Icons.schedule,
            text: 'Selasa, 15 April 2025 • 09:00 WIB',
          ),
          const SizedBox(height: 10),
          const NoteRow(
            icon: Icons.location_on_outlined,
            text: 'Puskesmas Melati • Poli KIA Terpadu',
          ),
          const SizedBox(height: 16),
          NuriSecondaryButton(
            label: 'Siapkan Catatan KIA',
            icon: Icons.note_alt_outlined,
            filled: true,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _GreenInfoBox extends StatelessWidget {
  const _GreenInfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.pastelGreenSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const IconBadge(
            icon: Icons.monitor_heart_outlined,
            size: 42,
            radius: AppDimens.radiusSm,
            color: AppColors.surface,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pemeriksaan Dokter & USG Skrining',
                  style: AppText.title.copyWith(fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Evaluasi kritik volume cairan ketuban, posisi plasenta, serta '
                  'cek kadar Hemoglobin (Hb) untuk memastikan bebas komplikasi '
                  'anemia defisiensi besi.',
                  style: AppText.bodySm.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComfortCard extends StatelessWidget {
  const _ComfortCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Posisi Tidur Miring ke Kiri untuk Maksimalkan Perfusi Janin',
            style: AppText.h3,
          ),
          const SizedBox(height: 8),
          Text(
            'Menghindari penekanan vena cava inferior oleh rahim yang '
            'membesar, memanfaatkan aliran darah ke janin dan oksigen '
            'terdistribusi lebih stabil menuju plasenta.',
            style: AppText.body,
          ),
          const SizedBox(height: 14),
          NuriPhoto(
            url: DemoImages.motherBaby,
            height: 140,
            radius: AppDimens.radiusMd,
          ),
          const SizedBox(height: 14),
          const NoteBox(
            background: AppColors.surfaceSoft,
            icon: Icons.bedtime_outlined,
            child: _BoldBody(
              title: 'Pengingat Relaksasi 21:00 WIB',
              body: 'Panduan pernapasan & posisi bantal',
            ),
          ),
        ],
      ),
    );
  }
}

class _BoldBody extends StatelessWidget {
  const _BoldBody({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: title,
            style: AppText.bodyStrong.copyWith(
              fontSize: 13,
              color: AppColors.ink,
            ),
          ),
          TextSpan(
            text: '\n$body',
            style: AppText.bodySm.copyWith(height: 1.5),
          ),
        ],
      ),
    );
  }
}
