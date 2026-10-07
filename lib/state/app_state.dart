import 'dart:async';

import 'package:flutter/widgets.dart';

import '../data/nuri_repository.dart';
import '../data/reference_data.dart';
import '../data/seed_data.dart';
import '../data/supabase_service.dart';
import '../domain/models/app_role.dart';
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

/// State aplikasi: membungkus [NuriRepository] dan memberi tahu UI setiap
/// ada perubahan. Menjaga aturan PRD (validasi, consent, append-only).
class NuriAppState extends ChangeNotifier {
  NuriAppState._(this.reference, this.repo, [this.cloud]);

  /// Konstruktor untuk pengujian: tanpa seed data dan tanpa cloud.
  factory NuriAppState.forTesting(ReferenceData reference) =>
      NuriAppState._(reference, NuriRepository(reference: reference));

  final ReferenceData reference;
  final NuriRepository repo;

  /// Integrasi Supabase (null bila tidak dikonfigurasi → mode offline).
  final SupabaseService? cloud;

  bool _disclaimerAccepted = false;
  String? _selectedChildId;

  /// Memuat aset referensi. Bila Supabase dikonfigurasi, inisialisasi cloud dan
  /// tarik data pengguna; bila tidak, pakai data contoh (mode demo offline).
  static Future<NuriAppState> bootstrap({bool seed = true}) async {
    final ReferenceData reference = await ReferenceData.load();
    final SupabaseService cloud = SupabaseService.instance;
    if (cloud.isConfigured) {
      await cloud.init();
    }
    final NuriRepository repo = NuriRepository(
      reference: reference,
      cloud: cloud.isConfigured ? cloud : null,
    );
    final NuriAppState state = NuriAppState._(
      reference,
      repo,
      cloud.isConfigured ? cloud : null,
    );

    if (cloud.isConfigured) {
      if (cloud.isSignedIn) {
        await state._adoptCloudSession();
      }
    } else if (seed) {
      SeedData.seedMother(repo);
      state._selectedChildId =
          repo.children.isEmpty ? null : repo.children.first.id;
    }
    return state;
  }

  /// Setelah sesi Supabase aktif: buat profil lokal, muat data pengguna.
  Future<void> _adoptCloudSession() async {
    final SupabaseService? svc = cloud;
    final String? uid = svc?.uid;
    if (svc == null || uid == null) return;
    final AppRole role = repo.user?.role ?? AppRole.ibuBalita;
    repo.signIn(
      UserProfile(
        id: uid,
        role: role,
        displayName: repo.user?.displayName ?? (svc.email ?? 'Bunda'),
        email: svc.email ?? '',
        privacyVersion: 'v1',
        privacyAt: DateTime.now(),
      ),
    );
    repo.setOnline(true);
    try {
      await repo.pullFromCloud();
    } catch (_) {
      // Tetap jalan offline bila penarikan gagal.
    }
    _selectedChildId =
        repo.children.isEmpty ? null : repo.children.first.id;
  }

  bool get cloudEnabled => cloud != null && cloud!.isConfigured;
  bool get cloudSignedIn => cloud?.isSignedIn ?? false;
  String? get cloudEmail => cloud?.email;

  // ---- Akun ----------------------------------------------------------------

  UserProfile? get user => repo.user;
  bool get isSignedIn => repo.isSignedIn;

  void signIn({
    required String name,
    required String role, // 'ibu_balita' | 'ibu_hamil' | 'kader'
    String? email,
    String? posyandu,
  }) {
    repo.signIn(
      UserProfile(
        id: repo.newId,
        role: AppRole.fromCode(role),
        displayName: name,
        email: email ?? '$name@nuri.app',
        posyanduName: posyandu,
        privacyVersion: 'v1',
        privacyAt: DateTime.now(),
      ),
    );
    _disclaimerAccepted = false;
    notifyListeners();
  }

  /// Login Supabase (email + sandi). Fallback ke mode lokal bila cloud mati.
  Future<void> authSignIn({
    required String email,
    required String password,
    String role = 'ibu_balita',
    String? name,
  }) async {
    final SupabaseService? svc = cloud;
    if (svc != null && svc.isReady && svc.isConfigured) {
      final String uid = await svc.signInWithPassword(
        email: email,
        password: password,
      );
      final AppRole appRole = AppRole.fromCode(role);
      final String display = (name != null && name.trim().isNotEmpty)
          ? name.trim()
          : (email.contains('@') ? email.split('@').first : email);
      await svc.upsertProfile(
        id: uid,
        role: appRole,
        displayName: display,
        email: email,
      );
      repo.signIn(
        UserProfile(
          id: uid,
          role: appRole,
          displayName: display,
          email: email,
          privacyVersion: 'v1',
          privacyAt: DateTime.now(),
        ),
      );
      repo.setOnline(true);
      try {
        await repo.pullFromCloud();
      } catch (_) {}
      _selectedChildId =
          repo.children.isEmpty ? null : repo.children.first.id;
      _disclaimerAccepted = false;
      notifyListeners();
      return;
    }
    signIn(
      name: name ?? 'Bunda',
      role: role,
      email: email.isNotEmpty ? email : null,
    );
  }

