import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../domain/models.dart';
import '../app_controller.dart';
import '../auth_service.dart';

/// Aksi akun, sesi, dan preferensi pengguna.
extension AuthActions on AppController {
  AppUser? _findUserByEmail(String email) {
    final normalized = _normalizedEmail(email);
    for (final user in currentState.users) {
      if (user.email.toLowerCase() == normalized) return user;
    }
    return null;
  }

  AppUser? _findUserByAuthUid(String uid) {
    for (final user in currentState.users) {
      if (user.authUid == uid) return user;
    }
    return null;
  }

  AppUser? _findDemoUser(UserRole role) {
    for (final user in currentState.users) {
      if (user.demo && user.role == role) return user;
    }
    return null;
  }

  String _normalizedEmail(String email) => email.trim().toLowerCase();

  bool _isValidEmail(String email) =>
      email.contains('@') && email.contains('.') && !email.contains(' ');

  List<AppUser> _upsertUser(AppUser user) {
    final index = currentState.users.indexWhere((item) => item.id == user.id);
    if (index == -1) return [...currentState.users, user];
    final users = [...currentState.users];
    users[index] = user;
    return users;
  }

  Future<String?> login(
    String email,
    String password, {
    UserRole role = UserRole.mother,
  }) async {
    final normalized = _normalizedEmail(email);
    if (!_isValidEmail(normalized)) return 'Format email belum benar.';
    if (password.trim().length < 6) return 'Password minimal 6 karakter.';

    final localUser = _findUserByEmail(normalized);

    // Web preview dan kondisi Firebase belum siap tetap memakai akun lokal.
    if (!authService.isAvailable) {
      return _loginLocal(localUser);
    }

    try {
      final session = await authService.signIn(
        email: normalized,
        password: password,
      );
      final existing = localUser ?? _findUserByAuthUid(session.uid);
      return _applyFirebaseSession(session, role: role, existing: existing);
    } on AuthFailure catch (failure) {
      // Demo tetap bisa dipakai saat akun demo belum dibuat di Firebase,
      // provider email/password belum aktif, atau perangkat sedang offline.
      // Jangan fallback untuk password salah agar autentikasi Firebase tetap
      // menjadi sumber kebenaran.
      if (localUser?.demo == true && _canUseDemoFallback(failure.code)) {
        debugPrint('Firebase Auth fallback demo: ${failure.code}');
        return _loginLocal(localUser);
      }
      return _messageFor(failure);
    } catch (error) {
      debugPrint('Login Firebase gagal: $error');
      if (localUser?.demo == true) return _loginLocal(localUser);
      return 'Gagal masuk. Periksa koneksi lalu coba lagi.';
    }
  }

  Future<String?> loginWithGoogle({UserRole role = UserRole.mother}) async {
    if (!authService.isAvailable) {
      return 'Masuk dengan Google memerlukan koneksi Firebase.';
    }
    try {
      final session = await authService.signInWithGoogle();
      if (session == null) return null; // Dibatalkan oleh pengguna
      final existing =
          _findUserByEmail(session.email) ?? _findUserByAuthUid(session.uid);
      return _applyFirebaseSession(session, role: role, existing: existing);
    } on AuthFailure catch (failure) {
      if (failure.code == 'account-exists-with-different-credential') {
        return 'Email ini sudah terdaftar dengan metode masuk lain.';
      }
      return _messageFor(failure);
    } catch (error) {
      debugPrint('Google Sign-In gagal: $error');
      return 'Gagal masuk dengan Google. Pastikan akun Google dipilih dan coba lagi.';
    }
  }

  String? _loginLocal(AppUser? user) {
    if (user == null) {
      return 'Email belum terdaftar. Periksa kembali atau daftar akun baru.';
    }
    commitState(
      currentState.copyWith(currentUserId: user.id, landingSeen: true),
    );
    return null;
  }

  bool _canUseDemoFallback(String code) =>
      code == 'user-not-found' ||
      code == 'network-request-failed' ||
      code == 'operation-not-allowed';

