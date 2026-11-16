import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_theme.dart';
import '../../data/app_controller.dart';
import '../../data/app_selectors.dart';
import '../../domain/models.dart';
import '../../shared/ui.dart';
import '../../shared/widgets.dart';
import 'add_target_screen.dart';
import 'kader_home_snapshot.dart';
import 'kader_home_widgets.dart';
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
                      const NuriLogo(
                        compact: false,
                        onDark: true,
                        subtitle: 'NURI KADER',
                      ),
                      KaderSyncButton(
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
                  const SizedBox(height: 10),
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
                      mainAxisSize: MainAxisSize.min,
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
                    child: KaderSessionCard(
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
                  // Menu Cepat Kader (Tactile Action Grid)
                  KaderQuickMenu(
                    onRoster: () =>
                        _push(context, const RosterScreen(embedded: false)),
                    onAddTarget: () => _push(context, const AddTargetScreen()),
                    onScan: () => _push(context, const ScanScreen()),
                    onFollowUp: () =>
                        _push(context, const FollowUpScreen(embedded: false)),
                  ),
                  const SizedBox(height: 16),
                  KaderNutritionSnapshot(
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
                    KaderFollowUpList(
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
