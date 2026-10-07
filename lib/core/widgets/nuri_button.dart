import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimens.dart';
import '../theme/app_text.dart';

/// Tombol utama NURI: pil hijau forest, teks putih, opsi ikon + panah.
class NuriPrimaryButton extends StatelessWidget {
  const NuriPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.trailingArrow = false,
    this.expand = true,
    this.loading = false,
    this.color = AppColors.brand,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool trailingArrow;
  final bool expand;
  final bool loading;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      child: Material(
        color: onPressed == null ? AppColors.lineStrong : color,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          onTap: loading ? null : onPressed,
          child: Container(
            height: AppDimens.buttonHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.4,
                      valueColor: AlwaysStoppedAnimation(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (icon != null) ...[
                        Icon(icon, color: Colors.white, size: 20),
                        const SizedBox(width: 10),
                      ],
                      Flexible(
                        child: Text(
                          label,
                          textAlign: TextAlign.center,
                          style: AppText.button,
                        ),
                      ),
                      if (trailingArrow) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 20),
                      ],
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

/// Tombol sekunder: pil putih dengan garis tepi.
class NuriSecondaryButton extends StatelessWidget {
  const NuriSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.expand = true,
    this.filled = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: expand ? double.infinity : null,
      child: Material(
        color: filled ? AppColors.surfaceSoft : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimens.radiusPill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppDimens.radiusPill),
          onTap: onPressed,
          child: Container(
            height: AppDimens.buttonHeight,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppDimens.radiusPill),
              border: filled
                  ? null
                  : Border.all(color: AppColors.line),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, color: AppColors.ink, size: 20),
                  const SizedBox(width: 10),
                ],
                Flexible(
                  child: Text(
                    label,
                    textAlign: TextAlign.center,
                    style: AppText.button.copyWith(color: AppColors.ink),
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

/// Tombol ikon bulat lembut (mis. tombol kembali, putar kamera).
class NuriSoftButton extends StatelessWidget {
  const NuriSoftButton({
    super.key,
    required this.icon,
    this.onPressed,
    this.size = 44,
    this.background = AppColors.surface,
    this.color = AppColors.ink,
    this.border,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final double size;
  final Color background;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      shape: CircleBorder(
        side: border != null ? BorderSide(color: border!) : BorderSide.none,
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, size: size * 0.5, color: color),
        ),
      ),
    );
  }
}