  String? _applyFirebaseSession(
    AuthSession session, {
    required UserRole role,
    AppUser? existing,
  }) {
    final email = _normalizedEmail(session.email);
    final displayName = session.displayName?.trim();
    final isNewUser = existing == null;
    final user = isNewUser
        ? AppUser(
            id: session.uid,
            name: displayName?.isNotEmpty == true
                ? displayName!
                : _nameFromEmail(email),
            email: email,
            role: role,
            posyanduId: role == UserRole.cadre ? 'p_${session.uid}' : null,
            authUid: session.uid,
            demo: false,
          )
        : AppUser(
            id: existing.id,
            name: existing.name,
            email: email,
            role: existing.role,
            posyanduId: existing.posyanduId,
            avatarAsset: existing.avatarAsset,
            demo: existing.demo,
            authUid: session.uid,
          );

    commitState(
      currentState.copyWith(
        users: _upsertUser(user),
        currentUserId: user.id,
        landingSeen: true,
        onboardingSeen: isNewUser ? false : currentState.onboardingSeen,
        consentAccepted: isNewUser
            ? (role == UserRole.cadre)
            : currentState.consentAccepted,
        roster: isNewUser && role == UserRole.cadre
            ? const []
            : currentState.roster,
        sessions: isNewUser && role == UserRole.cadre
            ? const []
            : currentState.sessions,
        posyanduName: isNewUser && role == UserRole.cadre
            ? ''
            : currentState.posyanduName,
        posyanduArea: isNewUser && role == UserRole.cadre
            ? ''
            : currentState.posyanduArea,
      ),
    );
    if (databaseService.isAvailable) {
      unawaited(_hydrateOrSeedFirestore(user));
    }
    return null;
  }

  Future<void> _hydrateOrSeedFirestore(AppUser user) async {
    if (!databaseService.isAvailable) return;
    try {
      final exists = await databaseService.userExists(user.id);
      if (!exists) {
        if (user.demo) {
          await databaseService.seedUserDataset(
            user: user,
            seedData: currentState,
          );
        } else {
          await databaseService.saveUser(user);
        }
      } else {
        final remote = await databaseService.pullUserDataset(
          user: user,
          currentState: currentState,
        );
        if (remote != null) {
          commitState(remote);
        }
      }
    } catch (e) {
      debugPrint('Firestore hydrate/seed gagal: $e');
    }
  }

  String _nameFromEmail(String email) {
    final localPart = email
        .split('@')
        .first
        .replaceAll(RegExp(r'[._-]+'), ' ')
        .trim();
    if (localPart.isEmpty) return 'Pengguna NURI';
    return localPart
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .map((part) => '${part[0].toUpperCase()}${part.substring(1)}')
        .join(' ');
  }

  void loginDemo(UserRole role) {
    final user =
        _findDemoUser(role) ??
        (currentState.users.isEmpty ? null : currentState.users.first);
    if (user == null) return;
    unawaited(signOutAuthQuietly());
    commitState(
      currentState.copyWith(
        currentUserId: user.id,
        onboardingSeen: true,
        landingSeen: true,
      ),
    );
    if (databaseService.isAvailable) {
      unawaited(_hydrateOrSeedFirestore(user));
    }
  }

  void loginAsUser(String userId) {
    // Pengalih akun adalah fitur demo lokal. Akhiri sesi Firebase agar tidak
    // ada sesi Firebase yang tertinggal saat beralih ke akun demo.
    unawaited(signOutAuthQuietly());
    commitState(
      currentState.copyWith(
        currentUserId: userId,
        onboardingSeen: true,
        landingSeen: true,
      ),
    );
    AppUser? user;
    for (final u in currentState.users) {
      if (u.id == userId) {
        user = u;
        break;
      }
    }
    if (user != null && databaseService.isAvailable) {
      unawaited(_hydrateOrSeedFirestore(user));
    }
  }

