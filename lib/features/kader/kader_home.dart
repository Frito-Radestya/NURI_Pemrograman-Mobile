import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../data/app_selectors.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'add_target_screen.dart';
import 'followup_screen.dart';
import 'recap_screen.dart';
import 'roster_screen.dart';
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

    return RefreshIndicator(
      color: AppColors.primary,
      onRefresh: () async {
        final ok = await ref.read(appControllerProvider.notifier).syncNow();
        if (context.mounted) {
          showNuriSnack(
            context,
            ok
                ? 'Data sesi dan sasaran berhasil disinkronkan.'
                : 'Data lokal termutakhir telah dimuat.',
          );
        }
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 96),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Curved Organic Header Canvas (Inspired by UI_UX/nuri_sesi_posyandu_kader)
          CurvedHeader(
            borderRadius: 36,
            padding: EdgeInsets.fromLTRB(
              20,
              MediaQuery.paddingOf(context).top + 8,
              20,
              28,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.circle,
                            size: 7,
                            color: AppColors.secondaryFixed,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Posyandu Aktif',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
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
                          ok
                              ? 'Semua data tersinkron. Siap bekerja offline.'
                              : 'Sinkronisasi gagal. Perubahan tetap tersimpan lokal.',
                          error: !ok,
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  'Semangat Pagi, Bu ${user?.name.split(' ').first ?? 'Kader'}! 🌿',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      size: 15,
                      color: AppColors.secondaryFixed,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        posyanduName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white70,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Transform.translate(
                  offset: const Offset(0, -14),
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
                              message:
                                  'Rekap sesi akan dikunci. Entri yang masih tertunda tetap tersimpan dan disinkronkan saat online.',
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
                // Menu Cepat Kader (Tactile Action Grid)
                _KaderQuickMenu(
                  onRoster: () =>
                      _push(context, const RosterScreen(embedded: false)),
                  onAddTarget: () =>
                      _push(context, const AddTargetScreen()),
                  onScan: () => _push(context, const ScanScreen()),
                  onFollowUp: () =>
                      _push(context, const FollowUpScreen(embedded: false)),
                ),
                const SizedBox(height: 16),
                _NutritionSnapshot(
                  normal: normal,
                  stunted: stunted,
                  severe: severe,
                  total: categorized.length,
                  notPresent: notPresent,
                  onTap: () =>
                      _push(context, const RecapScreen(embedded: false)),
                ),
                const SizedBox(height: 20),
                SectionHeader(
                  title: 'Perlu perhatian',
                  subtitle:
                      '${followUps.length} sasaran masuk daftar tindak lanjut',
                  actionLabel: followUps.isEmpty ? null : 'Semua',
                  onAction: () =>
                      _push(context, const FollowUpScreen(embedded: false)),
                ),
                const SizedBox(height: 10),
                if (followUps.isEmpty)
                  const InfoBanner(
                    title: 'Semua sasaran terpantau',
                    body: 'Belum ada tindak lanjut terbuka pada sesi ini.',
                    icon: Icons.task_alt_rounded,
                  )
                else
                  _FollowUpList(
                    entries: followUps.take(3).toList(),
                    onTap: () =>
                        _push(context, const FollowUpScreen(embedded: false)),
                  ),
                const SizedBox(height: 14),
                const NuriDisclaimer(),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}

class _KaderQuickMenu extends StatelessWidget {
  const _KaderQuickMenu({
    required this.onRoster,
    required this.onAddTarget,
    required this.onScan,
    required this.onFollowUp,
  });

  final VoidCallback onRoster;
  final VoidCallback onAddTarget;
  final VoidCallback onScan;
  final VoidCallback onFollowUp;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Menu Cepat Kader',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppColors.onSurface,
              ),
            ),
            Text(
              'Alat Sesi',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _KaderMenuItem(
              icon: Icons.groups_rounded,
              label: 'Daftar Sasaran',
              onTap: onRoster,
            ),
            _KaderMenuItem(
              icon: Icons.qr_code_scanner_rounded,
              label: 'Scan QR KMS',
              isHighlight: true,
              onTap: onScan,
            ),
            _KaderMenuItem(
              icon: Icons.person_add_rounded,
              label: 'Tambah Sasaran',
              onTap: onAddTarget,
            ),
            _KaderMenuItem(
              icon: Icons.warning_amber_rounded,
              label: 'Tindak Lanjut',
              onTap: onFollowUp,
            ),
          ],
        ),
      ],
    );
  }
}

