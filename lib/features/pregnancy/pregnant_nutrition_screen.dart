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

/// Nutrisi & Gizi Ibu Hamil: kecukupan gizi harian, analisis piring makan,
/// dan tips sehat trimester 2.
class PregnantNutritionScreen extends StatelessWidget {
  const PregnantNutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NuriScaffold(
      bottomNavigationBar: const PregnantTabBar(active: '/pregnant-nutrition'),
      topBar: NuriTopBar(
        showBack: false,
        titleWidget: const _NutritionBarTitle(),
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
            const Text('Nutrisi & Gizi Ibu Hamil', style: AppText.h1),
            const SizedBox(height: 8),
            Text(
              'Panduan gizi terarah 1.000 Hari Pertama Kehidupan (HPK) untuk '
              'mendukung perkembangan organ janin dan mencegah anemia serta '
              'risiko stunting sejak kandungan.',
              style: AppText.body,
            ),
            const SizedBox(height: 16),
            const Row(
              children: [
                PillLabel(
                  text: 'Target Harian Aktif',
                  leadingDot: false,
                  color: AppColors.canvasGreen,
                  textColor: AppColors.brandText,
                ),
                SizedBox(width: 10),
                Flexible(
                  child: Text('MR–KE 16:5', style: AppText.caption),
                ),
              ],
            ),
            const SizedBox(height: 18),
            const _GiziCard(),
            const SizedBox(height: 18),
            _ScanCard(onScan: () => context.push('/camera-plate')),
            const SizedBox(height: 18),
            const _PlatePhoto(),
            const SizedBox(height: 18),
            const _ProteinPlateCard(),
            const SizedBox(height: 24),
            const SectionHeader(
              title: 'Tips Sehat Bunda Hari Ini',
              actionLabel: 'Ditinjau Bidan NURI',
            ),
            const SizedBox(height: 12),
            const NoteBox(
              background: AppColors.pastelYellow,
              icon: Icons.nightlight_round,
              child: _BoldBody(
                title: 'Waktu Terbaik Minum Tablet Tambah Darah (TTD)',
                body:
                    'Minum dalam jarak waktu 1 jam sebelum tidur untuk '
                    'meminimalkan mual saat perut kosong.',
              ),
            ),
            const SizedBox(height: 12),
            const NoteBox(
              background: AppColors.pastelSand,
              icon: Icons.icecream,
              child: _BoldBody(
                title: 'Camilan Manis ala Trimester 2',
                body:
                    'Buah lokal seperti pisang, pepaya, dan lain-lain dapat '
                    'menjadi pilihan cerdas untuk asupan energi ibu hamil.',
              ),
            ),
            const SizedBox(height: 12),
            const NoteBox(
              background: AppColors.pastelPeach,
              icon: Icons.monitor_weight_outlined,
              child: _BoldBody(
                title: 'Kenaikan Berat Badan yang Sehat',
                body:
                    'Target kenaikan berat badan adalah 0.35 – 0.4 kg per '
                    'pekan pada trimester 2 untuk memastikan pertumbuhan janin '
                    'optimal.',
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _NutritionBarTitle extends StatelessWidget {
  const _NutritionBarTitle();

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

class _GiziCard extends StatelessWidget {
  const _GiziCard();

  @override
  Widget build(BuildContext context) {
    return NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Kecukupan Gizi Hari Ini', style: AppText.h3),
                    SizedBox(height: 2),
                    Text('Tercapai', style: AppText.caption),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const NutrientRing(value: 0.82, size: 64, trackLabel: ''),
            ],
          ),
          const SizedBox(height: 20),
          const _GiziRow(
            icon: Icons.bloodtype,
            title: 'Zat Besi & Asam Folat',
            percent: '100%',
            detail:
                'Tablet Tambah Darah + Bayam Kukus. Esensial untuk pembentukan '
                'sel darah merah dan mencegah BBLR/stunting.',
            value: 1.0,
          ),
          const SizedBox(height: 18),
          const _GiziRow(
            icon: Icons.egg_alt,
            title: 'Protein Hewani',
            percent: '2 dari 2 Porsi',
            detail:
                'Ikan Kembung & Telur Ayam. Fondasi pembentukan sel saraf dan '
                'jaringan vital tubuh janin.',
            value: 1.0,
          ),
          const SizedBox(height: 18),
          const _GiziRow(
            icon: Icons.local_drink,
            title: 'Kalsium & Vitamin D',
            percent: '75% Terpenuhi',
            detail:
                'Kurang 1 porsi susu/yoghurt untuk mendukung kapasitas tulang '
                'Bunda dan rangka janin.',
            value: 0.75,
          ),
          const SizedBox(height: 18),
          const _GiziRow(
            icon: Icons.water_drop,
            title: 'Hidrasi Bunda',
            percent: '84%',
            detail: '2.1 L dari 2.5 L target (8/10 gelas).',
            value: 0.84,
          ),
        ],
      ),
    );
  }
}

class _GiziRow extends StatelessWidget {
  const _GiziRow({
    required this.icon,
    required this.title,
    required this.percent,
    required this.detail,
    required this.value,
  });

