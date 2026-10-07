import 'package:flutter_test/flutter_test.dart';

import 'package:nuri_app/data/reference_data.dart';
import 'package:nuri_app/domain/engines/growth_engine.dart';
import 'package:nuri_app/domain/models/child.dart';
import 'package:nuri_app/domain/models/growth_result.dart';
import 'package:nuri_app/domain/models/growth_status.dart';
import 'package:nuri_app/domain/models/measurement.dart';
import 'package:nuri_app/domain/models/nutrient.dart';
import 'package:nuri_app/domain/models/sex.dart';
import 'package:nuri_app/domain/models/who_lms.dart';
import 'package:nuri_app/state/app_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ReferenceData ref;
  late GrowthEngine engine;

  setUpAll(() async {
    ref = await ReferenceData.load();
    engine = GrowthEngine(ref.whoLms);
  });

  Child childBornDaysAgo(int days, Sex sex) => Child(
    id: 'c',
    createdBy: 'u',
    nickname: 'Uji',
    birthDate: DateTime.now().subtract(Duration(days: days)),
    sex: sex,
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  group('Aset LMS WHO resmi', () {
    test('median sesuai publikasi WHO 2006', () {
      expect(ref.whoLms.atDays(Sex.lakiLaki, 0).m, closeTo(49.8842, 0.001));
      expect(ref.whoLms.atDays(Sex.lakiLaki, 365).m, closeTo(75.7391, 0.001));
      expect(ref.whoLms.atDays(Sex.lakiLaki, 730).m, closeTo(87.8018, 0.001));
      // Perpindahan panjang -> tinggi 0,7 cm pada hari ke-731.
      expect(ref.whoLms.atDays(Sex.lakiLaki, 731).m, closeTo(87.1303, 0.001));
      expect(ref.whoLms.atDays(Sex.lakiLaki, 1826).m, closeTo(109.9593, 0.001));
      expect(ref.whoLms.atDays(Sex.perempuan, 365).m, closeTo(74.0049, 0.001));
      expect(ref.whoLms.atDays(Sex.perempuan, 1826).m, closeTo(109.4189, 0.001));
    });

    test('rumus LMS bolak-balik (z -> cm -> z)', () {
      for (final Sex sex in Sex.values) {
        for (final double z in <double>[-3, -2, -1, 0, 1, 2, 3]) {
          final LmsPoint p = ref.whoLms.atDays(sex, 400);
          final double cm = p.valueForZ(z);
          expect(p.zScoreFor(cm), closeTo(z, 0.0001));
        }
      }
    });
  });

  group('GrowthEngine (F4/F5)', () {
    test('z-score = 0 saat tinggi sama dengan median pada berbagai umur', () {
      for (final int days in <int>[0, 100, 365, 730, 731, 1096, 1790]) {
        final Child c = childBornDaysAgo(days, Sex.lakiLaki);
        final double median = ref.whoLms.atDays(Sex.lakiLaki, days).m;
        final GrowthResult r = engine.assess(
          child: c,
          measuredOn: DateTime.now(),
          weightKg: 9,
          lengthHeightCm: median,
          method: MeasureMethod.recommendedForDays(days),
        );
        expect(r.zScore, closeTo(0, 0.01), reason: 'umur $days hari');
        expect(r.status, GrowthStatus.normal);
      }
    });

    test('koreksi metode ukur +0,7 cm saat berdiri padahal < 24 bulan', () {
      final Child c = childBornDaysAgo(365, Sex.lakiLaki);
      final GrowthResult r = engine.assess(
        child: c,
        measuredOn: DateTime.now(),
        weightKg: 9,
        lengthHeightCm: 74.0,
        method: MeasureMethod.berdiri,
      );
      expect(r.methodAdjusted, isTrue);
      expect(r.correctedCm, closeTo(74.7, 0.0001));
      expect(r.recommendedMethod, MeasureMethod.berbaring);
    });

    test('koreksi metode ukur -0,7 cm saat berbaring padahal >= 24 bulan', () {
      final Child c = childBornDaysAgo(800, Sex.perempuan);
      final GrowthResult r = engine.assess(
        child: c,
        measuredOn: DateTime.now(),
        weightKg: 11,
        lengthHeightCm: 88.0,
        method: MeasureMethod.berbaring,
      );
      expect(r.methodAdjusted, isTrue);
      expect(r.correctedCm, closeTo(87.3, 0.0001));
    });

    test('menolak umur di luar 0-59 bulan', () {
      final Child c = childBornDaysAgo(60 * 31, Sex.lakiLaki); // ~61 bulan
      expect(
        () => engine.assess(
          child: c,
          measuredOn: DateTime.now(),
          weightKg: 15,
          lengthHeightCm: 105,
          method: MeasureMethod.berdiri,
        ),
        throwsA(
          isA<GrowthValidationException>().having(
            (GrowthValidationException e) => e.kind,
            'kind',
            GrowthValidationKind.umurDiLuarRentang,
          ),
        ),
      );
    });

    test('menolak nilai tidak masuk akal (z di luar -6..+6)', () {
      final Child c = childBornDaysAgo(730, Sex.perempuan);
      expect(
        () => engine.assess(
          child: c,
          measuredOn: DateTime.now(),
          weightKg: 9,
          lengthHeightCm: 40,
          method: MeasureMethod.berdiri,
        ),
        throwsA(isA<GrowthValidationException>()),
      );
    });
  });

  group('Klasifikasi status (PRD Bagian 6)', () {
    test('batas kategori TB/U', () {
      expect(GrowthStatus.fromZ(-3.1), GrowthStatus.sangatPendek);
      expect(GrowthStatus.fromZ(-3.0), GrowthStatus.pendek);
      expect(GrowthStatus.fromZ(-2.0), GrowthStatus.normal);
      expect(GrowthStatus.fromZ(3.0), GrowthStatus.normal);
      expect(GrowthStatus.fromZ(3.1), GrowthStatus.tinggi);
    });
  });

  group('Traffic light gizi (F11)', () {
    test('ambang <80 kurang, 80-120 cukup, >120 lebih', () {
      expect(TrafficLight.fromPercent(50), TrafficLight.kurang);
      expect(TrafficLight.fromPercent(80), TrafficLight.cukup);
      expect(TrafficLight.fromPercent(120), TrafficLight.cukup);
      expect(TrafficLight.fromPercent(121), TrafficLight.lebih);
    });
  });

  group('Pencarian makanan (F10)', () {
    test('menemukan makanan lokal dan tetap cepat', () {
      final Stopwatch sw = Stopwatch()..start();
      final hits = ref.tkpi.search('nasi');
      sw.stop();
      expect(hits, isNotEmpty);
      expect(sw.elapsedMilliseconds, lessThan(300));
    });
  });

  group('Repository: append-only, consent, sinkron (F3/F4/F8/F12)', () {
    test('pengukuran tidak menimpa, tersimpan sebagai riwayat', () {
      final NuriAppState state = NuriAppState.forTesting(ref);
      final Child c = state.addChild(
        nickname: 'Anak Uji',
        birthDate: DateTime.now().subtract(const Duration(days: 400)),
        sex: Sex.lakiLaki,
      );
      state.recordMeasurement(
        child: c,
        measuredOn: DateTime.now().subtract(const Duration(days: 30)),
        weightKg: 9,
        lengthHeightCm: 74,
        method: MeasureMethod.berbaring,
      );
      state.recordMeasurement(
        child: c,
        measuredOn: DateTime.now(),
        weightKg: 9.5,
        lengthHeightCm: 76,
        method: MeasureMethod.berbaring,
      );
      expect(state.screeningsFor(c.id).length, 2);
      expect(state.latestScreening(c.id)!.measurement.lengthHeightCm, 76);
    });

    test('menolak tanggal lahir di masa depan (F3)', () {
      final NuriAppState state = NuriAppState.forTesting(ref);
      expect(
        () => state.addChild(
          nickname: 'X',
          birthDate: DateTime.now().add(const Duration(days: 1)),
          sex: Sex.perempuan,
        ),
        throwsA(isA<FormatException>()),
      );
    });

    test('outbox tersinkron saat online, tanpa duplikat (F12)', () {
      final NuriAppState state = NuriAppState.forTesting(ref);
      state.addChild(
        nickname: 'Anak Uji',
        birthDate: DateTime.now().subtract(const Duration(days: 200)),
        sex: Sex.perempuan,
      );
      expect(state.pendingCount, greaterThan(0));
      state.setOnline(true);
      return state.sync().then((int sent) {
        expect(sent, greaterThan(0));
        expect(state.pendingCount, 0);
      });
    });
  });
}
