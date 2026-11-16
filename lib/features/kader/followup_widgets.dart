import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class FollowUpSummaryTile extends StatelessWidget {
  const FollowUpSummaryTile({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.background,
    required this.icon,
  });

  final String label;
  final int value;
  final Color color;
  final Color background;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$value',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      fontFeatures: const [FontFeature.tabularFigures()],
                      color: color,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.muted,
                    ),
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

class FollowUpFilterChip extends StatelessWidget {
  const FollowUpFilterChip({
    super.key,
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.line,
          ),
        ),
        child: Text(
          '$label  $count',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.text,
          ),
        ),
      ),
    );
  }
}

class FollowUpCard extends StatelessWidget {
  const FollowUpCard({super.key, required this.entry, required this.onTap});

  final RosterEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final statusColors = colorsFor(entry.followUpStatus);
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(name: entry.name, index: entry.avatarIndex, size: 44),
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
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
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
                      entry.type == RosterType.child
                          ? '${entry.ageMonths ?? '—'} bulan • ${entry.guardianName}'
                          : '${entry.pregnancyWeeks ?? '—'} minggu • ${entry.guardianName}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Pill(
                label: shortStatus(entry.followUpStatus),
                background: statusColors.$1,
                foreground: statusColors.$2,
                fontSize: 11,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
            decoration: BoxDecoration(
              color: AppColors.surfaceSubtle,
              borderRadius: BorderRadius.circular(11),
            ),
            child: Row(
              children: [
                Icon(Icons.flag_outlined, size: 15, color: statusColors.$2),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    entry.reason ?? 'Perlu konfirmasi kader',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text,
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              Icon(
                entry.lastMeasuredAt == null
                    ? Icons.event_busy_outlined
                    : Icons.straighten_rounded,
                size: 14,
                color: AppColors.muted,
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  entry.lastMeasuredAt == null
                      ? 'Belum ada pengukuran'
                      : 'Diukur ${formatDateId(entry.lastMeasuredAt!, withYear: false)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ),
              if (entry.pendingSync) const SyncBadge(pending: true),
              const SizedBox(width: 4),
              const Icon(
                Icons.chevron_right_rounded,
                size: 19,
                color: AppColors.muted,
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String shortStatus(FollowUpStatus status) => switch (status) {
    FollowUpStatus.open => 'Terbuka',
    FollowUpStatus.visited => 'Dikunjungi',
    FollowUpStatus.referred => 'Dirujuk',
    FollowUpStatus.unreachable => 'Absen',
    FollowUpStatus.closed => 'Selesai',
  };

  static (Color, Color) colorsFor(FollowUpStatus status) => switch (status) {
    FollowUpStatus.open => (AppColors.amberSoft, AppColors.amber),
    FollowUpStatus.visited => (AppColors.blueSoft, AppColors.blue),
    FollowUpStatus.referred => (AppColors.redSoft, AppColors.red),
    FollowUpStatus.unreachable => (AppColors.purpleSoft, AppColors.purple),
    FollowUpStatus.closed => (AppColors.mint, AppColors.primary),
  };
}
