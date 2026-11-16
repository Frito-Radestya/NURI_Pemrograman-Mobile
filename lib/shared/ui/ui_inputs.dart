import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class NuriTextField extends StatelessWidget {
  const NuriTextField({
    super.key,
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.maxLines = 1,
    this.validator,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.inputFormatters,
    this.autofillHints,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final int maxLines;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final List<TextInputFormatter>? inputFormatters;
  final Iterable<String>? autofillHints;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          maxLines: obscureText ? 1 : maxLines,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          enabled: enabled,
          inputFormatters: inputFormatters,
          autofillHints: autofillHints,
          textCapitalization: textCapitalization,
          style: const TextStyle(fontSize: 14.5, color: AppColors.text),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppColors.muted.withValues(alpha: 0.45),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffixIcon,
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class NuriDateField extends StatelessWidget {
  const NuriDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.helper,
    this.icon = Icons.calendar_today_rounded,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onChanged;
  final DateTime? firstDate;
  final DateTime? lastDate;
  final String? helper;
  final IconData icon;

  Future<void> _pick(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: firstDate ?? DateTime(now.year - 8),
      lastDate: lastDate ?? DateTime(now.year + 2),
      helpText: label,
      cancelText: 'Batal',
      confirmText: 'Pilih',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme
                .copyWith(primary: AppColors.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) onChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.text,
          ),
        ),
        const SizedBox(height: 7),
        InkWell(
          onTap: () => _pick(context),
          borderRadius: BorderRadius.circular(AppRadius.input),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.input),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                Icon(icon, size: 19, color: AppColors.muted),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    value == null
                        ? 'Pilih tanggal'
                        : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}',
                    style: TextStyle(
                      fontSize: 14.5,
                      color: value == null ? AppColors.muted : AppColors.text,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const Icon(
                  Icons.expand_more_rounded,
                  size: 19,
                  color: AppColors.muted,
                ),
              ],
            ),
          ),
        ),
        if (helper != null) ...[
          const SizedBox(height: 6),
          Text(
            helper!,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ],
    );
  }
}

class NuriSegmentedControl<T> extends StatelessWidget {
  const NuriSegmentedControl({
    super.key,
    required this.values,
    required this.selected,
    required this.labelFor,
    required this.onChanged,
    this.background = AppColors.surfaceContainerLowest,
    this.padding = const EdgeInsets.all(5),
    this.icons,
  });

  final List<T> values;
  final T selected;
  final String Function(T value) labelFor;
  final ValueChanged<T> onChanged;
  final Color background;
  final EdgeInsetsGeometry padding;
  final Map<T, IconData>? icons;

  @override
  Widget build(BuildContext context) {
    final activeIndex = values.indexOf(selected).clamp(0, values.length - 1);
    final reduce = MediaQuery.disableAnimationsOf(context);
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: AppColors.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A002204),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final count = values.length;
          final slotWidth = count == 0 ? 0.0 : constraints.maxWidth / count;
          return Stack(
            children: [
              AnimatedPositioned(
                duration: Duration(milliseconds: reduce ? 0 : 220),
                curve: Curves.easeOutCubic,
                left: slotWidth * activeIndex,
                top: 0,
                bottom: 0,
                width: slotWidth,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: AppGradients.button,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x330D631B),
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: values.map((value) {
                  final active = value == selected;
                  final icon = icons?[value];
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        if (value != selected) {
                          HapticFeedback.selectionClick();
                          onChanged(value);
                        }
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (icon != null) ...[
                              Icon(
                                icon,
                                size: 17,
                                color: active
                                    ? Colors.white
                                    : AppColors.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                            ],
                            Flexible(
                              child: Text(
                                labelFor(value),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: active
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: active
                                      ? Colors.white
                                      : AppColors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}

class NuriFormLabel extends StatelessWidget {
  const NuriFormLabel({super.key, required this.text, this.trailing});
  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.text,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class NuriNumberStepper extends StatelessWidget {
  const NuriNumberStepper({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 100,
    this.step = 1,
    this.suffix,
  });

  final double value;
  final ValueChanged<double> onChanged;
  final double min;
  final double max;
  final double step;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepButton(
            icon: Icons.remove_rounded,
            onTap: value <= min
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onChanged((value - step).clamp(min, max));
                  },
          ),
          Container(
            constraints: const BoxConstraints(minWidth: 58),
            alignment: Alignment.center,
            child: Text(
              '${value.round()}${suffix ?? ''}',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                fontFeatures: [FontFeature.tabularFigures()],
                color: AppColors.text,
              ),
            ),
          ),
          _StepButton(
            icon: Icons.add_rounded,
            onTap: value >= max
                ? null
                : () {
                    HapticFeedback.selectionClick();
                    onChanged((value + step).clamp(min, max));
                  },
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(9),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: onTap == null ? Colors.transparent : AppColors.surface,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Icon(
          icon,
          size: 17,
          color: onTap == null ? AppColors.line : AppColors.text,
        ),
      ),
    );
  }
}
