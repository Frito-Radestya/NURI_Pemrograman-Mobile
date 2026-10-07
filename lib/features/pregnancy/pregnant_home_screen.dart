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
import '../../core/widgets/nutrient.dart';
import '../../core/widgets/section.dart';
import '../../core/widgets/tiles.dart';

/// Beranda ruang Ibu Hamil: ringkasan kehamilan, kawal 1.000 HPK,
/// catatan TTD, dan tips harian.
class PregnantHomeScreen extends StatelessWidget {
  const PregnantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      bottomNavigationBar: const PregnantTabBar(active: '/pregnant'),
      topBar: NuriTopBar(
        showBack: false,
        titleWidget: const _HomeBarTitle(),
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
                Tag(text: 'Kamis, 10 April 2025'),
                DotBadge(text: '1.000 HPK Aktif'),
              ],
            ),
            const SizedBox(height: 14),
            const Text('Selamat pagi, Bunda Arini 🌸', style: AppText.h1),
            const SizedBox(height: 8),
            Text(
              'Hari ini tubuh Bunda terus berproses luar biasa untuk menumbuhkan '
              'kehidupan dengan penuh cinta.',
              style: AppText.body,
            ),
            const SizedBox(height: 18),
            NuriPhoto(
              url: DemoImages.pregnancy,
              height: 300,
              radius: AppDimens.radiusXl,
              overlay: Stack(
                children: [
                  const Positioned(
                    left: 16,
                    top: 16,
                    child: PhotoTag(
                      label: 'Pekan 24 • Trimester 2',
                      icon: Icons.child_friendly_rounded,
                    ),
                  ),
                  const Positioned(
                    right: 16,
                    top: 16,
                    child: PhotoTag(
                      label: 'HPL: 1 Apr 2026',
                      icon: Icons.event_outlined,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const _FetalSizeCard(),
            const SizedBox(height: 12),
            const NoteBox(
              child: Text(
                'Pendengaran dan indera pendengaran si kecil mulai berkembang '
                'aktif melalui lembut suara dan sentuhan Bunda.',
                style: AppText.bodySm,
              ),
            ),
            const SizedBox(height: 18),
            const _JourneyCard(),
            const SizedBox(height: 18),
            const _HpkCard(),
            const SizedBox(height: 18),
            _TtdCard(onScan: () => context.push('/camera-plate')),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Hitung Gerak Janin',
                    icon: Icons.monitor_heart_outlined,
                    filled: true,
                    onPressed: () {},
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NuriSecondaryButton(
                    label: 'Catat Keluhan',
                    icon: Icons.sick_outlined,
                    filled: true,
                    onPressed: () {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SectionHeader(
              title: 'Nutrisi Penting Hari Ini',
              actionLabel: 'Lihat Detail',
              onAction: () => context.push('/pregnant-nutrition'),
            ),
            const SizedBox(height: 12),
            const NuriCard(
              child: Column(
                children: [
                  _NutrientRow(
                    title: 'Zat Besi & Asam Folat',
                    percent: '100% Terpenuhi',
                    detail:
                        'Tablet tambah darah + bayam kukus sudah tercatat',
                    value: 1.0,
                  ),
                  SizedBox(height: 18),
                  _NutrientRow(
                    title: 'Protein Hewani',
                    percent: '2 / 2 Porsi',
                    detail: '1 potong kembung balado & 1 butir telur rebus',
                    value: 1.0,
                  ),
                  SizedBox(height: 18),
                  _NutrientRow(
                    title: 'Kalsium & Vitamin D',
                    percent: '75% Terpenuhi',
                    detail: '2 gelas susu & tahu',
                    value: 0.75,
                  ),
                  SizedBox(height: 14),
                  NoteRow(
                    icon: Icons.lightbulb_outline_rounded,
                    text:
                        'Anjuran: Segelas susu hangat atau yoghurt hangat sore ini.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            const NuriCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text('Isi Piringku Ibu Hamil',
                            style: AppText.h3),
                      ),
                      Tag(text: 'Menu Pendukung'),
                    ],
                  ),
                  SizedBox(height: 12),
                  Text('Menu Pendukung Panjang Janin', style: AppText.h3),
                  SizedBox(height: 8),
                  Text(
                    'Prioritaskan protein hewani (ikan kembung, telur) & sayur '
                    'berdaun hijau gelap untuk cegah stunting sejak masa '
                    'kehamilan.',
                    style: AppText.body,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const SectionHeader(title: 'Tips & Agenda Bunda'),
            const SizedBox(height: 12),
            const NoteBox(
              background: AppColors.pastelPeach,
              icon: Icons.info_outline_rounded,
              child: _BoldBody(
                title: 'TIPS PENERAPAN ZAT BESI',
                body:
                    'Minum Tablet Tambah Darah (TTD) bersama air putih atau '
                    'jus jeruk. Hindari teh atau kopi 2 jam sebelum dan '
                    'sesudah minum agar zat besi terserap sempurna. '
                    '#CegahStunting #1000HPK',
              ),
            ),
            const SizedBox(height: 12),
            const ActionTile(
              title: 'Pemeriksaan ANC ke-4',
              subtitle:
                  '15 Puskesmas Melati • Bidan Nurhasanah  ·  5 Hari Lagi',
              leading: IconBadge(icon: Icons.event_available_outlined),
              trailing: Tag(text: '5 Hari Lagi'),
              showChevron: false,
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _HomeBarTitle extends StatelessWidget {
  const _HomeBarTitle();

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

class _FetalSizeCard extends StatelessWidget {
  const _FetalSizeCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Row(
        children: [
          NuriPhoto(
            url: DemoImages.veggies,
            width: 64,
            height: 64,
            radius: AppDimens.radiusMd,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'UKURAN JANIN PEKAN INI',
                  style: AppText.label.copyWith(fontSize: 10, letterSpacing: 0.6),
                ),
                const SizedBox(height: 3),
                Text('Seukuran Buah Jagung Manis', style: AppText.h3),
                const SizedBox(height: 2),
                const Text(
                  'Panjang ±30 cm • Bobot ±600 gram',
                  style: AppText.caption,
                ),
              ],
            ),
          ),
        ],
      ),
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
                child: Text('Perjalanan 40 Pekan', style: AppText.h3),
              ),
              Text(
                '60% Terlewati',
                style: AppText.caption.copyWith(
                  color: AppColors.brandText,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const NutrientBar(value: 0.6),
          const SizedBox(height: 14),
          const Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              StatusChip(text: 'Awal Kehamilan', color: AppColors.pastelGreen),
              _Dot(),
              Text('Trimester 2', style: AppText.bodySm),
              _Dot(),
              Text('HPL: 1 Apr 2026', style: AppText.bodySm),
            ],
          ),
        ],
      ),
    );
  }
}

class _HpkCard extends StatelessWidget {
  const _HpkCard();

  @override
  Widget build(BuildContext context) {
    return const NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Kawal 1.000 HPK', style: AppText.h3),
              ),
              Tag(text: 'Kemenkes RI'),
            ],
          ),
          SizedBox(height: 14),
          Row(
            children: [
              IconBadge(icon: Icons.health_and_safety_outlined),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RISIKO STUNTING DALAM KANDUNGAN',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.inkSoft,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text('Risiko Rendah / Terkendali', style: AppText.h3),
                  ],
                ),
              ),
              Icon(
                Icons.favorite_rounded,
                color: AppColors.statusNormal,
                size: 22,
              ),
            ],
          ),
          SizedBox(height: 14),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HpkBox(
                    title: 'Tablet Tambah Darah (TTD)',
                    value: '18 / 90 tablet',
                    caption: 'Sudah diminum hari ini',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _HpkBox(
                    title: 'Lingkar Lengan (LiLA)',
                    value: '25.5 cm',
                    caption: 'Normal • Bebas KEK (>23.5)',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _HpkBox(
                    title: 'Kenaikan Berat Badan',
                    value: '+5.8 kg',
                    caption: 'Optimal (Target 11–16 kg)',
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: _HpkBox(
                    title: 'Hemoglobin (Hb)',
                    value: '12.1 g/dL',
                    caption: 'Bebas Anemia (≥11.0)',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HpkBox extends StatelessWidget {
  const _HpkBox({
    required this.title,
    required this.value,
    required this.caption,
  });

  final String title;
  final String value;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceSoft,
        borderRadius: BorderRadius.circular(AppDimens.radiusMd),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppText.caption.copyWith(fontSize: 11, height: 1.3)),
          const SizedBox(height: 6),
          Text(value, style: AppText.h3),
          const SizedBox(height: 2),
          Text(caption, style: AppText.caption.copyWith(fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _TtdCard extends StatelessWidget {
  const _TtdCard({required this.onScan});

  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      gradient: AppColors.brandGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const IconBadge(
                icon: Icons.edit_note_rounded,
                color: Color(0x33FFFFFF),
                iconColor: Colors.white,
              ),
              const Spacer(),
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: 0.85),
                size: 22,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'Pencatatan Konsumsi TTD & Nutrisi',
            style: AppText.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Pastikan asupan zat besi & protein optimal untuk tumbuh kembang '
            'organ janin hari ini.',
            style: AppText.body.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 18),
          _WhitePillButton(
            label: 'Pindai Piring Makan Bunda',
            icon: Icons.camera_alt_outlined,
            onTap: onScan,
          ),
          const SizedBox(height: 12),
          NoteRow(
            icon: Icons.access_time_rounded,
            color: Colors.white.withValues(alpha: 0.7),
            text: 'Pengingat TTD Malam: Pukul 20:00 WIB setelah makan malam.',
          ),
        ],
      ),
    );
  }
}

class _WhitePillButton extends StatelessWidget {
  const _WhitePillButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: onTap,
        child: SizedBox(
          width: double.infinity,
          height: AppDimens.buttonHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: AppColors.brand, size: 20),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.button.copyWith(color: AppColors.brand),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({
    required this.title,
    required this.percent,
    required this.detail,
    required this.value,
  });

  final String title;
  final String percent;
  final String detail;
  final double value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(title, style: AppText.title)),
            const SizedBox(width: 8),
            Text(
              percent,
              style: AppText.bodyStrong.copyWith(
                color: AppColors.brandText,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(detail, style: AppText.bodySm.copyWith(fontSize: 12.5)),
        const SizedBox(height: 9),
        NutrientBar(value: value),
      ],
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
            style: AppText.label.copyWith(
              color: AppColors.ink,
              fontSize: 11,
              letterSpacing: 0.5,
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
