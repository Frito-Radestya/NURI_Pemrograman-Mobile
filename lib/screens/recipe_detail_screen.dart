import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/recipe.dart';
import '../services/recipe_service.dart';
import '../theme/app_colors.dart';

class RecipeDetailScreen extends StatefulWidget {
  final Recipe recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  int servings = 1;
  late bool bookmarked;

  @override
  void initState() {
    super.initState();
    bookmarked = widget.recipe.bookmarked;
  }

  void _toggleBookmark() {
    setState(() {
      bookmarked = !bookmarked;
      RecipeService().toggleBookmark(widget.recipe.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    final top = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(28),
                  ),
                  child: Image.network(
                    recipe.imageUrl,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(height: 300, color: AppColors.softBlue),
                  ),
                ),
                Positioned(
                  top: top + 8,
                  left: 16,
                  child: _circleBtn(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  top: top + 8,
                  right: 16,
                  child: _circleBtn(
                    icon: bookmarked ? Icons.bookmark : Icons.bookmark_border,
                    color: bookmarked ? AppColors.primary : AppColors.textDark,
                    onTap: _toggleBookmark,
                  ),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Transform.translate(
              offset: const Offset(0, -28),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.title,
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Text(
                          'Ingredients',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Servings',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(width: 8),
                        _servingBtn(Icons.add, () {
                          setState(() => servings++);
                        }),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            '$servings',
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        _servingBtn(Icons.remove, () {
                          if (servings > 1) setState(() => servings--);
                        }),
                      ],
                    ),
                    const SizedBox(height: 14),
                    ...recipe.ingredients.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Container(
                              width: 3,
                              height: 18,
                              decoration: BoxDecoration(
                                color: AppColors.stepTeal,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                item,
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppColors.textDark.withValues(
                                    alpha: 0.75,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final step = recipe.steps[index];
                final isOrange = index == 1;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Step ${index + 1}',
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isOrange
                              ? AppColors.stepOrange
                              : AppColors.stepTeal,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        step.instruction,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.45,
                          color: AppColors.textDark.withValues(alpha: 0.8),
                        ),
                      ),
                      if (step.imageUrl != null) ...[
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            step.imageUrl!,
                            height: 120,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 120,
                                  color: AppColors.softBlue,
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              }, childCount: recipe.steps.length),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleBtn({
    required IconData icon,
    required VoidCallback onTap,
    Color color = AppColors.textDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.85),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _servingBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE0E0E0)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: AppColors.textDark),
      ),
    );
  }
}
