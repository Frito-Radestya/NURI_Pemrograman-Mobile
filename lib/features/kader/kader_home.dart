import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../data/app_selectors.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'followup_screen.dart';
import 'recap_screen.dart';
import 'scan_screen.dart';

class KaderHomeScreen extends ConsumerWidget {
  const KaderHomeScreen({super.key});

  void _push(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final session = ref.watch(activeSessionProvider);
    final roster = ref.watch(rosterProvider);
    final pendingWrites = ref.watch(pendingWritesProvider);
    final posyanduName = ref.watch(posyanduNameProvider);
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
    final followUps = roster.where((r) => r.needsFollowUp).toList()
      ..sort((a, b) {
        if (a.priority != b.priority) return a.priority ? -1 : 1;
        return (b.reason ?? '').compareTo(a.reason ?? '');
      });
    final present = roster
        .where((r) => r.attendance == AttendanceStatus.present)
        .length;
    final target = session?.targetCount ?? roster.length;
    final notPresent = target - present;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  AppAvatar(
                    name: user?.name ?? 'Kader',
                    index: 7,
                    imageAsset: user?.avatarAsset,
                    size: 46,
                    showBadge: true,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Kader Posyandu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          user?.name ?? 'Nur Aisyah',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontSize: 21, letterSpacing: -0.35),
                        ),
                        Text(
                          posyanduName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SyncButton(
                    pending: pendingWrites,
                    onTap: () async {
                      final ok = await ref
                          .read(appControllerProvider.notifier)
                          .syncNow();
                      if (!context.mounted) return;
                      showNuriSnack(
                        context,
                        ok ? 'Semua data tersinkron. Siap bekerja offline.' : 'Sinkronisasi gagal. Perubahan tetap tersimpan lokal.',
                        error: !ok,
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _SessionCard(
                session: session,
                posyanduName: posyanduName,
                present: present,
                target: target,
                followUpCount: followUps.length,
                onMeasure: () => _push(context, const ScanScreen()),
                onComplete: session == null || session.isDone
                    ? null
                    : () async {
                        final ok = await showNuriConfirm(
                          context: context,
                          title: 'Selesaikan sesi?',
                          message: 'Rekap sesi akan dikunci. Entri yang masih tertunda tetap tersimpan dan disinkronkan saat online.',
                          confirmLabel: 'Selesaikan sesi',
                        );
                        if (!ok) return;
                        ref
                            .read(appControllerProvider.notifier)
                            .completeSession();
                        if (context.mounted) {
                          showNuriSnack(
                            context,
                            'Sesi selesai. Rekap sudah dikunci.',
                          );
                        }
                      },
              ),
            ),
            const SizedBox(height: 14),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _NutritionSnapshot(
                normal: normal,
                stunted: stunted,
                severe: severe,
                total: categorized.length,
                notPresent: notPresent,
                onTap: () => _push(context, const RecapScreen(embedded: false)),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                title: 'Perlu perhatian',
                subtitle:
                    '${followUps.length} sasaran masuk daftar tindak lanjut',
                actionLabel: followUps.isEmpty ? null : 'Semua',
                onAction: () =>
                    _push(context, const FollowUpScreen(embedded: false)),
              ),
            ),
            const SizedBox(height: 10),
            if (followUps.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: InfoBanner(
                  title: 'Semua sasaran terpantau',
                  body: 'Belum ada tindak lanjut terbuka pada sesi ini.',
                  icon: Icons.task_alt_rounded,
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _FollowUpList(
                  entries: followUps.take(3).toList(),
                  onTap: () =>
                      _push(context, const FollowUpScreen(embedded: false)),
                ),
              ),
            const SizedBox(height: 14),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: NuriDisclaimer(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SyncButton extends StatelessWidget {
  const _SyncButton({required this.pending, required this.onTap});

  final int pending;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: pending == 0 ? AppColors.mint : AppColors.amberSoft,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              pending == 0
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_upload_outlined,
              size: 16,
              color: pending == 0 ? AppColors.primary : AppColors.amber,
            ),
            const SizedBox(width: 5),
            Text(
              pending == 0 ? 'Sinkron' : '$pending tertunda',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: pending == 0 ? AppColors.primaryDark : AppColors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.posyanduName,
    required this.present,
    required this.target,
    required this.followUpCount,
    required this.onMeasure,
    required this.onComplete,
  });

  final PosyanduSession? session;
  final String posyanduName;
  final int present;
  final int target;
  final int followUpCount;
  final VoidCallback onMeasure;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : present / target;
    final done = session?.isDone ?? false;
    final hasSession = session != null;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF145C45), Color(0xFF0E4332)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF145C45).withValues(alpha: 0.22),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: !hasSession
                            ? Colors.white70
                            : (done
                                  ? AppColors.peach
                                  : AppColors.leafGreen),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      !hasSession
                          ? 'Belum ada sesi'
                          : (done ? 'Sesi selesai' : 'Sesi berlangsung'),
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Text(
                session == null
                    ? ''
                    : formatDateId(session!.date, withYear: false),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            session?.posyanduName ??
                (posyanduName.isEmpty ? 'Posyandu Anda' : posyanduName),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.15,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            session?.note ?? 'Belum ada sesi penimbangan bulan ini',
            style: TextStyle(
              fontSize: 12.5,
              color: Colors.white.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$present',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 38,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: Colors.white,
                  height: 0.95,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 4, left: 6),
                child: Text(
                  'dari $target sasaran',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.82),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
              backgroundColor: Colors.white.withValues(alpha: 0.18),
              valueColor: const AlwaysStoppedAnimation(AppColors.leafGreen),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _SessionStat(label: 'Hadir', value: '$present'),
              _SessionStat(label: 'Belum', value: '${target - present}'),
              _SessionStat(label: 'Tindak lanjut', value: '$followUpCount'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: done ? null : onMeasure,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.deepForest,
                disabledBackgroundColor: Colors.white.withValues(alpha: 0.4),
                minimumSize: const Size(0, 46),
                textStyle: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              icon: const Icon(Icons.straighten_rounded, size: 18),
              label: Text(present == 0 ? 'Mulai ukur' : 'Lanjut ukur'),
            ),
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 4),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onComplete,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.85),
                  minimumSize: const Size(0, 38),
                ),
                child: const Text('Selesaikan sesi'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SessionStat extends StatelessWidget {
  const _SessionStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
              color: Colors.white,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionSnapshot extends StatelessWidget {
  const _NutritionSnapshot({
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
        Row(
          children: [
            const Expanded(
              child: Text(
                'Status gizi sesi ini',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 8),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: const Text('Rekap'),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

class _FollowUpList extends StatelessWidget {
  const _FollowUpList({required this.entries, required this.onTap});

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
