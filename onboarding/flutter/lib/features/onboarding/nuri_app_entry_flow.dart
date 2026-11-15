// ============================================================================
// NURI — Alur Pengguna Baru End-to-End (Splash -> Onboarding -> Pilih Peran -> Auth)
// File: lib/features/onboarding/nuri_app_entry_flow.dart
// ============================================================================
import 'package:flutter/material.dart';
import '../splash/nuri_splash_screen_png.dart';
import 'nuri_onboarding_screen.dart';

class NuriAppEntryFlow extends StatefulWidget {
  final void Function(NuriUserRole role) onNavigateToAuth;

  const NuriAppEntryFlow({
    super.key,
    required this.onNavigateToAuth,
  });

  @override
  State<NuriAppEntryFlow> createState() => _NuriAppEntryFlowState();
}

class _NuriAppEntryFlowState extends State<NuriAppEntryFlow> {
  bool _splashCompleted = false;

  @override
  Widget build(BuildContext context) {
    if (!_splashCompleted) {
      return NuriSplashScreenPng(
        onFinished: () {
          if (mounted) {
            setState(() => _splashCompleted = true);
          }
        },
      );
    }

    return NuriOnboardingScreen(
      onRoleConfirmed: widget.onNavigateToAuth,
    );
  }
}
