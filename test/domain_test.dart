import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:nuri/data/app_controller.dart';
import 'package:nuri/data/app_repository.dart';
import 'package:nuri/data/auth_service.dart';
import 'package:nuri/data/demo_seed.dart';
import 'package:nuri/data/firestore_service.dart';
import 'package:nuri/domain/growth/growth_calculator.dart';
import 'package:nuri/domain/growth/who_lms.dart';
import 'package:nuri/domain/models.dart';
import 'package:nuri/domain/nutrition/nutrition_calculator.dart';
import 'package:nuri/domain/pregnancy/pregnancy_calculator.dart';

void main() {
  late WhoReference who;
  late GrowthCalculator growth;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    who = WhoReference(
      boys: WhoLmsTable.fromJsonString(
        await rootBundle.loadString('assets/data/who_hfa_boys.json'),
      ),
      girls: WhoLmsTable.fromJsonString(
        await rootBundle.loadString('assets/data/who_hfa_girls.json'),
      ),
    );
    WhoReference.setInstance(who);
    growth = GrowthCalculator(reference: who);
  });

  group('WHO LMS', () {
    test('median panjang lahir sesuai tabel WHO', () {
      expect(who.boys.atAgeDays(0).m, closeTo(49.8842, 0.0001));
      expect(who.girls.atAgeDays(0).m, closeTo(49.1477, 0.0001));
    });

    test('valueAtZ(0) sama dengan median', () {
      expect(
        who.boys.valueAtZ(548, 0),
        closeTo(who.boys.atAgeDays(548).m, 1e-9),
      );
      expect(
        who.girls.valueAtZ(548, 0),
        closeTo(who.girls.atAgeDays(548).m, 1e-9),
      );
    });

    test('interpolasi linear antar baris harian', () {
      final a = who.boys.atAgeDays(100).m;
      final b = who.boys.atAgeDays(101).m;
      expect(who.boys.atAgeDays(100.5).m, closeTo((a + b) / 2, 1e-9));
    });

    test('nilai di luar rentang di-clamp ke baris terakhir', () {
      final last = who.boys.lms.last;
      final point = who.boys.atAgeDays(5000);
      expect(point.m, closeTo(last.m, 1e-9));
    });
  });

  group('GrowthCalculator', () {
    final dob = DateTime(2024, 1, 1);
    final at18m = dob.add(const Duration(days: 548));

    test('median tepat menghasilkan z 0 dan kategori normal', () {
      final result = growth.evaluate(
        heightCm: 82.2628,
        weightKg: 11.0,
        sex: Sex.male,
        dob: dob,
        measureDate: at18m,
        method: MeasurementMethod.lying,
      );
      expect(result.zScore, closeTo(0, 0.001));
      expect(result.category, GrowthCategory.normal);
      expect(result.ageMonths, 18);
      expect(result.medianCm, closeTo(82.2628, 0.001));
      expect(result.correctionNote, isNull);
    });

    test('kategori pendek dan sangat pendek sesuai ambang -2/-3 SD', () {
      GrowthEvaluation evalAt(double height) => growth.evaluate(
        heightCm: height,
        weightKg: 10.5,
        sex: Sex.male,
        dob: dob,
        measureDate: at18m,
        method: MeasurementMethod.lying,
      );

      final stunted = evalAt(75);
      expect(stunted.zScore, closeTo(-2.69, 0.02));
      expect(stunted.category, GrowthCategory.stunted);
      expect(stunted.isBelowMinus2, isTrue);
      expect(stunted.isBelowMinus3, isFalse);

      final severe = evalAt(72);
      expect(severe.zScore, lessThan(-3));
      expect(severe.category, GrowthCategory.severelyStunted);
      expect(severe.isBelowMinus3, isTrue);

      final tall = evalAt(93);
      expect(tall.zScore, greaterThan(3));
      expect(tall.category, GrowthCategory.tall);
    });

    test('koreksi +0,7 cm saat berdiri di bawah 24 bulan', () {
      final result = growth.evaluate(
        heightCm: 82.0,
        weightKg: 11.0,
        sex: Sex.male,
        dob: dob,
        measureDate: at18m,
        method: MeasurementMethod.standing,
      );
      expect(result.correctedCm, closeTo(82.7, 1e-9));
      expect(result.correctionNote, contains('+0,7'));
      expect(result.flags, contains('Koreksi PB +0,7 cm'));
    });

    test('koreksi -0,7 cm saat berbaring di usia 24 bulan atau lebih', () {
      final result = growth.evaluate(
        heightCm: 87.8,
        weightKg: 12.0,
        sex: Sex.male,
        dob: dob,
        measureDate: dob.add(const Duration(days: 731)),
        method: MeasurementMethod.lying,
      );
      expect(result.ageMonths, 24);
      expect(result.correctedCm, closeTo(87.1, 1e-9));
      expect(result.correctionNote, contains('−0,7'));
      expect(result.flags, contains('Koreksi TB −0,7 cm'));
    });

    test('klasifikasi batas -3, -2, dan 3 SD', () {
      expect(GrowthCalculator.classify(-3.001), GrowthCategory.severelyStunted);
      expect(GrowthCalculator.classify(-3), GrowthCategory.stunted);
      expect(GrowthCalculator.classify(-2.001), GrowthCategory.stunted);
      expect(GrowthCalculator.classify(-2), GrowthCategory.normal);
      expect(GrowthCalculator.classify(3), GrowthCategory.normal);
      expect(GrowthCalculator.classify(3.001), GrowthCategory.tall);
    });

    test('menolak tinggi, berat, tanggal, dan usia di luar batas', () {
      expect(
        () => growth.evaluate(
          heightCm: 34,
          weightKg: 10,
          sex: Sex.male,
          dob: dob,
          measureDate: at18m,
          method: MeasurementMethod.lying,
        ),
        throwsA(isA<GrowthValidationException>()),
      );
      expect(
        () => growth.evaluate(
          heightCm: 80,
          weightKg: 40,
          sex: Sex.male,
          dob: dob,
          measureDate: at18m,
          method: MeasurementMethod.lying,
        ),
        throwsA(isA<GrowthValidationException>()),
      );
      expect(
        () => growth.evaluate(
          heightCm: 80,
          weightKg: 10,
          sex: Sex.male,
          dob: dob,
          measureDate: dob.subtract(const Duration(days: 1)),
          method: MeasurementMethod.lying,
        ),
        throwsA(isA<GrowthValidationException>()),
      );
      expect(
        () => growth.evaluate(
          heightCm: 110,
          weightKg: 18,
          sex: Sex.male,
          dob: dob,
          measureDate: dob.add(const Duration(days: 1857)),
          method: MeasurementMethod.standing,
        ),
        throwsA(isA<GrowthValidationException>()),
      );
    });

    test('z ekstrem ditolak kecuali allowImplausible', () {
      expect(
        () => growth.evaluate(
          heightCm: 120,
          weightKg: 11,
          sex: Sex.male,
          dob: dob,
          measureDate: at18m,
          method: MeasurementMethod.lying,
        ),
        throwsA(isA<GrowthValidationException>()),
      );
      final allowed = growth.evaluate(
        heightCm: 120,
        weightKg: 11,
        sex: Sex.male,
        dob: dob,
        measureDate: at18m,
        method: MeasurementMethod.lying,
        allowImplausible: true,
      );
      expect(allowed.implausible, isTrue);
      expect(allowed.flags.any((f) => f.contains('di luar ±6')), isTrue);
    });

    test('default method mengikuti umur', () {
      expect(GrowthCalculator.defaultMethodForAge(23), MeasurementMethod.lying);
      expect(
        GrowthCalculator.defaultMethodForAge(24),
        MeasurementMethod.standing,
      );
    });
  });

  group('Measurement derived flags', () {
    Measurement measurement(List<String> flags) => Measurement(
      id: 'm1',
      date: DateTime(2026, 1, 1),
      ageDays: 548,
      ageMonths: 18,
      weightKg: 11,
      measuredCm: 82,
      method: MeasurementMethod.standing,
      correctedCm: 82.7,
      zHfa: 0,
      category: GrowthCategory.normal,
      source: 'kader',
      flags: flags,
    );

    test('catatan koreksi diturunkan dari flag', () {
      expect(
        measurement(['Koreksi PB +0,7 cm']).correctionNote,
        contains('berdiri'),
      );
      expect(
        measurement(['Koreksi TB −0,7 cm']).correctionNote,
        contains('berbaring'),
      );
      expect(measurement([]).correctionNote, isNull);
    });

    test('flag z ekstrem menandai implausible', () {
      expect(
        measurement(['Nilai z di luar ±6; periksa kembali input']).implausible,
        isTrue,
      );
      expect(measurement([]).implausible, isFalse);
    });
  });

  group('NutritionCalculator', () {
    test('persen dan status null-safe', () {
      expect(NutritionCalculator.percent(null, 100), isNull);
      expect(NutritionCalculator.percent(50, 0), isNull);
      expect(NutritionCalculator.percent(50, 100), 50);
      expect(NutritionCalculator.status(null, 100), isNull);
    });

    test('batas status gizi 80% dan 110%', () {
      expect(NutrientStatus.fromPercent(79.9), NutrientStatus.low);
      expect(NutrientStatus.fromPercent(80), NutrientStatus.adequate);
      expect(NutrientStatus.fromPercent(110), NutrientStatus.adequate);
      expect(NutrientStatus.fromPercent(110.1), NutrientStatus.high);
    });

    test('status protein hewani memakai target gram', () {
      expect(
        NutritionCalculator.animalProteinStatus(null, 15),
        NutrientStatus.low,
      );
      expect(
        NutritionCalculator.animalProteinStatus(11.9, 15),
        NutrientStatus.low,
      );
      expect(
        NutritionCalculator.animalProteinStatus(12, 15),
        NutrientStatus.adequate,
      );
      expect(
        NutritionCalculator.animalProteinStatus(17, 15),
        NutrientStatus.high,
      );
    });

    test('AKG anak berpindah pada batas usia', () {
      const akg = AkgReference();
      expect(akg.forChild(5, Sex.male).energyKcal, 550);
      expect(akg.forChild(6, Sex.male).energyKcal, 800);
      expect(akg.forChild(11, Sex.male).energyKcal, 800);
      expect(akg.forChild(12, Sex.male).energyKcal, 1350);
      expect(akg.forChild(35, Sex.female).energyKcal, 1350);
      expect(akg.forChild(36, Sex.female).energyKcal, 1400);
    });

    test('AKG kehamilan per trimester', () {
      const akg = AkgReference();
      expect(akg.forPregnancy(1).energyKcal, 2250);
      expect(akg.forPregnancy(2).energyKcal, 2550);
      expect(akg.forPregnancy(3).proteinG, 85);
      expect(AkgReference.ttdTarget, 90);
      expect(AkgReference.ancTarget, 6);
    });

    test('targetFor mengembalikan nilai sesuai nutrisi', () {
      const akg = AkgReference();
      final target = akg.forChild(18, Sex.male);
      expect(target.targetFor('protein'), 20);
      expect(target.targetFor('zat besi'), 7);
      expect(target.targetFor('tidak dikenal'), target.energyKcal);
    });
  });

  group('NutritionTotals', () {
    test('menjumlahkan item dan menandai nutrisi yang hilang', () {
      const items = [
        FoodLogItem(
          foodId: 'a',
          name: 'Nasi',
          grams: 100,
          kcalPer100: 180,
          proteinPer100: 3,
          fatPer100: 0.3,
          carbPer100: 39.8,
          ironPer100: 0.4,
          zincPer100: 0.4,
        ),
        FoodLogItem(
          foodId: 'b',
          name: 'Telur',
          grams: 50,
          kcalPer100: 154,
          proteinPer100: 12.4,
          fatPer100: 10.8,
          carbPer100: 0.7,
          ironPer100: 1.2,
          zincPer100: 1.0,
        ),
      ];
      final totals = NutritionTotals.fromItems(items);
      expect(totals.kcal, closeTo(180 + 77, 0.001));
      expect(totals.proteinG, closeTo(3 + 6.2, 0.001));
      expect(totals.incomplete, isFalse);

      const partial = [
        FoodLogItem(foodId: 'c', name: 'Air', grams: 200, kcalPer100: 0),
      ];
      final partialTotals = NutritionTotals.fromItems(partial);
      expect(partialTotals.kcal, 0);
      expect(partialTotals.proteinG, isNull);
      expect(partialTotals.incomplete, isTrue);
      expect(partialTotals.incompleteNutrients, contains('protein'));
    });

    test('daftar kosong menghasilkan total kosong', () {
      final totals = NutritionTotals.fromItems(const []);
      expect(totals.kcal, isNull);
      expect(totals.incomplete, isFalse);
    });
  });

  group('PregnancyCalculator', () {
    test('HPL = HPHT + 280 hari dan sebaliknya', () {
      final hpht = DateTime(2026, 1, 1);
      expect(PregnancyCalculator.hplFromHpht(hpht), DateTime(2026, 10, 8));
      expect(PregnancyCalculator.hphtFromHpl(DateTime(2026, 10, 8)), hpht);
    });

    test('trimester berpindah pada minggu 14 dan 28', () {
      expect(PregnancyCalculator.trimesterForWeeks(13), 1);
      expect(PregnancyCalculator.trimesterForWeeks(14), 2);
      expect(PregnancyCalculator.trimesterForWeeks(27), 2);
      expect(PregnancyCalculator.trimesterForWeeks(28), 3);
    });

    test('progres 20 minggu menghasilkan setengah perjalanan', () {
      final hpht = DateTime(2026, 1, 1);
      final hpl = PregnancyCalculator.hplFromHpht(hpht);
      final progress = PregnancyCalculator.progress(
        hpht: hpht,
        hpl: hpl,
        today: hpht.add(const Duration(days: 140)),
      );
      expect(progress.weeks, 20);
      expect(progress.days, 0);
      expect(progress.trimester, 2);
      expect(progress.progress, closeTo(0.5, 1e-9));
      expect(progress.daysToHpl, 140);
      expect(progress.fetalLengthCm, closeTo(25.6, 1e-9));
      expect(progress.fetalWeightG, 300);
      expect(progress.ageLabel, '20 minggu 0 hari');
    });

    test('HPHT di masa depan tidak menghasilkan progres negatif', () {
      final today = DateTime(2026, 3, 1);
      final hpht = today.add(const Duration(days: 30));
      final progress = PregnancyCalculator.progress(
        hpht: hpht,
        hpl: PregnancyCalculator.hplFromHpht(hpht),
        today: today,
      );
      expect(progress.weeks, 0);
      expect(progress.progress, 0);
      expect(progress.daysToHpl, 310);
    });

    test('ukuran janin diinterpolasi antar minggu', () {
      final hpht = DateTime(2026, 1, 1);
      final progress = PregnancyCalculator.progress(
        hpht: hpht,
        hpl: PregnancyCalculator.hplFromHpht(hpht),
        today: hpht.add(const Duration(days: 7 * 21)),
      );
      expect(progress.weeks, 21);
      expect(progress.fetalLengthCm, greaterThan(25.6));
      expect(progress.fetalLengthCm, lessThan(27.8));
      expect(progress.fetalWeightG, greaterThan(300));
      expect(progress.fetalWeightG, lessThan(430));
    });
  });

  group('DemoSeed', () {
    final today = DateTime(2026, 3, 15);
    late AppState state;

    setUpAll(() {
      state = DemoSeed.build(who: who, today: today);
    });

    test('menyediakan 52 sasaran dan 38 hadir pada sesi berjalan', () {
      expect(state.roster.length, 52);
      final session = state.sessions.single;
      expect(session.targetCount, 52);
      expect(session.presentCount, 38);
      expect(
        state.roster
            .where((r) => r.attendance == AttendanceStatus.present)
            .length,
        38,
      );
    });

    test('distribusi kategori anak konsisten dengan dashboard kader', () {
      final children = state.roster.where((r) => r.type == RosterType.child);
      expect(children.length, 38);
      expect(
        children.where((r) => r.category == GrowthCategory.normal).length,
        31,
      );
      expect(
        children.where((r) => r.category == GrowthCategory.stunted).length,
        5,
      );
      expect(
        children
            .where((r) => r.category == GrowthCategory.severelyStunted)
            .length,
        2,
      );
    });

    test('total energi sarapan dan makan siang Rafi = 685 kkal', () {
      final logs = state.foodLogsFor('c_rafi', today);
      expect(logs.length, 2);
      expect(logs.first.meal, MealType.breakfast);
      expect(logs.last.meal, MealType.lunch);
      final total = logs.fold<double>(
        0,
        (sum, log) => sum + (log.totals.kcal ?? 0),
      );
      expect(total, closeTo(685, 0.5));
    });

    test('akun demo ibu dan kader tersedia', () {
      expect(
        state.users.map((u) => u.email),
        containsAll(['ibu@nuri.id', 'kader@nuri.id']),
      );
      expect(
        state.users.firstWhere((u) => u.email == 'ibu@nuri.id').role,
        UserRole.mother,
      );
      expect(
        state.users.firstWhere((u) => u.email == 'kader@nuri.id').role,
        UserRole.cadre,
      );
      expect(state.landingSeen, isFalse);
    });
  });

  group('AppController addRosterTarget', () {
    ProviderContainer makeContainer(AppState seed) {
      final repo = _MemoryRepository();
      return ProviderContainer(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          appControllerProvider.overrideWith(() => AppController(seed, repo)),
        ],
      );
    }

    test('menolak BB lahir dan PB lahir di luar batas', () {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_kader');
      final container = makeContainer(seed);
      addTearDown(container.dispose);
      final controller = container.read(appControllerProvider.notifier);

      expect(
        controller.addRosterTarget(
          name: 'Bayi Uji',
          type: RosterType.child,
          dob: DateTime(2026, 1, 1),
          sex: Sex.male,
          birthWeightKg: 9,
        ),
        'BB lahir harus di antara 0,5–6 kg.',
      );
      expect(
        controller.addRosterTarget(
          name: 'Bayi Uji',
          type: RosterType.child,
          dob: DateTime(2026, 1, 1),
          sex: Sex.male,
          birthLengthCm: 15,
        ),
        'PB lahir harus di antara 20–70 cm.',
      );
      expect(
        controller.addRosterTarget(
          name: 'Bayi Uji',
          type: RosterType.child,
          dob: DateTime(2026, 1, 1),
          sex: Sex.male,
          birthWeightKg: 3.1,
          birthLengthCm: 49,
        ),
        isNull,
      );
    });
  });

  group('AppController Firebase Auth', () {
    ProviderContainer makeContainer(AppState seed, AuthService auth) {
      final repo = _MemoryRepository();
      return ProviderContainer(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          appControllerProvider.overrideWith(
            () => AppController(seed, repo, authService: auth),
          ),
        ],
      );
    }

    test('login Firebase mempertahankan data akun demo', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final auth = _FakeAuthService()
        ..signInSession = const AuthSession(
          uid: 'fb_ibu',
          email: 'ibu@nuri.id',
          displayName: 'Siti Rahma',
        );
      final container = makeContainer(seed, auth);
      addTearDown(container.dispose);

      final error = await container
          .read(appControllerProvider.notifier)
          .login('ibu@nuri.id', 'rahasia123');

      expect(error, isNull);
      final state = container.read(appControllerProvider);
      expect(state.currentUser?.id, 'u_ibu');
      expect(state.currentUser?.authUid, 'fb_ibu');
      expect(state.currentUser?.demo, isTrue);
      expect(state.myChildren, isNotEmpty);
    });

    test(
      'login Firebase pengguna baru memakai UID dan peran pilihan',
      () async {
        final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
        final auth = _FakeAuthService()
          ..signInSession = const AuthSession(
            uid: 'fb_kader',
            email: 'kader.baru@nuri.id',
            displayName: 'Kader Baru',
          );
        final container = makeContainer(seed, auth);
        addTearDown(container.dispose);

        final error = await container
            .read(appControllerProvider.notifier)
            .login('kader.baru@nuri.id', 'rahasia123', role: UserRole.cadre);

        expect(error, isNull);
        final state = container.read(appControllerProvider);
        expect(state.currentUser?.id, 'fb_kader');
        expect(state.currentUser?.role, UserRole.cadre);
        expect(state.currentUser?.authUid, 'fb_kader');
        expect(state.currentUser?.demo, isFalse);
        expect(state.onboardingSeen, isFalse);
        expect(state.consentAccepted, isFalse);
      },
    );

    test('login Firebase menampilkan pesan password salah', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final auth = _FakeAuthService()
        ..signInFailure = const AuthFailure('wrong-password');
      final container = makeContainer(seed, auth);
      addTearDown(container.dispose);

      final error = await container
          .read(appControllerProvider.notifier)
          .login('ibu@nuri.id', 'rahasia123');

      expect(error, 'Email atau password salah.');
      expect(container.read(appControllerProvider).currentUser, isNull);
    });

    test('akun demo tetap bisa masuk saat belum ada di Firebase', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final auth = _FakeAuthService()
        ..signInFailure = const AuthFailure('user-not-found');
      final container = makeContainer(seed, auth);
      addTearDown(container.dispose);

      final error = await container
          .read(appControllerProvider.notifier)
          .login('ibu@nuri.id', 'rahasia123');

      expect(error, isNull);
      expect(container.read(appControllerProvider).currentUser?.id, 'u_ibu');
    });

    test('register Firebase membuat pengguna dengan UID Firebase', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final auth = _FakeAuthService()
        ..registerSession = const AuthSession(
          uid: 'fb_reg',
          email: 'baru@nuri.id',
          displayName: 'Ibu Baru',
        );
      final container = makeContainer(seed, auth);
      addTearDown(container.dispose);

      final error = await container
          .read(appControllerProvider.notifier)
          .register(
            name: 'Ibu Baru',
            email: 'baru@nuri.id',
            password: 'rahasia123',
            role: UserRole.mother,
          );

      expect(error, isNull);
      final state = container.read(appControllerProvider);
      expect(state.currentUser?.id, 'fb_reg');
      expect(state.currentUser?.authUid, 'fb_reg');
      expect(state.currentUser?.demo, isFalse);
      expect(state.onboardingSeen, isFalse);
      expect(auth.registerCalls, 1);
    });

    test('register menolak email lokal yang sudah dipakai', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final auth = _FakeAuthService();
      final container = makeContainer(seed, auth);
      addTearDown(container.dispose);

      final error = await container
          .read(appControllerProvider.notifier)
          .register(
            name: 'Siti Rahma',
            email: 'ibu@nuri.id',
            password: 'rahasia123',
            role: UserRole.mother,
          );

      expect(error, contains('sudah digunakan'));
      expect(auth.registerCalls, 0);
    });

    test('reset password memanggil Firebase', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final auth = _FakeAuthService();
      final container = makeContainer(seed, auth);
      addTearDown(container.dispose);

      final error = await container
          .read(appControllerProvider.notifier)
          .resetPassword('baru@nuri.id');

      expect(error, isNull);
      expect(auth.resetCalls, 1);
    });

    test('login lokal tetap tersedia saat Firebase tidak siap', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final auth = _FakeAuthService(available: false);
      final container = makeContainer(seed, auth);
      addTearDown(container.dispose);

      final error = await container
          .read(appControllerProvider.notifier)
          .login('ibu@nuri.id', 'rahasia123');

      expect(error, isNull);
      expect(container.read(appControllerProvider).currentUser?.id, 'u_ibu');
      expect(auth.signInCalls, 0);
    });

    test(
      'loginWithGoogle berhasil masuk dan membuat profil pengguna',
      () async {
        final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
        final auth = _FakeAuthService()
          ..googleSession = const AuthSession(
            uid: 'google_123',
            email: 'bunda@gmail.com',
            displayName: 'Bunda Google',
          );
        final container = makeContainer(seed, auth);
        addTearDown(container.dispose);

        final error = await container
            .read(appControllerProvider.notifier)
            .loginWithGoogle(role: UserRole.mother);

        expect(error, isNull);
        final state = container.read(appControllerProvider);
        expect(state.currentUser?.id, 'google_123');
        expect(state.currentUser?.email, 'bunda@gmail.com');
        expect(state.currentUser?.authUid, 'google_123');
        expect(auth.googleSignInCalls, 1);
      },
    );
  });

  group('Label ramah keluarga', () {
    test('setiap kategori pertumbuhan punya label non-klinis', () {
      expect(GrowthCategory.normal.plainLabel, 'Tumbuh optimal');
      expect(GrowthCategory.stunted.plainLabel, 'Perlu perhatian');
      expect(GrowthCategory.severelyStunted.plainLabel, 'Perlu rujukan');
      expect(GrowthCategory.tall.plainLabel, 'Tinggi, tetap pantau');
    });
  });

  group('AppController aksi fitur', () {
    ProviderContainer makeContainer(AppState seed) {
      final repo = _MemoryRepository();
      return ProviderContainer(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          appControllerProvider.overrideWith(() => AppController(seed, repo)),
        ],
      );
    }

    test('loginDemo kader mengaktifkan konteks kader', () {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final container = makeContainer(seed);
      addTearDown(container.dispose);

      container.read(appControllerProvider.notifier).loginDemo(UserRole.cadre);

      final state = container.read(appControllerProvider);
      expect(state.currentUser?.role, UserRole.cadre);
      expect(state.isCadre, isTrue);
    });

    test('pengukuran kader menandai hadir dan menambah antrean sinkron', () {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_kader');
      final waiting = seed.roster.firstWhere(
        (entry) =>
            entry.type == RosterType.child &&
            entry.attendance == AttendanceStatus.waiting &&
            entry.subjectId != null,
      );
      final child = seed.children.firstWhere(
        (item) => item.id == waiting.subjectId,
      );
      final container = makeContainer(seed);
      addTearDown(container.dispose);
      final controller = container.read(appControllerProvider.notifier);
      final before = container.read(appControllerProvider);

      final result = controller.addMeasurement(
        childId: child.id,
        weightKg: 11.2,
        heightCm: 82.5,
        date: DateTime(2026, 3, 15),
      );

      expect(result, isNotNull);
      final after = container.read(appControllerProvider);
      expect(after.pendingWrites, before.pendingWrites + 1);
      expect(
        after.roster
            .firstWhere((entry) => entry.subjectId == child.id)
            .attendance,
        AttendanceStatus.present,
      );
    });

    test('pengukuran ibu langsung tersinkron tanpa antrean', () {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_ibu');
      final rafi = seed.children.firstWhere((child) => child.id == 'c_rafi');
      final container = makeContainer(seed);
      addTearDown(container.dispose);
      final controller = container.read(appControllerProvider.notifier);
      final before = container.read(appControllerProvider);

      final result = controller.addMeasurement(
        childId: rafi.id,
        weightKg: 11.2,
        heightCm: 82.5,
        date: DateTime(2026, 3, 15),
      );

      expect(result, isNotNull);
      expect(result!.source, 'mandiri');
      expect(result.synced, isTrue);
      final after = container.read(appControllerProvider);
      expect(after.pendingWrites, before.pendingWrites);
    });
  });

  group('AppController Firestore CRUD & Sync', () {
    ProviderContainer makeContainer(
      AppState seed, {
      AuthService? auth,
      DatabaseService? db,
    }) {
      final repo = _MemoryRepository();
      return ProviderContainer(
        overrides: [
          localRepositoryProvider.overrideWithValue(repo),
          appControllerProvider.overrideWith(
            () => AppController(
              seed,
              repo,
              authService: auth ?? _FakeAuthService(),
              databaseService: db ?? _FakeDatabaseService(),
            ),
          ),
        ],
      );
    }

    test('seedUserDataset menyalin data demo pengguna ke database', () async {
      final seed = DemoSeed.build(who: who, today: DateTime(2026, 3, 15));
      final db = _FakeDatabaseService();
      final user = seed.users.firstWhere((u) => u.id == 'u_ibu');

      await db.seedUserDataset(user: user, seedData: seed);

      expect(db.users.containsKey('u_ibu'), isTrue);
      expect(db.children.containsKey('c_rafi'), isTrue);
      expect(db.pregnancies.isNotEmpty, isTrue);
      expect(db.foodLogs.isNotEmpty, isTrue);
    });

    test('addChild menyinkronkan data anak baru ke Firestore', () async {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_ibu');
      final db = _FakeDatabaseService();
      final container = makeContainer(seed, db: db);
      addTearDown(container.dispose);

      final controller = container.read(appControllerProvider.notifier);
      final error = controller.addChild(
        nickname: 'Adik Bayi',
        dob: DateTime(2025, 6, 1),
        sex: Sex.female,
      );

      expect(error, isNull);
      final state = container.read(appControllerProvider);
      final created = state.children.firstWhere(
        (c) => c.nickname == 'Adik Bayi',
      );
      expect(db.children.containsKey(created.id), isTrue);
      expect(db.children[created.id]?.nickname, 'Adik Bayi');
    });

    test('addMeasurement memperbarui anak di Firestore', () async {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_ibu');
      final db = _FakeDatabaseService();
      final container = makeContainer(seed, db: db);
      addTearDown(container.dispose);

      final controller = container.read(appControllerProvider.notifier);
      final result = controller.addMeasurement(
        childId: 'c_rafi',
        weightKg: 11.5,
        heightCm: 83.0,
        date: DateTime(2026, 3, 15),
      );

      expect(result, isNotNull);
      expect(db.children.containsKey('c_rafi'), isTrue);
      expect(
        db.children['c_rafi']?.measurements.any((m) => m.weightKg == 11.5),
        isTrue,
      );
    });

    test('addFoodLog dan deleteFoodLog menyinkronkan catatan makan', () async {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_ibu');
      final db = _FakeDatabaseService();
      final container = makeContainer(seed, db: db);
      addTearDown(container.dispose);

      final controller = container.read(appControllerProvider.notifier);
      final log = controller.addFoodLog(
        subjectId: 'c_rafi',
        date: DateTime(2026, 3, 15),
        meal: MealType.breakfast,
        items: [
          const FoodLogItem(
            foodId: 'f_egg',
            name: 'Telur Ayam Rebus',
            grams: 55,
            kcalPer100: 155,
            proteinPer100: 12.6,
          ),
        ],
      );

      expect(log, isNotNull);
      expect(db.foodLogs.containsKey(log.id), isTrue);

      controller.deleteFoodLog(log.id);
      expect(db.foodLogs.containsKey(log.id), isFalse);
    });

    test('addRosterTarget menyinkronkan sasaran kader ke Firestore', () async {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_kader');
      final db = _FakeDatabaseService();
      final container = makeContainer(seed, db: db);
      addTearDown(container.dispose);

      final controller = container.read(appControllerProvider.notifier);
      final error = controller.addRosterTarget(
        name: 'Anak Posyandu Baru',
        type: RosterType.child,
        dob: DateTime(2025, 8, 1),
        sex: Sex.male,
        birthWeightKg: 3.2,
        birthLengthCm: 49.5,
      );

      expect(error, isNull);
      final state = container.read(appControllerProvider);
      final entry = state.roster.firstWhere(
        (r) => r.name == 'Anak Posyandu Baru',
      );
      expect(db.roster.containsKey(entry.id), isTrue);
    });

    test(
      'syncNow menyinkronkan seluruh entitas dan membersihkan pendingWrites',
      () async {
        final seed = DemoSeed.build(
          who: who,
          today: DateTime(2026, 3, 15),
        ).copyWith(currentUserId: 'u_kader');
        final db = _FakeDatabaseService();
        final container = makeContainer(seed, db: db);
        addTearDown(container.dispose);

        final controller = container.read(appControllerProvider.notifier);
        await controller.syncNow();

        final state = container.read(appControllerProvider);
        expect(state.pendingWrites, 0);
        expect(state.lastSyncAt, isNotNull);
        expect(db.syncAllCalls, 1);
        expect(db.pullCalls, 1);
      },
    );

    test('commitState tetap berjalan normal saat database tidak siap', () {
      final seed = DemoSeed.build(
        who: who,
        today: DateTime(2026, 3, 15),
      ).copyWith(currentUserId: 'u_ibu');
      final db = _FakeDatabaseService(available: false);
      final container = makeContainer(seed, db: db);
      addTearDown(container.dispose);

      final controller = container.read(appControllerProvider.notifier);
      final error = controller.addChild(
        nickname: 'Bayi Offline',
        dob: DateTime(2025, 9, 1),
        sex: Sex.male,
      );

      expect(error, isNull);
      expect(db.syncChangesCalls, 0);
    });
  });
}

