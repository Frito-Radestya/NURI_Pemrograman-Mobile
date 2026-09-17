import 'package:flutter/material.dart';
import 'animated_splash_logo.dart';

/// Alias kompatibilitas — logo NURI (statis).
class AppLogo extends StatelessWidget {
  final double size;
  final bool white;

  const AppLogo({super.key, this.size = 88, this.white = false});

  @override
  Widget build(BuildContext context) {
    return NuriLogo(size: size, white: white);
  }
}
