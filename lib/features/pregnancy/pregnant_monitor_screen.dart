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
import '../../core/widgets/step_dots.dart';
import '../../core/widgets/tiles.dart';

/// Pantau Si Kecil & Bunda: perkembangan janin, fokus 1.000 HPK,
/// standar KIA, dan agenda medis trimester 2.
class PregnantMonitorScreen extends StatelessWidget {
  const PregnantMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      bottomNavigationBar: const PregnantTabBar(active: '/pregnant-monitor'),
      topBar: NuriTopBar(
        showBack: false,
        titleWidget: const _MonitorBarTitle(),
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
            const Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                PillLabel(text: 'Pekan 24 • Trimester 2'),
                Tag(text: 'HPL: 1 Apr 2026'),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Pantau Si Kecil & Bunda', style: AppText.h1),
            const SizedBox(height: 8),
            Text(
              'Dari ke-168 dan 280 hari perjalanan cinta Bunda Arini',
              style: AppText.body,
            ),
            const SizedBox(height: 18),
            const _JourneyCard(),
            const SizedBox(height: 18),
            const _FetalCard(),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Fokus 1.000 HPK',
              actionLabel: 'Trimester 2',
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                const cards = [
                  _FocusCard(
                    icon: Icons.psychology,
                    title: 'Jaringan Otak',
                    caption: 'Myelinisasi neuron aktif',
                  ),
                  _FocusCard(
                    icon: Icons.directions_run,
                    title: 'Refleks Gerak',
                    caption: 'Tendangan makin kuat',
                  ),
                  _FocusCard(
                    icon: Icons.bloodtype,
                    title: 'Depot Besi',
                    caption: 'Penyimpanan sel darah',
                  ),
                ];
                if (constraints.maxWidth < 360) {
                  return Column(
                    children: [
                      cards[0],
                      const SizedBox(height: 10),
                      cards[1],
                      const SizedBox(height: 10),
                      cards[2],
                    ],
                  );
                }
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(child: cards[0]),
                      const SizedBox(width: 10),
                      Expanded(child: cards[1]),
                      const SizedBox(width: 10),
                      Expanded(child: cards[2]),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 18),
            const _KiaCard(),
            const SizedBox(height: 18),
            const _AttentionCard(),
            const SizedBox(height: 18),
            const _AgendaCard(),
            const SizedBox(height: 18),
            const NoteBox(
              background: AppColors.surfaceSoft,
              child: Column(
                children: [
                  Icon(
                    Icons.favorite_rounded,
                    color: AppColors.brand,
                    size: 22,
                  ),
                  SizedBox(height: 8),
                  Text(
                    '“Setiap detak jantung dan nutrisi yang Bunda jaga hari ini '
                    'adalah fondasi generasi bebas stunting masa depan.”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 13.5,
                      height: 1.55,
                      fontStyle: FontStyle.italic,
                      color: AppColors.inkSoft,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text('— NURI Sahabat Bunda', style: AppText.caption),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _MonitorBarTitle extends StatelessWidget {
  const _MonitorBarTitle();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'NURI',
          style: AppText.caption.copyWith(
            color: AppColors.inkFaint,
            fontSize: 9.5,
            letterSpacing: 2.2,
            fontWeight: FontWeight.w700,
          ),
        ),
        Text('Ibu Hamil', style: AppText.h3),
      ],
    );
  }
}

class _JourneyCard extends StatelessWidget {
  const _JourneyCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text('60% Perjalanan', style: AppText.h3),
              ),
              Text(
                '112 Hari Menuju Kelahiran',
                style: AppText.caption.copyWith(
                  color: AppColors.brandText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const StepProgress(value: 0.6),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(text: 'Trim 1 (Tuntas)', color: AppColors.pastelGreen),
              _Dot(),
              Text('Trim 2 (Pekan 24)', style: AppText.bodySm),
              _Dot(),
              Text('Trim 3 (Pekan 28)', style: AppText.bodySm),
            ],
          ),
        ],
      ),
    );
  }
}

class _FetalCard extends StatelessWidget {
  const _FetalCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              NuriPhoto(
                url: DemoImages.veggies,
                width: 76,
                height: 76,
                radius: AppDimens.radiusMd,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERKEMBANGAN JANIN',
                      style: AppText.label.copyWith(
                        fontSize: 10,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text('Seukuran Jagung Manis', style: AppText.h3),
                    const SizedBox(height: 2),
                    const Text('±30 cm • ±600 gram', style: AppText.caption),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            '“Kelopak mata dan indera pendengaran si kecil mulai aktif pekan '
            'ini. Ia mulai mengenal alunan suara lembut Bunda dan sentuhan '
            'hangat Ayah di perut.”',
            style: AppText.body,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const IconBadge(
                icon: Icons.front_hand,
                color: AppColors.pastelGreen,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tendangan Hari Ini', style: AppText.caption),
                    SizedBox(height: 2),
                    Text('Terpantau aktif & riang', style: AppText.h3),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text('8', style: AppText.metric),
                  const SizedBox(height: 4),
                  const Tag(text: '+ Tendang'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconBadge(
            icon: icon,
            size: 40,
            radius: AppDimens.radiusMd,
            color: AppColors.pastelGreenSoft,
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: AppText.title.copyWith(fontSize: 13.5),
          ),
          const SizedBox(height: 3),
          Text(
            caption,
            style: AppText.caption.copyWith(fontSize: 11, height: 1.35),
          ),
        ],
      ),
    );
  }
}

