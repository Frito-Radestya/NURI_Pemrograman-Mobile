import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../domain/nutrition/food_catalog.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class ManualFoodSearchScreen extends StatefulWidget {
  const ManualFoodSearchScreen({super.key});

  @override
  State<ManualFoodSearchScreen> createState() => _ManualFoodSearchScreenState();
}

class _ManualFoodSearchScreenState extends State<ManualFoodSearchScreen> {
  final _search = TextEditingController();
  String _category = 'Semua';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<FoodCatalogItem> _results() {
    final catalog = FoodCatalog.instance;
    final query = _search.text.trim().toLowerCase();
    return catalog.foods.where((food) {
      final matchesCategory =
          _category == 'Semua' || food.category == _category;
      final matchesQuery =
          query.isEmpty ||
          food.name.toLowerCase().contains(query) ||
          food.originalName.toLowerCase().contains(query);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _pick(FoodCatalogItem food) async {
    final grams = await showNuriSheet<double>(
      context: context,
      builder: (sheetContext) {
        var value = 100.0;
        return StatefulBuilder(
          builder: (context, setSheetState) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(food.name, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                Text(
                  '${food.energyKcal?.round() ?? '—'} kkal • ${food.proteinG?.toStringAsFixed(1) ?? '—'} g protein per 100 g',
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.muted,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Porsi',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    NuriNumberStepper(
                      value: value,
                      min: 5,
                      max: 500,
                      step: 5,
                      suffix: 'g',
                      onChanged: (next) => setSheetState(() => value = next),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSubtle,
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Text(
                    '${((food.energyKcal ?? 0) * value / 100).round()} kkal • '
                    '${((food.proteinG ?? 0) * value / 100).toStringAsFixed(1)} g protein',
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                NuriButton(
                  label: 'Tambahkan',
                  icon: Icons.add_rounded,
                  onPressed: () => Navigator.of(sheetContext).pop(value),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sumber: TKPI 2017 • Kemenkes RI',
                  style: TextStyle(fontSize: 11.5, color: AppColors.muted),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (!mounted || grams == null) return;
    Navigator.of(context)
        .pop([food.toLogItem(grams: grams, foodSource: FoodSource.manual)]);
  }

  @override
  Widget build(BuildContext context) {
    final catalog = FoodCatalog.instance;
    final results = _results();
    final categories = ['Semua', ...catalog.categories];
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            ScreenHeader(
              title: 'Cari makanan',
              subtitle: '${catalog.foods.length} item TKPI 2017',
              onBack: () => Navigator.of(context).pop(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: NuriTextField(
                label: 'Nama makanan',
                controller: _search,
                hint: 'Cari nasi, telur, ikan…',
                prefixIcon: Icons.search_rounded,
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              height: 38,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: categories.map((category) {
                  final selected = category == _category;
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: selected,
                      onSelected: (_) => setState(() => _category = category),
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selected ? Colors.white : AppColors.text,
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      visualDensity: VisualDensity.compact,
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: results.isEmpty
                  ? const EmptyState(
                      title: 'Makanan tidak ditemukan',
                      body: 'Coba kata kunci lain atau pilih kategori berbeda.',
                      icon: Icons.search_off_rounded,
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      itemCount: results.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 7),
                      itemBuilder: (context, index) {
                        final food = results[index];
                        return AppCard(
                          padding: const EdgeInsets.all(12),
                          onTap: () => _pick(food),
                          child: Row(
                            children: [
                              Container(
                                width: 42,
                                height: 42,
                                decoration: BoxDecoration(
                                  color: AppColors.mint,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.restaurant_rounded,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      food.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      '${food.energyKcal?.round() ?? '—'} kkal • ${food.proteinG?.toStringAsFixed(1) ?? '—'} g protein / 100 g',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: AppColors.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Pill(
                                label: '100 g',
                                background: AppColors.surfaceSubtle,
                                foreground: AppColors.muted,
                                fontSize: 11.5,
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.add_circle_outline_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
