import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class RosterFilterChip extends StatelessWidget {
  const RosterFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.isAlert = false,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;
  final bool isAlert;

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;
    Gradient? gradient;

    if (selected) {
      if (isAlert) {
        bg = AppColors.red;
        fg = Colors.white;
      } else {
        bg = AppColors.primary;
        fg = Colors.white;
        gradient = AppGradients.button;
      }
    } else {
      if (isAlert) {
        bg = AppColors.redSoft;
        fg = AppColors.red;
      } else {
        bg = AppColors.surfaceContainerLow;
        fg = AppColors.onSurfaceVariant;
      }
    }

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: gradient == null ? bg : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: selected ? AppShadows.glow : null,
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }
}

class RosterTile extends StatelessWidget {
  const RosterTile({super.key, required this.entry, required this.onTap});

  final RosterEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isPregnant = entry.type == RosterType.pregnant;
    final stripeColor = entry.needsFollowUp
        ? AppColors.red
        : (entry.attendance == AttendanceStatus.present
              ? AppColors.primary
              : AppColors.outlineVariant);

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 5,
              child: Container(color: stripeColor),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 14, 14),
              child: Column(
                children: [
                  Row(
                    children: [
                      AppAvatar(
                        name: entry.name,
                        index: entry.avatarIndex,
                        size: 44,
                      ),
                      const SizedBox(width: 11),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    entry.name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontFamily: 'Nunito',
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.onSurface,
                                    ),
                                  ),
                                ),
                                if (entry.priority) ...[
                                  const SizedBox(width: 4),
                                  const Icon(
                                    Icons.priority_high_rounded,
                                    size: 15,
                                    color: AppColors.red,
                                  ),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              isPregnant
                                  ? '${entry.pregnancyWeeks ?? '—'} minggu • ${entry.guardianName}'
                                  : '${entry.ageMonths ?? '—'} bulan • Ibu: ${entry.guardianName}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                color: AppColors.muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      if (isPregnant)
                        const Pill(
                          label: 'Bumil',
                          icon: Icons.pregnant_woman_rounded,
                          background: AppColors.purpleSoft,
                          foreground: AppColors.purple,
                          fontSize: 11,
                        )
                      else if (entry.category != null)
                        GrowthStatusBadge(
                          category: entry.category!,
                          compact: true,
                        )
                      else
                        const Pill(label: 'Belum diukur', fontSize: 11),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        entry.attendance == AttendanceStatus.present
                            ? Icons.check_circle_rounded
                            : entry.attendance == AttendanceStatus.absent
                            ? Icons.cancel_rounded
                            : Icons.schedule_rounded,
                        size: 15,
                        color: entry.attendance == AttendanceStatus.present
                            ? AppColors.primary
                            : entry.attendance == AttendanceStatus.absent
                            ? AppColors.red
                            : AppColors.amber,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        entry.attendance.label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: entry.attendance == AttendanceStatus.present
                              ? AppColors.primary
                              : entry.attendance == AttendanceStatus.absent
                              ? AppColors.red
                              : AppColors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          entry.reason ?? entry.guardianName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ),
                      if (entry.pendingSync) const SyncBadge(pending: true),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
