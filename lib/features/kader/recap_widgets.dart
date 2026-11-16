import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models.dart';
import '../../shared/widgets.dart';

class RecapExportButton extends StatelessWidget {
  const RecapExportButton({super.key, required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onTap,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, 40),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        textStyle: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
      ),
      icon: const Icon(Icons.download_rounded, size: 16),
      label: const Text('CSV'),
    );
  }
}

class RecapSessionSummaryCard extends StatelessWidget {
  const RecapSessionSummaryCard({
    super.key,
    required this.session,
    required this.present,
    required this.target,
    required this.done,
  });

  final PosyanduSession session;
  final int present;
  final int target;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : present / target;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.posyanduName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${formatDateId(session.date)} • ${session.note ?? 'Sesi posyandu'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Pill(
                label: done ? 'Selesai' : 'Berlangsung',
                icon: done
                    ? Icons.lock_outline_rounded
                    : Icons.play_circle_outline_rounded,
                background: done ? AppColors.mint : AppColors.amberSoft,
                foreground: done ? AppColors.primaryDark : AppColors.amber,
                fontSize: 11.5,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: LinearProgress(value: progress, height: 8)),
              const SizedBox(width: 10),
              Text(
                '$present / $target',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            '${(progress * 100).round()}% sasaran hadir pada sesi ini',
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          if (done) ...[
            const SizedBox(height: 10),
            const InfoBanner(
              title: 'Rekap terkunci',
              body: 'Perubahan entri setelah sesi selesai hanya oleh pembuatnya dengan alasan tercatat.',
              icon: Icons.lock_outline_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class RecapStatCard extends StatelessWidget {
  const RecapStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AppCard(
        padding: const EdgeInsets.all(11),
        radius: 14,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 17, color: color),
            const SizedBox(height: 7),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w800,
                fontFeatures: const [FontFeature.tabularFigures()],
                color: color,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 11, color: AppColors.muted),
            ),
          ],
        ),
      ),
    );
  }
}