class _FakeDatabaseService implements DatabaseService {
  _FakeDatabaseService({this.available = true});

  bool available;
  final Map<String, AppUser> users = {};
  final Map<String, Child> children = {};
  final Map<String, Pregnancy> pregnancies = {};
  final Map<String, FoodLog> foodLogs = {};
  final Map<String, RosterEntry> roster = {};
  final Map<String, PosyanduSession> sessions = {};
  final Map<String, AccessGrant> grants = {};

  int syncChangesCalls = 0;
  int syncAllCalls = 0;
  int seedCalls = 0;
  int pullCalls = 0;

  @override
  bool get isAvailable => available;

  @override
  Future<bool> userExists(String userId) async => users.containsKey(userId);

  @override
  Future<void> seedUserDataset({
    required AppUser user,
    required AppState seedData,
  }) async {
    seedCalls++;
    users[user.id] = user;
    for (final c in seedData.children) {
      children[c.id] = c;
    }
    for (final p in seedData.pregnancies) {
      pregnancies[p.id] = p;
    }
    for (final f in seedData.foodLogs) {
      foodLogs[f.id] = f;
    }
    for (final r in seedData.roster) {
      roster[r.id] = r;
    }
    for (final s in seedData.sessions) {
      sessions[s.id] = s;
    }
  }

