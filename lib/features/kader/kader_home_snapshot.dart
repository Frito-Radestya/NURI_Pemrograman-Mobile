import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class KaderNutritionSnapshot extends StatelessWidget {
  const KaderNutritionSnapshot({
    super.key,
    required this.normal,
    required this.stunted,
    required this.severe,
    required this.total,
    required this.notPresent,
    required this.onTap,
  });

  final int normal;
  final int stunted;
  final int severe;
  final int total;
  final int notPresent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status gizi sesi ini',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _SnapshotCount(
              label: 'Normal',
              value: normal,
              color: AppColors.primary,
              background: AppColors.mint,
            ),
            _SnapshotCount(
              label: 'Pendek',
              value: stunted,
              color: AppColors.amber,
              background: AppColors.amberSoft,
            ),
            _SnapshotCount(
              label: 'Sangat pendek',
              value: severe,
              color: AppColors.red,
              background: AppColors.redSoft,
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          '$total balita terukur • $notPresent belum hadir',
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
      ],
    );
  }
}

class _SnapshotCount extends StatelessWidget {
  const _SnapshotCount({
    required this.label,
    required this.value,
    required this.color,
    required this.background,
  });

  final String label;
  final int value;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$value',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class KaderFollowUpList extends StatelessWidget {
  const KaderFollowUpList({
    super.key,
    required this.entries,
    required this.onTap,
  });

  final List<RosterEntry> entries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < entries.length; i++) ...[
            _FollowUpPreview(entry: entries[i], onTap: onTap),
            if (i < entries.length - 1) const Divider(height: 1),
          ],
        ],
      ),
    );
  }
}

class _FollowUpPreview extends StatelessWidget {
  const _FollowUpPreview({required this.entry, required this.onTap});

  final RosterEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
        child: Row(
          children: [
            AppAvatar(name: entry.name, index: entry.avatarIndex, size: 42),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Pill(
                        label: switch (entry.followUpStatus) {
                          FollowUpStatus.open => 'Terbuka',
                          FollowUpStatus.visited => 'Dikunjungi',
                          FollowUpStatus.referred => 'Dirujuk',
                          FollowUpStatus.unreachable => 'Absen',
                          FollowUpStatus.closed => 'Selesai',
                        },
                        background: entry.followUpStatus == FollowUpStatus.open
                            ? AppColors.amberSoft
                            : AppColors.blueSoft,
                        foreground: entry.followUpStatus == FollowUpStatus.open
                            ? AppColors.amber
                            : AppColors.blue,
                        fontSize: 11,
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    entry.reason ?? 'Perlu konfirmasi kader',
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
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.muted,
            ),
          ],
        ),
      ),
    );
  }
}
