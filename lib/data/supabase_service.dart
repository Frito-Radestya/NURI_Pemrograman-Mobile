import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/supabase_config.dart';
import '../domain/models/app_role.dart';
import '../domain/models/child.dart';
import '../domain/models/food_item.dart';
import '../domain/models/food_log.dart';
import '../domain/models/growth_result.dart';
import '../domain/models/growth_status.dart';
import '../domain/models/guardian_consent.dart';
import '../domain/models/measurement.dart';
import '../domain/models/nutrient.dart';
import '../domain/models/screening_session.dart';
import '../domain/models/sex.dart';
import '../domain/models/user_profile.dart';
import 'nuri_repository.dart';

/// Data yang ditarik dari Supabase untuk menghidrasi penyimpanan lokal.
class CloudSnapshot {
  const CloudSnapshot({
    required this.children,
    required this.screenings,
    required this.sessions,
    required this.foodItems,
  });

  final List<Child> children;
  final List<ScreeningRecord> screenings;
  final List<ScreeningSession> sessions;
  final List<FoodLogItem> foodItems;

  bool get isEmpty =>
      children.isEmpty &&
      screenings.isEmpty &&
      sessions.isEmpty &&
      foodItems.isEmpty;
}

/// Integrasi Supabase (Auth + Postgres + RLS) untuk NURI v2.0.
///
/// Skema mengikuti `supabase/migrations/0001_nuri_schema.sql`:
/// enum child_sex ('L'/'P'), children.created_by, screening_sessions.kader_id,
/// food_logs + food_log_items, kolom device_id & server_updated_at.
class SupabaseService {
  SupabaseService._();

  static final SupabaseService instance = SupabaseService._();

  bool _initialized = false;

  bool get isConfigured => SupabaseConfig.isConfigured;
  bool get isReady => _initialized;
  bool get isSignedIn => _initialized && _client.auth.currentUser != null;
  String? get uid => isSignedIn ? _client.auth.currentUser!.id : null;
  String? get email => isSignedIn ? _client.auth.currentUser!.email : null;

  SupabaseClient get _client => Supabase.instance.client;

  /// Pemetaan Nutrient <-> kunci `nutrients_json` di skema.
  static const Map<Nutrient, String> _nutrientKey = <Nutrient, String>{
    Nutrient.energy: 'energy_kcal',
    Nutrient.protein: 'protein_g',
    Nutrient.fat: 'fat_g',
    Nutrient.carb: 'carb_g',
    Nutrient.iron: 'iron_mg',
    Nutrient.zinc: 'zinc_mg',
    Nutrient.calcium: 'calcium_mg',
    Nutrient.vitaminA: 'vit_a_mcg',
  };

  static Nutrient _nutrientFromKey(String key) {
    for (final MapEntry<Nutrient, String> e in _nutrientKey.entries) {
      if (e.value == key) return e.key;
    }
    return Nutrient.energy;
  }

  Future<void> init() async {
    if (_initialized || !isConfigured) return;
    await Supabase.initialize(
      url: SupabaseConfig.url,
      publishableKey: SupabaseConfig.key,
    );
    _initialized = true;
  }

  // ---- Auth (F1) -----------------------------------------------------------

  Future<String> signInWithPassword({
    required String email,
    required String password,
  }) async {
    final AuthResponse res = await _client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    final User? user = res.user;
    if (user == null) {
      throw Exception('Tidak dapat masuk. Periksa email dan sandi.');
    }
    return user.id;
  }

