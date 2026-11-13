import '../app_controller.dart';
import '../../core/utils/iterable_ext.dart';
import '../../domain/models.dart';

/// Aksi sesi posyandu, sasaran, kehadiran, dan tindak lanjut.
extension CadreActions on AppController {
  String? addRosterTarget({
    required String name,
    required RosterType type,
    DateTime? dob,
    Sex? sex,
    String? guardianName,
    int? pregnancyWeeks,
    double? lilaCm,
    double? hbGdl,
    double? birthWeightKg,
    double? birthLengthCm,
  }) {
    if (name.trim().length < 2) return 'Nama sasaran minimal 2 karakter.';
    if (type == RosterType.child) {
      if (dob == null) return 'Tanggal lahir wajib diisi.';
      if (birthWeightKg != null && (birthWeightKg < 0.5 || birthWeightKg > 6)) {
        return 'BB lahir harus di antara 0,5–6 kg.';
      }
      if (birthLengthCm != null && (birthLengthCm < 20 || birthLengthCm > 70)) {
        return 'PB lahir harus di antara 20–70 cm.';
      }
    } else {
      if (pregnancyWeeks == null || pregnancyWeeks < 1 || pregnancyWeeks > 42) {
        return 'Usia kehamilan harus 1–42 minggu.';
      }
      if (lilaCm != null && (lilaCm < 10 || lilaCm > 40)) {
        return 'LiLA harus di antara 10–40 cm.';
      }
      if (hbGdl != null && (hbGdl < 5 || hbGdl > 20)) {
        return 'Hb harus di antara 5–20 g/dL.';
      }
    }
    final user = currentState.currentUser;
    if (user == null) return 'Sesi pengguna tidak ditemukan.';
    final id = 'r_${DateTime.now().microsecondsSinceEpoch}';
    String? childId;
    var children = currentState.children;
    if (type == RosterType.child && dob != null) {
      final ageDays = dateOnly(DateTime.now()).difference(dateOnly(dob)).inDays;
      if (ageDays < 0 || ageDays >= 1857) return 'Usia anak harus 0–59 bulan.';
      final child = Child(
        id: 'c_${DateTime.now().microsecondsSinceEpoch}',
        nickname: name.trim(),
        dob: dateOnly(dob),
        sex: sex ?? Sex.male,
        guardianName: guardianName?.trim().isNotEmpty == true
            ? guardianName!.trim()
            : 'Wali',
        posyanduId: user.posyanduId,
        birthWeightKg: birthWeightKg,
        birthLengthCm: birthLengthCm,
        linked: false,
        avatarIndex: currentState.children.length % 8,
      );
      childId = child.id;
      children = [...currentState.children, child];
    }
    final entry = RosterEntry(
      id: id,
      name: name.trim(),
      type: type,
      attendance: AttendanceStatus.waiting,
      avatarIndex: currentState.roster.length % 8,
      posyanduId: user.posyanduId,
      subjectId: childId,
      guardianName: guardianName ?? '',
      ageMonths: type == RosterType.child && dob != null
          ? Child(
              id: '',
              nickname: '',
              dob: dob,
              sex: sex ?? Sex.male,
              guardianName: '',
            ).ageMonthsAt(DateTime.now())
          : null,
      pregnancyWeeks: pregnancyWeeks,
      sex: sex,
      linked: false,
      lilaCm: lilaCm,
      hbGdl: hbGdl,
      priority:
          (lilaCm != null && lilaCm < 23.5) || (hbGdl != null && hbGdl < 11),
      reason: lilaCm != null && lilaCm < 23.5
          ? 'LiLA ${lilaCm.toStringAsFixed(1)} cm (< 23,5 cm Risiko KEK)'
          : null,
      pendingSync: true,
    );
    final sessions = currentState.sessions.map((session) {
      if (session.id != currentState.activeSession?.id) return session;
      return PosyanduSession(
        id: session.id,
        posyanduName: session.posyanduName,
        date: session.date,
        targetCount: session.targetCount + 1,
        presentCount: session.presentCount,
        status: session.status,
        createdByUid: session.createdByUid,
        note: session.note,
      );
    }).toList();
    commitState(
      currentState.copyWith(
        children: children,
        roster: [...currentState.roster, entry],
        sessions: sessions,
        pendingWrites: currentState.pendingWrites + 1,
      ),
    );
    return null;
  }

