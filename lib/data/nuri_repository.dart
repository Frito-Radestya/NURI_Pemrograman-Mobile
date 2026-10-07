import 'dart:async';
import 'dart:math';

import '../domain/engines/growth_engine.dart';
import '../domain/engines/nutrition_engine.dart';
import '../domain/engines/recommendation_engine.dart';
import '../domain/models/child.dart';
import '../domain/models/food_item.dart';
import '../domain/models/food_log.dart';
import '../domain/models/growth_result.dart';
import '../domain/models/guardian_consent.dart';
import '../domain/models/measurement.dart';
import '../domain/models/nutrition_summary.dart';
import '../domain/models/screening_session.dart';
import '../domain/models/sex.dart';
import '../domain/models/user_profile.dart';
import 'reference_data.dart';
import 'supabase_service.dart';

/// Status antrean sinkron (PRD Bagian 8, tabel `outbox`).
enum OutboxStatus { pending, synced, failed }

/// Status koneksi & sinkronisasi yang terlihat di app bar (F12).
enum SyncState { offline, pending, syncing, synced }

/// Satu baris antrean sinkron.
class OutboxEntry {
  OutboxEntry({
    required this.id,
    required this.table,
    required this.op,
    required this.payload,
    required this.createdAt,
    this.attempts = 0,
    this.status = OutboxStatus.pending,
  });

  final String id;
  final String table;
  final String op;
  final Map<String, dynamic> payload;
  final DateTime createdAt;
  int attempts;
  OutboxStatus status;
}

/// Pengukuran beserta hasil skriningnya.
class ScreeningRecord {
  const ScreeningRecord({required this.measurement, required this.result});

  final Measurement measurement;
  final GrowthResult result;
}

/// Sumber data aplikasi.
///
/// Sesuai aturan arsitektur (PRD Bagian 5): UI tidak memanggil backend
/// langsung; semua tulis melewati repository -> penyimpanan lokal -> outbox.
/// Pada prototipe ini penyimpanan lokal disimulasikan di memori agar aplikasi
/// berjalan tanpa backend, tetapi alur dan antrean sinkron tetap nyata.
class NuriRepository {
  NuriRepository({
    required this.reference,
    this.deviceId = 'device-lokal',
    this.cloud,
  }) : growth = GrowthEngine(reference.whoLms),
       nutrition = NutritionEngine(reference.akg),
       recommendations = RecommendationEngine(reference.recommendations);

  final ReferenceData reference;
  final String deviceId;

  /// Integrasi Supabase (opsional). Bila null, aplikasi murni offline.
  final SupabaseService? cloud;

  final GrowthEngine growth;
  final NutritionEngine nutrition;
  final RecommendationEngine recommendations;

  static final Random _random = Random.secure();

  /// UUID v4 dibuat di klien agar bisa offline tanpa bentrok (PRD Bagian 5).
  static String _newUuid() {
    final List<int> bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    String hex(int b) => b.toRadixString(16).padLeft(2, '0');
    final String h = bytes.map(hex).join();
    return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
        '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
  }

  String get newId => _newUuid();

  UserProfile? _user;
  final List<Child> _children = <Child>[];
  final List<ScreeningRecord> _screenings = <ScreeningRecord>[];
  final List<FoodLogItem> _foodItems = <FoodLogItem>[];
  final List<ScreeningSession> _sessions = <ScreeningSession>[];
  final List<OutboxEntry> _outbox = <OutboxEntry>[];

  bool _online = false;
  bool _syncing = false;
  DateTime? _lastSyncedAt;

  // ---- Sesi & pengguna ------------------------------------------------------

  UserProfile? get user => _user;
  bool get isSignedIn => _user != null;

  void signIn(UserProfile user) => _user = user;

  void signOut() {
    _user = null;
    _children.clear();
    _screenings.clear();
    _foodItems.clear();
    _sessions.clear();
    _outbox.clear();
  }

  // ---- Anak -----------------------------------------------------------------

  List<Child> get children =>
      _children.where((Child c) => c.deletedAt == null).toList();

  /// Semua anak termasuk yang di-soft-delete (dipakai sinkronisasi).
  List<Child> get allChildren => List<Child>.unmodifiable(_children);

  Child addChild({
    required String nickname,
    required DateTime birthDate,
    required Sex sex,
    String? posyanduName,
    GuardianConsent? consent,
    String? id,
  }) {
    final DateTime now = DateTime.now();
    final Child child = Child(
      id: id ?? newId,
      createdBy: _user?.id ?? 'lokal',
      nickname: nickname,
      birthDate: birthDate,
      sex: sex,
      posyanduName: posyanduName,
      consent: consent,
      createdAt: now,
      updatedAt: now,
      deviceId: deviceId,
    );
    _children.add(child);
    _enqueue('children', 'insert', <String, dynamic>{
      'id': child.id,
      'nickname': child.nickname,
    });
    return child;
  }

  Child? childById(String id) {
    for (final Child child in _children) {
      if (child.id == id) return child;
    }
    return null;
  }