  Future<String> signUp({
    required String email,
    required String password,
    required String displayName,
    AppRole role = AppRole.ibuBalita,
    String? posyanduName,
  }) async {
    final AuthResponse res = await _client.auth.signUp(
      email: email.trim(),
      password: password,
      data: <String, dynamic>{'display_name': displayName, 'role': role.dbCode},
    );
    final User? user = res.user;
    if (user == null) {
      throw Exception('Pendaftaran gagal. Coba lagi.');
    }
    await _client.from('profiles').upsert(<String, dynamic>{
      'id': user.id,
      'role': role.dbCode,
      'display_name': displayName,
      'email': email.trim(),
      'posyandu_name': posyanduName,
      'privacy_version': 'v1',
      'privacy_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
    return user.id;
  }

  Future<void> upsertProfile({
    required String id,
    required AppRole role,
    required String displayName,
    required String email,
    String? posyanduName,
  }) async {
    await _client.from('profiles').upsert(<String, dynamic>{
      'id': id,
      'role': role.dbCode,
      'display_name': displayName,
      'email': email,
      'posyandu_name': posyanduName,
      'privacy_version': 'v1',
      'privacy_at': DateTime.now().toUtc().toIso8601String(),
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  Future<void> signOut() async {
    if (!_initialized) return;
    await _client.auth.signOut();
  }

  Future<void> deleteMyAccount() async {
    if (!isSignedIn) return;
    await _client.rpc('delete_my_account');
  }

  // ---- Unggah (F12) --------------------------------------------------------

  /// Mendorong seluruh state lokal ke Supabase (upsert idempoten).
  Future<int> push({
    required UserProfile user,
    required List<Child> children,
    required List<ScreeningRecord> screenings,
    required List<ScreeningSession> sessions,
    required List<FoodLogItem> foodItems,
    String deviceId = 'device-lokal',
  }) async {
    final String? authUid = uid;
    if (authUid == null) {
      throw Exception('Belum masuk ke Supabase.');
    }
    if (user.id != authUid) {
      throw StateError(
        'Profil lokal belum terhubung ke akun Supabase. Masuk ulang lewat layar Masuk.',
      );
    }

    int sent = 0;
    final String now = DateTime.now().toUtc().toIso8601String();

    await _client.from('profiles').upsert(<String, dynamic>{
      'id': user.id,
      'role': user.role.dbCode,
      'display_name': user.displayName,
      'email': user.email,
      'posyandu_name': user.posyanduName,
      'privacy_version': user.privacyVersion ?? 'v1',
      'privacy_at':
          (user.privacyAt ?? DateTime.now()).toUtc().toIso8601String(),
      'device_id': deviceId,
      'updated_at': now,
    });
    sent++;

    for (final Child child in children) {
      await _client.from('children').upsert(<String, dynamic>{
        'id': child.id,
        'created_by': authUid,
        'nickname': child.nickname,
        'birth_date': _date(child.birthDate),
        'sex': child.sex.dbCode,
        'posyandu_name': child.posyanduName,
        'created_at': child.createdAt.toUtc().toIso8601String(),
        'updated_at': child.updatedAt.toUtc().toIso8601String(),
        'deleted_at': child.deletedAt?.toUtc().toIso8601String(),
        'device_id': deviceId,
      });
      sent++;

      final GuardianConsent? consent = child.consent;
      if (consent != null) {
        await _client.from('guardian_consents').upsert(<String, dynamic>{
          'child_id': child.id,
          'method': consent.method.name,
          'consented_at': consent.consentedAt.toUtc().toIso8601String(),
          'recorded_by': authUid,
          'device_id': deviceId,
          'updated_at': now,
        }, onConflict: 'child_id');
        sent++;
      }
    }

    for (final ScreeningSession session in sessions) {
      await _client.from('screening_sessions').upsert(<String, dynamic>{
        'id': session.id,
        'kader_id': authUid,
        'posyandu_name': session.posyanduName,
        'held_on': _date(session.heldOn),
        'closed': session.closed,
        'created_at': session.createdAt.toUtc().toIso8601String(),
        'updated_at': now,
        'device_id': deviceId,
      });
      sent++;
    }

    for (final ScreeningRecord record in screenings) {
      final Measurement m = record.measurement;
      final GrowthResult r = record.result;
      await _client.from('measurements').upsert(<String, dynamic>{
        'id': m.id,
        'child_id': m.childId,
        'session_id': m.sessionId,
        'measured_on': _date(m.measuredOn),
        'age_months': m.ageMonths,
        'weight_kg': m.weightKg,
        'length_height_cm': m.lengthHeightCm,
        'method': m.method.name,
        'adjusted_cm': m.adjustedCm,
        'recorded_by': authUid,
        'created_at': m.createdAt.toUtc().toIso8601String(),
        'updated_at': now,
        'device_id': deviceId,
      });
      await _client.from('screenings').upsert(<String, dynamic>{
        'measurement_id': m.id,
        'haz': double.parse(r.zScore.toStringAsFixed(3)),
        'status': r.status.code,
        'ref_version': r.refVersion,
        'app_version': '2.0.0',
        'updated_at': now,
        'device_id': deviceId,
      }, onConflict: 'measurement_id');
      sent += 2;
    }

    // Makanan: food_logs (grup child+date+meal) lalu food_log_items.
    final Map<String, List<FoodLogItem>> groups = <String, List<FoodLogItem>>{};
    for (final FoodLogItem item in foodItems) {
      final String key = '${item.childId}|${_date(item.logDate)}|${item.meal.name}';
      groups.putIfAbsent(key, () => <FoodLogItem>[]).add(item);
    }
    for (final MapEntry<String, List<FoodLogItem>> entry in groups.entries) {
      final List<String> parts = entry.key.split('|');
      final List<dynamic> logRows = await _client
          .from('food_logs')
          .upsert(<String, dynamic>{
            'child_id': parts[0],
            'log_date': parts[1],
            'meal': parts[2],
            'updated_at': now,
            'device_id': deviceId,
          }, onConflict: 'child_id,log_date,meal')
          .select('id');
      final String logId = (logRows.first as Map)['id'] as String;
      sent++;

      for (final FoodLogItem item in entry.value) {
        await _client.from('food_log_items').upsert(<String, dynamic>{
          'id': item.id,
          'food_log_id': logId,
          'tkpi_id': item.tkpiId,
          'food_name': item.foodName,
          'portion_label': item.portionLabel,
          'grams': item.grams,
          'source': item.source.name,
          'confidence': item.confidence,
          'nutrients_json': <String, dynamic>{
            for (final MapEntry<Nutrient, double> n in item.nutrients.entries)
              _nutrientKey[n.key]!: double.parse(n.value.toStringAsFixed(4)),
          },
          'created_at': item.createdAt.toUtc().toIso8601String(),
          'updated_at': now,
          'device_id': deviceId,
        });
        sent++;
      }
    }

    return sent;
  }

  Future<void> deleteFoodItem(String id) async {
    if (!isSignedIn) return;
    await _client.from('food_log_items').update(<String, dynamic>{
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  Future<void> softDeleteChild(String id) async {
    if (!isSignedIn) return;
    await _client.from('children').update(<String, dynamic>{
      'deleted_at': DateTime.now().toUtc().toIso8601String(),
    }).eq('id', id);
  }

  // ---- Unduh ---------------------------------------------------------------

  Future<CloudSnapshot> pull() async {
    if (!isSignedIn) {
      return const CloudSnapshot(
        children: <Child>[],
        screenings: <ScreeningRecord>[],
        sessions: <ScreeningSession>[],
        foodItems: <FoodLogItem>[],
      );
    }

    final List<dynamic> childRows = await _client.from('children').select();
    final List<dynamic> consentRows =
        await _client.from('guardian_consents').select();
    final List<dynamic> sessionRows =
        await _client.from('screening_sessions').select();
    final List<dynamic> measurementRows =
        await _client.from('measurements').select();
    final List<dynamic> screeningRows = await _client.from('screenings').select();
    final List<dynamic> foodLogRows = await _client.from('food_logs').select();
    final List<dynamic> foodItemRows =
        await _client.from('food_log_items').select();

    final Map<String, GuardianConsent> consentByChild =
        <String, GuardianConsent>{
      for (final dynamic row in consentRows)
        (row as Map<String, dynamic>)['child_id'] as String: GuardianConsent(
          method: ConsentMethod.fromCode(row['method'] as String?),
          consentedAt: DateTime.parse(row['consented_at'] as String),
          recordedBy: (row['recorded_by'] as String?) ?? '',
        ),
    };

    final List<Child> children = <Child>[];
    for (final dynamic row in childRows) {
      final Map<String, dynamic> m = row as Map<String, dynamic>;
      children.add(
        Child(
          id: m['id'] as String,
          createdBy: m['created_by'] as String,
          nickname: m['nickname'] as String,
          birthDate: DateTime.parse(m['birth_date'] as String),
          sex: Sex.fromDb(m['sex'] as String?),
          posyanduName: m['posyandu_name'] as String?,
          consent: consentByChild[m['id']],
          createdAt: DateTime.parse(m['created_at'] as String),
          updatedAt: DateTime.parse(m['updated_at'] as String),
          deletedAt: m['deleted_at'] == null
              ? null
              : DateTime.parse(m['deleted_at'] as String),
        ),
      );
    }

    final Map<String, Map<String, dynamic>> screeningByMeasurement =
        <String, Map<String, dynamic>>{
      for (final dynamic row in screeningRows)
        (row as Map<String, dynamic>)['measurement_id'] as String: row,
    };

    final List<ScreeningRecord> screenings = <ScreeningRecord>[];
    for (final dynamic row in measurementRows) {
      final Map<String, dynamic> m = row as Map<String, dynamic>;
      final Map<String, dynamic>? s = screeningByMeasurement[m['id']];
      if (s == null) continue;
      final int ageMonths = (m['age_months'] as num).toInt();
      final MeasureMethod method = MeasureMethod.fromCode(m['method'] as String?);
      final MeasureMethod recommended = MeasureMethod.recommendedFor(ageMonths);
      final GrowthResult result = GrowthResult(
        zScore: (s['haz'] as num).toDouble(),
        status: GrowthStatus.fromCode(s['status'] as String?),
        ageMonths: ageMonths,
        rawCm: (m['length_height_cm'] as num).toDouble(),
        correctedCm: (m['adjusted_cm'] as num).toDouble(),
        method: method,
        recommendedMethod: recommended,
        methodAdjusted: method != recommended,
        weightKg: (m['weight_kg'] as num).toDouble(),
        measuredOn: DateTime.parse(m['measured_on'] as String),
        refVersion: (s['ref_version'] as String?) ?? 'who-2006-hfa-daily',
        recommendation: null,
      );
      screenings.add(
        ScreeningRecord(
          measurement: Measurement(
            id: m['id'] as String,
            childId: m['child_id'] as String,
            sessionId: m['session_id'] as String?,
            measuredOn: DateTime.parse(m['measured_on'] as String),
            ageMonths: ageMonths,
            weightKg: (m['weight_kg'] as num).toDouble(),
            lengthHeightCm: (m['length_height_cm'] as num).toDouble(),
            method: method,
            adjustedCm: (m['adjusted_cm'] as num).toDouble(),
            recordedBy: (m['recorded_by'] as String?) ?? '',
            createdAt: DateTime.parse(m['created_at'] as String),
          ),
          result: result,
        ),
      );
    }

    final List<ScreeningSession> sessions = <ScreeningSession>[
      for (final dynamic row in sessionRows)
        ScreeningSession(
          id: (row as Map<String, dynamic>)['id'] as String,
          kaderId: row['kader_id'] as String,
          posyanduName: row['posyandu_name'] as String,
          heldOn: DateTime.parse(row['held_on'] as String),
          createdAt: DateTime.parse(row['created_at'] as String),
          closed: (row['closed'] as bool?) ?? false,
        ),
    ];

    final Map<String, Map<String, dynamic>> logById =
        <String, Map<String, dynamic>>{
      for (final dynamic row in foodLogRows)
        (row as Map<String, dynamic>)['id'] as String: row,
    };

    final List<FoodLogItem> foodItems = <FoodLogItem>[];
    for (final dynamic row in foodItemRows) {
      final Map<String, dynamic> m = row as Map<String, dynamic>;
      final Map<String, dynamic>? log = logById[m['food_log_id']];
      if (log == null) continue;
      final Map<String, dynamic> nutrients =
          (m['nutrients_json'] as Map<String, dynamic>?) ?? <String, dynamic>{};
      foodItems.add(
        FoodLogItem(
          id: m['id'] as String,
          childId: log['child_id'] as String,
          logDate: DateTime.parse(log['log_date'] as String),
          meal: MealType.fromCode(log['meal'] as String?),
          tkpiId: (m['tkpi_id'] as String?) ?? '',
          foodName: m['food_name'] as String,
          emoji: '🍽',
          group: 'Lainnya',
          portionLabel: (m['portion_label'] as String?) ?? '-',
          grams: (m['grams'] as num).toDouble(),
          source: FoodSource.fromCode(m['source'] as String?),
          confidence: (m['confidence'] as num?)?.toDouble(),
          nutrients: <Nutrient, double>{
            for (final MapEntry<String, dynamic> e in nutrients.entries)
              _nutrientFromKey(e.key): (e.value as num).toDouble(),
          },
          createdAt: DateTime.parse(m['created_at'] as String),
        ),
      );
    }

    return CloudSnapshot(
      children: children,
      screenings: screenings,
      sessions: sessions,
      foodItems: foodItems,
    );
  }

  static String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
