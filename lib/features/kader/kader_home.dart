import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/formatters.dart';
import '../../data/app_controller.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'add_target_screen.dart';
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
    final state = ref.watch(appControllerProvider);
    final user = state.currentUser;
    final session = state.activeSession;
    final roster = state.roster;
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
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontSize: 21, letterSpacing: -0.35),
                        ),
                        Text(
                          state.posyanduName,
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _SyncButton(
                    pending: state.pendingWrites,
                    onTap: () {
                      ref.read(appControllerProvider.notifier).syncNow();
                      showNuriSnack(
                        context,
                        'Semua data tersinkron. Siap bekerja offline.',
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
                present: present,
                target: target,
                followUpCount: followUps.length,
                onMeasure: () => _push(context, const ScanScreen()),
                onRecap: () =>
                    _push(context, const RecapScreen(embedded: false)),
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
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _OfflineStrip(pending: state.pendingWrites),
            ),
            const SizedBox(height: 22),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(title: 'Aksi cepat'),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 2.35,
                children: [
                  _QuickAction(
                    icon: Icons.qr_code_scanner_rounded,
                    title: 'Pindai QR',
                    subtitle: 'Kode Keluarga',
                    color: AppColors.primary,
                    background: AppColors.mint,
                    onTap: () => _push(context, const ScanScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.person_add_alt_1_rounded,
                    title: 'Tambah sasaran',
                    subtitle: 'Tanpa akun',
                    color: AppColors.coral,
                    background: AppColors.peachSoft,
                    onTap: () => _push(context, const AddTargetScreen()),
                  ),
                  _QuickAction(
                    icon: Icons.insert_chart_rounded,
                    title: 'Rekap sesi',
                    subtitle: '${categorized.length} balita',
                    color: AppColors.blue,
                    background: AppColors.blueSoft,
                    onTap: () =>
                        _push(context, const RecapScreen(embedded: false)),
                  ),
                  _QuickAction(
                    icon: Icons.follow_the_signs_rounded,
                    title: 'Tindak lanjut',
                    subtitle: '${followUps.length} perlu perhatian',
                    color: AppColors.amber,
                    background: AppColors.amberSoft,
                    onTap: () =>
                        _push(context, const FollowUpScreen(embedded: false)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _DistributionCard(
                normal: normal,
                stunted: stunted,
                severe: severe,
                total: categorized.length,
                notPresent: notPresent,
              ),
            ),
            const SizedBox(height: 22),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SectionHeader(
                title: 'Perlu perhatian',
                subtitle:
                    '${followUps.length} sasaran masuk daftar tindak lanjut',
                actionLabel: 'Semua',
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
              ...followUps
                  .take(3)
                  .map(
                    (entry) => Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
                      child: _FollowUpPreview(
                        entry: entry,
                        onTap: () => _push(
                          context,
                          const FollowUpScreen(embedded: false),
                        ),
                      ),
                    ),
                  ),
            const SizedBox(height: 6),
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
    required this.present,
    required this.target,
    required this.followUpCount,
    required this.onMeasure,
    required this.onRecap,
    required this.onComplete,
  });

  final PosyanduSession? session;
  final int present;
  final int target;
  final int followUpCount;
  final VoidCallback onMeasure;
  final VoidCallback onRecap;
  final VoidCallback? onComplete;

  @override
  Widget build(BuildContext context) {
    final progress = target == 0 ? 0.0 : present / target;
    final done = session?.isDone ?? false;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0C6D5C), Color(0xFF06483D)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDeep.withValues(alpha: 0.16),
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
                        color: done ? AppColors.peach : const Color(0xFF9FE3C8),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      done ? 'Sesi selesai' : 'Sesi berlangsung',
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
                    ? 'Belum ada sesi'
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
            session?.posyanduName ?? 'Posyandu Melati II',
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
            session?.note ?? 'Sesi penimbangan bulan ini',
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
              valueColor: const AlwaysStoppedAnimation(Color(0xFFFFD6BE)),
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
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: onMeasure,
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primaryDark,
                    minimumSize: const Size(0, 46),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(Icons.straighten_rounded, size: 18),
                  label: const Text('Mulai ukur'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onRecap,
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 46),
                    side: BorderSide(
                      color: Colors.white.withValues(alpha: 0.36),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  icon: const Icon(
                    Icons.insert_chart_outlined_rounded,
                    size: 18,
                  ),
                  label: const Text('Rekap'),
                ),
              ),
            ],
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 6),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: onComplete,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.85),
                  minimumSize: const Size(0, 40),
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

class _OfflineStrip extends StatelessWidget {
  const _OfflineStrip({required this.pending});

  final int pending;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      radius: 14,
      child: Row(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 18,
            color: AppColors.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mode offline aktif',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  pending > 0
                      ? '$pending perubahan tersimpan di perangkat, siap sinkron saat online.'
                      : 'Semua perubahan tersimpan aman dan tersinkron.',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      radius: 15,
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionCard extends StatelessWidget {
  const _DistributionCard({
    required this.normal,
    required this.stunted,
    required this.severe,
    required this.total,
    required this.notPresent,
  });

  final int normal;
  final int stunted;
  final int severe;
  final int total;
  final int notPresent;

  @override
  Widget build(BuildContext context) {
    final safeTotal = total == 0 ? 1 : total;
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Distribusi status gizi',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Pill(
                label: '$total balita',
                background: AppColors.surfaceSubtle,
                foreground: AppColors.primaryDark,
                fontSize: 11.5,
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'Panjang/tinggi badan menurut umur • WHO 2006',
            style: TextStyle(fontSize: 12, color: AppColors.muted),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: SizedBox(
              height: 11,
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _DistributionLegend(
                color: AppColors.primary,
                label: 'Normal',
                value: normal,
                percent: normal / safeTotal,
              ),
              _DistributionLegend(
                color: AppColors.amber,
                label: 'Pendek',
                value: stunted,
                percent: stunted / safeTotal,
              ),
              _DistributionLegend(
                color: AppColors.red,
                label: 'Sangat pendek',
                value: severe,
                percent: severe / safeTotal,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$notPresent sasaran belum hadir. Status diambil dari pengukuran terakhir.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.muted,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _DistributionLegend extends StatelessWidget {
  const _DistributionLegend({
    required this.color,
    required this.label,
    required this.value,
    required this.percent,
  });

  final Color color;
  final String label;
  final int value;
  final double percent;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.muted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            '$value',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            '${(percent * 100).round()}%',
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
          ),
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
    return AppCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
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
                  style: const TextStyle(fontSize: 12, color: AppColors.muted),
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
    );
  }
}
