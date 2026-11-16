import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class NuriTapScale extends StatefulWidget {
  const NuriTapScale({
    super.key,
    required this.child,
    this.onTap,
    this.haptic = false,
    this.scale = 0.975,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool haptic;
  final double scale;

  @override
  State<NuriTapScale> createState() => _NuriTapScaleState();
}

class _NuriTapScaleState extends State<NuriTapScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || widget.onTap == null) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    final child = AnimatedScale(
      scale: !reduce && _pressed ? widget.scale : 1,
      duration: Duration(milliseconds: reduce ? 0 : 120),
      curve: Curves.easeOutCubic,
      child: widget.child,
    );
    if (widget.onTap == null) return child;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: () {
        if (widget.haptic) HapticFeedback.selectionClick();
        widget.onTap!();
      },
      child: child,
    );
  }
}

class NuriButton extends StatelessWidget {
  const NuriButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.loading = false,
    this.variant = NuriButtonVariant.filled,
    this.expand = true,
    this.height = 50,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final NuriButtonVariant variant;
  final bool expand;
  final double height;

  @override
  Widget build(BuildContext context) {
    final spinnerColor = switch (variant) {
      NuriButtonVariant.filled => Colors.white,
      NuriButtonVariant.secondary => AppColors.primary,
      NuriButtonVariant.outlined || NuriButtonVariant.text => AppColors.primary,
      NuriButtonVariant.danger => AppColors.red,
    };
    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: spinnerColor,
            ),
          )
        else if (icon != null)
          Icon(icon, size: 19),
        if (loading || icon != null) const SizedBox(width: 8),
        Flexible(
          child: Text(
            loading ? 'Memproses…' : label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
      ],
    );

    if (variant == NuriButtonVariant.filled) {
      final btn = Container(
        height: height,
        width: expand ? double.infinity : null,
        decoration: BoxDecoration(
          gradient: onPressed == null || loading ? null : AppGradients.button,
          color: onPressed == null || loading
              ? AppColors.primary.withValues(alpha: 0.4)
              : null,
          borderRadius: BorderRadius.circular(AppRadius.button),
          boxShadow: onPressed == null || loading ? null : AppShadows.glow,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: loading ? null : onPressed,
            borderRadius: BorderRadius.circular(AppRadius.button),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: DefaultTextStyle(
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
                child: IconTheme(
                  data: const IconThemeData(color: Colors.white, size: 19),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      );
      return NuriTapScale(onTap: loading ? null : onPressed, child: btn);
    }

    final style = ButtonStyle(
      minimumSize: WidgetStatePropertyAll(
        Size(expand ? double.infinity : 48, height),
      ),
      padding: const WidgetStatePropertyAll(
        EdgeInsets.symmetric(horizontal: 18),
      ),
      shape: WidgetStatePropertyAll(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.button),
        ),
      ),
    );

    return switch (variant) {
      NuriButtonVariant.filled => const SizedBox.shrink(),
      NuriButtonVariant.secondary => FilledButton(
        onPressed: loading ? null : onPressed,
        style: style.copyWith(
          backgroundColor: const WidgetStatePropertyAll(
            AppColors.surfaceContainerLow,
          ),
          foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
        ),
        child: content,
      ),
      NuriButtonVariant.outlined => OutlinedButton(
        onPressed: loading ? null : onPressed,
        style: style.copyWith(
          foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
          side: const WidgetStatePropertyAll(
            BorderSide(color: AppColors.line, width: 1.2),
          ),
        ),
        child: content,
      ),
      NuriButtonVariant.text => TextButton(
        onPressed: loading ? null : onPressed,
        style: style.copyWith(
          foregroundColor: const WidgetStatePropertyAll(AppColors.primary),
          minimumSize: WidgetStatePropertyAll(
            Size(expand ? double.infinity : 0, height),
          ),
        ),
        child: content,
      ),
      NuriButtonVariant.danger => FilledButton(
        onPressed: loading ? null : onPressed,
        style: style.copyWith(
          backgroundColor: const WidgetStatePropertyAll(AppColors.redSoft),
          foregroundColor: const WidgetStatePropertyAll(AppColors.red),
        ),
        child: content,
      ),
    };
  }
}

enum NuriButtonVariant { filled, secondary, outlined, text, danger }
