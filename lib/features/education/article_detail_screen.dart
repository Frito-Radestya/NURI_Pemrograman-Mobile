import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  const ArticleDetailScreen({super.key, required this.article});

  final ContentArticle article;

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(appControllerProvider.notifier)
          .markArticleRead(widget.article.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final article = widget.article;
    final paragraphs = article.body.split('\n\n');
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                NuriImage(
                  asset: article.imageAsset ?? 'assets/images/article_food.jpg',
                  width: double.infinity,
                  height: 230,
                  radius: 0,
                ),
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.36),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: SafeArea(
                      bottom: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 30),
                        child: Row(
                          children: [
                            InkWell(
                              onTap: () => Navigator.of(context).pop(),
                              borderRadius: BorderRadius.circular(100),
                              child: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.94),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_back_rounded,
                                  size: 20,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 11,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.94),
                                borderRadius: BorderRadius.circular(100),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.schedule_rounded,
                                    size: 14,
                                    color: AppColors.muted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${article.readMinutes} menit',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.text,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Transform.translate(
              offset: const Offset(0, -18),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.line),
                  boxShadow: AppShadows.soft,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Pill(
                          label: article.category,
                          background: AppColors.mint,
                          foreground: AppColors.primaryDark,
                          fontSize: 11.5,
                        ),
                        const Spacer(),
                        const Icon(
                          Icons.verified_outlined,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            'Ditinjau ${article.reviewedBy}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      article.title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.22,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      article.excerpt,
                      style: const TextStyle(
                        fontSize: 13.5,
                        color: AppColors.muted,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ...paragraphs.map(
                    (paragraph) => Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: Text(
                        paragraph,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.7,
                          color: AppColors.text,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  AppCard(
                    padding: const EdgeInsets.all(15),
                    color: AppColors.surfaceSubtle,
                    borderColor: Colors.transparent,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(
                              Icons.menu_book_outlined,
                              size: 16,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Sumber & peninjau',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          article.source,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                            height: 1.45,
                          ),
                        ),
                        Text(
                          'Ditinjau oleh ${article.reviewedBy} • ${article.readMinutes} menit baca',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                        if (article.tags.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: article.tags
                                .map(
                                  (tag) => Pill(
                                    label: '#$tag',
                                    background: AppColors.surface,
                                    foreground: AppColors.muted,
                                    fontSize: 11.5,
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const NuriDisclaimer(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