class _KiaCard extends StatelessWidget {
  const _KiaCard();

  @override
  Widget build(BuildContext context) {
    return const NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Standar Pemantauan KIA', style: AppText.h3),
              ),
              Tag(text: 'Kemenkes RI'),
            ],
          ),
          SizedBox(height: 16),
          _KiaRow(
            icon: Icons.medication,
            title: 'Tablet Tambah Darah',
            value: '18 / 90 butir',
          ),
          SizedBox(height: 16),
          _KiaRow(
            icon: Icons.straighten,
            title: 'Lingkar Lengan (LiLA)',
            value: '25.5 cm',
            caption: 'Normal (>23.5 cm)',
          ),
          SizedBox(height: 16),
          _KiaRow(
            icon: Icons.bloodtype,
            title: 'Bebas Anemia',
            value: '12.1 g/dL',
            caption: 'Optimal (>10.5 g/dL)',
          ),
          SizedBox(height: 16),
          _KiaRow(
            icon: Icons.show_chart,
            title: 'Sesuai Kurva',
            value: '+5.8 kg',
            caption: 'Kenaikan BB Bunda • +0.4 kg/pekan (Ideal)',
          ),
        ],
      ),
    );
  }
}

class _KiaRow extends StatelessWidget {
  const _KiaRow({
    required this.icon,
    required this.title,
    required this.value,
    this.caption,
  });

  final IconData icon;
  final String title;
  final String value;
  final String? caption;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(
          icon: icon,
          size: 42,
          radius: AppDimens.radiusSm,
          color: AppColors.pastelGreenSoft,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: Text(title, style: AppText.title)),
                  const SizedBox(width: 8),
                  Text(
                    value,
                    style: AppText.bodyStrong.copyWith(
                      color: AppColors.brandText,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              if (caption != null) ...[
                const SizedBox(height: 2),
                Text(caption!, style: AppText.caption),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AttentionCard extends StatelessWidget {
  const _AttentionCard();

  @override
  Widget build(BuildContext context) {
    return const NuriCard(
      color: AppColors.pastelPeach,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconBadge(
                icon: Icons.info_outline,
                color: AppColors.pastelPink,
                iconColor: AppColors.accent,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'PERHATIAN PEKAN INI',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text('Saatnya Jadwalkan ANC ke–4', style: AppText.h3),
                    SizedBox(height: 8),
                    Text(
                      'Pemeriksaan ANC ke-4 direkomendasikan pada rentang pekan '
                      '24–28 untuk mengevaluasi posisi plasenta, volume '
                      'ketuban, dan takaran suplemen TTD.',
                      style: AppText.bodySm,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14),
          NoteRow(
            icon: Icons.water_drop,
            text:
                'Target Hidrasi: Pastikan minum minimal 2.5 Liter air per hari '
                'untuk cairan ketuban.',
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
          const Row(
            children: [
              Expanded(
                child: Text('Agenda Medis Terjadwal', style: AppText.h3),
              ),
              Tag(text: 'Tersisa 5 Hari'),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 64,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.pastelGreenSoft,
                  borderRadius: BorderRadius.circular(AppDimens.radiusMd),
                ),
                child: Column(
                  children: [
                    Text(
                      'SELASA',
                      style: AppText.label.copyWith(
                        fontSize: 9.5,
                        color: AppColors.brandText,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text('15', style: AppText.h2),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Tag(text: 'Pemeriksaan ANC ke–4'),
                    SizedBox(height: 8),
                    Text('Pemeriksaan ANC ke–4', style: AppText.h3),
                    SizedBox(height: 4),
                    Text(
                      'Puskesmas Melati • Pukul 09:00 WIB • Bidan Nurhasanah, '
                      'S.Tr. Keb',
                      style: AppText.caption,
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
                  label: 'Buku KIA',
                  icon: Icons.menu_book_outlined,
                  filled: true,
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NuriSecondaryButton(
                  label: 'Ingatkan Saya',
                  icon: Icons.notifications_none_rounded,
                  filled: true,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Center(
            child: Text('Konsultasi Cetak Tanda Bahaya', style: AppText.caption),
          ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 4,
      height: 4,
      decoration: const BoxDecoration(
        color: AppColors.inkFaint,
        shape: BoxShape.circle,
      ),
    );
  }
}
