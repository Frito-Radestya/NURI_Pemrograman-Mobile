import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'router.dart';

/// Akar aplikasi NURI v2.
class NuriApp extends StatelessWidget {
  const NuriApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'NURI — Nutrisi & Pertumbuhan Anak',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routerConfig: appRouter,
    );
  }
}
