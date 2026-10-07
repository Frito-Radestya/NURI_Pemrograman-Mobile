import '../domain/models/app_role.dart';
import '../domain/models/child.dart';
import '../domain/models/food_item.dart';
import '../domain/models/food_log.dart';
import '../domain/models/guardian_consent.dart';
import '../domain/models/measurement.dart';
import '../domain/models/screening_session.dart';
import '../domain/models/sex.dart';
import '../domain/models/user_profile.dart';
import 'nuri_repository.dart';

/// Data contoh untuk prototipe UI/UX.
///
/// Angka sengaja dibuat bervariasi agar setiap status (normal, pendek, sangat
/// pendek, tinggi) dan keadaan (belum diukur, antrean sinkron) bisa
/// didemonstrasikan. Data ini menggantikan hasil "login pertama" dari Supabase.
class SeedData {
  SeedData._();

  static DateTime _monthsBefore(DateTime base, int months, {int dayOffset = 0}) {
    return DateTime(base.year, base.month - months, base.day + dayOffset);
  }

  static DateTime _addMonths(DateTime base, int months) {
    return DateTime(base.year, base.month + months, base.day);
  }

  // ---- Akun Ibu (Sari) ------------------------------------------------------

  static void seedMother(NuriRepository repo) {
    final DateTime now = DateTime.now();
    const String uid = 'u-ibu-sari';

    repo.signIn(
      UserProfile(
        id: uid,
        role: AppRole.ibuBalita,
        displayName: 'Sari',
        email: 'sari@contoh.id',
        privacyVersion: 'v1',
        privacyAt: now,
        avatarEmoji: '\u{1F469}',
      ),
    );

    final Child alya = repo.addChild(
      id: 'child-alya',
      nickname: 'Alya',
      birthDate: _monthsBefore(now, 16),
      sex: Sex.perempuan,
      posyanduName: 'Posyandu Melati',
    );

    final Child bima = repo.addChild(
      id: 'child-bima',
      nickname: 'Bima',
      birthDate: _monthsBefore(now, 30),
      sex: Sex.lakiLaki,
      posyanduName: 'Posyandu Melati',
    );

    // Riwayat pengukuran Alya: tren melambat hingga masuk kategori pendek.
    final List<List<double>> alyaHistory = <List<double>>[
      <double>[6, 7.0, 61.5],
      <double>[10, 7.9, 68.0],
      <double>[13, 8.6, 71.0],
      <double>[16, 9.2, 73.0],
    ];
    for (final List<double> row in alyaHistory) {
      repo.recordMeasurement(
        child: alya,
        measuredOn: _addMonths(alya.birthDate, row[0].toInt()),
        weightKg: row[1],
        lengthHeightCm: row[2],
        method: MeasureMethod.recommendedFor(row[0].toInt()),
      );
    }

    final List<List<double>> bimaHistory = <List<double>>[
      <double>[24, 10.9, 87.0],
      <double>[27, 11.8, 89.5],
      <double>[30, 13.0, 92.0],
    ];
    for (final List<double> row in bimaHistory) {
      repo.recordMeasurement(
        child: bima,
        measuredOn: _addMonths(bima.birthDate, row[0].toInt()),
        weightKg: row[1],
        lengthHeightCm: row[2],
        method: MeasureMethod.recommendedFor(row[0].toInt()),
      );
    }

    // Diary hari ini untuk Alya.
    final DateTime today = NuriRepository.dateOnly(now);
    void log(String foodId, MealType meal, int portionIndex) {
      final TkpiFood? food = repo.reference.tkpi.byId(foodId);
      if (food == null) return;
      final FoodPortion portion = food.portions[portionIndex.clamp(
        0,
        food.portions.length - 1,
      )];
      repo.addFoodItem(
        child: alya,
        date: today,
        meal: meal,
        food: food,
        portion: portion,
        source: FoodSource.manual,
      );
    }

    log('TKPI-001', MealType.pagi, 0);
    log('TKPI-006', MealType.pagi, 0);
    log('TKPI-016', MealType.pagi, 0);
    log('TKPI-001', MealType.siang, 1);
    log('TKPI-007', MealType.siang, 0);
    log('TKPI-013', MealType.siang, 0);
    log('TKPI-022', MealType.snack, 1);
  }

  // ---- Akun Kader (Bu Ratna) ------------------------------------------------

  static void seedKader(NuriRepository repo) {
    final DateTime now = DateTime.now();
    final DateTime today = NuriRepository.dateOnly(now);
    const String uid = 'u-kader-ratna';

    repo.signIn(
      UserProfile(
        id: uid,
        role: AppRole.kader,
        displayName: 'Bu Ratna',
        email: 'ratna@contoh.id',
        posyanduName: 'Posyandu Melati',
        privacyVersion: 'v1',
        privacyAt: now,
        avatarEmoji: '\u{1F469}\u200D\u{1F373}',
      ),
    );

    final ScreeningSession session = repo.createSession(
      posyanduName: 'Posyandu Melati',
      heldOn: today,
    );

    // (nama, jenis kelamin, umur bulan, tinggi cm, berat kg)
    const List<List<Object>> rows = <List<Object>>[
      <Object>['Rani', Sex.perempuan, 24, 76.0, 9.0],
      <Object>['Dafa', Sex.lakiLaki, 36, 96.0, 13.5],
      <Object>['Salsa', Sex.perempuan, 12, 74.0, 8.5],
      <Object>['Raka', Sex.lakiLaki, 18, 91.0, 11.5],
      <Object>['Nadia', Sex.perempuan, 30, 84.0, 11.0],
      <Object>['Fajar', Sex.lakiLaki, 48, 99.0, 14.5],
      <Object>['Kirana', Sex.perempuan, 6, 59.0, 6.2],
      <Object>['Bagas', Sex.lakiLaki, 24, 88.0, 11.5],
    ];

    for (final List<Object> row in rows) {
      final int ageMonths = row[2] as int;
      final Child child = repo.addChild(
        id: 'child-${(row[0] as String).toLowerCase()}',
        nickname: row[0] as String,
        birthDate: _monthsBefore(now, ageMonths),
        sex: row[1] as Sex,
        posyanduName: 'Posyandu Melati',
        consent: GuardianConsent(
          method: ConsentMethod.lisan,
          consentedAt: today,
          recordedBy: uid,
        ),
      );
      repo.recordMeasurement(
        child: child,
        measuredOn: today,
        weightKg: row[4] as double,
        lengthHeightCm: row[3] as double,
        method: MeasureMethod.recommendedFor(ageMonths),
        sessionId: session.id,
      );
    }

    // Dua anak terdaftar yang belum diukur pada sesi ini (untuk alur entri).
    repo.addChild(
      id: 'child-tiara',
      nickname: 'Tiara',
      birthDate: _monthsBefore(now, 20),
      sex: Sex.perempuan,
      posyanduName: 'Posyandu Melati',
      consent: GuardianConsent(
        method: ConsentMethod.lisan,
        consentedAt: today,
        recordedBy: uid,
      ),
    );
    repo.addChild(
      id: 'child-alif',
      nickname: 'Alif',
      birthDate: _monthsBefore(now, 40),
      sex: Sex.lakiLaki,
      posyanduName: 'Posyandu Melati',
      consent: GuardianConsent(
        method: ConsentMethod.kertas,
        consentedAt: today,
        recordedBy: uid,
      ),
    );
  }
}
