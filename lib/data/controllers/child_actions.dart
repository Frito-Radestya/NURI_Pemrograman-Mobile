import '../app_controller.dart';
import '../../core/utils/iterable_ext.dart';
import '../../domain/growth/growth_calculator.dart';
import '../../domain/growth/who_lms.dart';
import '../../domain/models.dart';

/// Aksi data anak dan pengukuran antropometri.
extension ChildActions on AppController {
  String? addChild({
    required String nickname,
    required DateTime dob,
    required Sex sex,
    String? guardianName,
    double? birthWeightKg,
    double? birthLengthCm,
  }) {
    final user = currentState.currentUser;
    if (user == null) return 'Sesi pengguna tidak ditemukan.';
    final ageDays = dateOnly(DateTime.now()).difference(dateOnly(dob)).inDays;
    if (ageDays < 0) return 'Tanggal lahir tidak boleh di masa depan.';
    if (ageDays >= 1857) return 'Usia anak di luar cakupan 0–59 bulan.';
    final id = 'c_${DateTime.now().microsecondsSinceEpoch}';
    final child = Child(
      id: id,
      nickname: nickname.trim(),
      dob: dateOnly(dob),
      sex: sex,
      guardianName: guardianName?.trim().isNotEmpty == true
          ? guardianName!.trim()
          : user.name,
      guardianUid: user.role == UserRole.mother ? user.id : null,
      posyanduId: user.posyanduId,
      birthWeightKg: birthWeightKg,
      birthLengthCm: birthLengthCm,
      linked: user.role == UserRole.mother,
      avatarIndex: currentState.children.length % 8,
    );
    final updatedRoster = user.role == UserRole.cadre
        ? [
            ...currentState.roster,
            RosterEntry(
              id: 'r_$id',
              name: child.nickname,
              type: RosterType.child,
              attendance: AttendanceStatus.waiting,
              avatarIndex: child.avatarIndex,
              subjectId: child.id,
              guardianName: child.guardianName,
              ageMonths: child.ageMonthsAt(DateTime.now()),
              sex: child.sex,
              linked: false,
            ),
          ]
        : currentState.roster;
    commitState(
      currentState.copyWith(
        children: [...currentState.children, child],
        roster: updatedRoster,
        selectedChildId: currentState.selectedChildId ?? child.id,
      ),
    );
    return null;
  }

  Measurement? addMeasurement({
    required String childId,
    required double weightKg,
    required double heightCm,
    required DateTime date,
    MeasurementMethod? method,
    bool allowImplausible = true,
  }) {
    final child = currentState.children.firstWhereOrNull(
      (c) => c.id == childId,
    );
    if (child == null) return null;
    final ageMonths = child.ageMonthsAt(date);
    final GrowthEvaluation eval;
    try {
      eval = GrowthCalculator(reference: WhoReference.instance).evaluate(
        heightCm: heightCm,
        weightKg: weightKg,
        sex: child.sex,
        dob: child.dob,
        measureDate: date,
        method: method ?? GrowthCalculator.defaultMethodForAge(ageMonths),
        allowImplausible: allowImplausible,
      );
    } on GrowthValidationException {
      return null;
    }
    final source = currentState.isCadre ? 'kader' : 'mandiri';
    final sessionId = currentState.isCadre
        ? currentState.activeSession?.id
        : null;
    final synced = !currentState.isCadre;
    final measurement = Measurement(
      id: 'm_${DateTime.now().microsecondsSinceEpoch}',
      date: dateOnly(date),
      ageDays: eval.ageDays,
      ageMonths: eval.ageMonths,
      weightKg: weightKg,
      measuredCm: heightCm,
      method: eval.method,
      correctedCm: eval.correctedCm,
      zHfa: eval.zScore,
      category: eval.category,
      source: source,
      recordedByUid: currentState.currentUserId,
      sessionId: sessionId,
      flags: eval.flags,
      synced: synced,
      createdAt: DateTime.now(),
    );
    final updatedChild = child.copyWith(
      measurements: [...child.measurements, measurement],
    );
    final children = currentState.children
        .map((c) => c.id == childId ? updatedChild : c)
        .toList();
    final roster = currentState.roster.map((entry) {
      if (entry.subjectId != childId) return entry;
      return entry.copyWith(
        category: eval.category,
        attendance: AttendanceStatus.present,
        lastMeasuredAt: dateOnly(date),
        pendingSync: !synced,
        priority: eval.category.needsFollowUp,
        reason: eval.category.needsFollowUp
            ? '${eval.category.label} (${eval.zScore.toStringAsFixed(1)} SD)'
            : entry.reason,
        followUpStatus: eval.category.needsFollowUp
            ? FollowUpStatus.open
            : FollowUpStatus.closed,
      );
    }).toList();
    final sessions = currentState.sessions.map((session) {
      if (session.id != sessionId) return session;
      final alreadyPresent = currentState.roster
          .where((r) => r.subjectId == childId)
          .any((r) => r.attendance == AttendanceStatus.present);
      return PosyanduSession(
        id: session.id,
        posyanduName: session.posyanduName,
        date: session.date,
        targetCount: session.targetCount,
        presentCount: alreadyPresent
            ? session.presentCount
            : session.presentCount + 1,
        status: session.status,
        createdByUid: session.createdByUid,
        note: session.note,
      );
    }).toList();
    commitState(
      currentState.copyWith(
        children: children,
        roster: roster,
        sessions: sessions,
        pendingWrites: synced
            ? currentState.pendingWrites
            : currentState.pendingWrites + 1,
      ),
    );
    return measurement;
  }
}