  final IconData icon;
  final String title;
  final String percent;
  final String detail;
  final double value;

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
                    percent,
                    style: AppText.bodyStrong.copyWith(
                      color: AppColors.brandText,
                      fontSize: 12.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(detail, style: AppText.bodySm.copyWith(fontSize: 12.5)),
              const SizedBox(height: 9),
              NutrientBar(value: value),
            ],
          ),
        ),
      ],
    );
  }
}

class _ScanCard extends StatelessWidget {
  const _ScanCard({required this.onScan});

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
              Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white.withValues(alpha: 0.9),
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                'NURI AI Lembuh Ibu Hamil',
                style: AppText.caption.copyWith(
                  color: Colors.white.withValues(alpha: 0.9),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Pindai Piring Makan Bunda',
            style: AppText.h2.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Gunakan kamera pintar NURI untuk mengenali takaran protein, zat '
            'besi, dan gizi seimbang piring makan Bunda secara instan.',
            style: AppText.body.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 18),
          _WhitePillButton(
            label: 'Mulai Analisis Piring Makan',
            icon: Icons.camera_alt_outlined,
            onTap: onScan,
          ),
          const SizedBox(height: 12),
          const Row(
            children: [
              Expanded(
                child: _DarkPillButton(
                  label: 'Catat TTD',
                  icon: Icons.add_rounded,
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: _DarkPillButton(
                  label: 'Air (≤250ml)',
                  icon: Icons.water_drop_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PlatePhoto extends StatelessWidget {
  const _PlatePhoto();

  @override
  Widget build(BuildContext context) {
    return NuriPhoto(
      url: DemoImages.plateMeal,
      height: 220,
      radius: AppDimens.radiusXl,
      overlay: Stack(
        children: [
          const Positioned(
            left: 12,
            top: 12,
            child: PhotoTag(
              label: 'Isi Piringku Ibu Hamil',
              icon: Icons.restaurant_rounded,
            ),
          ),
          Positioned(
            right: 12,
            top: 12,
            child: PhotoTag(
              label: 'Trimester 2',
              background: AppColors.pastelGreen,
            ),
          ),
          Positioned(
            left: 12,
            top: 58,
            child: const PhotoTag(label: '½ Sayur & Buah'),
          ),
          Positioned(
            right: 12,
            top: 58,
            child: const PhotoTag(label: '¾ Protein & Lauk'),
          ),
          Positioned(
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(AppDimens.radiusMd),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_dining_rounded,
                    size: 18,
                    color: AppColors.brand,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Porsi Rekomendasi Trimester 2',
                      style: AppText.bodyStrong.copyWith(fontSize: 12.5),
                    ),
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

class _ProteinPlateCard extends StatelessWidget {
  const _ProteinPlateCard();

  @override
  Widget build(BuildContext context) {
    return const NuriCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Piring Kaya Protein Hewani & Asam Folat',
              style: AppText.h3),
          SizedBox(height: 4),
          Text(
            'Komposisi ideal makan siang atau malam untuk tumbuh kembang janin',
            style: AppText.caption,
          ),
          SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: NutrientMetric(value: '460', unit: 'kkal', label: 'Energi'),
              ),
              Expanded(
                child: NutrientMetric(value: '24', unit: 'g', label: 'Protein'),
              ),
              Expanded(
                child: NutrientMetric(
                  value: '4.2',
                  unit: 'mg',
                  label: 'Zat Besi',
                ),
              ),
              Expanded(
                child: NutrientMetric(
                  value: '180',
                  unit: 'mcg',
                  label: 'Asam Folat',
                ),
              ),
            ],
          ),
          SizedBox(height: 18),
          _FoodRow(
            icon: Icons.rice_bowl,
            title: 'Makanan Pokok Kompleks',
            caption: 'Nasi/mie/beras/ubi/pasta (pelapisan energi)',
          ),
          SizedBox(height: 14),
          _FoodRow(
            icon: Icons.eco,
            title: 'Sayuran Hijau Daun',
            caption: 'Sayur bayam & jagung manis kukus (kaya zat besi)',
          ),
          SizedBox(height: 14),
          _FoodRow(
            icon: Icons.set_meal,
            title: 'Lauk Hewani Berkualitas',
            caption: 'Ikan kembung segar & tahu bungkil (tinggi DHA & Omega-3)',
          ),
          SizedBox(height: 14),
          _FoodRow(
            icon: Icons.local_florist,
            title: 'Buah Segar Pilihan',
            caption: 'Jeruk manis & pepaya (vitamin C tinggi)',
          ),
        ],
      ),
    );
  }
}

class _FoodRow extends StatelessWidget {
  const _FoodRow({
    required this.icon,
    required this.title,
    required this.caption,
  });

  final IconData icon;
  final String title;
  final String caption;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconBadge(
          icon: icon,
          size: 38,
          radius: AppDimens.radiusSm,
          color: AppColors.pastelGreenSoft,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppText.title.copyWith(fontSize: 14)),
              const SizedBox(height: 2),
              Text(caption, style: AppText.bodySm.copyWith(fontSize: 12.5)),
            ],
          ),
        ),
      ],
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

class _DarkPillButton extends StatelessWidget {
  const _DarkPillButton({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.14),
      borderRadius: BorderRadius.circular(AppDimens.radiusPill),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        onTap: () {},
        child: SizedBox(
          height: 48,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: AppText.bodyStrong.copyWith(
                    color: Colors.white,
                    fontSize: 13,
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
