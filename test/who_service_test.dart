import 'package:flutter_test/flutter_test.dart';
import 'package:stunting_care/services/measurement_service.dart';
import 'package:stunting_care/services/who_service.dart';

void main() {
  test('Klasifikasi batas z-score F-05.2', () {
    expect(WhoService.classify(-3.5), 'Sangat Pendek');
    expect(WhoService.classify(-2.5), 'Pendek');
    expect(WhoService.classify(0), 'Normal');
    expect(WhoService.classify(3.5), 'Tinggi');
  });

  test('Koreksi WHO ±0,7 cm bila metode tidak sesuai umur', () {
    final m1 = WhoService.resolveMethod(
      ageMonths: 30,
      measuredCm: 90.0,
      measuredIsLength: true,
    );
    expect(m1.isLength, false);
    expect(m1.correctedCm, closeTo(89.3, 0.001));

    final m2 = WhoService.resolveMethod(
      ageMonths: 12,
      measuredCm: 75.0,
      measuredIsLength: false,
    );
    expect(m2.correctedCm, closeTo(75.7, 0.001));
  });

  test('Tolak usia di luar 0-59 bulan', () {
    expect(
      () => WhoService.screen(
        birthDate: DateTime(2020, 1, 1),
        measureDate: DateTime(2026, 1, 1),
        isBoy: true,
        weightKg: 15,
        measuredCm: 100,
        measuredIsLength: false,
      ),
      throwsArgumentError,
    );
  });

  test('Riwayat pengukuran tersimpan berurutan', () {
    final svc = MeasurementService()..clear();
    final r = WhoService.screen(
      birthDate: DateTime.now().subtract(const Duration(days: 365)),
      measureDate: DateTime.now(),
      isBoy: true,
      weightKg: 10,
      measuredCm: 75,
      measuredIsLength: true,
    );
    svc.add(childId: 'c1', date: DateTime.now(), weightKg: 10, result: r);
    expect(svc.forChild('c1').length, 1);
    expect(svc.forChild('c1').first.category, r.category);
  });
}
