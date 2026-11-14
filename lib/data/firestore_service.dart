import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../domain/models.dart';

/// Kontrak backend database. Implementasi palsu dipakai di test agar pengujian
/// tidak bergantung pada koneksi internet atau emulator Firebase.
abstract class DatabaseService {
  bool get isAvailable;

  Future<bool> userExists(String userId);

  /// Menyalin dataset demo ke Firestore saat pengguna login pertama kali.
  Future<void> seedUserDataset({
    required AppUser user,
    required AppState seedData,
  });

  /// Mengambil dokumen pengguna dari Firestore sesuai ruang lingkup aksesnya
  /// dan menggabungkannya ke [currentState].
  Future<AppState?> pullUserDataset({
    required AppUser user,
    required AppState currentState,
  });

  /// Menyinkronkan perubahan parsial (tambah, ubah, hapus) ke Firestore.
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> syncChanges({
    required AppState previous,
    required AppState next,
    required AppUser user,
  });

  /// Menyinkronkan seluruh state lokal pengguna ke Firestore.
  /// Mengembalikan `true` jika berhasil, `false` jika gagal.
  Future<bool> syncAll({required AppState state, required AppUser user});

  /// Memasukkan seluruh dataset demo bawaan (semua akun dan entitas) ke Firestore.
  Future<void> seedAllDemoData({required AppState seedData});

  // Operasi CRUD satuan
  Future<void> saveUser(AppUser user);
  Future<void> saveChild(Child child);
  Future<void> deleteChild(String id);
  Future<void> savePregnancy(Pregnancy pregnancy);
  Future<void> deletePregnancy(String id);
  Future<void> saveFoodLog(FoodLog log);
  Future<void> deleteFoodLog(String id);
  Future<void> saveRosterEntry(RosterEntry entry);
  Future<void> deleteRosterEntry(String id);
  Future<void> saveSession(PosyanduSession session);
  Future<void> saveAccessGrant(AccessGrant grant);
  Future<void> saveLinkCode(LinkCode code);
  Future<LinkCode?> getLinkCode(String code);
}

/// Implementasi Cloud Firestore dengan offline persistence bawaan SDK.
class FirestoreService implements DatabaseService {
  FirestoreService([this._firestore]);

  final FirebaseFirestore? _firestore;

  FirebaseFirestore get _db => _firestore ?? FirebaseFirestore.instance;

