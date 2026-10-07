import 'app_role.dart';

/// Profil pengguna (PRD Bagian 8, tabel `profiles`).
class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
    required this.displayName,
    required this.email,
    this.posyanduName,
    this.privacyVersion,
    this.privacyAt,
    this.avatarEmoji = '\u{1F469}',
  });

  final String id;
  final AppRole role;
  final String displayName;
  final String email;
  final String? posyanduName;
  final String? privacyVersion;
  final DateTime? privacyAt;
  final String avatarEmoji;

  UserProfile copyWith({
    String? displayName,
    AppRole? role,
    String? posyanduName,
    String? privacyVersion,
    DateTime? privacyAt,
  }) {
    return UserProfile(
      id: id,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      email: email,
      posyanduName: posyanduName ?? this.posyanduName,
      privacyVersion: privacyVersion ?? this.privacyVersion,
      privacyAt: privacyAt ?? this.privacyAt,
      avatarEmoji: avatarEmoji,
    );
  }
}
