import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../domain/models.dart';
import '../../../shared/ui.dart';
import '../../../shared/widgets.dart';

class MotherForYouCard extends StatelessWidget {
  const MotherForYouCard({
    super.key,
    required this.article,
    required this.onArticle,
    required this.onMenu,
    this.isPregnancy = false,
  });

  final ContentArticle? article;
  final VoidCallback onArticle;
  final VoidCallback onMenu;
  final bool isPregnancy;

  @override
  Widget build(BuildContext context) {
    final item = article;
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          if (item != null)
            InkWell(
              onTap: onArticle,
              borderRadius: BorderRadius.circular(AppRadius.card),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    NuriImage(
                      asset:
                          item.imageAsset ?? 'assets/images/article_food.jpg',
                      width: 72,
                      height: 72,
                      radius: 12,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            item.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14.5,
                              height: 1.25,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${item.readMinutes} menit baca',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: AppColors.muted,
                    ),
                  ],
                ),
              ),
            ),
          if (item != null) const Divider(height: 1),
          InkWell(
            onTap: onMenu,
            borderRadius: BorderRadius.circular(AppRadius.card),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const SizedBox(
                    width: 38,
                    height: 38,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppColors.mint,
                        borderRadius: BorderRadius.all(Radius.circular(11)),
                      ),
                      child: Icon(
                        Icons.restaurant_menu_rounded,
                        color: AppColors.primary,
                        size: 19,
                      ),
                    ),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isPregnancy
                              ? 'Rekomendasi menu trimester'
                              : 'Inspirasi menu hari ini',
                          style: const TextStyle(
                            fontSize: 13.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isPregnancy
                              ? 'Menu kaya folat, kalsium, zat besi & DHA.'
                              : 'Menu tinggi protein hewani yang mudah dibuat.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    size: 20,
                    color: AppColors.muted,
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
