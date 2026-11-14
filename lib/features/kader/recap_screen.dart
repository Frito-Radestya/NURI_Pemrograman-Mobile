import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';

class RecapScreen extends ConsumerWidget {
  const RecapScreen({super.key, this.embedded = true});

  final bool embedded;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final session = state.activeSession;
    final roster = state.myRoster;
    final children = roster.where((r) => r.type == RosterType.child).toList();
    final categorized = children.where((r) => r.category != null).toList();
    final normal = categorized
        .where((r) => r.category == GrowthCategory.normal)
        .length;
    final stunted = categorized
        .where((r) => r.category == GrowthCategory.stunted)
        .length;
    final severe = categorized
        .where((r) => r.category == GrowthCategory.severelyStunted)
        .length;
    final tall = categorized
        .where((r) => r.category == GrowthCategory.tall)
        .length;
    final present = roster
        .where((r) => r.attendance == AttendanceStatus.present)
        .length;
    final waiting = roster
        .where((r) => r.attendance == AttendanceStatus.waiting)
        .length;
    final absent = roster
        .where((r) => r.attendance == AttendanceStatus.absent)
        .length;
    final followUps = roster.where((r) => r.needsFollowUp).toList();
    final target = session?.targetCount ?? roster.length;
    final done = session?.isDone ?? false;

    final exportButton = _ExportButton(onTap: () => _export(context, state));
    final subtitle = session == null
        ? 'Belum ada sesi aktif'
        : '${session.posyanduName} • ${formatDateId(session.date, withYear: false)}';

    final content = SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (embedded)
              NuriPageHeader(
                title: 'Rekap sesi',
                subtitle: subtitle,
                trailing: exportButton,
              )
            else
              ScreenHeader(
                title: 'Rekap sesi',
                subtitle: subtitle,
                onBack: () => Navigator.of(context).pop(),
                action: exportButton,
              ),
            const SizedBox(height: 12),
            if (session == null)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: EmptyState(
                  title: 'Belum ada sesi',
                  body:
                      'Buat sesi Posyandu terlebih dahulu untuk melihat rekap.',
                  icon: Icons.event_busy_rounded,
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SessionSummaryCard(
                  session: session,
                  present: present,
                  target: target,
                  done: done,
                ),
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    _StatCard(
                      label: 'Sasaran',
                      value: '$target',
                      icon: Icons.groups_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: 'Hadir',
                      value: '$present',
                      icon: Icons.how_to_reg_rounded,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: 'Belum',
                      value: '${waiting + absent}',
                      icon: Icons.person_off_outlined,
                      color: AppColors.amber,
                    ),
                    const SizedBox(width: 8),
                    _StatCard(
                      label: 'Tindak',
                      value: '${followUps.length}',
                      icon: Icons.follow_the_signs_rounded,
                      color: AppColors.red,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Status gizi balita',
                  subtitle: 'Panjang/tinggi badan menurut umur • WHO 2006',
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _DistributionDetail(
                  normal: normal,
                  stunted: stunted,
                  severe: severe,
                  tall: tall,
                  total: categorized.length,
                ),
              ),
              const SizedBox(height: 22),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(title: 'Kehadiran'),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _AttendanceCard(
                  present: present,
                  waiting: waiting,
                  absent: absent,
                  target: target,
                ),
              ),
              const SizedBox(height: 22),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SectionHeader(
                  title: 'Daftar tindak lanjut',
                  subtitle: '${followUps.length} sasaran perlu ditindaklanjuti',
                ),
              ),
              const SizedBox(height: 10),
              if (followUps.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: InfoBanner(
                    title: 'Tidak ada tindak lanjut terbuka',
                    body: 'Semua sasaran pada sesi ini sudah tercatat.',
                    icon: Icons.task_alt_rounded,
                  ),
                )
              else
                ...followUps
                    .take(6)
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                        child: _FollowUpRow(entry: entry),
                      ),
                    ),
              if (followUps.length > 6)
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 2, 20, 0),
                  child: Text(
                    '+${followUps.length - 6} sasaran lainnya ada di tab Tindak Lanjut.',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ),
              const SizedBox(height: 18),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: NuriButton(
                  label: done ? 'Sesi sudah selesai' : 'Selesaikan sesi',
                  icon: done
                      ? Icons.lock_outline_rounded
                      : Icons.check_circle_outline_rounded,
                  variant: done
                      ? NuriButtonVariant.outlined
                      : NuriButtonVariant.filled,
                  onPressed: done
                      ? null
                      : () async {
                          final ok = await showNuriConfirm(
                            context: context,
                            title: 'Selesaikan sesi?',
                            message: 'Rekap akan dikunci. Data yang tertunda tetap tersimpan di perangkat dan disinkronkan saat online.',
                            confirmLabel: 'Selesaikan',
                          );
                          if (!ok) return;
                          ref
                              .read(appControllerProvider.notifier)
                              .completeSession();
                          if (context.mounted) {
                            showNuriSnack(
                              context,
                              'Sesi selesai dan rekap dikunci.',
                            );
                          }
                        },
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: NuriDisclaimer(),
              ),
            ],
          ],
        ),
      ),
    );

    if (embedded) return content;
    return Scaffold(backgroundColor: AppColors.background, body: content);
  }

  Future<void> _export(BuildContext context, AppState state) async {
    final rows = <List<String>>[
      [
        'Nama',
        'Jenis',
        'Usia (bulan)',
        'JK',
        'Kehadiran',
        'Status gizi',
        'LiLA (cm)',
        'Hb (g/dL)',
        'Tindak lanjut',
      ],
      ...state.roster.map(
        (entry) => [
          entry.name,
          entry.type.label,
          entry.ageMonths?.toString() ?? '',
          entry.sex?.short ?? '',
          entry.attendance.label,
          entry.category?.label ?? '',
          entry.lilaCm?.toStringAsFixed(1) ?? '',
          entry.hbGdl?.toStringAsFixed(1) ?? '',
          entry.followUpStatus.label,
        ],
      ),
    ];
    final csv = rows.map((row) => row.map(_csvCell).join(',')).join('\n');
    await Clipboard.setData(ClipboardData(text: csv));
    if (!context.mounted) return;
    await showNuriSheet<void>(
      context: context,
      builder: (sheetContext) => SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ekspor rekap CSV',
              style: Theme.of(sheetContext).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              '${state.roster.length} baris disalin ke clipboard. Tempel ke Excel atau e-PPGBM.',
              style: const TextStyle(fontSize: 12.5, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxHeight: 280),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceSubtle,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: SingleChildScrollView(
                child: Text(
                  csv,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11.5,
                    height: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            NuriButton(
              label: 'Tutup',
              onPressed: () => Navigator.of(sheetContext).pop(),
            ),
          ],
        ),
      ),
    );
  }

  String _csvCell(String value) {
    if (value.contains(',') || value.contains('"') || value.contains('\n')) {
      return '"${value.replaceAll('"', '""')}"';
    }
    return value;
  }
}

class _ExportButton extends StatelessWidget {
  const _ExportButton({required this.onTap});

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

class _SessionSummaryCard extends StatelessWidget {
  const _SessionSummaryCard({
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

class _StatCard extends StatelessWidget {
  const _StatCard({
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

class _DistributionDetail extends StatelessWidget {
  const _DistributionDetail({
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

class _AttendanceCard extends StatelessWidget {
  const _AttendanceCard({
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

class _FollowUpRow extends StatelessWidget {
  const _FollowUpRow({required this.entry});

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
