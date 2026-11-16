import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class RecapDistributionDetail extends StatelessWidget {
  const RecapDistributionDetail({
    super.key,
    required this.normal,
    required this.stunted,
    required this.severe,
    required this.tall,
    required this.total,
  });

  final int normal;
  final int stunted;
  final int severe;
  final int tall;
  final int total;

  @override
  Widget build(BuildContext context) {
    final safe = total == 0 ? 1 : total;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 12,
              child: Row(
                children: [
                  if (normal > 0)
                    Expanded(
                      flex: normal,
                      child: Container(color: AppColors.primary),
                    ),
                  if (stunted > 0)
                    Expanded(
                      flex: stunted,
                      child: Container(color: AppColors.amber),
                    ),
                  if (severe > 0)
                    Expanded(
                      flex: severe,
                      child: Container(color: AppColors.red),
                    ),
                  if (tall > 0)
                    Expanded(
                      flex: tall,
                      child: Container(color: AppColors.blue),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          _DistributionRow(
            color: AppColors.primary,
            icon: Icons.check_circle_outline_rounded,
            label: 'Normal',
            note: '≥ -2 SD s.d. ≤ +2 SD',
            value: normal,
            percent: normal / safe,
          ),
          const Divider(height: 18),
          _DistributionRow(
            color: AppColors.amber,
            icon: Icons.trending_down_rounded,
            label: 'Pendek',
            note: '≥ -3 SD s.d. < -2 SD',
            value: stunted,
            percent: stunted / safe,
          ),
          const Divider(height: 18),
          _DistributionRow(
            color: AppColors.red,
            icon: Icons.error_outline_rounded,
            label: 'Sangat pendek',
            note: '< -3 SD • rujuk faskes',
            value: severe,
            percent: severe / safe,
          ),
          if (tall > 0) ...[
            const Divider(height: 18),
            _DistributionRow(
              color: AppColors.blue,
              icon: Icons.trending_up_rounded,
              label: 'Tinggi',
              note: '> +3 SD • pantau',
              value: tall,
              percent: tall / safe,
            ),
          ],
          const SizedBox(height: 12),
          Text(
            '$total balita memiliki status gizi terklasifikasi',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _DistributionRow extends StatelessWidget {
  const _DistributionRow({
    required this.color,
    required this.icon,
    required this.label,
    required this.note,
    required this.value,
    required this.percent,
  });

  final Color color;
  final IconData icon;
  final String label;
  final String note;
  final int value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 11),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                note,
                style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
              ),
            ],
          ),
        ),
        Text(
          '$value',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 19,
            fontWeight: FontWeight.w800,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 6),
        SizedBox(
          width: 40,
          child: Text(
            '${(percent * 100).round()}%',
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class RecapAttendanceCard extends StatelessWidget {
  const RecapAttendanceCard({
    super.key,
    required this.present,
    required this.waiting,
    required this.absent,
    required this.target,
  });

  final int present;
  final int waiting;
  final int absent;
  final int target;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              _AttendanceStat(
                label: 'Hadir',
                value: present,
                color: AppColors.primary,
                background: AppColors.mint,
                icon: Icons.check_circle_outline_rounded,
              ),
              const SizedBox(width: 9),
              _AttendanceStat(
                label: 'Menunggu',
                value: waiting,
                color: AppColors.amber,
                background: AppColors.amberSoft,
                icon: Icons.schedule_rounded,
              ),
              const SizedBox(width: 9),
              _AttendanceStat(
                label: 'Belum hadir',
                value: absent,
                color: AppColors.red,
                background: AppColors.redSoft,
                icon: Icons.cancel_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$present dari $target sasaran tercatat hadir',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}

class _AttendanceStat extends StatelessWidget {
  const _AttendanceStat({
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
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(height: 4),
            Text(
              '$value',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}

class RecapFollowUpRow extends StatelessWidget {
  const RecapFollowUpRow({super.key, required this.entry});

  final RosterEntry entry;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          AppAvatar(name: entry.name, index: entry.avatarIndex, size: 40),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  entry.reason ?? entry.followUpStatus.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Pill(
            label: entry.followUpStatus.label,
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
    );
  }
}