  void logout() {
    commitState(
      currentState.copyWith(
        currentUserId: null,
        selectedChildId: null,
        pregnancyContext: true,
      ),
    );
    unawaited(signOutAuthQuietly());
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    final normalized = _normalizedEmail(email);
    if (name.trim().length < 2) return 'Nama minimal 2 karakter.';
    if (!_isValidEmail(normalized)) return 'Format email belum benar.';
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (_findUserByEmail(normalized) != null) {
      return 'Email sudah digunakan. Coba masuk atau gunakan email lain.';
    }

    if (!authService.isAvailable) {
      // Web preview tidak memiliki konfigurasi Firebase; tetap izinkan akun
      // lokal agar preview tidak buntu. Android meminta Firebase yang siap.
      if (kIsWeb) {
        return _registerLocal(name: name, email: normalized, role: role);
      }
      return 'Pendaftaran memerlukan koneksi ke Firebase. Periksa koneksi lalu coba lagi.';
    }

    try {
      final session = await authService.register(
        name: name,
        email: normalized,
        password: password,
      );
      final user = AppUser(
        id: session.uid,
        name: name.trim(),
        email: normalized,
        role: role,
        posyanduId: role == UserRole.cadre ? 'p_${session.uid}' : null,
        authUid: session.uid,
        demo: false,
      );
      commitState(
        currentState.copyWith(
          users: _upsertUser(user),
          currentUserId: user.id,
          onboardingSeen: false,
          consentAccepted: role == UserRole.cadre,
          landingSeen: true,
          roster: role == UserRole.cadre ? const [] : currentState.roster,
          sessions: role == UserRole.cadre ? const [] : currentState.sessions,
          posyanduName: role == UserRole.cadre ? '' : currentState.posyanduName,
          posyanduArea: role == UserRole.cadre ? '' : currentState.posyanduArea,
        ),
      );
      if (databaseService.isAvailable) {
        unawaited(_hydrateOrSeedFirestore(user));
      }
      return null;
    } on AuthFailure catch (failure) {
      if (failure.code == 'network-request-failed') {
        return 'Tidak ada koneksi internet. Pendaftaran memerlukan koneksi ke Firebase.';
      }
      return _messageFor(failure);
    } catch (error) {
      debugPrint('Registrasi Firebase gagal: $error');
      return 'Pendaftaran gagal. Periksa koneksi lalu coba lagi.';
    }
  }

  String? _registerLocal({
    required String name,
    required String email,
    required UserRole role,
  }) {
    final uid = 'u_${DateTime.now().microsecondsSinceEpoch}';
    final user = AppUser(
      id: uid,
      name: name.trim(),
      email: email,
      role: role,
      posyanduId: role == UserRole.cadre ? 'p_$uid' : null,
      demo: false,
    );
    commitState(
      currentState.copyWith(
        users: [...currentState.users, user],
        currentUserId: user.id,
        onboardingSeen: false,
        consentAccepted: role == UserRole.cadre,
        landingSeen: true,
        roster: role == UserRole.cadre ? const [] : currentState.roster,
        sessions: role == UserRole.cadre ? const [] : currentState.sessions,
        posyanduName: role == UserRole.cadre ? '' : currentState.posyanduName,
        posyanduArea: role == UserRole.cadre ? '' : currentState.posyanduArea,
      ),
    );
    return null;
  }

  Future<String?> resetPassword(String email) async {
    final normalized = _normalizedEmail(email);
    if (!_isValidEmail(normalized)) return 'Format email belum benar.';
    if (!authService.isAvailable) {
      return 'Reset password memerlukan koneksi ke Firebase.';
    }
    try {
      await authService.sendPasswordResetEmail(normalized);
      return null;
    } on AuthFailure catch (failure) {
      if (failure.code == 'user-not-found') {
        return 'Email belum terdaftar di Firebase.';
      }
      if (failure.code == 'network-request-failed') {
        return 'Tidak ada koneksi internet. Coba lagi.';
      }
      return _messageFor(failure);
    } catch (error) {
      debugPrint('Reset password gagal: $error');
      return 'Gagal mengirim tautan reset. Periksa koneksi lalu coba lagi.';
    }
  }

  String _messageFor(AuthFailure failure) {
    switch (failure.code) {
      case 'invalid-email':
        return 'Format email belum benar.';
      case 'user-disabled':
        return 'Akun ini dinonaktifkan. Hubungi admin.';
      case 'user-not-found':
        return 'Email belum terdaftar. Periksa kembali atau daftar akun baru.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'email-already-in-use':
        return 'Email sudah digunakan. Coba masuk atau gunakan email lain.';
      case 'weak-password':
        return 'Password minimal 6 karakter.';
      case 'operation-not-allowed':
        return 'Email/password belum diaktifkan di Firebase Console.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Coba lagi beberapa saat.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Untuk mode demo, gunakan tombol Demo Ibu/Kader.';
      default:
        return 'Terjadi kendala autentikasi. Coba lagi.';
    }
  }