  @override
  Future<AppState?> pullUserDataset({
    required AppUser user,
    required AppState currentState,
  }) async {
    pullCalls++;
    return currentState.copyWith(
      children: children.values.toList(),
      pregnancies: pregnancies.values.toList(),
      foodLogs: foodLogs.values.toList(),
      roster: roster.values.toList(),
      sessions: sessions.values.toList(),
      pendingWrites: 0,
      lastSyncAt: DateTime.now(),
    );
  }

  @override
  Future<void> syncChanges({
    required AppState previous,
    required AppState next,
    required AppUser user,
  }) async {
    syncChangesCalls++;
    for (final c in next.children) {
      children[c.id] = c;
    }
    final nextChildIds = next.children.map((c) => c.id).toSet();
    for (final c in previous.children) {
      if (!nextChildIds.contains(c.id)) children.remove(c.id);
    }

    for (final p in next.pregnancies) {
      pregnancies[p.id] = p;
    }
    for (final f in next.foodLogs) {
      foodLogs[f.id] = f;
    }
    final nextLogIds = next.foodLogs.map((l) => l.id).toSet();
    for (final f in previous.foodLogs) {
      if (!nextLogIds.contains(f.id)) foodLogs.remove(f.id);
    }

    for (final r in next.roster) {
      roster[r.id] = r;
    }
    for (final s in next.sessions) {
      sessions[s.id] = s;
    }
  }