  /// Daftar akun Supabase baru (email + sandi).
  Future<void> authSignUp({
    required String email,
    required String password,
    required String name,
    String role = 'ibu_balita',
  }) async {
    final SupabaseService? svc = cloud;
    if (svc != null && svc.isReady && svc.isConfigured) {
      final AppRole appRole = AppRole.fromCode(role);
      final String uid = await svc.signUp(
        email: email,
        password: password,
        displayName: name,
        role: appRole,
      );
      if (!svc.isSignedIn) {
        throw Exception(
          'Akun dibuat. Cek email untuk konfirmasi, lalu masuk kembali.',
        );
      }
      repo.signIn(
        UserProfile(
          id: uid,
          role: appRole,
          displayName: name,
          email: email,
          privacyVersion: 'v1',
          privacyAt: DateTime.now(),
        ),
      );
      repo.setOnline(true);
      try {
        await repo.pullFromCloud();
      } catch (_) {}
      _selectedChildId =
          repo.children.isEmpty ? null : repo.children.first.id;
      _disclaimerAccepted = false;
      notifyListeners();
      return;
    }
    signIn(name: name, role: role, email: email);
  }

  void signOut() {
    final SupabaseService? svc = cloud;
    if (svc != null && svc.isReady && svc.isSignedIn) {
      unawaited(svc.signOut());
    }
    repo.signOut();
    _selectedChildId = null;
    notifyListeners();
  }

  /// Hapus akun & seluruh data. Bila Supabase aktif, hapus juga di cloud (F13).
  Future<void> deleteAccount() async {
    final SupabaseService? svc = cloud;
    if (svc != null && svc.isReady && svc.isSignedIn) {
      try {
        await svc.deleteMyAccount();
      } catch (_) {
        // Bila gagal di cloud, tetap bersihkan lokal.
      }
    }
    repo.deleteAccountData();
    _selectedChildId = null;
    notifyListeners();
  }

  // ---- Disclaimer (F2) -----------------------------------------------------

  bool get disclaimerAccepted => _disclaimerAccepted;

  void acceptDisclaimer() {
    _disclaimerAccepted = true;
    notifyListeners();
  }

  // ---- Anak ----------------------------------------------------------------

  List<Child> get children => repo.children;

  Child? get selectedChild {
    if (children.isEmpty) return null;
    for (final Child c in children) {
      if (c.id == _selectedChildId) return c;
    }
    return children.first;
  }

  void selectChild(String id) {
    _selectedChildId = id;
    notifyListeners();
  }

  Child? childById(String id) => repo.childById(id);

  /// Menambah anak. Menolak tanggal lahir di masa depan (F3).
  Child addChild({
    required String nickname,
    required DateTime birthDate,
    required Sex sex,
    String? posyanduName,
    GuardianConsent? consent,
  }) {
    if (birthDate.isAfter(DateTime.now())) {
      throw const FormatException('Tanggal lahir tidak boleh di masa depan.');
    }
    final Child child = repo.addChild(
      nickname: nickname,
      birthDate: birthDate,
      sex: sex,
      posyanduName: posyanduName,
      consent: consent,
    );
    _selectedChildId ??= child.id;
    notifyListeners();
    return child;
  }

  void deleteChild(String id) {
    repo.deleteChild(id);
    if (_selectedChildId == id) {
      _selectedChildId = children.isEmpty ? null : children.first.id;
    }
    notifyListeners();
  }

  // ---- Pengukuran & z-score (F4, F5, F6) -----------------------------------

  /// Menghitung z-score lokal lalu menyimpan. Melempar
  /// [GrowthValidationException] bila tidak valid (ditampilkan ke pengguna).
  GrowthResult recordMeasurement({
    required Child child,
    required DateTime measuredOn,
    required double weightKg,
    required double lengthHeightCm,
    required MeasureMethod method,
    String? sessionId,
  }) {
    final GrowthResult result = repo.recordMeasurement(
      child: child,
      measuredOn: measuredOn,
      weightKg: weightKg,
      lengthHeightCm: lengthHeightCm,
      method: method,
      sessionId: sessionId,
    );
    notifyListeners();
    return result;
  }

