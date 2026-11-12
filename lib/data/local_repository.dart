import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';
import 'app_repository.dart';

/// Penyimpanan lama berbasis satu string JSON di SharedPreferences.
///
/// Produksi memakai SqliteRepository. Kelas ini dipertahankan untuk
/// migrasi data lama dan pengujian yang tidak membutuhkan plugin database.
class LocalRepository implements AppRepository {
  LocalRepository(this._prefs);

  static const String storageKey = 'nuri_state_v1';
  final SharedPreferences _prefs;

  @override
  AppState? load() {
    final raw = _prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(AppState state) async {
    await _prefs.setString(storageKey, jsonEncode(state.toJson()));
  }

  @override
  Future<void> clear() async {
    await _prefs.remove(storageKey);
  }
}
