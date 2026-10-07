import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

class NuriNavItem {
  const NuriNavItem({required this.icon, required this.label});

  final IconData icon;
  final String label;
}

/// Navigasi bawah NURI. `dark = true` untuk gaya pil gelap (akun/profil),
/// `false` untuk bilah putih (beranda ibu/kader/hamil).
class NuriBottomNav extends StatelessWidget {
  const NuriBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
    this.centerIndex,
    this.dark = false,
  });

  final List<NuriNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;
  final int? centerIndex;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.navDark : AppColors.navBackground;
    final inactive = dark ? Colors.white60 : AppColors.navInactive;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: dark
            ? BorderRadius.circular(28)
            : const BorderRadius.only(
                topLeft: Radius.circular(26),
                topRight: Radius.circular(26),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: dark ? 0.18 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      margin: dark
          ? const EdgeInsets.fromLTRB(16, 0, 16, 14)
          : EdgeInsets.zero,
      padding: EdgeInsets.symmetric(
        horizontal: dark ? 8 : 6,
        vertical: dark ? 10 : 8,
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final active = i == currentIndex;
            final highlight = centerIndex == i;
            final color = active
                ? (dark ? Colors.white : AppColors.brand)
                : inactive;

            if (highlight) {
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: const BoxDecoration(
                          color: AppColors.brand,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.icon, color: Colors.white, size: 22),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.label,
                        style: AppText.caption.copyWith(
                          color: active
                              ? (dark ? Colors.white : AppColors.brand)
                              : inactive,
                          fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return Expanded(
              child: GestureDetector(
                onTap: () => onTap(i),
                behavior: HitTestBehavior.opaque,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(item.icon, color: color, size: 23),
                    const SizedBox(height: 3),
                    Text(
                      item.label,
                      style: AppText.caption.copyWith(
                        color: color,
                        fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 10.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