  @override
  Future<void> syncAll({required AppState state, required AppUser user}) async {
    syncAllCalls++;
    for (final c in state.children) {
      children[c.id] = c;
    }
    for (final p in state.pregnancies) {
      pregnancies[p.id] = p;
    }
    for (final f in state.foodLogs) {
      foodLogs[f.id] = f;
    }
    for (final r in state.roster) {
      roster[r.id] = r;
    }
    for (final s in state.sessions) {
      sessions[s.id] = s;
    }
  }

  @override
  Future<void> saveUser(AppUser user) async => users[user.id] = user;
  @override
  Future<void> saveChild(Child child) async => children[child.id] = child;
  @override
  Future<void> deleteChild(String id) async => children.remove(id);
  @override
  Future<void> savePregnancy(Pregnancy pregnancy) async =>
      pregnancies[pregnancy.id] = pregnancy;
  @override
  Future<void> deletePregnancy(String id) async => pregnancies.remove(id);
  @override
  Future<void> saveFoodLog(FoodLog log) async => foodLogs[log.id] = log;
  @override
  Future<void> deleteFoodLog(String id) async => foodLogs.remove(id);
  @override
  Future<void> saveRosterEntry(RosterEntry entry) async =>
      roster[entry.id] = entry;
  @override
  Future<void> deleteRosterEntry(String id) async => roster.remove(id);
  @override
  Future<void> saveSession(PosyanduSession session) async =>
      sessions[session.id] = session;
  @override
  Future<void> saveAccessGrant(AccessGrant grant) async =>
      grants[grant.id] = grant;
}