class _KaderMenuItem extends StatelessWidget {
  const _KaderMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isHighlight = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isHighlight;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                gradient: isHighlight ? AppGradients.button : null,
                color: isHighlight ? null : AppColors.surfaceContainerLow,
                borderRadius: BorderRadius.circular(18),
                boxShadow: isHighlight ? AppShadows.glow : null,
              ),
              child: Icon(
                icon,
                size: 24,
                color: isHighlight ? Colors.white : AppColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
                color: isHighlight ? AppColors.primary : AppColors.onSurface,
              ),
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
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              pending == 0
                  ? Icons.cloud_done_rounded
                  : Icons.cloud_upload_outlined,
              size: 15,
              color: Colors.white,
            ),
            const SizedBox(width: 5),
            Text(
              pending == 0 ? 'Tersinkron' : '$pending Tertunda',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
    final progress = target == 0 ? 0.0 : (present / target).clamp(0.0, 1.0);
    final done = session?.isDone ?? false;
    final hasSession = session != null;
    final percentInt = (progress * 100).round();
    final notPresent = (target - present).clamp(0, target);

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'SESI PENIMBANGAN RUTIN',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      session?.posyanduName ??
                          (posyanduName.isEmpty
                              ? 'Posyandu Anda'
                              : posyanduName),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: !hasSession
                      ? AppColors.surfaceContainerLow
                      : (done
                            ? AppColors.amberSoft
                            : AppColors.secondaryContainer),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: !hasSession
                            ? AppColors.muted
                            : (done ? AppColors.amber : AppColors.primary),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Text(
                      !hasSession
                          ? 'Belum ada sesi'
                          : (done ? 'SESI SELESAI' : 'SESI BERLANGSUNG'),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: !hasSession
                            ? AppColors.muted
                            : (done
                                  ? AppColors.amber
                                  : AppColors.onSecondaryContainer),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Cakupan Kehadiran (D/S)',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        RichText(
                          text: TextSpan(
                            text: '$present',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primary,
                              fontFeatures: [FontFeature.tabularFigures()],
                            ),
                            children: [
                              TextSpan(
                                text: ' / $target Balita Sasaran',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  fontWeight: FontWeight.normal,
                                  color: AppColors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$percentInt%',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                            color: AppColors.secondary,
                          ),
                        ),
                        const Text(
                          'Target 85%',
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    height: 8,
                    color: AppColors.surfaceContainerHigh,
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primary,
                              AppColors.secondaryFixedDim,
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (followUpCount > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_rounded,
                            size: 15,
                            color: AppColors.red,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$followUpCount Butuh Tindak Lanjut',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: AppColors.red,
                            ),
                          ),
                        ],
                      )
                    else
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle_rounded,
                            size: 15,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Semua terpantau',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ],
                      ),
                    Text(
                      '$notPresent Belum Hadir',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          NuriButton(
            label: present == 0
                ? '+ Mulai Scan / Ukur Baru'
                : '+ Lanjut Scan / Ukur',
            icon: Icons.add_a_photo_rounded,
            height: 48,
            onPressed: done ? null : onMeasure,
          ),
          if (onComplete != null) ...[
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 42,
              child: TextButton.icon(
                onPressed: onComplete,
                icon: const Icon(Icons.lock_reset_rounded, size: 17),
                label: const Text(
                  'Kunci & Selesaikan Rekap Sesi',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
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
