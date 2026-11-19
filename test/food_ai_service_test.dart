import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nuri/data/food_ai_service.dart';
import 'package:nuri/domain/models.dart';
import 'package:nuri/domain/nutrition/food_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final json = await rootBundle.loadString('assets/data/tkpi_v1.json');
    FoodCatalog.setInstance(FoodCatalog.fromJsonString(json));
  });

  group('FoodAiService.parseResponse', () {
    test('membaca JSON array dari jawaban model', () {
      final items = FoodAiService.parseResponse(
        '```json\n'
        '[{"name": "Pizza Keju Spesial", "grams": 150, "category": "Makanan Pokok", '
        '"energyKcal": 130, "proteinG": 2.4, "fatG": 0.3, "carbG": 28.7, '
        '"confidence": 0.93}]\n'
        '```',
      );

      expect(items, hasLength(1));
      expect(items.first.grams, 150);
      expect(items.first.confidence, closeTo(0.93, 0.001));
      expect(items.first.toLogItem().source, FoodSource.ai);
      expect(items.first.toLogItem().kcal, closeTo(195, 0.001));
    });

    test('mencocokkan nama AI dengan katalog TKPI', () {
      final items = FoodAiService.parseResponse(
        '[{"name": "Nasi putih", "grams": 100, '
        '"category": "Makanan Pokok", "energyKcal": 1, '
        '"proteinG": 1, "fatG": 1, "carbG": 1, "confidence": 0.9}]',
      );

      final item = items.single;
      expect(item.food.source, contains('TKPI'));
      expect(item.food.energyKcal, isNot(1));
    });

    test('memakai estimasi AI saat katalog tidak cocok', () {
      final items = FoodAiService.parseResponse(
        '[{"name": "Pizza Keju Spesial", "grams": 200, '
        '"category": "Makanan Pokok", "energyKcal": 266, "proteinG": 11, '
        '"fatG": 10, "carbG": 33, "confidence": 0.8}]',
      );

      final item = items.single;
      expect(item.food.id, startsWith('ai_'));
      expect(item.food.source, 'AI Vision 9router');
      expect(item.food.energyKcal, 266);
      expect(item.toLogItem().kcal, closeTo(532, 0.001));
    });

    test('menolak jawaban yang bukan JSON', () {
      expect(
        () =>
            FoodAiService.parseResponse('Maaf, saya tidak bisa melihat foto.'),
        throwsA(isA<FoodAiException>()),
      );
    });

    test('array kosong berarti tidak ada makanan', () {
      expect(FoodAiService.parseResponse('[]'), isEmpty);
    });
  });
}
