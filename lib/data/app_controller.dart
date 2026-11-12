import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/growth/growth_calculator.dart';
import '../domain/growth/who_lms.dart';
import '../domain/models.dart';
import '../domain/nutrition/food_catalog.dart';
import '../domain/pregnancy/pregnancy_calculator.dart';
import 'demo_seed.dart';
import 'local_repository.dart';

final localRepositoryProvider = Provider<AppRepository>(
  (ref) => throw UnimplementedError('Repository harus di-override di main().'),
);

final whoReferenceProvider = Provider<WhoReference>(
  (ref) => WhoReference.instance,
);

final foodCatalogProvider = Provider<FoodCatalog>(
  (ref) => FoodCatalog.instance,
);

final appControllerProvider = NotifierProvider<AppController, AppState>(
  () => throw UnimplementedError('AppController harus di-override di main().'),
);

class AppController extends Notifier<AppState> {
  AppController(this._initial, this._repository);

  final AppState _initial;
  final AppRepository _repository;

  @override
  AppState build() => _initial;

  void _commit(AppState next) {
    state = next;
    unawaited(_repository.save(next));
  }

  AppUser? _findUserByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in state.users) {
      if (user.email.toLowerCase() == normalized) return user;
    }
    return null;
  }

  AppUser? _findDemoUser(UserRole role) {
    for (final user in state.users) {
      if (user.demo && user.role == role) return user;
    }
    return null;
  }

  String? login(String email, String password) {
    final user = _findUserByEmail(email);
    if (user == null) {
      return 'Email belum terdaftar. Periksa kembali atau daftar akun baru.';
    }
    if (password.trim().length < 6) return 'Password minimal 6 karakter.';
    _commit(state.copyWith(currentUserId: user.id, landingSeen: true));
    return null;
  }

  void loginDemo(UserRole role) {
    final user = _findDemoUser(role) ?? state.users.firstOrNull;
    if (user == null) return;
    _commit(
      state.copyWith(
        currentUserId: user.id,
        onboardingSeen: true,
        landingSeen: true,
      ),
    );
  }

  void loginAsUser(String userId) {
    _commit(
      state.copyWith(
        currentUserId: userId,
        onboardingSeen: true,
        landingSeen: true,
      ),
    );
  }

  void logout() {
    _commit(
      state.copyWith(
        currentUserId: null,
        selectedChildId: null,
        pregnancyContext: true,
      ),
    );
  }

  String? register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    if (name.trim().length < 2) return 'Nama minimal 2 karakter.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Format email belum benar.';
    }
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (_findUserByEmail(email) != null) {
      return 'Email sudah digunakan. Coba masuk atau gunakan email lain.';
    }
    final user = AppUser(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: role,
      posyanduId: role == UserRole.cadre ? 'p_melati' : null,
      demo: false,
    );
    _commit(
      state.copyWith(
        users: [...state.users, user],
        currentUserId: user.id,
        onboardingSeen: false,
        consentAccepted: false,
        landingSeen: true,
      ),
    );
    return null;
  }

  void acceptConsent() {
    _commit(state.copyWith(consentAccepted: true, consentVersion: '2026-11'));
  }

  void completeOnboarding() {
    _commit(state.copyWith(onboardingSeen: true));
  }

  void setLandingSeen() {
    _commit(state.copyWith(landingSeen: true));
  }

  void selectContext({required bool pregnancy}) {
    _commit(state.copyWith(pregnancyContext: pregnancy));
  }

  void selectChild(String childId) {
    _commit(state.copyWith(selectedChildId: childId));
  }

  void toggleReminders() {
    _commit(state.copyWith(remindersEnabled: !state.remindersEnabled));
  }

  void updateProfile({required String name}) {
    final user = state.currentUser;
    if (user == null) return;
    final updated = AppUser(
      id: user.id,
      name: name.trim(),
      email: user.email,
      role: user.role,
      posyanduId: user.posyanduId,
      avatarAsset: user.avatarAsset,
      demo: user.demo,
    );
    _commit(
      state.copyWith(
        users: state.users.map((u) => u.id == user.id ? updated : u).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Kehamilan
  // ---------------------------------------------------------------------------

  Pregnancy? addPregnancy({required DateTime hpht, DateTime? hpl}) {
    final user = state.currentUser;
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
    _commit(
      state.copyWith(
        pregnancies: [...state.pregnancies, pregnancy],
        pregnancyContext: true,
      ),
    );
    return pregnancy;
  }

  void setPosyandu({required String name, String? area}) {
    _commit(
      state.copyWith(
        posyanduName: name.trim().isEmpty ? state.posyanduName : name.trim(),
        posyanduArea: area?.trim().isNotEmpty == true
            ? area!.trim()
            : state.posyanduArea,
      ),
    );
  }

  void toggleTtdForDate(DateTime date) {
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) return;
    final key = dateToIso(date);
    final dates = List<String>.from(pregnancy.ttdDates);
    if (dates.contains(key)) {
      dates.remove(key);
    } else {
      dates.add(key);
    }
    final updated = pregnancy.copyWith(ttdDates: dates);
    _commit(
      state.copyWith(
        pregnancies: state.pregnancies
            .map((p) => p.id == pregnancy.id ? updated : p)
            .toList(),
      ),
    );
  }

  void addAncVisit({DateTime? date, String? facility, String? note}) {
    final pregnancy = state.activePregnancy;
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
    _commit(
      state.copyWith(
        pregnancies: state.pregnancies
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
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) return;
    final checkup = Checkup(
      id: 'chk_${DateTime.now().microsecondsSinceEpoch}',
      date: dateOnly(date ?? DateTime.now()),
      weightKg: weightKg,
      lilaCm: lilaCm,
      hbGdl: hbGdl,
      systolic: systolic,
      diastolic: diastolic,
      source: state.isCadre ? 'kader' : 'mandiri',
      recordedBy: state.currentUser?.name ?? 'Ibu',
    );
    final updated = pregnancy.copyWith(
      checkups: [...pregnancy.checkups, checkup],
    );
    _commit(
      state.copyWith(
        pregnancies: state.pregnancies
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
    final pregnancy = state.activePregnancy;
    final user = state.currentUser;
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
    _commit(
      state.copyWith(
        children: [...state.children, child],
        pregnancies: state.pregnancies
            .map((p) => p.id == pregnancy.id ? updatedPregnancy : p)
            .toList(),
        selectedChildId: child.id,
        pregnancyContext: false,
      ),
    );
    return child;
  }

  void endPregnancy() {
    final pregnancy = state.activePregnancy;
    if (pregnancy == null) return;
    final updated = pregnancy.copyWith(status: PregnancyStatus.ended);
    _commit(
      state.copyWith(
        pregnancies: state.pregnancies
            .map((p) => p.id == pregnancy.id ? updated : p)
            .toList(),
        pregnancyContext: false,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Anak dan pengukuran
  // ---------------------------------------------------------------------------

  String? addChild({
    required String nickname,
    required DateTime dob,
    required Sex sex,
    String? guardianName,
    double? birthWeightKg,
    double? birthLengthCm,
  }) {
    final user = state.currentUser;
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
      avatarIndex: state.children.length % 8,
    );
    final updatedRoster = user.role == UserRole.cadre
        ? [
            ...state.roster,
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
        : state.roster;
    _commit(
      state.copyWith(
        children: [...state.children, child],
        roster: updatedRoster,
        selectedChildId: state.selectedChildId ?? child.id,
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
  }) {
    final child = state.children.firstWhereOrNull((c) => c.id == childId);
    if (child == null) return null;
    final ageMonths = child.ageMonthsAt(date);
    final eval = GrowthCalculator(reference: WhoReference.instance).evaluate(
      heightCm: heightCm,
      weightKg: weightKg,
      sex: child.sex,
      dob: child.dob,
      measureDate: date,
      method: method ?? GrowthCalculator.defaultMethodForAge(ageMonths),
      allowImplausible: true,
    );
    final source = state.isCadre ? 'kader' : 'mandiri';
    final sessionId = state.isCadre ? state.activeSession?.id : null;
    final synced = !state.isCadre;
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
      recordedByUid: state.currentUserId,
      sessionId: sessionId,
      flags: eval.flags,
      synced: synced,
      createdAt: DateTime.now(),
    );
    final updatedChild = child.copyWith(
      measurements: [...child.measurements, measurement],
    );
    final children = state.children
        .map((c) => c.id == childId ? updatedChild : c)
        .toList();
    final roster = state.roster.map((entry) {
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
    final sessions = state.sessions.map((session) {
      if (session.id != sessionId) return session;
      final alreadyPresent = state.roster
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
    _commit(
      state.copyWith(
        children: children,
        roster: roster,
        sessions: sessions,
        pendingWrites: synced ? state.pendingWrites : state.pendingWrites + 1,
      ),
    );
    return measurement;
  }

  // ---------------------------------------------------------------------------
  // Makanan
  // ---------------------------------------------------------------------------

  FoodLog addFoodLog({
    required String subjectId,
    required MealType meal,
    required List<FoodLogItem> items,
    DateTime? date,
    String? note,
  }) {
    final log = FoodLog(
      id: 'fl_${DateTime.now().microsecondsSinceEpoch}',
      subjectId: subjectId,
      date: dateOnly(date ?? DateTime.now()),
      meal: meal,
      items: items,
      note: note,
      createdAt: DateTime.now(),
    );
    _commit(state.copyWith(foodLogs: [...state.foodLogs, log]));
    return log;
  }

  void updateFoodLog(
    String id, {
    List<FoodLogItem>? items,
    MealType? meal,
    String? note,
  }) {
    _commit(
      state.copyWith(
        foodLogs: state.foodLogs
            .map(
              (log) => log.id == id
                  ? log.copyWith(items: items, meal: meal, note: note)
                  : log,
            )
            .toList(),
      ),
    );
  }

  void deleteFoodLog(String id) {
    _commit(
      state.copyWith(
        foodLogs: state.foodLogs.where((log) => log.id != id).toList(),
      ),
    );
  }

  void markArticleRead(String id) {
    _commit(state.copyWith(readArticles: {...state.readArticles, id}));
  }

  void setMealPlan(List<String> menuIds) {
    _commit(state.copyWith(mealPlan: menuIds));
  }

  // ---------------------------------------------------------------------------
  // Kader, sesi, tindak lanjut
  // ---------------------------------------------------------------------------

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
    final user = state.currentUser;
    if (user == null) return 'Sesi pengguna tidak ditemukan.';
    final id = 'r_${DateTime.now().microsecondsSinceEpoch}';
    String? childId;
    var children = state.children;
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
        avatarIndex: state.children.length % 8,
      );
      childId = child.id;
      children = [...state.children, child];
    }
    final entry = RosterEntry(
      id: id,
      name: name.trim(),
      type: type,
      attendance: AttendanceStatus.waiting,
      avatarIndex: state.roster.length % 8,
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
    final sessions = state.sessions.map((session) {
      if (session.id != state.activeSession?.id) return session;
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
    _commit(
      state.copyWith(
        children: children,
        roster: [...state.roster, entry],
        sessions: sessions,
        pendingWrites: state.pendingWrites + 1,
      ),
    );
    return null;
  }

  void markAttendance(String rosterId, AttendanceStatus status) {
    final entry = state.roster.firstWhereOrNull((r) => r.id == rosterId);
    if (entry == null) return;
    final wasPresent = entry.attendance == AttendanceStatus.present;
    final isPresent = status == AttendanceStatus.present;
    final sessionId = state.activeSession?.id;
    final sessions = state.sessions.map((session) {
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
    _commit(
      state.copyWith(
        roster: state.roster
            .map(
              (item) => item.id == rosterId
                  ? item.copyWith(attendance: status)
                  : item,
            )
            .toList(),
        sessions: sessions,
        pendingWrites: state.pendingWrites + 1,
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
    final entry = state.roster.firstWhereOrNull((r) => r.id == rosterId);
    if (entry == null) return;
    final wasPresent = entry.attendance == AttendanceStatus.present;
    final risky = lilaCm < 23.5 || (hbGdl != null && hbGdl < 11);
    final reason = risky
        ? 'LiLA ${lilaCm.toStringAsFixed(1)} cm'
              '${hbGdl == null ? '' : ' • Hb ${hbGdl.toStringAsFixed(1)} g/dL'}'
        : 'Pemeriksaan ibu hamil tercatat';
    final sessionId = state.activeSession?.id;
    final sessions = state.sessions.map((session) {
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
    _commit(
      state.copyWith(
        roster: state.roster.map((item) {
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
        pendingWrites: state.pendingWrites + 1,
      ),
    );
  }

  void recordFollowUp(String rosterId, FollowUpStatus status, {String? note}) {
    _commit(
      state.copyWith(
        roster: state.roster.map((entry) {
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
    final session = state.activeSession;
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
    _commit(
      state.copyWith(
        sessions: state.sessions
            .map((s) => s.id == session.id ? updated : s)
            .toList(),
      ),
    );
  }

  void syncNow() {
    final children = state.children.map((child) {
      return child.copyWith(
        measurements: child.measurements
            .map((m) => m.copyWith(synced: true))
            .toList(),
      );
    }).toList();
    final roster = state.roster
        .map((entry) => entry.copyWith(pendingSync: false))
        .toList();
    _commit(
      state.copyWith(
        children: children,
        roster: roster,
        pendingWrites: 0,
        lastSyncAt: DateTime.now(),
      ),
    );
  }

  void revokeGrant(String id) {
    _commit(
      state.copyWith(
        accessGrants: state.accessGrants
            .map(
              (grant) =>
                  grant.id == id ? grant.copyWith(status: 'dicabut') : grant,
            )
            .toList(),
      ),
    );
  }

  void resetDemo() {
    final seed = DemoSeed.build(who: WhoReference.instance);
    _commit(seed);
  }
}

extension _FirstWhereOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
