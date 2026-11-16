import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'article_detail_screen.dart';
import 'education_widgets.dart';

export 'article_detail_screen.dart';

class EducationScreen extends ConsumerStatefulWidget {
  const EducationScreen({super.key, this.showBack = false});

  final bool showBack;

  @override
  ConsumerState<EducationScreen> createState() => _EducationScreenState();
}

class _EducationScreenState extends ConsumerState<EducationScreen> {
  final _search = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final articles = state.contents
        .where((article) => article.published)
        .toList();
    final categories = <String>{
      for (final article in articles) article.category,
    }.toList()..sort();
    final query = _search.text.trim().toLowerCase();
    final filtered = articles.where((article) {
      final matchesCategory =
          _category == null || article.category == _category;
      final matchesQuery =
          query.isEmpty ||
          article.title.toLowerCase().contains(query) ||
          article.excerpt.toLowerCase().contains(query) ||
          article.category.toLowerCase().contains(query) ||
          article.tags.any((tag) => tag.toLowerCase().contains(query));
      return matchesCategory && matchesQuery;
    }).toList();
    final featured = _featured(articles, state);
    final list = filtered
        .where((article) => article.id != featured?.id)
        .toList();

    return Column(
      children: [
        CurvedHeader(
          borderRadius: 32,
          padding: EdgeInsets.fromLTRB(
            20,
            widget.showBack ? 12 : MediaQuery.paddingOf(context).top + 8,
            20,
            20,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (widget.showBack && Navigator.of(context).canPop())
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: GestureDetector(
                            onTap: () => Navigator.of(context).pop(),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.arrow_back_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      const NuriLogo(compact: true, onDark: true),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.menu_book_rounded,
                              size: 13,
                              color: AppColors.secondaryFixed,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Kemenkes & WHO',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Text(
                'Edukasi Kesehatan',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
              const Text(
                'Tumbuh kembang, gizi MPASI, & kehamilan sehat',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x15000000),
                      blurRadius: 10,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  style: const TextStyle(fontSize: 13.5),
                  decoration: InputDecoration(
                    hintText: 'Cari artikel, topik, atau kata kunci…',
                    hintStyle: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.muted,
                    ),
                    suffixIcon: _search.text.isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _search.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close_rounded, size: 18),
                          ),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    filled: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              EducationCategoryChip(
                label: 'Semua',
                selected: _category == null,
                onTap: () => setState(() => _category = null),
              ),
              const SizedBox(width: 7),
              ...categories.map(
                (category) => Padding(
                  padding: const EdgeInsets.only(right: 7),
                  child: EducationCategoryChip(
                    label: category,
                    selected: _category == category,
                    onTap: () => setState(() => _category = category),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: filtered.isEmpty
              ? const EmptyState(
                  title: 'Artikel tidak ditemukan',
                  body: 'Coba kata kunci lain atau pilih kategori Semua.',
                  icon: Icons.search_off_rounded,
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 96),
                  children: [
                    if (featured != null &&
                        _category == null &&
                        query.isEmpty) ...[
                      EducationFeaturedArticle(
                        article: featured,
                        read: state.readArticles.contains(featured.id),
                        onTap: () => _open(context, featured),
                      ),
                      const SizedBox(height: 20),
                    ],
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Artikel untukmu',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Text(
                          '${list.length} artikel',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ...list.map(
                      (article) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: EducationArticleRow(
                          article: article,
                          read: state.readArticles.contains(article.id),
                          onTap: () => _open(context, article),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const NuriDisclaimer(),
                  ],
                ),
        ),
      ],
    );
  }

  ContentArticle? _featured(List<ContentArticle> articles, AppState state) {
    if (articles.isEmpty) return null;
    if (state.pregnancyContext && state.activePregnancy != null) {
      for (final article in articles) {
        if (article.category == 'Kehamilan') return article;
      }
    }
    for (final article in articles) {
      if (article.id == 'art_protein') return article;
    }
    return articles.first;
  }

  void _open(BuildContext context, ContentArticle article) {
    ref.read(appControllerProvider.notifier).markArticleRead(article.id);
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article)),
    );
  }
}