  void deleteChild(String id) {
    final int index = _children.indexWhere((Child c) => c.id == id);
    if (index == -1) return;
    _children[index] = _children[index].copyWith(
      deletedAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    _enqueue('children', 'soft_delete', <String, dynamic>{'id': id});
    if (cloud != null && cloud!.isSignedIn) {
      unawaited(cloud!.softDeleteChild(id));
    }
  }

  // ---- Pengukuran & skrining ------------------------------------------------

  /// Menghitung z-score lokal lalu menyimpan (append-only). Melempar
  /// [GrowthValidationException] bila input tidak valid.
  GrowthResult recordMeasurement({
    required Child child,
    required DateTime measuredOn,
    required double weightKg,
    required double lengthHeightCm,
    required MeasureMethod method,
    String? sessionId,
  }) {
    final GrowthResult result = growth.assess(
      child: child,
      measuredOn: measuredOn,
      weightKg: weightKg,
      lengthHeightCm: lengthHeightCm,
      method: method,
      recommendations: reference.recommendations,
    );

    final Measurement measurement = Measurement(
      id: newId,
      childId: child.id,
      sessionId: sessionId,
      measuredOn: measuredOn,
      ageMonths: result.ageMonths,
      weightKg: weightKg,
      lengthHeightCm: lengthHeightCm,
      method: method,
      adjustedCm: result.correctedCm,
      recordedBy: _user?.id ?? 'lokal',
      createdAt: DateTime.now(),
    );

    _screenings.add(
      ScreeningRecord(measurement: measurement, result: result),
    );
    _enqueue('measurements', 'insert', <String, dynamic>{
      'id': measurement.id,
      'child_id': child.id,
      'haz': result.zScore,
    });
    return result;
  }

  List<ScreeningRecord> get allScreenings =>
      List<ScreeningRecord>.unmodifiable(_screenings);

  List<FoodLogItem> get allFoodItems =>
      List<FoodLogItem>.unmodifiable(_foodItems);

  List<ScreeningRecord> screeningsFor(String childId) {
    final List<ScreeningRecord> list = _screenings
        .where((ScreeningRecord s) => s.measurement.childId == childId)
        .toList();
    list.sort(
      (ScreeningRecord a, ScreeningRecord b) =>
          a.measurement.measuredOn.compareTo(b.measurement.measuredOn),
    );
    return list;
  }

  ScreeningRecord? latestScreening(String childId) {
    final List<ScreeningRecord> list = screeningsFor(childId);
    return list.isEmpty ? null : list.last;
  }

  List<ScreeningRecord> screeningsInSession(String sessionId) => _screenings
      .where((ScreeningRecord s) => s.measurement.sessionId == sessionId)
      .toList();

  // ---- Makanan --------------------------------------------------------------

  FoodLogItem addFoodItem({
    required Child child,
    required DateTime date,
    required MealType meal,
    required TkpiFood food,
    required FoodPortion portion,
    required FoodSource source,
    double? confidence,
  }) {
    final FoodLogItem item = FoodLogItem(
      id: newId,
      childId: child.id,
      logDate: _dateOnly(date),
      meal: meal,
      tkpiId: food.id,
      foodName: food.name,
      emoji: food.emoji,
      group: food.group,
      portionLabel: portion.label,
      grams: portion.grams,
      source: source,
      confidence: confidence,
      nutrients: food.nutrientsFor(portion.grams),
      createdAt: DateTime.now(),
    );
    _foodItems.add(item);
    _enqueue('food_log_items', 'insert', <String, dynamic>{
      'id': item.id,
      'tkpi_id': item.tkpiId,
      'grams': item.grams,
    });
    return item;
  }

  void removeFoodItem(String id) {
    _foodItems.removeWhere((FoodLogItem item) => item.id == id);
    _enqueue('food_log_items', 'soft_delete', <String, dynamic>{'id': id});
    if (cloud != null && cloud!.isSignedIn) {
      unawaited(cloud!.deleteFoodItem(id));
    }
  }

  List<FoodLogItem> foodItemsFor({
    required String childId,
    required DateTime date,
  }) {
    final DateTime day = _dateOnly(date);
    final List<FoodLogItem> list = _foodItems
        .where(
          (FoodLogItem item) =>
              item.childId == childId && _dateOnly(item.logDate) == day,
        )
        .toList();
    return list;
  }

  NutritionSummary nutritionSummaryFor({
    required Child child,
    required DateTime date,
  }) {
    return nutrition.summarize(
      child: child,
      date: date,
      items: foodItemsFor(childId: child.id, date: date),
    );
  }

  // ---- Sesi kader -----------------------------------------------------------

  List<ScreeningSession> get sessions {
    final List<ScreeningSession> list = List<ScreeningSession>.of(_sessions);
    list.sort(
      (ScreeningSession a, ScreeningSession b) =>
          b.heldOn.compareTo(a.heldOn),
    );
    return list;
  }

  /// Semua sesi tanpa pengurutan (dipakai sinkronisasi).
  List<ScreeningSession> get allSessions =>
      List<ScreeningSession>.unmodifiable(_sessions);

  ScreeningSession? get activeSession {
    for (final ScreeningSession session in sessions) {
      if (!session.closed) return session;
    }
    return null;
  }

  ScreeningSession createSession({
    required String posyanduName,
    required DateTime heldOn,
  }) {
    final ScreeningSession session = ScreeningSession(
      id: newId,
      kaderId: _user?.id ?? 'lokal',
      posyanduName: posyanduName,
      heldOn: _dateOnly(heldOn),
      createdAt: DateTime.now(),
    );
    _sessions.add(session);
    _enqueue('screening_sessions', 'insert', <String, dynamic>{
      'id': session.id,
    });
    return session;
  }

  ScreeningSession? sessionById(String id) {
    for (final ScreeningSession session in _sessions) {
      if (session.id == id) return session;
    }
    return null;
  }

  void closeSession(String id) {
    final int index = _sessions.indexWhere(
      (ScreeningSession s) => s.id == id,
    );
    if (index == -1) return;
    _sessions[index] = _sessions[index].copyWith(closed: true);
    _enqueue('screening_sessions', 'update', <String, dynamic>{'id': id});
  }

  // ---- Sinkronisasi ---------------------------------------------------------

  bool get online => _online;
  bool get syncing => _syncing;
  DateTime? get lastSyncedAt => _lastSyncedAt;

  int get pendingCount =>
      _outbox.where((OutboxEntry e) => e.status == OutboxStatus.pending).length;
  int get syncedCount =>
      _outbox.where((OutboxEntry e) => e.status == OutboxStatus.synced).length;
  int get outboxCount => _outbox.length;

  SyncState get syncState {
    if (!_online) return SyncState.offline;
    if (_syncing) return SyncState.syncing;
    if (pendingCount > 0) return SyncState.pending;
    return SyncState.synced;
  }

  /// Indikator "tersimpan di HP / tersinkron" (PRD Bagian 4.2).
  String get storageLabel =>
      pendingCount == 0 ? 'Tersimpan di HP & tersinkron' : 'Tersimpan di HP';

  void setOnline(bool value) => _online = value;

  /// Sinkronisasi: ke Supabase bila terkonfigurasi & sudah masuk; jika tidak,
  /// simulasi lokal (offline-first, PRD Bagian 5).
  Future<int> sync() async {
    final SupabaseService? svc = cloud;
    if (svc != null && svc.isReady && svc.isSignedIn) {
      final UserProfile? profile = _user;
      if (profile == null) {
        throw StateError('Profil belum dimuat. Masuk terlebih dahulu.');
      }
      _syncing = true;
      try {
        final int sent = await svc.push(
          user: profile,
          children: allChildren,
          screenings: _screenings,
          sessions: _sessions,
          foodItems: _foodItems,
          deviceId: deviceId,
        );
        for (final OutboxEntry entry in _outbox) {
          if (entry.status == OutboxStatus.pending) {
            entry.attempts += 1;
            entry.status = OutboxStatus.synced;
          }
        }
        _lastSyncedAt = DateTime.now();
        _syncing = false;
        return sent;
      } catch (_) {
        for (final OutboxEntry entry in _outbox) {
          if (entry.status == OutboxStatus.pending) {
            entry.attempts += 1;
            entry.status = OutboxStatus.failed;
          }
        }
        _syncing = false;
        rethrow;
      }
    }

    if (!_online) return 0;
    _syncing = true;
    await Future<void>.delayed(const Duration(milliseconds: 900));
    int sent = 0;
    for (final OutboxEntry entry in _outbox) {
      if (entry.status == OutboxStatus.pending) {
        entry.attempts += 1;
        entry.status = OutboxStatus.synced;
        sent += 1;
      }
    }
    _syncing = false;
    _lastSyncedAt = DateTime.now();
    return sent;
  }

  /// Tarik data pengguna dari Supabase lalu gantikan state lokal.
  Future<void> pullFromCloud() async {
    final SupabaseService? svc = cloud;
    if (svc == null || !svc.isReady || !svc.isSignedIn) return;
    final CloudSnapshot snapshot = await svc.pull();
    _children
      ..clear()
      ..addAll(snapshot.children);
    _screenings
      ..clear()
      ..addAll(snapshot.screenings);
    _sessions
      ..clear()
      ..addAll(snapshot.sessions);
    _foodItems
      ..clear()
      ..addAll(snapshot.foodItems);
  }

  void _enqueue(String table, String op, Map<String, dynamic> payload) {
    _outbox.add(
      OutboxEntry(
        id: newId,
        table: table,
        op: op,
        payload: payload,
        createdAt: DateTime.now(),
      ),
    );
  }

  // ---- Hapus akun (F13) -----------------------------------------------------

  /// Menghapus seluruh data pengguna, di cloud dan lokal.
  void deleteAccountData() {
    _children.clear();
    _screenings.clear();
    _foodItems.clear();
    _sessions.clear();
    _outbox.clear();
    _user = null;
  }

  static DateTime dateOnly(DateTime value) => _dateOnly(value);
  static DateTime _dateOnly(DateTime value) =>
      DateTime(value.year, value.month, value.day);
}
