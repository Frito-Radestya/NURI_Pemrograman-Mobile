import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Kerangka layar NURI: latar krem, konten aman dari notch,
/// opsional bilah navigasi bawah.
class NuriScaffold extends StatelessWidget {
  const NuriScaffold({
    super.key,
    required this.body,
    this.background = AppColors.canvas,
    this.bottomNavigationBar,
    this.topBar,
    this.safeTop = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 20),
  });

  final Widget body;
  final Color background;
  final Widget? bottomNavigationBar;
  final Widget? topBar;
  final bool safeTop;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: bottomNavigationBar,
      body: SafeArea(
        top: safeTop,
        bottom: bottomNavigationBar == null,
        child: Column(
          children: [
            ?topBar,
            Expanded(
              child: Padding(
                padding: padding,
                child: body,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
