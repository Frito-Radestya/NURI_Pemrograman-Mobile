import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/data/akg_reference.dart';
import 'package:stunting_care/models/food_entry.dart';
import 'package:stunting_care/services/screening_session_service.dart';

void main() {
  test('AKG anak berbeda by usia', () {
    final bayi = AkgReference.forChild(ageMonths: 3, isBoy: true);
    final balita = AkgReference.forChild(ageMonths: 30, isBoy: true);
    expect(balita.calories, greaterThan(bayi.calories));
  });

  test('percentOf memakai target anak', () {
    const summary = DailyNutritionSummary(
      totalCalories: 700,
      totalProtein: 10,
      totalCarbs: 90,
      totalFat: 20,
    );
    final target = AkgReference.forChild(ageMonths: 30, isBoy: true);
    final pct = summary.percentOf(target);
    expect(pct['calories']!, closeTo(700 / 1350, 0.01));
  });

  test('Rekap sesi menghitung per kategori', () {
    final svc = ScreeningSessionService()..clear();
    final s = svc.create(kaderUserId: 'k1', posyanduName: 'Posyandu A');
    svc.addChild(s.id, 'c1');
    svc.addChild(s.id, 'c2');
    svc.addChild(s.id, 'c3');
    final recap = svc.recap(s.id, (id) {
      return {'c1': 'Normal', 'c2': 'Perlu Pemantauan', 'c3': 'Risiko Stunting'}[id]!;
    });
    expect(recap.total, 3);
    expect(recap.normal, 1);
    expect(recap.followUpChildIds.length, 2);
  });
}
