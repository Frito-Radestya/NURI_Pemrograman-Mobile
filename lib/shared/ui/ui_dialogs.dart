import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

Future<T?> showNuriSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = true,
  bool isDismissible = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    isDismissible: isDismissible,
    enableDrag: isDismissible,
    useSafeArea: true,
    builder: (context) => PopScope(
      canPop: isDismissible,
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(top: 10, bottom: 8),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            Flexible(child: builder(context)),
          ],
        ),
      ),
    ),
  );
}

Future<bool> showNuriConfirm({
  required BuildContext context,
  required String title,
  required String message,
  String confirmLabel = 'Ya, lanjutkan',
  String cancelLabel = 'Batal',
  bool danger = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(
        message,
        style: const TextStyle(
          fontSize: 13.5,
          height: 1.5,
          color: AppColors.muted,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: danger
              ? FilledButton.styleFrom(backgroundColor: AppColors.red)
              : null,
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
