import '../app_controller.dart';
import '../../domain/models.dart';

/// Aksi akun, sesi, dan preferensi pengguna.
extension AuthActions on AppController {
  AppUser? _findUserByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in currentState.users) {
      if (user.email.toLowerCase() == normalized) return user;
    }
    return null;
  }

  AppUser? _findDemoUser(UserRole role) {
    for (final user in currentState.users) {
      if (user.demo && user.role == role) return user;
    }
    return null;
  }

  String? login(String email, String password) {
    final user = _findUserByEmail(email);
    if (user == null) {
      return 'Email belum terdaftar. Periksa kembali atau daftar akun baru.';
    }
    if (password.trim().length < 6) return 'Password minimal 6 karakter.';
    commitState(
      currentState.copyWith(currentUserId: user.id, landingSeen: true),
    );
    return null;
  }

  void loginDemo(UserRole role) {
    final user =
        _findDemoUser(role) ??
        (currentState.users.isEmpty ? null : currentState.users.first);
    if (user == null) return;
    commitState(
      currentState.copyWith(
        currentUserId: user.id,
        onboardingSeen: true,
        landingSeen: true,
      ),
    );
  }

  void loginAsUser(String userId) {
    commitState(
      currentState.copyWith(
        currentUserId: userId,
        onboardingSeen: true,
        landingSeen: true,
      ),
    );
  }

  void logout() {
    commitState(
      currentState.copyWith(
        currentUserId: null,
        selectedChildId: null,
        pregnancyContext: true,
      ),
    );
  }

  String? register({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) {
    if (name.trim().length < 2) return 'Nama minimal 2 karakter.';
    if (!email.contains('@') || !email.contains('.')) {
      return 'Format email belum benar.';
    }
    if (password.length < 6) return 'Password minimal 6 karakter.';
    if (_findUserByEmail(email) != null) {
      return 'Email sudah digunakan. Coba masuk atau gunakan email lain.';
    }
    final user = AppUser(
      id: 'u_${DateTime.now().microsecondsSinceEpoch}',
      name: name.trim(),
      email: email.trim().toLowerCase(),
      role: role,
      posyanduId: role == UserRole.cadre ? 'p_melati' : null,
      demo: false,
    );
    commitState(
      currentState.copyWith(
        users: [...currentState.users, user],
        currentUserId: user.id,
        onboardingSeen: false,
        consentAccepted: false,
        landingSeen: true,
      ),
    );
    return null;
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
    final updated = AppUser(
      id: user.id,
      name: name.trim(),
      email: user.email,
      role: user.role,
      posyanduId: user.posyanduId,
      avatarAsset: user.avatarAsset,
      demo: user.demo,
    );
    commitState(
      currentState.copyWith(
        users: currentState.users
            .map((u) => u.id == user.id ? updated : u)
            .toList(),
      ),
    );
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
