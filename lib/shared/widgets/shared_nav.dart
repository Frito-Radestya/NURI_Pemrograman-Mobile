import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';

class BottomNavItem {
  const BottomNavItem({
    required this.icon,
    required this.label,
    this.activeIcon,
    this.isCenter = false,
  });

  final IconData icon;
  final IconData? activeIcon;
  final String label;
  final bool isCenter;
}

class NuriBottomNav extends StatelessWidget {
  const NuriBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final reduce = MediaQuery.disableAnimationsOf(context);

    return Container(
      color: Colors.transparent,
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        bottomPadding > 0 ? bottomPadding : 12,
      ),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.98),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: AppColors.line.withValues(alpha: 0.8)),
          boxShadow: AppShadows.floating,
        ),
        child: Row(
          children: List.generate(items.length, (index) {
            final item = items[index];
            final selected = index == selectedIndex;

            if (item.isCenter) {
              return Expanded(
                child: Center(
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onTap(index);
                      },
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppGradients.button,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x4D2E7D32),
                              blurRadius: 14,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.activeIcon ?? item.icon,
                              color: Colors.white,
                              size: 23,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              item.label,
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                height: 1,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }

            return Expanded(
              child: InkWell(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onTap(index);
                },
                borderRadius: BorderRadius.circular(32),
                splashColor: AppColors.primary.withValues(alpha: 0.08),
                highlightColor: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AnimatedContainer(
                      duration: Duration(milliseconds: reduce ? 0 : 200),
                      curve: Curves.easeOutCubic,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppColors.softMint
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        selected ? (item.activeIcon ?? item.icon) : item.icon,
                        color: selected ? AppColors.primary : AppColors.muted,
                        size: 21,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10.5,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: selected ? AppColors.primary : AppColors.muted,
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
