import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class ScannerCorners extends StatelessWidget {
  const ScannerCorners({super.key});

  @override
  Widget build(BuildContext context) {
    const color = AppColors.secondaryFixed;
    return Stack(
      children: const [
        Positioned(
          top: 22,
          left: 22,
          child: _Corner(color: color, top: true, left: true),
        ),
        Positioned(
          top: 22,
          right: 22,
          child: _Corner(color: color, top: true, left: false),
        ),
        Positioned(
          bottom: 22,
          left: 22,
          child: _Corner(color: color, top: false, left: true),
        ),
        Positioned(
          bottom: 22,
          right: 22,
          child: _Corner(color: color, top: false, left: false),
        ),
      ],
    );
  }
}

class _Corner extends StatelessWidget {
  const _Corner({required this.color, required this.top, required this.left});

  final Color color;
  final bool top;
  final bool left;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        border: Border(
          top: top ? BorderSide(color: color, width: 3) : BorderSide.none,
          bottom: !top ? BorderSide(color: color, width: 3) : BorderSide.none,
          left: left ? BorderSide(color: color, width: 3) : BorderSide.none,
          right: !left ? BorderSide(color: color, width: 3) : BorderSide.none,
        ),
        borderRadius: BorderRadius.only(
          topLeft: top && left ? const Radius.circular(12) : Radius.zero,
          topRight: top && !left ? const Radius.circular(12) : Radius.zero,
          bottomLeft: !top && left ? const Radius.circular(12) : Radius.zero,
          bottomRight: !top && !left ? const Radius.circular(12) : Radius.zero,
        ),
      ),
    );
  }
}
