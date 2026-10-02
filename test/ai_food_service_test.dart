import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/services/ai_food_service.dart';

void main() {
  test('Mapping label pretrained ke TKPI', () {
    final svc = AiFoodService();
    expect(svc.mapLabelToFoodId('fried chicken'), 'ayam_goreng');
    expect(svc.mapLabelToFoodId('Banana'), 'pisang');
    expect(svc.mapLabelToFoodId('rendang padang asli'), isNull);
  });

  test('Heuristik selalu beri 3 kandidat + threshold', () {
    final svc = AiFoodService();
    final preds = svc.classifyHeuristic('nasi_putih.jpg');
    expect(preds.length, 3);
    expect(preds.first.foodItemId, isNotNull);
  });
}
