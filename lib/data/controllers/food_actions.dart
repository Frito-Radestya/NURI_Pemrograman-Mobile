import '../app_controller.dart';
import '../../domain/models.dart';

/// Aksi catatan makan, artikel, dan rencana menu.
extension FoodActions on AppController {
  FoodLog addFoodLog({
    required String subjectId,
    required MealType meal,
    required List<FoodLogItem> items,
    DateTime? date,
    String? note,
  }) {
    final log = FoodLog(
      id: 'fl_${DateTime.now().microsecondsSinceEpoch}',
      subjectId: subjectId,
      date: dateOnly(date ?? DateTime.now()),
      meal: meal,
      items: items,
      note: note,
      createdAt: DateTime.now(),
    );
    commitState(
      currentState.copyWith(foodLogs: [...currentState.foodLogs, log]),
    );
    return log;
  }

  void updateFoodLog(
    String id, {
    List<FoodLogItem>? items,
    MealType? meal,
    String? note,
  }) {
    commitState(
      currentState.copyWith(
        foodLogs: currentState.foodLogs
            .map(
              (log) => log.id == id
                  ? log.copyWith(items: items, meal: meal, note: note)
                  : log,
            )
            .toList(),
      ),
    );
  }

  void deleteFoodLog(String id) {
    commitState(
      currentState.copyWith(
        foodLogs: currentState.foodLogs.where((log) => log.id != id).toList(),
      ),
    );
  }

  void markArticleRead(String id) {
    commitState(
      currentState.copyWith(readArticles: {...currentState.readArticles, id}),
    );
  }

  void setMealPlan(List<String> menuIds) {
    commitState(currentState.copyWith(mealPlan: menuIds));
  }
}
