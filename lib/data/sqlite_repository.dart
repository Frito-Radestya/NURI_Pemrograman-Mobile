import 'dart:async';
import 'dart:convert';

import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';

import '../domain/models.dart';
import 'app_repository.dart';
import 'local_repository.dart';

/// Penyimpanan lokal berbasis SQLite.
///
/// Data yang sering bertambah (anak, kehamilan, catatan makan, sasaran, sesi)
/// disimpan sebagai baris terpisah agar tidak ada satu string JSON raksasa.
/// Pengaturan akun dan preferensi tetap berupa key-value kecil di tabel `meta`.
class SqliteRepository implements AppRepository {
  SqliteRepository._(this._db);

  static const String databaseName = 'nuri.db';
  static const int schemaVersion = 1;

  static const List<String> _collectionTables = [
    'users',
    'pregnancies',
    'children',
    'food_logs',
    'roster',
    'sessions',
    'contents',
    'access_grants',
  ];

  static const List<String> _metaKeys = [
    'currentUserId',
    'selectedChildId',
    'onboardingSeen',
    'consentAccepted',
    'consentVersion',
    'pregnancyContext',
    'pendingWrites',
    'lastSyncAt',
    'posyanduName',
    'posyanduArea',
    'nextPosyanduDate',
    'landingSeen',
    'readArticles',
    'mealPlan',
    'remindersEnabled',
  ];

  final Database _db;
  AppState? _cachedState;
  Future<void> _writeQueue = Future<void>.value();

  static Future<SqliteRepository> open({SharedPreferences? legacyPrefs}) async {
    final path = p.join(await getDatabasesPath(), databaseName);
    final db = await openDatabase(
      path,
      version: schemaVersion,
      onCreate: _createSchema,
    );
    final repository = SqliteRepository._(db);
    var state = await repository._readState();

    // Migrasi sekali jalan dari penyimpanan SharedPreferences lama.
    if (state == null && legacyPrefs != null) {
      final raw = legacyPrefs.getString(LocalRepository.storageKey);
      if (raw != null && raw.isNotEmpty) {
        try {
          state = AppState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
          await repository.save(state);
          await legacyPrefs.remove(LocalRepository.storageKey);
        } catch (_) {
          // Data lama rusak: biarkan aplikasi memakai seed demo.
        }
      }
    }

    repository._cachedState = state;
    return repository;
  }

  static Future<void> _createSchema(Database db, int version) async {
    for (final table in _collectionTables) {
      await db.execute(
        'CREATE TABLE $table (id TEXT PRIMARY KEY, payload TEXT NOT NULL)',
      );
    }
    await db.execute(
      'CREATE TABLE meta (key TEXT PRIMARY KEY, value TEXT NOT NULL)',
    );
  }

  @override
  AppState? load() => _cachedState;

  @override
  Future<void> save(AppState state) => _enqueue(() async {
    final previous = _cachedState;
    await _db.transaction((txn) async {
      await _syncTable(
        txn,
        'users',
        state.users,
        previous?.users,
        (user) => user.toJson(),
        (user) => user.id,
      );
      await _syncTable(
        txn,
        'pregnancies',
        state.pregnancies,
        previous?.pregnancies,
        (pregnancy) => pregnancy.toJson(),
        (pregnancy) => pregnancy.id,
      );
      await _syncTable(
        txn,
        'children',
        state.children,
        previous?.children,
        (child) => child.toJson(),
        (child) => child.id,
      );
      await _syncTable(
        txn,
        'food_logs',
        state.foodLogs,
        previous?.foodLogs,
        (log) => log.toJson(),
        (log) => log.id,
      );
      await _syncTable(
        txn,
        'roster',
        state.roster,
        previous?.roster,
        (entry) => entry.toJson(),
        (entry) => entry.id,
      );
      await _syncTable(
        txn,
        'sessions',
        state.sessions,
        previous?.sessions,
        (session) => session.toJson(),
        (session) => session.id,
      );
      await _syncTable(
        txn,
        'contents',
        state.contents,
        previous?.contents,
        (article) => article.toJson(),
        (article) => article.id,
      );
      await _syncTable(
        txn,
        'access_grants',
        state.accessGrants,
        previous?.accessGrants,
        (grant) => grant.toJson(),
        (grant) => grant.id,
      );

      final meta = _metaValues(state);
      for (final key in _metaKeys) {
        await txn.insert('meta', {
          'key': key,
          'value': jsonEncode(meta[key]),
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    });
    _cachedState = state;
  });

  @override
  Future<void> clear() => _enqueue(() async {
    await _db.transaction((txn) async {
      for (final table in _collectionTables) {
        await txn.delete(table);
      }
      await txn.delete('meta');
    });
    _cachedState = null;
  });

  Map<String, Object?> _metaValues(AppState state) => {
    'currentUserId': state.currentUserId,
    'selectedChildId': state.selectedChildId,
    'onboardingSeen': state.onboardingSeen,
    'consentAccepted': state.consentAccepted,
    'consentVersion': state.consentVersion,
    'pregnancyContext': state.pregnancyContext,
    'pendingWrites': state.pendingWrites,
    'lastSyncAt': state.lastSyncAt?.toIso8601String(),
    'posyanduName': state.posyanduName,
    'posyanduArea': state.posyanduArea,
    'nextPosyanduDate': state.nextPosyanduDate == null
        ? null
        : dateToIso(state.nextPosyanduDate!),
    'landingSeen': state.landingSeen,
    'readArticles': state.readArticles.toList(),
    'mealPlan': state.mealPlan,
    'remindersEnabled': state.remindersEnabled,
  };

  Future<void> _syncTable<T>(
    Transaction txn,
    String table,
    List<T> current,
    List<T>? previous,
    Map<String, dynamic> Function(T item) toJson,
    String Function(T item) idOf,
  ) async {
    final currentById = <String, T>{
      for (final item in current) idOf(item): item,
    };
    final previousById = <String, T>{
      for (final item in previous ?? const []) idOf(item): item,
    };

    for (final entry in currentById.entries) {
      final old = previousById[entry.key];
      final payload = jsonEncode(toJson(entry.value));
      if (old == null || jsonEncode(toJson(old)) != payload) {
        await txn.insert(table, {
          'id': entry.key,
          'payload': payload,
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }
    }

    for (final id in previousById.keys) {
      if (!currentById.containsKey(id)) {
        await txn.delete(table, where: 'id = ?', whereArgs: [id]);
      }
    }
  }

  Future<AppState?> _readState() async {
    final metaRows = await _db.query('meta');
    if (metaRows.isEmpty) return null;
    final meta = <String, String>{
      for (final row in metaRows) row['key'] as String: row['value'] as String,
    };
    return AppState.fromJson({
      'users': await _readList('users'),
      'pregnancies': await _readList('pregnancies'),
      'children': await _readList('children'),
      'foodLogs': await _readList('food_logs'),
      'roster': await _readList('roster'),
      'sessions': await _readList('sessions'),
      'contents': await _readList('contents'),
      'accessGrants': await _readList('access_grants'),
      for (final key in _metaKeys) key: _decode(meta[key]),
    });
  }

  Future<List<Map<String, dynamic>>> _readList(String table) async {
    final rows = await _db.query(table);
    return rows
        .map(
          (row) => jsonDecode(row['payload'] as String) as Map<String, dynamic>,
        )
        .toList();
  }

  Object? _decode(String? raw) {
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> _enqueue(Future<void> Function() action) {
    final task = _writeQueue.then((_) => action());
    _writeQueue = task.catchError((Object _) {});
    return task;
  }
}