  void markAttendance(String rosterId, AttendanceStatus status) {
    final entry = currentState.roster.firstWhereOrNull((r) => r.id == rosterId);
    if (entry == null) return;
    final wasPresent = entry.attendance == AttendanceStatus.present;
    final isPresent = status == AttendanceStatus.present;
    final sessionId = currentState.activeSession?.id;
    final sessions = currentState.sessions.map((session) {
      if (session.id != sessionId) return session;
      var present = session.presentCount;
      if (!wasPresent && isPresent) present += 1;
      if (wasPresent && !isPresent) present -= 1;
      return PosyanduSession(
        id: session.id,
        posyanduName: session.posyanduName,
        date: session.date,
        targetCount: session.targetCount,
        presentCount: present < 0 ? 0 : present,
        status: session.status,
        createdByUid: session.createdByUid,
        note: session.note,
      );
    }).toList();
    commitState(
      currentState.copyWith(
        roster: currentState.roster
            .map(
              (item) => item.id == rosterId
                  ? item.copyWith(attendance: status)
                  : item,
            )
            .toList(),
        sessions: sessions,
        pendingWrites: currentState.pendingWrites + 1,
      ),
    );
  }

  /// Pemeriksaan ibu hamil dari mode kader. Dicatat pada entri roster karena
  /// akun ibu mungkin belum terhubung.
  void recordPregnancyCheckup({
    required String rosterId,
    required double lilaCm,
    double? hbGdl,
    double? weightKg,
    DateTime? date,
  }) {
    final entry = currentState.roster.firstWhereOrNull((r) => r.id == rosterId);
    if (entry == null) return;
    final wasPresent = entry.attendance == AttendanceStatus.present;
    final risky = lilaCm < 23.5 || (hbGdl != null && hbGdl < 11);
    final reason = risky
        ? 'LiLA ${lilaCm.toStringAsFixed(1)} cm'
              '${hbGdl == null ? '' : ' • Hb ${hbGdl.toStringAsFixed(1)} g/dL'}'
        : 'Pemeriksaan ibu hamil tercatat';
    final sessionId = currentState.activeSession?.id;
    final sessions = currentState.sessions.map((session) {
      if (session.id != sessionId) return session;
      return PosyanduSession(
        id: session.id,
        posyanduName: session.posyanduName,
        date: session.date,
        targetCount: session.targetCount,
        presentCount: wasPresent
            ? session.presentCount
            : session.presentCount + 1,
        status: session.status,
        createdByUid: session.createdByUid,
        note: session.note,
      );
    }).toList();
    commitState(
      currentState.copyWith(
        roster: currentState.roster.map((item) {
          if (item.id != rosterId) return item;
          return item.copyWith(
            attendance: AttendanceStatus.present,
            lilaCm: lilaCm,
            hbGdl: hbGdl,
            priority: risky,
            reason: reason,
            followUpStatus: risky ? FollowUpStatus.open : FollowUpStatus.closed,
            lastMeasuredAt: dateOnly(date ?? DateTime.now()),
            pendingSync: true,
          );
        }).toList(),
        sessions: sessions,
        pendingWrites: currentState.pendingWrites + 1,
      ),
    );
  }

  void recordFollowUp(String rosterId, FollowUpStatus status, {String? note}) {
    commitState(
      currentState.copyWith(
        roster: currentState.roster.map((entry) {
          if (entry.id != rosterId) return entry;
          return entry.copyWith(
            followUpStatus: status,
            priority: status == FollowUpStatus.open,
            reason: note ?? entry.reason,
          );
        }).toList(),
      ),
    );
  }

  void completeSession() {
    final session = currentState.activeSession;
    if (session == null) return;
    final updated = PosyanduSession(
      id: session.id,
      posyanduName: session.posyanduName,
      date: session.date,
      targetCount: session.targetCount,
      presentCount: session.presentCount,
      status: 'selesai',
      createdByUid: session.createdByUid,
      note: session.note,
    );
    commitState(
      currentState.copyWith(
        sessions: currentState.sessions
            .map((s) => s.id == session.id ? updated : s)
            .toList(),
      ),
    );
  }

  Future<void> syncNow() async {
    final user = currentState.currentUser;
    if (databaseService.isAvailable && user != null) {
      await databaseService.syncAll(state: currentState, user: user);
      final pulled = await databaseService.pullUserDataset(
        user: user,
        currentState: currentState,
      );
      if (pulled != null) {
        commitState(pulled);
        return;
      }
    }
    final children = currentState.children.map((child) {
      return child.copyWith(
        measurements: child.measurements
            .map((m) => m.copyWith(synced: true))
            .toList(),
      );
    }).toList();
    final roster = currentState.roster
        .map((entry) => entry.copyWith(pendingSync: false))
        .toList();
    commitState(
      currentState.copyWith(
        children: children,
        roster: roster,
        pendingWrites: 0,
        lastSyncAt: DateTime.now(),
      ),
    );
  }
}
