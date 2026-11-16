import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/app_controller.dart';
import '../../domain/models.dart';
import 'auth_consent_screen.dart';
import 'auth_login_screen.dart';
import 'auth_role_setup_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) => const LoginScreen(showBack: false);
}

class OnboardingGate extends ConsumerWidget {
  const OnboardingGate({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    if (state.currentUser == null) {
      return const AuthScreen();
    }
    // Kader / Admin adalah pengelola, persetujuan data keluarga hanya untuk Ibu
    if (role == UserRole.mother && !state.consentAccepted) {
      return const ConsentScreen();
    }
    return RoleSetupScreen(role: role);
  }
}
