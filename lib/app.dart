import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'data/app_controller.dart';
import 'features/auth/onboarding_screens.dart';
import 'features/landing/landing_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/splash/splash_screen.dart';

class NuriApp extends ConsumerStatefulWidget {
  const NuriApp({super.key});

  @override
  ConsumerState<NuriApp> createState() => _NuriAppState();
}

class _NuriAppState extends ConsumerState<NuriApp> {
  bool _showSplash = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final loggedIn = state.currentUser != null;

    Widget home;
    if (_showSplash) {
      home = NuriSplashScreen(
        onFinished: () {
          if (mounted) setState(() => _showSplash = false);
        },
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
    return NuriSplashScreen(onFinished: () {});
  }
}
