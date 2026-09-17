class Recipe {
  final String id;
  final String title;
  final String time;
  final String ingredientsPreview;
  final String imageUrl;
  final List<String> ingredients;
  final List<RecipeStep> steps;
  final String category;
  bool bookmarked;

  Recipe({
    required this.id,
    required this.title,
    required this.time,
    required this.ingredientsPreview,
    required this.imageUrl,
    required this.ingredients,
    required this.steps,
    required this.category,
    this.bookmarked = false,
  });
}

class RecipeStep {
  final String instruction;
  final String? imageUrl;

  const RecipeStep({required this.instruction, this.imageUrl});
}