  void acceptConsent() {
    final user = currentState.currentUser;
    final now = DateTime.now();
    final updatedUsers = user == null
        ? currentState.users
        : currentState.users
              .map(
                (u) => u.id == user.id
                    ? AppUser(
                        id: u.id,
                        name: u.name,
                        email: u.email,
                        role: u.role,
                        posyanduId: u.posyanduId,
                        avatarAsset: u.avatarAsset,
                        demo: u.demo,
                        authUid: u.authUid,
                        consentVersion: '2026-11',
                        consentAcceptedAt: now,
                      )
                    : u,
              )
              .toList();
    commitState(
      currentState.copyWith(
        users: updatedUsers,
        consentAccepted: true,
        consentVersion: '2026-11',
      ),
    );
  }

  void completeOnboarding() {
    commitState(currentState.copyWith(onboardingSeen: true));
  }

  void setLandingSeen() {
    commitState(currentState.copyWith(landingSeen: true));
  }

  void selectContext({required bool pregnancy}) {
    commitState(currentState.copyWith(pregnancyContext: pregnancy));
  }

  void selectChild(String childId) {
    commitState(currentState.copyWith(selectedChildId: childId));
  }

  void toggleReminders() {
    commitState(
      currentState.copyWith(remindersEnabled: !currentState.remindersEnabled),
    );
  }

  void updateProfile({required String name}) {
    final user = currentState.currentUser;
    if (user == null) return;
    final cleanName = name.trim();
    if (cleanName.isEmpty) return;
    final updated = AppUser(
      id: user.id,
      name: cleanName,
      email: user.email,
      role: user.role,
      posyanduId: user.posyanduId,
      avatarAsset: user.avatarAsset,
      demo: user.demo,
      authUid: user.authUid,
    );
    commitState(
      currentState.copyWith(
        users: currentState.users
            .map((u) => u.id == user.id ? updated : u)
            .toList(),
      ),
    );
    if (user.authUid != null) {
      unawaited(_updateFirebaseName(cleanName));
    }
  }

  Future<void> _updateFirebaseName(String name) async {
    if (!authService.isAvailable) return;
    try {
      await authService.updateDisplayName(name);
    } catch (error) {
      debugPrint('Update nama Firebase gagal: $error');
    }
  }

  void setPosyandu({required String name, String? area}) {
    commitState(
      currentState.copyWith(
        posyanduName: name.trim().isEmpty
            ? currentState.posyanduName
            : name.trim(),
        posyanduArea: area?.trim().isNotEmpty == true
            ? area!.trim()
            : currentState.posyanduArea,
      ),
    );
  }

  void revokeGrant(String id) {
    final now = DateTime.now();
    commitState(
      currentState.copyWith(
        accessGrants: currentState.accessGrants
            .map(
              (grant) => grant.id == id
                  ? grant.copyWith(status: 'dicabut', revokedAt: now)
                  : grant,
            )
            .toList(),
      ),
    );
  }