  @override
  bool get isAvailable {
    if (_firestore != null) return true;
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> userExists(String userId) async {
    if (!isAvailable) return false;
    try {
      final doc = await _db.collection('users').doc(userId).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Firestore userExists gagal: $e');
      return false;
    }
  }

  @override
  Future<void> seedUserDataset({
    required AppUser user,
    required AppState seedData,
  }) async {
    if (!isAvailable) return;
    try {
      final batch = _db.batch();

      // 1. Simpan user
      batch.set(
        _db.collection('users').doc(user.id),
        user.toJson(),
        SetOptions(merge: true),
      );

      // 2. Data anak milik pengguna atau posyandu
      final myChildren = seedData.children.where((c) {
        if (user.role == UserRole.cadre) {
          return c.posyanduId == user.posyanduId;
        }
        return c.guardianUid == user.id ||
            (user.demo && c.guardianUid == 'u_ibu');
      });
      for (final child in myChildren) {
        batch.set(
          _db.collection('children').doc(child.id),
          child.toJson(),
          SetOptions(merge: true),
        );
      }

      // 3. Data kehamilan (untuk ibu)
      if (user.role == UserRole.mother) {
        final myPregnancies = seedData.pregnancies.where(
          (p) => p.ownerUid == user.id || (user.demo && p.ownerUid == 'u_ibu'),
        );
        for (final p in myPregnancies) {
          batch.set(
            _db.collection('pregnancies').doc(p.id),
            p.toJson(),
            SetOptions(merge: true),
          );
        }
      }

      // 4. Catatan makan milik subjek pengguna
      final subjectIds = {
        ...myChildren.map((c) => c.id),
        ...seedData.pregnancies
            .where((p) => p.ownerUid == user.id)
            .map((p) => p.id),
      };
      for (final log in seedData.foodLogs.where(
        (l) => subjectIds.contains(l.subjectId),
      )) {
        batch.set(
          _db.collection('food_logs').doc(log.id),
          log.toJson(),
          SetOptions(merge: true),
        );
      }

      // 5. Roster dan sesi (untuk kader)
      if (user.role == UserRole.cadre) {
        for (final roster in seedData.roster) {
          batch.set(
            _db.collection('roster').doc(roster.id),
            roster.toJson(),
            SetOptions(merge: true),
          );
        }
        for (final session in seedData.sessions) {
          batch.set(
            _db.collection('sessions').doc(session.id),
            session.toJson(),
            SetOptions(merge: true),
          );
        }
      }

      // 6. Grant akses pengguna
      for (final grant in seedData.accessGrants.where(
        (g) => g.ownerUid == user.id || g.granteeUid == user.id,
      )) {
        batch.set(
          _db.collection('access_grants').doc(grant.id),
          grant.toJson(),
          SetOptions(merge: true),
        );
      }

      // 7. Konten artikel edukasi
      for (final article in seedData.contents) {
        batch.set(
          _db.collection('contents').doc(article.id),
          article.toJson(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      debugPrint('Firestore dataset di-seed untuk user: ${user.email}');
    } catch (e) {
      debugPrint('Firestore seedUserDataset gagal: $e');
    }
  }

  @override
  Future<AppState?> pullUserDataset({
    required AppUser user,
    required AppState currentState,
  }) async {
    if (!isAvailable) return null;
    try {
      // 1. Baca grant akses sesuai ruang lingkup pengguna
      final grantsQuery = user.role == UserRole.mother
          ? _db
                .collection('access_grants')
                .where('ownerUid', isEqualTo: user.id)
          : _db
                .collection('access_grants')
                .where('posyanduId', isEqualTo: user.posyanduId);
      final grantsSnap = await grantsQuery.get();
      final remoteGrants = grantsSnap.docs
          .map((doc) => AccessGrant.fromJson(doc.data()))
          .toList();

      // 2. Baca anak berdasarkan ruang lingkup (guardianUid untuk Ibu, posyanduId untuk Kader)
      final childrenQuery = user.role == UserRole.mother
          ? _db.collection('children').where('guardianUid', isEqualTo: user.id)
          : _db
                .collection('children')
                .where('posyanduId', isEqualTo: user.posyanduId);
      final childrenSnap = await childrenQuery.get();
      final remoteChildren = childrenSnap.docs
          .map((doc) => Child.fromJson(doc.data()))
          .toList();

      // 3. Baca kehamilan milik ibu
      final remotePregnancies = <Pregnancy>[];
      if (user.role == UserRole.mother) {
        final pregSnap = await _db
            .collection('pregnancies')
            .where('ownerUid', isEqualTo: user.id)
            .get();
        remotePregnancies.addAll(
          pregSnap.docs.map((doc) => Pregnancy.fromJson(doc.data())),
        );
      }

      // 4. Baca catatan makan hanya untuk subjek yang berhak diakses
      final allowedSubjectIds = <String>{
        ...remoteChildren.map((c) => c.id),
        ...remotePregnancies.map((p) => p.id),
      };
      final remoteLogs = <FoodLog>[];
      if (allowedSubjectIds.isNotEmpty) {
        final batchIds = allowedSubjectIds.take(10).toList();
        final logsSnap = await _db
            .collection('food_logs')
            .where('subjectId', whereIn: batchIds)
            .get();
        remoteLogs.addAll(
          logsSnap.docs.map((doc) => FoodLog.fromJson(doc.data())),
        );
      }

      // 5. Baca roster dan sesi khusus ruang lingkup Posyandu kader
      final remoteRoster = <RosterEntry>[];
      final remoteSessions = <PosyanduSession>[];
      if (user.role == UserRole.cadre && user.posyanduId != null) {
        final rosterSnap = await _db
            .collection('roster')
            .where('posyanduId', isEqualTo: user.posyanduId)
            .get();
        remoteRoster.addAll(
          rosterSnap.docs.map((doc) => RosterEntry.fromJson(doc.data())),
        );

        final sessionSnap = await _db
            .collection('sessions')
            .where('createdByUid', isEqualTo: user.id)
            .get();
        remoteSessions.addAll(
          sessionSnap.docs.map((doc) => PosyanduSession.fromJson(doc.data())),
        );
      }

      // Gabungkan dengan entitas lokal yang tidak bertabrakan
      List<T> mergeById<T>(
        List<T> local,
        List<T> remote,
        String Function(T) idOf,
      ) {
        if (remote.isEmpty) return local;
        final map = {for (final item in local) idOf(item): item};
        for (final item in remote) {
          map[idOf(item)] = item;
        }
        return map.values.toList();
      }

      return currentState.copyWith(
        children: mergeById(currentState.children, remoteChildren, (c) => c.id),
        pregnancies: mergeById(
          currentState.pregnancies,
          remotePregnancies,
          (p) => p.id,
        ),
        foodLogs: mergeById(currentState.foodLogs, remoteLogs, (l) => l.id),
        roster: mergeById(currentState.roster, remoteRoster, (r) => r.id),
        sessions: mergeById(currentState.sessions, remoteSessions, (s) => s.id),
        accessGrants: mergeById(
          currentState.accessGrants,
          remoteGrants,
          (g) => g.id,
        ),
        lastSyncAt: DateTime.now(),
        pendingWrites: 0,
      );
    } catch (e) {
      debugPrint('Firestore pullUserDataset gagal: $e');
      return null;
    }
  }

  @override
  Future<bool> syncChanges({
    required AppState previous,
    required AppState next,
    required AppUser user,
  }) async {
    if (!isAvailable) return false;
    try {
      final batch = _db.batch();
      var hasOps = false;

      // 0. Users diff (termasuk persetujuan privasi & nama)
      final prevUsers = {for (final u in previous.users) u.id: u};
      final nextUsers = {for (final u in next.users) u.id: u};
      for (final entry in nextUsers.entries) {
        if (entry.key == user.id && prevUsers[entry.key] != entry.value) {
          batch.set(
            _db.collection('users').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }

      // 1. Children diff
      final prevChildren = {for (final c in previous.children) c.id: c};
      final nextChildren = {for (final c in next.children) c.id: c};
      for (final entry in nextChildren.entries) {
        if (prevChildren[entry.key] != entry.value) {
          batch.set(
            _db.collection('children').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }
      for (final removedId in prevChildren.keys) {
        if (!nextChildren.containsKey(removedId)) {
          batch.delete(_db.collection('children').doc(removedId));
          hasOps = true;
        }
      }

      // 2. Pregnancies diff
      final prevPreg = {for (final p in previous.pregnancies) p.id: p};
      final nextPreg = {for (final p in next.pregnancies) p.id: p};
      for (final entry in nextPreg.entries) {
        if (prevPreg[entry.key] != entry.value) {
          batch.set(
            _db.collection('pregnancies').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }
      for (final removedId in prevPreg.keys) {
        if (!nextPreg.containsKey(removedId)) {
          batch.delete(_db.collection('pregnancies').doc(removedId));
          hasOps = true;
        }
      }

      // 3. Food logs diff
      final prevLogs = {for (final l in previous.foodLogs) l.id: l};
      final nextLogs = {for (final l in next.foodLogs) l.id: l};
      for (final entry in nextLogs.entries) {
        if (prevLogs[entry.key] != entry.value) {
          batch.set(
            _db.collection('food_logs').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }
      for (final removedId in prevLogs.keys) {
        if (!nextLogs.containsKey(removedId)) {
          batch.delete(_db.collection('food_logs').doc(removedId));
          hasOps = true;
        }
      }

      // 4. Roster diff
      final prevRoster = {for (final r in previous.roster) r.id: r};
      final nextRoster = {for (final r in next.roster) r.id: r};
      for (final entry in nextRoster.entries) {
        if (prevRoster[entry.key] != entry.value) {
          batch.set(
            _db.collection('roster').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }
      for (final removedId in prevRoster.keys) {
        if (!nextRoster.containsKey(removedId)) {
          batch.delete(_db.collection('roster').doc(removedId));
          hasOps = true;
        }
      }

      // 5. Sessions diff
      final prevSessions = {for (final s in previous.sessions) s.id: s};
      final nextSessions = {for (final s in next.sessions) s.id: s};
      for (final entry in nextSessions.entries) {
        if (prevSessions[entry.key] != entry.value) {
          batch.set(
            _db.collection('sessions').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }

      // 6. Access grants diff (termasuk pencabutan akses)
      final prevGrants = {for (final g in previous.accessGrants) g.id: g};
      final nextGrants = {for (final g in next.accessGrants) g.id: g};
      for (final entry in nextGrants.entries) {
        if (prevGrants[entry.key] != entry.value) {
          batch.set(
            _db.collection('access_grants').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }

      // 7. Link codes diff (pembuatan & penukaran kode)
      final prevCodes = {for (final c in previous.linkCodes) c.code: c};
      final nextCodes = {for (final c in next.linkCodes) c.code: c};
      for (final entry in nextCodes.entries) {
        if (prevCodes[entry.key] != entry.value) {
          batch.set(
            _db.collection('link_codes').doc(entry.key),
            entry.value.toJson(),
            SetOptions(merge: true),
          );
          hasOps = true;
        }
      }

      if (hasOps) {
        await batch.commit();
      }
      return true;
    } catch (e) {
      debugPrint('Firestore syncChanges gagal: $e');
      return false;
    }
  }

  @override
  Future<bool> syncAll({required AppState state, required AppUser user}) async {
    if (!isAvailable) return false;
    try {
      final batch = _db.batch();

      batch.set(
        _db.collection('users').doc(user.id),
        user.toJson(),
        SetOptions(merge: true),
      );

      for (final child in state.myChildren) {
        batch.set(
          _db.collection('children').doc(child.id),
          child.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final p in state.pregnancies.where((p) => p.ownerUid == user.id)) {
        batch.set(
          _db.collection('pregnancies').doc(p.id),
          p.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final log in state.foodLogs) {
        batch.set(
          _db.collection('food_logs').doc(log.id),
          log.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final r in state.myRoster) {
        batch.set(
          _db.collection('roster').doc(r.id),
          r.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final s in state.sessions.where((s) => s.createdByUid == user.id)) {
        batch.set(
          _db.collection('sessions').doc(s.id),
          s.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final g in state.accessGrants.where(
        (g) => g.ownerUid == user.id || g.granteeUid == user.id,
      )) {
        batch.set(
          _db.collection('access_grants').doc(g.id),
          g.toJson(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
      debugPrint('Firestore syncAll berhasil');
      return true;
    } catch (e) {
      debugPrint('Firestore syncAll gagal: $e');
      return false;
    }
  }

  @override
  Future<void> seedAllDemoData({required AppState seedData}) async {
    if (!isAvailable) return;
    try {
      final batch = _db.batch();

      for (final user in seedData.users) {
        batch.set(
          _db.collection('users').doc(user.id),
          user.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final child in seedData.children) {
        batch.set(
          _db.collection('children').doc(child.id),
          child.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final p in seedData.pregnancies) {
        batch.set(
          _db.collection('pregnancies').doc(p.id),
          p.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final f in seedData.foodLogs) {
        batch.set(
          _db.collection('food_logs').doc(f.id),
          f.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final r in seedData.roster) {
        batch.set(
          _db.collection('roster').doc(r.id),
          r.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final s in seedData.sessions) {
        batch.set(
          _db.collection('sessions').doc(s.id),
          s.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final c in seedData.contents) {
        batch.set(
          _db.collection('contents').doc(c.id),
          c.toJson(),
          SetOptions(merge: true),
        );
      }
      for (final g in seedData.accessGrants) {
        batch.set(
          _db.collection('access_grants').doc(g.id),
          g.toJson(),
          SetOptions(merge: true),
        );
      }

      await batch.commit();
    } catch (e) {
      debugPrint('Firestore seedAllDemoData gagal: $e');
    }
  }

  // CRUD satuan
  @override
  Future<void> saveUser(AppUser user) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('users')
          .doc(user.id)
          .set(user.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveUser gagal: $e');
    }
  }

  @override
  Future<void> saveChild(Child child) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('children')
          .doc(child.id)
          .set(child.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveChild gagal: $e');
    }
  }

  @override
  Future<void> deleteChild(String id) async {
    if (!isAvailable) return;
    try {
      await _db.collection('children').doc(id).delete();
    } catch (e) {
      debugPrint('deleteChild gagal: $e');
    }
  }

  @override
  Future<void> savePregnancy(Pregnancy pregnancy) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('pregnancies')
          .doc(pregnancy.id)
          .set(pregnancy.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('savePregnancy gagal: $e');
    }
  }

  @override
  Future<void> deletePregnancy(String id) async {
    if (!isAvailable) return;
    try {
      await _db.collection('pregnancies').doc(id).delete();
    } catch (e) {
      debugPrint('deletePregnancy gagal: $e');
    }
  }

  @override
  Future<void> saveFoodLog(FoodLog log) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('food_logs')
          .doc(log.id)
          .set(log.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveFoodLog gagal: $e');
    }
  }

  @override
  Future<void> deleteFoodLog(String id) async {
    if (!isAvailable) return;
    try {
      await _db.collection('food_logs').doc(id).delete();
    } catch (e) {
      debugPrint('deleteFoodLog gagal: $e');
    }
  }

  @override
  Future<void> saveRosterEntry(RosterEntry entry) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('roster')
          .doc(entry.id)
          .set(entry.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveRosterEntry gagal: $e');
    }
  }

  @override
  Future<void> deleteRosterEntry(String id) async {
    if (!isAvailable) return;
    try {
      await _db.collection('roster').doc(id).delete();
    } catch (e) {
      debugPrint('deleteRosterEntry gagal: $e');
    }
  }

  @override
  Future<void> saveSession(PosyanduSession session) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('sessions')
          .doc(session.id)
          .set(session.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveSession gagal: $e');
    }
  }

  @override
  Future<void> saveAccessGrant(AccessGrant grant) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('access_grants')
          .doc(grant.id)
          .set(grant.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveAccessGrant gagal: $e');
    }
  }

  @override
  Future<void> saveLinkCode(LinkCode code) async {
    if (!isAvailable) return;
    try {
      await _db
          .collection('link_codes')
          .doc(code.code)
          .set(code.toJson(), SetOptions(merge: true));
    } catch (e) {
      debugPrint('saveLinkCode gagal: $e');
    }
  }

  @override
  Future<LinkCode?> getLinkCode(String code) async {
    if (!isAvailable) return null;
    try {
      final doc = await _db
          .collection('link_codes')
          .doc(code.trim().toUpperCase())
          .get();
      if (!doc.exists || doc.data() == null) return null;
      return LinkCode.fromJson(doc.data()!);
    } catch (e) {
      debugPrint('getLinkCode gagal: $e');
      return null;
    }
  }
}
