import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'nuri_button.dart';
import 'nuri_logo.dart';

/// App bar NURI: tombol kembali bulat lembut, judul/brand di tengah,
/// dan aksi di kanan.
class NuriTopBar extends StatelessWidget {
  const NuriTopBar({
    super.key,
    this.title,
    this.titleWidget,
    this.subtitle,
    this.showBack = true,
    this.onBack,
    this.actions = const [],
    this.leading,
    this.centerTitle = true,
    this.showBrand = false,
    this.padding = const EdgeInsets.fromLTRB(16, 6, 16, 10),
  });

  final String? title;
  final Widget? titleWidget;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final Widget? leading;
  final bool centerTitle;
  final bool showBrand;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final left = leading ??
        (showBack
            ? NuriSoftButton(
                icon: Icons.arrow_back_rounded,
                background: AppColors.surface.withValues(alpha: 0.85),
                onPressed: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : null);

    Widget? center;
    if (titleWidget != null) {
      center = titleWidget;
    } else if (showBrand) {
      center = const NuriBrand();
    } else if (title != null) {
      center = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(title!, style: AppText.h3.copyWith(fontSize: 17)),
          if (subtitle != null)
            Text(subtitle!, style: AppText.caption.copyWith(fontSize: 11)),
        ],
      );
    }

    return Padding(
      padding: padding,
      child: SizedBox(
        height: 48,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (center != null)
              centerTitle
                  ? Center(child: center)
                  : Align(alignment: Alignment.centerLeft, child: center),
            Row(
              children: [
                if (left != null) left else const SizedBox(width: 44),
                const Spacer(),
                if (actions.isNotEmpty)
                  Row(children: actions)
                else
                  const SizedBox(width: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Tombol teks sederhana untuk aksi app bar (mis. "Lewati").
class NuriTextAction extends StatelessWidget {
  const NuriTextAction({super.key, required this.label, this.onTap, this.color});

  final String label;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onTap,
      style: TextButton.styleFrom(
        foregroundColor: color ?? AppColors.inkSoft,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        minimumSize: const Size(0, 40),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: AppText.bodyStrong.copyWith(
          color: color ?? AppColors.inkSoft,
          fontSize: 14,
        ),
      ),
    );
  }
}

/// Lingkaran avatar profil (ikon atau inisial).
class NuriAvatar extends StatelessWidget {
  const NuriAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = 40,
    this.icon = Icons.person_rounded,
    this.background = AppColors.brand,
    this.color = Colors.white,
  });

  final String? imageUrl;
  final String? initials;
  final double size;
  final IconData icon;
  final Color background;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        image: imageUrl != null
            ? DecorationImage(image: NetworkImage(imageUrl!), fit: BoxFit.cover)
            : null,
      ),
      alignment: Alignment.center,
      child: imageUrl != null
          ? null
          : (initials != null
              ? Text(
                  initials!,
                  style: AppText.title.copyWith(color: color, fontSize: size * 0.36),
                )
              : Icon(icon, size: size * 0.5, color: color)),
    );
  }
}
