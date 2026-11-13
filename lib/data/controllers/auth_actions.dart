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
    commitState(
      currentState.copyWith(consentAccepted: true, consentVersion: '2026-11'),
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
    commitState(
      currentState.copyWith(
        accessGrants: currentState.accessGrants
            .map(
              (grant) =>
                  grant.id == id ? grant.copyWith(status: 'dicabut') : grant,
            )
            .toList(),
      ),
    );
  }
}
