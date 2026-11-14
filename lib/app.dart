import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/app_controller.dart';
import 'features/auth/onboarding_screens.dart';
import 'features/landing/landing_screen.dart';
import 'features/shell/app_shell.dart';

class NuriApp extends ConsumerStatefulWidget {
  const NuriApp({super.key});

  @override
  ConsumerState<NuriApp> createState() => _NuriAppState();
}

class _NuriAppState extends ConsumerState<NuriApp> {
  bool _showSplash = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) setState(() => _showSplash = false);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final loggedIn = state.currentUser != null;

    Widget home;
    if (_showSplash) {
      home = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _timer?.cancel();
          if (mounted) setState(() => _showSplash = false);
        },
        child: const SplashScreen(),
      );
    } else if (!loggedIn) {
      home = state.landingSeen ? const AuthScreen() : const LandingScreen();
    } else if (!state.onboardingSeen) {
      home = OnboardingGate(role: state.currentUser!.role);
    } else {
      home = const AppShell();
    }

    return MaterialApp(
      title: 'NURI',
      debugShowCheckedModeBanner: false,
      locale: const Locale('id', 'ID'),
      supportedLocales: const [Locale('id', 'ID')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppTheme.light(),
      themeMode: ThemeMode.light,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.white,
          systemNavigationBarIconBrightness: Brightness.dark,
        ),
        child: ColoredBox(
          color: AppColors.background,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 560),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
      ),
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: KeyedSubtree(
          key: ValueKey(
            '${home.runtimeType}_${loggedIn}_${state.onboardingSeen}_${state.landingSeen}',
          ),
          child: home,
        ),
      ),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            color: AppColors.medicalBlack,
          ),
          child: SafeArea(
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.vitalYellow,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.vitalYellow.withValues(alpha: 0.35),
                              blurRadius: 20,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.spa_rounded,
                          color: AppColors.medicalBlack,
                          size: 42,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'NURI',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          height: 1,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Sahabat Ibu & Balita',
                        style: TextStyle(
                          color: AppColors.neutralGray,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 36),
                      const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.vitalYellow,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  left: 24,
                  right: 24,
                  bottom: 24,
                  child: Text(
                    'Skrining awal, bukan diagnosis.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.neutralGray,
                      fontSize: 11.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