  List<ScreeningRecord> screeningsFor(String childId) =>
      repo.screeningsFor(childId);

  ScreeningRecord? latestScreening(String childId) =>
      repo.latestScreening(childId);

  ScreeningRecord? get latestForSelected {
    final Child? child = selectedChild;
    return child == null ? null : repo.latestScreening(child.id);
  }

  // ---- Makanan & gizi (F10, F11) -------------------------------------------

  List<FoodLogItem> foodItemsFor({required String childId, required DateTime date}) =>
      repo.foodItemsFor(childId: childId, date: date);

  NutritionSummary nutritionSummaryFor({
    required Child child,
    required DateTime date,
  }) =>
      repo.nutritionSummaryFor(child: child, date: date);

  FoodLogItem addFoodItem({
    required Child child,
    required DateTime date,
    required MealType meal,
    required TkpiFood food,
    required FoodPortion portion,
    required FoodSource source,
    double? confidence,
  }) {
    final FoodLogItem item = repo.addFoodItem(
      child: child,
      date: date,
      meal: meal,
      food: food,
      portion: portion,
      source: source,
      confidence: confidence,
    );
    notifyListeners();
    return item;
  }

  void removeFoodItem(String id) {
    repo.removeFoodItem(id);
    notifyListeners();
  }

  /// Klasifikasi foto makanan (F9). Model TFLite belum dibundel, jadi
  /// simulasi mengembalikan top-3 dengan skor; ambang keyakinan 0,60.
  List<FoodCandidate> mockScan() {
    final List<TkpiFood> foods = reference.tkpi.foods;
    if (foods.isEmpty) return const <FoodCandidate>[];
    TkpiFood pick(String id, int fallback) =>
        reference.tkpi.byId(id) ?? foods[fallback % foods.length];
    return <FoodCandidate>[
      FoodCandidate(food: pick('TKPI-001', 0), confidence: 0.82),
      FoodCandidate(food: pick('TKPI-007', 1), confidence: 0.64),
      FoodCandidate(food: pick('TKPI-016', 2), confidence: 0.31),
    ];
  }

  DateTime get today {
    final DateTime now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  // ---- Sesi kader (F8) -----------------------------------------------------

  List<ScreeningSession> get sessions => repo.sessions;
  ScreeningSession? get activeSession => repo.activeSession;

  ScreeningSession createSession({
    required String posyanduName,
    required DateTime heldOn,
  }) {
    final ScreeningSession session = repo.createSession(
      posyanduName: posyanduName,
      heldOn: heldOn,
    );
    notifyListeners();
    return session;
  }

  ScreeningSession? sessionById(String id) => repo.sessionById(id);

  void closeSession(String id) {
    repo.closeSession(id);
    notifyListeners();
  }

  List<ScreeningRecord> screeningsInSession(String sessionId) =>
      repo.screeningsInSession(sessionId);

  // ---- Sinkronisasi (F12) --------------------------------------------------

  bool get online => repo.online;
  bool get syncing => repo.syncing;
  int get pendingCount => repo.pendingCount;
  SyncState get syncState => repo.syncState;
  String get storageLabel => repo.storageLabel;
  DateTime? get lastSyncedAt => repo.lastSyncedAt;

  void setOnline(bool value) {
    repo.setOnline(value);
    notifyListeners();
  }

  Future<int> sync() async {
    if (!repo.online) {
      repo.setOnline(true);
    }
    notifyListeners();
    final int sent = await repo.sync();
    notifyListeners();
    return sent;
  }
}

/// Menyediakan [NuriAppState] ke seluruh widget tree dan rebuild saat berubah.
class NuriScope extends InheritedNotifier<NuriAppState> {
  const NuriScope({super.key, required NuriAppState state, required super.child})
    : super(notifier: state);

  static NuriAppState of(BuildContext context) {
    final NuriScope? scope =
        context.dependOnInheritedWidgetOfExactType<NuriScope>();
    assert(scope != null, 'NuriScope tidak ditemukan di widget tree.');
    return scope!.notifier!;
  }

  static NuriAppState read(BuildContext context) {
    final NuriScope? scope =
        context.getInheritedWidgetOfExactType<NuriScope>();
    assert(scope != null, 'NuriScope tidak ditemukan di widget tree.');
    return scope!.notifier!;
  }
}
