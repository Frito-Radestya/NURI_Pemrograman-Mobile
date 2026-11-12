import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models.dart';

/// Kontrak penyimpanan. Implementasi Firebase dapat menggantikan kelas lokal
/// tanpa mengubah UI maupun controller (PRD §9.3).
abstract class AppRepository {
  AppState? load();
  Future<void> save(AppState state);
  Future<void> clear();
}

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
