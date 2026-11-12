import '../app_controller.dart';
import '../../domain/models.dart';
import '../../domain/pregnancy/pregnancy_calculator.dart';

/// Aksi kehamilan, TTD, ANC, pemeriksaan, dan persalinan.
extension PregnancyActions on AppController {
  Pregnancy? addPregnancy({required DateTime hpht, DateTime? hpl}) {
    final user = currentState.currentUser;
    if (user == null) return null;
    final start = dateOnly(hpht);
    final pregnancy = Pregnancy(
      id: 'preg_${DateTime.now().microsecondsSinceEpoch}',
      ownerUid: user.id,
      hpht: start,
      hpl: dateOnly(hpl ?? PregnancyCalculator.hplFromHpht(start)),
      status: PregnancyStatus.active,
      createdAt: DateTime.now(),
    );
    commitState(
      currentState.copyWith(
        pregnancies: [...currentState.pregnancies, pregnancy],
        pregnancyContext: true,
      ),
    );
    return pregnancy;
  }

  void toggleTtdForDate(DateTime date) {
    final pregnancy = currentState.activePregnancy;
    if (pregnancy == null) return;
    final key = dateToIso(date);
    final dates = List<String>.from(pregnancy.ttdDates);
    if (dates.contains(key)) {
      dates.remove(key);
    } else {
      dates.add(key);
    }
    final updated = pregnancy.copyWith(ttdDates: dates);
    commitState(
      currentState.copyWith(
        pregnancies: currentState.pregnancies
            .map((p) => p.id == pregnancy.id ? updated : p)
            .toList(),
      ),
    );
  }

  void addAncVisit({DateTime? date, String? facility, String? note}) {
    final pregnancy = currentState.activePregnancy;
    if (pregnancy == null) return;
    final visit = AncVisit(
      id: 'anc_${DateTime.now().microsecondsSinceEpoch}',
      date: dateOnly(date ?? DateTime.now()),
      facility: facility ?? 'Posyandu Melati II',
      note: note,
    );
    final updated = pregnancy.copyWith(
      ancVisits: [...pregnancy.ancVisits, visit],
    );
    commitState(
      currentState.copyWith(
        pregnancies: currentState.pregnancies
            .map((p) => p.id == pregnancy.id ? updated : p)
            .toList(),
      ),
    );
  }

  void addCheckup({
    required double weightKg,
    required double lilaCm,
    double? hbGdl,
    int? systolic,
    int? diastolic,
    DateTime? date,
  }) {
    final pregnancy = currentState.activePregnancy;
    if (pregnancy == null) return;
    final checkup = Checkup(
      id: 'chk_${DateTime.now().microsecondsSinceEpoch}',
      date: dateOnly(date ?? DateTime.now()),
      weightKg: weightKg,
      lilaCm: lilaCm,
      hbGdl: hbGdl,
      systolic: systolic,
      diastolic: diastolic,
      source: currentState.isCadre ? 'kader' : 'mandiri',
      recordedBy: currentState.currentUser?.name ?? 'Ibu',
    );
    final updated = pregnancy.copyWith(
      checkups: [...pregnancy.checkups, checkup],
    );
    commitState(
      currentState.copyWith(
        pregnancies: currentState.pregnancies
            .map((p) => p.id == pregnancy.id ? updated : p)
            .toList(),
      ),
    );
  }

  Child? giveBirth({
    required DateTime dob,
    required Sex sex,
    String? nickname,
    double? birthWeightKg,
    double? birthLengthCm,
  }) {
    final pregnancy = currentState.activePregnancy;
    final user = currentState.currentUser;
    if (pregnancy == null || user == null) return null;
    final child = Child(
      id: 'c_${DateTime.now().microsecondsSinceEpoch}',
      nickname: nickname?.trim().isNotEmpty == true
          ? nickname!.trim()
          : 'Si Kecil',
      dob: dateOnly(dob),
      sex: sex,
      guardianName: user.name,
      guardianUid: user.id,
      posyanduId: user.posyanduId,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      linked: true,
      avatarIndex: 0,
    );
    final updatedPregnancy = pregnancy.copyWith(
      status: PregnancyStatus.born,
      childId: child.id,
    );
    commitState(
      currentState.copyWith(
        children: [...currentState.children, child],
        pregnancies: currentState.pregnancies
            .map((p) => p.id == pregnancy.id ? updatedPregnancy : p)
            .toList(),
        selectedChildId: child.id,
        pregnancyContext: false,
      ),
    );
    return child;
  }

  void endPregnancy() {
    final pregnancy = currentState.activePregnancy;
    if (pregnancy == null) return;
    final updated = pregnancy.copyWith(status: PregnancyStatus.ended);
    commitState(
      currentState.copyWith(
        pregnancies: currentState.pregnancies
            .map((p) => p.id == pregnancy.id ? updated : p)
            .toList(),
        pregnancyContext: false,
      ),
    );
  }
}
