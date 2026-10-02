import '../data/sample_data.dart';
import '../models/recipe.dart';

/// Menyimpan data resep dan state bookmark agar tetap sinkron antara
/// halaman daftar dan halaman detail.
class RecipeService {
  static final RecipeService _instance = RecipeService._internal();
  factory RecipeService() => _instance;
  RecipeService._internal() {
    _recipes = SampleData.recipes.map(_copyRecipe).toList();
  }

  late List<Recipe> _recipes;

  static const categories = [
    'Semua',
    'Sarapan',
    'Makan Siang',
    'Makan Malam',
    'Camilan',
  ];

  void syncWithSampleData() {
    final existingIds = _recipes.map((r) => r.id).toSet();
    for (final r in SampleData.recipes) {
      if (!existingIds.contains(r.id)) {
        _recipes.add(_copyRecipe(r));
      }
    }
  }

  List<Recipe> get allRecipes {
    syncWithSampleData();
    return List.unmodifiable(_recipes);
  }

  List<Recipe> byCategory(String category) {
    syncWithSampleData();
    if (category == 'Semua') return allRecipes;
    return _recipes.where((r) => r.category == category).toList();
  }

  Recipe? findById(String id) {
    for (final recipe in _recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  bool toggleBookmark(String id) {
    final recipe = findById(id);
    if (recipe == null) return false;
    recipe.bookmarked = !recipe.bookmarked;
    return recipe.bookmarked;
  }

  static Recipe _copyRecipe(Recipe source) {
    return Recipe(
      id: source.id,
      title: source.title,
      time: source.time,
      ingredientsPreview: source.ingredientsPreview,
      imageUrl: source.imageUrl,
      ingredients: List<String>.from(source.ingredients),
      steps: source.steps
          .map(
            (step) => RecipeStep(
              instruction: step.instruction,
              imageUrl: step.imageUrl,
            ),
          )
          .toList(),
      category: source.category,
      bookmarked: source.bookmarked,
    );
  }
}