  /// Flow A (Ibu → Kader): Membuat kode keluarga acak sekali pakai yang berlaku
  /// selama 24 jam untuk anak/kehamilan yang dipilih beserta cakupan izin.
  LinkCode? createFamilyLinkCode({
    required String subjectId,
    required String subjectName,
    List<String> scopes = const ['ukur'],
  }) {
    final user = currentState.currentUser;
    if (user == null || user.role != UserRole.mother) return null;
    final now = DateTime.now();
    final linkCode = LinkCode(
      code: LinkCode.generateSecureCode(prefix: 'NR'),
      type: 'keluarga',
      issuerUid: user.id,
      issuerName: user.name,
      subjectId: subjectId,
      subjectName: subjectName,
      scopes: scopes.isEmpty ? const ['ukur'] : scopes,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 24)),
    );
    commitState(
      currentState.copyWith(linkCodes: [...currentState.linkCodes, linkCode]),
    );
    if (databaseService.isAvailable) {
      unawaited(databaseService.saveLinkCode(linkCode));
    }
    return linkCode;
  }

  /// Flow B (Kader → Ibu): Membuat kode klaim sekali pakai (berlaku 7 hari)
  /// untuk anak yang sudah dicatat kader tetapi belum terhubung ke akun ibu.
  LinkCode? createChildClaimCode({
    required String childId,
    required String childName,
  }) {
    final user = currentState.currentUser;
    if (user == null || user.role != UserRole.cadre) return null;
    final now = DateTime.now();
    final linkCode = LinkCode(
      code: LinkCode.generateSecureCode(prefix: 'KL'),
      type: 'klaim',
      issuerUid: user.id,
      issuerName: user.name,
      subjectId: childId,
      subjectName: childName,
      posyanduId: user.posyanduId,
      scopes: const ['ukur'],
      createdAt: now,
      expiresAt: now.add(const Duration(days: 7)),
    );
    commitState(
      currentState.copyWith(linkCodes: [...currentState.linkCodes, linkCode]),
    );
    if (databaseService.isAvailable) {
      unawaited(databaseService.saveLinkCode(linkCode));
    }
    return linkCode;
  }

  /// Flow A (Kader menukar kode keluarga Ibu):
  /// Memverifikasi token sekali pakai, masa berlaku, membuat [AccessGrant] aktif,
  /// dan menghubungkan anak ke roster Posyandu kader.
  Future<(AccessGrant?, Child?, String?)> redeemFamilyLinkCode(
    String rawCode,
  ) async {
    final cadre = currentState.currentUser;
    if (cadre == null || cadre.role != UserRole.cadre) {
      return (
        null,
        null,
        'Hanya akun Kader Posyandu yang dapat memindai kode keluarga.',
      );
    }
    final cleanCode = rawCode.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return (null, null, 'Masukkan kode keluarga terlebih dahulu.');
    }

    LinkCode? found;
    for (final c in currentState.linkCodes) {
      if (c.code.toUpperCase() == cleanCode) {
        found = c;
        break;
      }
    }
    if (found == null && databaseService.isAvailable) {
      found = await databaseService.getLinkCode(cleanCode);
    }
    if (found == null) {
      return (
        null,
        null,
        'Kode keluarga tidak ditemukan. Pastikan kode benar.',
      );
    }
    if (found.type != 'keluarga') {
      return (
        null,
        null,
        'Kode ini adalah kode klaim ibu, bukan kode keluarga untuk kader.',
      );
    }
    if (found.isUsed) {
      return (
        null,
        null,
        'Kode ini sudah pernah digunakan dan tidak berlaku lagi.',
      );
    }
    if (found.isExpired) {
      return (
        null,
        null,
        'Kode sudah kedaluwarsa (melebihi 24 jam). Minta Ibu membuat kode baru.',
      );
    }

    final codeRecord = found;
    final now = DateTime.now();
    final usedCode = codeRecord.copyWith(usedAt: now, usedByUid: cadre.id);

    final grant = AccessGrant(
      id: 'g_${codeRecord.subjectId}_${cadre.id}_${now.millisecondsSinceEpoch}',
      ownerUid: codeRecord.issuerUid,
      granteeUid: cadre.id,
      granteeName: '${cadre.name} • ${currentState.posyanduName}',
      subjectId: codeRecord.subjectId,
      subjectName: codeRecord.subjectName,
      posyanduId: cadre.posyanduId,
      scopes: codeRecord.scopes,
      createdAt: now,
      expiresAt: now.add(const Duration(days: 365)),
      status: 'aktif',
    );

    Child? linkedChild;
    final updatedChildren = currentState.children.map((c) {
      if (c.id == codeRecord.subjectId) {
        linkedChild = c.copyWith(
          posyanduId: cadre.posyanduId ?? c.posyanduId,
          linked: true,
        );
        return linkedChild!;
      }
      return c;
    }).toList();

    final hasRoster = currentState.roster.any(
      (r) => r.subjectId == codeRecord.subjectId,
    );
    final updatedRoster = hasRoster
        ? currentState.roster.map((r) {
            if (r.subjectId == codeRecord.subjectId) {
              return r.copyWith(posyanduId: cadre.posyanduId);
            }
            return r;
          }).toList()
        : [
            ...currentState.roster,
            RosterEntry(
              id: 'r_${codeRecord.subjectId}',
              name: codeRecord.subjectName,
              type: RosterType.child,
              attendance: AttendanceStatus.waiting,
              avatarIndex: currentState.roster.length % 8,
              posyanduId: cadre.posyanduId,
              subjectId: codeRecord.subjectId,
              guardianName: codeRecord.issuerName,
              ageMonths: linkedChild?.ageMonthsAt(now),
              sex: linkedChild?.sex,
              category: linkedChild?.latestMeasurement?.category,
              linked: true,
            ),
          ];

    final updatedCodes = [
      ...currentState.linkCodes.where((c) => c.code.toUpperCase() != cleanCode),
      usedCode,
    ];

    commitState(
      currentState.copyWith(
        children: updatedChildren,
        roster: updatedRoster,
        accessGrants: [
          ...currentState.accessGrants.where(
            (g) =>
                !(g.subjectId == grant.subjectId && g.granteeUid == cadre.id),
          ),
          grant,
        ],
        linkCodes: updatedCodes,
      ),
    );
    return (grant, linkedChild, null);
  }

  /// Flow B (Ibu menukar kode klaim dari Kader):
  /// Memindahkan kepemilikan profil anak yang dibuat kader ke akun Ibu, beserta
  /// seluruh riwayat pengukurannya.
  Future<(Child?, String?)> redeemChildClaimCode(String rawCode) async {
    final mother = currentState.currentUser;
    if (mother == null || mother.role != UserRole.mother) {
      return (
        null,
        'Hanya akun Ibu / Keluarga yang dapat mengklaim profil anak.',
      );
    }
    final cleanCode = rawCode.trim().toUpperCase();
    if (cleanCode.isEmpty) {
      return (null, 'Masukkan kode klaim terlebih dahulu.');
    }

    LinkCode? found;
    for (final c in currentState.linkCodes) {
      if (c.code.toUpperCase() == cleanCode) {
        found = c;
        break;
      }
    }
    if (found == null && databaseService.isAvailable) {
      found = await databaseService.getLinkCode(cleanCode);
    }
    if (found == null) {
      return (
        null,
        'Kode klaim tidak ditemukan. Periksa kembali kode dari kader.',
      );
    }
    if (found.type != 'klaim') {
      return (null, 'Kode ini bukan kode klaim anak Posyandu.');
    }
    if (found.isUsed) {
      return (null, 'Kode klaim ini sudah pernah digunakan.');
    }
    if (found.isExpired) {
      return (null, 'Kode klaim sudah kedaluwarsa (melebihi 7 hari).');
    }

    final codeRecord = found;
    final now = DateTime.now();
    final usedCode = codeRecord.copyWith(usedAt: now, usedByUid: mother.id);

    Child? claimedChild;
    final updatedChildren = currentState.children.map((c) {
      if (c.id == codeRecord.subjectId) {
        claimedChild = c.copyWith(
          guardianUid: mother.id,
          guardianName: mother.name,
          linked: true,
        );
        return claimedChild!;
      }
      return c;
    }).toList();

    if (claimedChild == null) {
      return (null, 'Data anak untuk kode klaim ini tidak ditemukan.');
    }

    final grant = AccessGrant(
      id: 'g_${claimedChild!.id}_${codeRecord.issuerUid}',
      ownerUid: mother.id,
      granteeUid: codeRecord.issuerUid,
      granteeName: codeRecord.issuerName,
      subjectId: claimedChild!.id,
      subjectName: claimedChild!.nickname,
      posyanduId: codeRecord.posyanduId ?? claimedChild!.posyanduId,
      scopes: const ['ukur'],
      createdAt: now,
      expiresAt: now.add(const Duration(days: 365)),
      status: 'aktif',
    );

    final updatedCodes = [
      ...currentState.linkCodes.where((c) => c.code.toUpperCase() != cleanCode),
      usedCode,
    ];

    commitState(
      currentState.copyWith(
        children: updatedChildren,
        selectedChildId: claimedChild!.id,
        accessGrants: [...currentState.accessGrants, grant],
        linkCodes: updatedCodes,
      ),
    );
    return (claimedChild, null);
  }
}
