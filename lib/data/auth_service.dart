import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

/// Identitas pengguna yang sudah terautentikasi.
class AuthSession {
  const AuthSession({required this.uid, required this.email, this.displayName});

  final String uid;
  final String email;
  final String? displayName;
}

/// Kegagalan autentikasi dengan kode dari Firebase.
///
/// Controller memetakan [code] menjadi pesan berbahasa Indonesia agar UI tidak
/// bergantung langsung pada paket Firebase.
class AuthFailure implements Exception {
  const AuthFailure(this.code, [this.cause]);

  final String code;
  final Object? cause;

  @override
  String toString() => 'AuthFailure($code)';
}

/// Kontrak autentikasi. Implementasi palsu dapat dipakai di test tanpa
/// menghubungi Firebase.
abstract class AuthService {
  bool get isAvailable;

  Future<AuthSession> signIn({required String email, required String password});

  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<void> sendPasswordResetEmail(String email);

  Future<void> updateDisplayName(String name);
}

/// Implementasi Firebase Authentication email/password.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService([this._auth]);

  final FirebaseAuth? _auth;

  FirebaseAuth get _instance => _auth ?? FirebaseAuth.instance;

  @override
  bool get isAvailable {
    if (_auth != null) return true;
    try {
      return Firebase.apps.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<AuthSession> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _sessionFrom(credential.user, fallbackEmail: email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code, error);
    }
  }

  @override
  Future<AuthSession> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user;
      if (user == null) {
        throw const AuthFailure('unknown');
      }
      final cleanName = name.trim();
      if (cleanName.isNotEmpty) {
        try {
          await user.updateDisplayName(cleanName);
        } catch (_) {
          // Akun sudah dibuat; kegagalan nama tampilan tidak boleh membatalkan
          // pendaftaran.
        }
      }
      return AuthSession(
        uid: user.uid,
        email: (user.email ?? email).trim().toLowerCase(),
        displayName: cleanName.isEmpty ? user.displayName : cleanName,
      );
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code, error);
    }
  }

  @override
  Future<void> signOut() => _instance.signOut();

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code, error);
    }
  }

  @override
  Future<void> updateDisplayName(String name) async {
    final user = _instance.currentUser;
    if (user == null) return;
    try {
      await user.updateDisplayName(name);
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(error.code, error);
    }
  }

  AuthSession _sessionFrom(User? user, {required String fallbackEmail}) {
    if (user == null) {
      throw const AuthFailure('unknown');
    }
    return AuthSession(
      uid: user.uid,
      email: (user.email ?? fallbackEmail).trim().toLowerCase(),
      displayName: user.displayName,
    );
  }
}