class _FakeAuthService implements AuthService {
  _FakeAuthService({this.available = true});

  bool available;

  AuthSession? signInSession;
  AuthSession? registerSession;
  AuthFailure? signInFailure;
  AuthFailure? registerFailure;
  AuthFailure? resetFailure;

  int signInCalls = 0;
  int registerCalls = 0;
  int resetCalls = 0;
  int signOutCalls = 0;
  int updateNameCalls = 0;
  int googleSignInCalls = 0;
  AuthSession? googleSession;
  AuthFailure? googleFailure;

  @override
  bool get isAvailable => available;

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    signInCalls++;
    if (signInFailure != null) throw signInFailure!;
    return signInSession ?? AuthSession(uid: 'uid_$email', email: email);
  }

  @override
  Future<AuthSession?> signInWithGoogle() async {
    googleSignInCalls++;
    if (googleFailure != null) throw googleFailure!;
    return googleSession ??
        const AuthSession(
          uid: 'google_uid',
          email: 'user.google@gmail.com',
          displayName: 'Google User',
        );
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    registerCalls++;
    if (registerFailure != null) throw registerFailure!;
    return registerSession ??
        AuthSession(uid: 'uid_$email', email: email, displayName: name);
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    resetCalls++;
    if (resetFailure != null) throw resetFailure!;
  }

  @override
  Future<void> updateDisplayName(String name) async {
    updateNameCalls++;
  }
}

class _MemoryRepository implements AppRepository {
  AppState? _saved;

  @override
  AppState? load() => _saved;

  @override
  Future<void> save(AppState state) async {
    _saved = state;
  }

  @override
  Future<void> clear() async {
    _saved = null;
  }
}
