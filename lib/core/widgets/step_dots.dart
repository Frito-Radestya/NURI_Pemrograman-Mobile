import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Indikator langkah (pil panjang untuk aktif, titik untuk lainnya).
class StepDots extends StatelessWidget {
  const StepDots({
    super.key,
    required this.count,
    required this.index,
  });

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: const EdgeInsets.symmetric(horizontal: 3.5),
          height: 7,
          width: active ? 26 : 7,
          decoration: BoxDecoration(
            color: active ? AppColors.brand : AppColors.lineStrong,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}

/// Bilah kemajuan tipis untuk langkah form.
class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 6,
        backgroundColor: AppColors.line,
        valueColor: const AlwaysStoppedAnimation(AppColors.brand),
      ),
    );
  }
}
