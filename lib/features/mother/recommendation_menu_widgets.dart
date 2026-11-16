import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class RecommendationTrimesterGuideCard extends StatelessWidget {
  const RecommendationTrimesterGuideCard({super.key, required this.trimester});

  final int trimester;

  @override
  Widget build(BuildContext context) {
    final (title, focus, tip) = switch (trimester) {
      1 => (
        'Fokus Trimester 1: Asam Folat & Atasi Mual',
        'Pembentukan tabung saraf dan organ vital janin (cegah anensefali & spina bifida).',
        'Makan dalam porsi kecil tapi sering (5–6x sehari), pilih makanan hangat yang tidak berbau tajam, dan perbanyak vitamin B6.',
      ),
      2 => (
        'Fokus Trimester 2: Pertumbuhan Tulang & Organ',
        'Pertumbuhan pesat janin membutuhkan tambahan energi +300 kkal dan protein hewani tinggi.',
        'Pastikan lauk ikan kembung, telur, atau daging selalu ada untuk mencegah Berat Badan Lahir Rendah (BBLR).',
      ),
      _ => (
        'Fokus Trimester 3: Otak Janin & Persiapan ASI',
        'Pematangan otak dan cadangan zat besi janin, serta persiapan laktasi Ibu.',
        'Penuhi asam lemak DHA (ikan laut), zat besi tinggi cegah anemia saat bersalin, dan serat tinggi untuk cegah sembelit.',
      ),
    };

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: const BoxDecoration(
                  color: AppColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.stars_rounded,
                  size: 16,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            focus,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
              color: AppColors.text,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tip,
            style: const TextStyle(
              fontSize: 11.5,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class MenuIdea {
  const MenuIdea({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    required this.kcal,
    required this.protein,
    required this.minutes,
    required this.tags,
    required this.ingredients,
    required this.steps,
  });

  final String id;
  final String title;
  final String subtitle;
  final String image;
  final int kcal;
  final int protein;
  final int minutes;
  final List<String> tags;
  final List<String> ingredients;
  final List<String> steps;
}

class RecommendationHeroBanner extends StatelessWidget {
  const RecommendationHeroBanner({super.key, required this.pregnancyMode});

  final bool pregnancyMode;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.peachSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            pregnancyMode ? 'Gizi ibu hamil' : 'Gizi balita',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.coral,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            pregnancyMode
                ? 'Makan untuk dua, bukan dua porsi.'
                : 'Piring kecil, gizi lengkap.',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 21,
              height: 1.2,
              fontWeight: FontWeight.w800,
              color: AppColors.text,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            pregnancyMode
                ? 'Tambahkan protein hewani, sayur hijau, buah, dan cukup air setiap hari.'
                : 'Setiap makan usahakan ada makanan pokok, protein hewani, sayur, dan buah.',
            style: const TextStyle(
              fontSize: 13,
              height: 1.45,
              color: AppColors.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class RecommendationMenuCard extends StatelessWidget {
  const RecommendationMenuCard({
    super.key,
    required this.menu,
    required this.selected,
    required this.onToggle,
    required this.onRecipe,
  });

  final MenuIdea menu;
  final bool selected;
  final VoidCallback onToggle;
  final VoidCallback onRecipe;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(12),
      borderColor: selected ? AppColors.primary : AppColors.line,
      color: selected ? AppColors.mint : AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              NuriImage(asset: menu.image, width: 84, height: 84, radius: 14),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            menu.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14.5,
                              height: 1.2,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: onToggle,
                          borderRadius: BorderRadius.circular(10),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.primary
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(7),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.primary
                                      : AppColors.muted,
                                  width: 1.5,
                                ),
                              ),
                              child: selected
                                  ? const Icon(
                                      Icons.check_rounded,
                                      size: 16,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      menu.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.35,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: menu.tags
                          .map(
                            (tag) => Pill(
                              label: tag,
                              background: AppColors.surfaceSubtle,
                              foreground: AppColors.text,
                              fontSize: 11,
                            ),
                          )
                          .toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                size: 15,
                color: AppColors.amber,
              ),
              const SizedBox(width: 4),
              Text(
                '${menu.kcal} kkal',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const SizedBox(width: 12),
              const Icon(
                Icons.fitness_center_rounded,
                size: 14,
                color: AppColors.primary,
              ),
              const SizedBox(width: 4),
              Text(
                '${menu.protein} g protein',
                style: const TextStyle(fontSize: 12, color: AppColors.muted),
              ),
              const Spacer(),
              TextButton(
                onPressed: onRecipe,
                style: TextButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Lihat resep'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class RecommendationRecipeMetric extends StatelessWidget {
  const RecommendationRecipeMetric({
    super.key,
    required this.icon,
    required this.value,
  });
  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 15, color: AppColors.primary),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
